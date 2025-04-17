library;

use ::core::slot::{Slot, SlotID};

pub enum KombinationTokenError {
    SlotNotFound: SlotID,
    InvalidSlotType: (SlotID, Slot),
    AssetAlreadyMinted: AssetId,
}
