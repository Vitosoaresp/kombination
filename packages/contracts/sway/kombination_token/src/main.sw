contract;

use std::hash::*;
use std::string::String;
use std::context::this_balance;
use std::storage::storage_vec::*;
use std::call_frames::msg_asset_id;
use std::asset::{transfer, mint_to};
use std::storage::storage_string::*;

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
        equipped: StorageMap<AssetId, AssetId> = StorageMap {},
    },
    slot {
        total_slots: u64 = 0,
        slots: StorageMap<SlotID, Slot> = StorageMap {},
        asset_slot: StorageMap<AssetId, SlotID> = StorageMap {},
        slots_config: StorageMap<(SlotID, SlotID), bool> = StorageMap {},
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

#[storage(read)]
fn require_is_slot(asset_id: AssetId, slot: Slot) -> SlotID {
    let slot_id = get_asset_slot(asset_id);
    require(slot_id.is_some(), KombinationTokenError::AssetNotFound(asset_id));

    let slot_id = slot_id.unwrap();
    require(slot_id.1 == slot, KombinationTokenError::InvalidSlotType(slot_id));
    slot_id.0
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
        get_asset_slot(asset_id)
    }

    // TODO: Consider sending the base asset and piece asset to the contract
    //       In this case enable a user to equip asset to another user
    #[storage(read, write), payable]
    fn equip(base_asset: AssetId) {
        let sender = msg_sender().unwrap();

        // Check if the asset is a piece slot
        let piece_asset = msg_asset_id();
        let piece_slot_id = require_is_slot(piece_asset, Slot::PIECE);

        // Check if the base asset is a base slot
        let base_slot_id = require_is_slot(base_asset, Slot::BASE);

        // Check if the base asset accepts the piece asset
        let accepts = storage::slot.slots_config.get((base_slot_id, piece_slot_id)).try_read().unwrap_or(false);
        require(accepts, KombinationTokenError::BaseNotAcceptsPiece((base_slot_id, piece_slot_id)));

        // Set the equipped asset
        storage::asset.equipped.insert(piece_asset, base_asset);
    }

    #[storage(read)]
    fn equipped_by(piece_asset: AssetId) -> Option<AssetId> {
        storage::asset.equipped.get(piece_asset).try_read()
    }

    #[storage(read, write), payable]
    fn unequip(piece_asset: AssetId) {
        let sender = msg_sender().unwrap();

        // Check the base asset is a base slot
        let base_asset = msg_asset_id();
        require_is_slot(base_asset, Slot::BASE);

        // Check if the asset is equipped
        match storage::asset.equipped.get(piece_asset).try_read() {
            Some(base_asset_equipped) => {
                // Check if the base asset is the same as the base asset to unequip
                require(base_asset_equipped == base_asset, KombinationTokenError::AssetNotEquipped(piece_asset));
            },
            None => require(false, KombinationTokenError::AssetNotEquipped(piece_asset)),
        }

        // Remove the equipped asset
        storage::asset.equipped.remove(piece_asset);

        // Check has balance to transfer the piece asset
        let amount = this_balance(piece_asset);
        require(amount > 0, KombinationTokenError::AssetNotFound(piece_asset));

        // Transfer the piece asset to the sender
        transfer(msg_sender().unwrap(), piece_asset, amount);
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

    #[storage(read, write)]
    fn set_slot_config(slot_id: SlotID, slot_id_2: SlotID) {
        storage::slot.slots_config.insert((slot_id, slot_id_2), true);
    }

    #[storage(read)]
    fn accept_slot(slot_id: SlotID, slot_id_2: SlotID) -> bool {
        storage::slot.slots_config.get((slot_id, slot_id_2)).try_read().unwrap_or(false)
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