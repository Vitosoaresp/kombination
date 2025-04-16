library;

use ::types::slot::{SlotID};

pub enum CatalogError {
    PartAlreadyExists: (SlotID, SlotID),
    PartNotFound: (SlotID, SlotID),
    ParentNotFound: (SlotID),
    ParentNotFixed: (SlotID),
    PartNotPart: (SlotID, SlotID),
}

pub enum ComposableError {
    ParentNotFound: (AssetId),
    SlotNotRegistered: (AssetId),
    ParentNotFixed: (AssetId),
    ChildNotFound: (AssetId),
    ChildNotPart: (AssetId),
    PartAlreadyExists: (AssetId, AssetId),
}