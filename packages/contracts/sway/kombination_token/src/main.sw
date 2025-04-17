contract;

use std::hash::*;
use std::string::String;
use std::storage::storage_string::*;
use std::storage::storage_vec::*;
use std::asset::{transfer, mint_to};

use standards::src20::{SRC20};
use standards::src7::{SRC7, Metadata};

use sway_libs::asset::metadata::*;
use sway_libs::asset::supply::{_mint};

use kombination_lib::abis::{KombinationToken, KombinationSlots};
use kombination_lib::errors::{KombinationTokenError};
use kombination_lib::core::slot::*;
use kombination_lib::core::asset::{get_asset_id, get_sub_id};

storage {
    asset {
        total_assets: u64 = 0,
        metadata: StorageMetadata = StorageMetadata {},
        decimals: StorageMap<AssetId, u8> = StorageMap {},
        total_supply: StorageMap<AssetId, u64> = StorageMap {},
        name: StorageMap<AssetId, StorageString> = StorageMap {},
        symbol: StorageMap<AssetId, StorageString> = StorageMap {},
    },
    slot {
        total_slots: u64 = 0,
        slots: StorageMap<SlotID, Slot> = StorageMap {},
        asset_slot: StorageMap<AssetId, SlotID> = StorageMap {},
    },
}

#[storage(read, write)]
fn mint_slot(slot: Slot, slot_id: SlotID) {
    // Check if the slot exists
    let slot_type = storage::slot.slots.get(slot_id).try_read();
    require(slot_type.is_some(), KombinationTokenError::SlotNotFound(slot_id));

    // Check if the slot type is correct
    let slot_type = slot_type.unwrap();
    require(slot == slot_type, KombinationTokenError::InvalidSlotType((slot_id, slot_type)));

    // Check if the asset already minted
    let total_assets = storage::asset.total_assets.read();
    let asset_id = get_asset_id(ContractId::this(), slot_id, total_assets);
    let total_supply = storage::asset.total_supply.get(asset_id).try_read().unwrap_or(0);
    require(total_supply == 0, KombinationTokenError::AssetAlreadyMinted(asset_id));

    // Mint the asset
    let asset_id = _mint(
        storage::asset.total_assets,
        storage::asset.total_supply,
        msg_sender().unwrap(),
        get_sub_id(slot_id, total_assets),
        1,
    );

    // Set the relationship between the asset and the slot
    storage::slot.asset_slot.insert(asset_id, slot_id);
}

impl KombinationToken for Contract {
    #[storage(read, write)]
    fn mint_base(slot_id: SlotID) {
        mint_slot(Slot::BASE, slot_id);
    }

    #[storage(read, write)]
    fn mint_piece(slot_id: SlotID) {
        mint_slot(Slot::PIECE, slot_id);
    }

    #[storage(read)]
    fn get_asset_slot(asset_id: AssetId) -> Option<(SlotID, Slot)> {
        match storage::slot.asset_slot.get(asset_id).try_read() {
            Some(slot_id) => {
                let slot = storage::slot.slots.get(slot_id).try_read().unwrap();
                Some((slot_id, slot))
            },
            None => None,
        }
    }
}

impl KombinationSlots for Contract {
    #[storage(read, write)]
    fn register_slot(slot: Slot) -> SlotID {
        let total_slots = storage::slot.total_slots.read();
        let slot_id = sha256((slot, total_slots));
        storage::slot.total_slots.write(total_slots + 1);
        storage::slot.slots.insert(slot_id, slot);
        slot_id
    }

    #[storage(read)]
    fn get_slot(id: SlotID) -> Option<Slot> {
        storage::slot.slots.get(id).try_read()
    }
}

impl SRC20 for Contract {
    #[storage(read)]
    fn total_assets() -> u64 {
        storage::asset.total_assets.read()
    }

    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        storage::asset.total_supply.get(asset).try_read()
    }

    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        storage::asset.name.get(asset).read_slice()
    }

    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        storage::asset.symbol.get(asset).read_slice()
    }

    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        storage::asset.decimals.get(asset).try_read()
    }
}

impl SRC7 for Contract {
    #[storage(read)]
    fn metadata(asset: AssetId, key: String) -> Option<Metadata> {
        storage::asset.metadata.get(asset, key)
    }
}