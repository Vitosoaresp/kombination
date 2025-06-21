library;

mod structs;
use ::structs::{AuctionId};

pub enum AuctionError {
    /// The auction is not active
    AuctionNotActive: (AuctionId),
    
    /// The auction was not found
    AuctionNotFound: (AuctionId),
    
    /// The bid amount is less than 5% of the current highest bid
    BidTooLow: (u64),
    
    /// The bid amount is less than the initial bid
    InitialBidTooLow: (u64),
    
    /// The caller is not the owner of the contract
    NotOwner: (),
    
    /// The contract is paused
    ContractPaused: (),
    
    /// The auction already exists
    AuctionAlreadyExists: (AssetId),
    
    /// The auction end time is in the past
    EndTimeInPast: (u64),
}