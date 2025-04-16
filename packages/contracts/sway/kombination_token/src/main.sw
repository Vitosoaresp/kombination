contract;

use std::hash::*;
use std::string::String;
use std::storage::storage_string::*;
use std::storage::storage_vec::*;
use std::asset::{transfer, mint_to};

use standards::src20::{SRC20};
use standards::src7::{SRC7, Metadata};

use sway_libs::asset::metadata::*;
use sway_libs::asset::supply::{_burn, _mint};

use kombination_lib::abis::{KombinationToken, KombinationSlots};
use kombination_lib::types::slot::*;

storage {
    asset {
        total_assets: u64 = 0,
        total_supply: StorageMap<AssetId, u64> = StorageMap {},
        name: StorageMap<AssetId, StorageString> = StorageMap {},
        symbol: StorageMap<AssetId, StorageString> = StorageMap {},
        decimals: StorageMap<AssetId, u8> = StorageMap {},
        metadata: StorageMetadata = StorageMetadata {},
    },
    slot {
        total_slots: u64 = 0,
        asset_slot: StorageMap<AssetId, SlotID> = StorageMap {},
        slots: StorageMap<SlotID, Slot> = StorageMap {},
    },
}

impl KombinationToken for Contract {
    #[storage(read, write)]
    fn mint_base() {
        // TODO: Implement minting base
    }

    #[storage(read, write)]
    fn mint_part() {
        // TODO: Implement minting part
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

    #[storage(read, write)]
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