library;

use std::string::*;
use ::core::slot::*;

abi KombinationToken {
    #[storage(read, write)]
    fn mint_base(slot_id: SlotID);

    #[storage(read, write)]
    fn mint_piece(slot_id: SlotID);

    #[storage(read)]
    fn get_asset_slot(asset_id: AssetId) -> Option<(SlotID, Slot)>;

    #[storage(read, write), payable]
    fn equip(base_asset: AssetId);

    #[storage(read)]
    fn equipped_by(piece_asset: AssetId) -> Option<AssetId>;

    #[storage(read, write), payable]
    fn unequip(piece_asset: AssetId);
}

abi KombinationSlots {
    #[storage(read, write)]
    fn register_slot(slot: Slot) -> SlotID;

    #[storage(read)]
    fn get_slot(id: SlotID) -> Option<Slot>;

    #[storage(read, write)]
    fn set_slot_config(slot_id: SlotID, slot_id_2: SlotID);

    #[storage(read)]
    fn accept_slot(slot_id: SlotID, slot_id_2: SlotID) -> bool;

    #[storage(read, write)]
    fn set_slot_metadata(slot_id: SlotID, key: String, value: String);

    #[storage(read)]
    fn get_slot_metadata(slot_id: SlotID, key: String) -> Option<String>;
}
