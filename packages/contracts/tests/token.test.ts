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

  const { value: baseSlotId } = await callAndWait(
    kombination.functions.register_slot(SlotInput.BASE),
  );

  const { value: pieceSlotId } = await callAndWait(
    kombination.functions.register_slot(SlotInput.PIECE),
  );

  return {
    slots: {
      base: baseSlotId,
      piece: pieceSlotId,
    },
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

  test("should mint a base token", async () => {
    const { contract, slots, mainWallet } = testSetup;

    const {
      logs: [mintLog],
    } = await callAndWait(contract.functions.mint_base(slots.base));

    expect(mintLog).toBeDefined();
    expect(mintLog.asset.bits).toBeDefined();

    const balance = await mainWallet.getBalance(mintLog.asset.bits);
    expect(balance.toString()).toBe("1");
  });
});
