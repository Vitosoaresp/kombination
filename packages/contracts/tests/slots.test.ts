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
});
