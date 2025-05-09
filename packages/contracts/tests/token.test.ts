import { expect, describe, test, beforeAll, afterAll } from "bun:test";
import { launchTestNode } from "fuels/test-utils";
import { type KombinationToken, KombinationTokenFactory } from "../src";
import { assetInput, callAndWait } from "./utils";
import { SlotInput } from "../src/artifacts/contracts/KombinationToken";

const setup = async () => {
  const node = await launchTestNode({
    contractsConfigs: [{ factory: KombinationTokenFactory }],
  });

  const { contracts, wallets } = node;
  const [mainWallet] = wallets;
  const [kombination] = contracts;

  const { value: baseSlots } = await callAndWait(
    kombination.multiCall([
      kombination.functions.register_slot(SlotInput.BASE),
      kombination.functions.register_slot(SlotInput.BASE),
    ]),
  );

  const { value: pieceSlots } = await callAndWait(
    kombination.multiCall([
      kombination.functions.register_slot(SlotInput.PIECE),
      kombination.functions.register_slot(SlotInput.PIECE),
    ]),
  );

  await callAndWait(
    kombination.functions.set_slot_config(baseSlots[0], pieceSlots[0]),
  );

  return {
    slots: {
      base: baseSlots,
      piece: pieceSlots,
    },
    contract: kombination as KombinationToken,
    mainWallet,
    ...node,
  };
};

describe("Slots", async () => {
  let testSetup: Awaited<ReturnType<typeof setup>>;

  const mintedAssets: {
    base: string[];
    piece: string[];
  } = {
    base: [],
    piece: [],
  };

  beforeAll(async () => {
    testSetup = await setup();
  });

  afterAll(async () => {
    testSetup.cleanup();
  });

  const mint = async (slotId: string, type: "base" | "piece") => {
    const { contract } = testSetup;

    const {
      logs: [mintLog],
    } = await callAndWait(
      type === "base"
        ? contract.functions.mint_base(slotId)
        : contract.functions.mint_piece(slotId),
    );

    return mintLog.asset.bits as string;
  };

  test("should mint a base token", async () => {
    const { slots, mainWallet } = testSetup;

    const assetId = await mint(slots.base[0], "base");
    expect(assetId).toBeDefined();

    const balance = await mainWallet.getBalance(assetId);
    expect(balance.toString()).toBe("1");

    mintedAssets.base.push(assetId);
  });

  test("should mint a piece token", async () => {
    const { slots, mainWallet } = testSetup;

    const assetId = await mint(slots.piece[0], "piece");
    expect(assetId).toBeDefined();

    const balance = await mainWallet.getBalance(assetId);
    expect(balance.toString()).toBe("1");

    mintedAssets.piece.push(assetId);
  });

  test("should not mint a piece token when already minted", async () => {
    const { slots } = testSetup;

    await expect(mint(slots.piece[0], "piece")).rejects.toThrow(
      /AssetAlreadyMinted/,
    );
  });

  test("should equip a piece token", async () => {
    const { contract, mainWallet } = testSetup;

    const baseAssetId = mintedAssets.base[0];
    const pieceAsset = mintedAssets.piece[0];

    await callAndWait(
      contract.functions.equip({ bits: baseAssetId }).callParams({
        forward: {
          assetId: pieceAsset,
          amount: 1,
        },
      }),
    );

    const { balances } = await mainWallet.getBalances();

    // The piece should have been equipped
    let pieceBalance = balances.find((b) => b.assetId === pieceAsset)?.amount;
    expect(pieceBalance).toBeDefined();
    expect(pieceBalance?.toString()).toBe("0");

    // The piece should have been locked in the contract
    pieceBalance = await contract.getBalance(pieceAsset);
    expect(pieceBalance.toString()).toBe("1");

    // The base should have been sent to the main wallet
    const baseBalance = balances.find((b) => b.assetId === baseAssetId);
    expect(baseBalance).toBeDefined();
    expect(baseBalance?.amount.toString()).toBe("1");
  });

  test("should not equip a piece token if the slot not accepts piece slot", async () => {
    const { slots, contract } = testSetup;

    const baseAssetId = mintedAssets.base[0];
    const pieceAsset = await mint(slots.piece[1], "piece");

    await expect(
      callAndWait(
        contract.functions.equip({ bits: baseAssetId }).callParams({
          forward: {
            assetId: pieceAsset,
            amount: 1,
          },
        }),
      ),
    ).rejects.toThrow(/BaseNotAcceptsPiece/);
  });

  // TODO: Fix unequip in the contract
  test.skip("should unequip a piece token", async () => {
    const { contract, mainWallet } = testSetup;

    const baseAsset = mintedAssets.base[0];
    const pieceAsset = mintedAssets.base[0];

    await callAndWait(
      contract.functions.unequip(assetInput(pieceAsset)).callParams({
        forward: {
          assetId: baseAsset,
          amount: 1,
        },
      }),
    );

    const walletBalance = await mainWallet.getBalance(pieceAsset);
    expect(walletBalance.toString()).toBe("1");

    const contractBalance = await contract.getBalance(pieceAsset);
    expect(contractBalance.toString()).toBe("0");
  });

  // TODO: Implement this case in the contract
  test.skip("should not equip an equipped piece slot", async () => {
    const { contract, slots } = testSetup;

    const baseAssetId = mintedAssets.base[0];
    const pieceAsset = await mint(slots.piece[0], "piece");

    await expect(
      callAndWait(
        contract.functions.equip({ bits: baseAssetId }).callParams({
          forward: { assetId: pieceAsset, amount: 1 },
        }),
      ),
    ).rejects.toThrow(/SlotAlreadyEquipped/);
  });
});
