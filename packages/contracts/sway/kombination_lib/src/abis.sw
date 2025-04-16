library;

use ::types::slot::*;

abi KombinationToken {
    #[storage(read, write)]
    fn mint_base();

    #[storage(read, write)]
    fn mint_part();

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