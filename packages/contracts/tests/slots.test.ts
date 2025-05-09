import { expect, describe, test, beforeAll, afterAll } from "bun:test";
import { launchTestNode } from "fuels/test-utils";
import { KombinationTokenFactory, type KombinationToken } from "../src";
import { callAndWait } from "./utils";
import {
  SlotInput,
  SlotOutput,
} from "../src/artifacts/contracts/KombinationToken";

const setup = async () => {
  const node = await launchTestNode({
    contractsConfigs: [{ factory: KombinationTokenFactory }],
  });

  const { contracts, wallets } = node;
  const [mainWallet] = wallets;
  const [kombination] = contracts;

  return {
    contract: kombination as KombinationToken,
    mainWallet,
    ...node,
  };
};

describe("Slots", async () => {
  let testSetup: Awaited<ReturnType<typeof setup>>;

  beforeAll(async () => {
    testSetup = await setup();
  });

  afterAll(async () => {
    testSetup.cleanup();
  });

  const slots = {
    base: "",
    piece: "",
  };
  test("should register a slot", async () => {
    const { contract } = testSetup;
    const { value: baseSlotId } = await callAndWait(
      contract.functions.register_slot(SlotInput.BASE),
    );
    expect(baseSlotId).toBeDefined();
    slots.base = baseSlotId;

    const { value: pieceSlotId } = await callAndWait(
      contract.functions.register_slot(SlotInput.PIECE),
    );
    expect(pieceSlotId).toBeDefined();
    slots.piece = pieceSlotId;
  });

  test("should get the slot by id", async () => {
    const { contract } = testSetup;
    const { value: baseSlot } = await callAndWait(
      contract.functions.get_slot(slots.base),
    );

    expect(baseSlot).toBeDefined();
    expect(baseSlot).toBe(SlotOutput.BASE);

    const { value: pieceSlot } = await callAndWait(
      contract.functions.get_slot(slots.piece),
    );

    expect(pieceSlot).toBeDefined();
    expect(pieceSlot).toBe(SlotOutput.PIECE);
  });

  test("should set the slot config", async () => {
    const { contract } = testSetup;

    await callAndWait(
      contract.functions.set_slot_config(slots.base, slots.piece),
    );

    const { value: accepts } = await contract.functions
      .accept_slot(slots.base, slots.piece)
      .get();

    expect(accepts).toBe(true);
  });

  test("should set the slot metadata", async () => {
    const { contract } = testSetup;

    /**{
        type: "Type 1",
        image: "https://example.com/image.png",
        kilometer: 1000,
      } */
    const metadata = {
      base: [
        ["attr:type", "Type 1"],
        ["attr:image", "https://example.com/image.png"],
        ["attr:kilometer", "1000"],
      ],
      piece: [
        ["attr:type", "Wheel"],
        ["attr:image", "https://example.com/image2.png"],
      ],
    };

    // Set Base Metadata
    const baseBatchSetCalls = metadata.base.map(([key, value]) =>
      contract.functions.set_slot_metadata(slots.base, key, value),
    );
    await callAndWait(contract.multiCall(baseBatchSetCalls));

    // Get Base Metadata
    const baseBatchGetCalls = metadata.base.map(([key]) =>
      contract.functions.get_slot_metadata(slots.base, key),
    );
    const { value: baseBatchGetResults } = await contract
      .multiCall(baseBatchGetCalls)
      .get();
    const expectedBaseBatchGetResults = metadata.base.map(
      ([_, value]) => value,
    );
    expect(expectedBaseBatchGetResults).toEqual(baseBatchGetResults);

    // Set Piece Metadata
    const pieceBatchSetCalls = metadata.piece.map(([key, value]) =>
      contract.functions.set_slot_metadata(slots.piece, key, value),
    );
    await callAndWait(contract.multiCall(pieceBatchSetCalls));

    // Get Piece Metadata
    const pieceBatchGetCalls = metadata.piece.map(([key]) =>
      contract.functions.get_slot_metadata(slots.piece, key),
    );
    const { value: pieceBatchGetResults } = await contract
      .multiCall(pieceBatchGetCalls)
      .get();
    const expectedPieceBatchGetResults = metadata.piece.map(
      ([_, value]) => value,
    );
    expect(expectedPieceBatchGetResults).toEqual(pieceBatchGetResults);
  });
});
