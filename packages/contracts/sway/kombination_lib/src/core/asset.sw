library;

use std::hash::sha256;

use ::core::slot::{Slot, SlotID};

pub fn get_asset_id(contract_id: ContractId, slot_id: SlotID, id: u64) -> AssetId {
    AssetId::new(contract_id, get_sub_id(slot_id, id))
}

pub fn get_sub_id(slot_id: SlotID, sub_id: u64) -> SubId {
    sha256((slot_id, sub_id))
}