library;

use ::core::slot::*;

abi KombinationToken {
    #[storage(read, write)]
    fn mint_base(slot_id: SlotID);

    #[storage(read, write)]
    fn mint_piece(slot_id: SlotID);

    // #[storage(read, write)]
    // fn compose();

    // #[storage(read, write)]
    // fn remove(asset_id: AssetId);
}

abi KombinationSlots {
    #[storage(read, write)]
    fn register_slot(slot: Slot) -> SlotID;

    #[storage(read, write)]
    fn get_slot(id: SlotID) -> Option<Slot>;
}
