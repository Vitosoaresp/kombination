library;

mod structs;

use ::structs::{StartAuction, AuctionId};

abi KombinationAuction {
    /// Place a bid on the auction
    ///
    /// # Arguments
    ///
    /// * `auction_id`: The ID of the auction to bid on
    /// * `amount`: The amount to bid
    ///
    /// # Reverts
    ///
    /// * If the auction is not active
    /// * If the auction is not found
    /// * If the bid amount is less than 5% to the current highest bid
    /// * If the bid amount is less than the initial bid
    ///
    /// # Events
    ///
    /// * `BidPlacedEvent`: Emitted when a bid is successfully placed
    #[storage(write, read), payable]
    fn place_bid(auction_id: AuctionId, amount: u64);

    /// Start a new auction
    ///
    /// # Arguments
    ///
    /// * `auction`: The details of the auction to start
    ///
    /// # Reverts
    ///
    /// * If the caller is not the owner of the contract
    /// * If the contract is paused
    /// * If the auction already exists
    /// * If the auction end time is in the past
    /// * If the initial bid is less than 0
    ///
    /// # Events
    ///
    /// * `AuctionStartedEvent`: Emitted when a new auction is successfully started
    ///
    /// # Returns
    ///
    /// * `AuctionId`: The ID of the newly created auction
    #[storage(write)]
    fn start_auction(auction: StartAuction) -> AuctionId;

    /// End the auction
    ///
    /// # Arguments
    ///
    /// * `auction_id`: The ID of the auction to end
    ///
    /// # Reverts
    ///
    /// * If the auction is not found
    /// * If the auction is not active
    ///
    /// # Events
    ///
    /// * `AuctionEndedEvent`: Emitted when the auction is successfully ended
    #[storage(write, read)]
    fn end_auction(auction_id: AuctionId);

    /// Get the highest bid
    ///
    /// # Arguments
    ///
    /// * `auction_id`: The ID of the auction to get the highest bid for
    ///
    /// # Reverts
    ///
    /// * If the auction is not found
    ///
    /// # Returns
    ///
    /// * `(Address, u64)`: Returns the address of the highest bidder and the highest bid amount
    #[storage(read)]
    fn get_highest_bid(auction_id: AuctionId) -> (Address, u64);

    /// Check if the auction is active
    ///
    /// # Arguments
    ///
    /// * `auction_id`: The ID of the auction to check
    ///
    /// # Reverts
    /// 
    /// * If the auction is not found
    ///
    /// # Returns
    ///
    /// * `bool`: Returns true if the auction is active, false otherwise
    ///
    #[storage(read)]
    fn is_active(auction_id: AuctionId) -> bool;
}

/// Interface for managing ownership of the contract
abi Ownership {
    /// Initializes the contract with an initial owner
    ///
    /// # Arguments
    ///
    /// * `owner`: The initial owner of the contract
    ///
    /// # Events
    ///
    /// * `OwnershipTransferredEvent`: Emitted when the ownership is successfully transferred
    #[storage(read, write)]
    fn initialize(owner: Identity);

    /// Transfers ownership of the contract to a new owner
    ///
    /// # Arguments
    ///
    /// * `new_owner`: The new owner of the contract
    ///
    /// # Events
    ///
    /// * `OwnershipTransferredEvent`: Emitted when the ownership is successfully transferred
    #[storage(write)]
    fn transfer_ownership(new_owner: Identity);
}
