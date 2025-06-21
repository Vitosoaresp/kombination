contract;

mod interfaces;
mod events;
mod structs;
mod errors;

use ::errors::{AuctionError};
use ::structs::{Auction, AuctionId, StartAuction};
use ::interfaces::{KombinationAuction, Ownership};
use ::events::{BidPlacedEvent, AuctionStartedEvent, AuctionEndedEvent};

use sway_libs::pausable::*;
use sway_libs::ownership::*;
use sway_libs::reentrancy::*;

storage {
    // Auction owner address
    owner: Address = Address::zero(),
    
    // Auctions map
    auctions: StorageMap<AuctionId, Auction> = StorageMap {},
}

fn _get_auction_id(auction: Auction) -> AuctionId {
    sha256((auction.asset_id, auction.end_time))
}

#[storage(read)]
fn _get_auction(auction_id: AuctionId) -> Auction {
    let auction = auctions.get(auction_id).try_read();
    require(auction.is_some(), AuctionError::AuctionNotFound(auction_id));
    auction.unwrap()
}

impl KombinationAuction for Contract {
    #[storage(write, read), payable]
    fn place_bid(auction_id: AuctionId, amount: u64) {
        reentrancy_guard();
        _require_not_paused();
    }

    #[storage(write, read)]
    fn start_auction(payload: StartAuction) -> AuctionId {
        only_owner();
        _require_not_paused();

        let auction_id = _get_auction_id(payload);

        // let already_exists = auctions.get(auction_id).read_slice().unwrap();
        // require(!already_exists, AuctionError::AuctionAlreadyExists(payload.asset_id));
        require(payload.end_time > block_timestamp(), AuctionError::EndTimeInPast(payload.end_time));
        require(payload.initial_bid > 0, AuctionError::InitialBidTooLow(payload.initial_bid));
        
        let auction = Auction::new(
            payload.asset_id,
            payload.end_time,
            payload.initial_bid,
        );

        auctions.insert(auction_id, auction);

        log(AuctionStartedEvent {
            auction_id,
            asset_id: payload.asset_id,
            end_time: payload.end_time,
            initial_bid: payload.initial_bid,
        });

        auction_id
    }

    #[storage(write, read)]
    fn end_auction(auction_id: AuctionId) {
        only_owner();
        _require_not_paused();

        let mut auction = _get_auction(auction_id);

        require(auction.active, AuctionError::AuctionNotActive(auction_id));

        // Logic to finalize the auction, e.g., transfer asset to highest bidder
        // ...

        auction.active = false;
        auctions.insert(auction_id, auction);
    }

    #[storage(read)]
    fn get_highest_bid(auction_id: AuctionId) -> (Address, u64) {
        let auction = _get_auction(auction_id);

        (auction.highest_bidder, auction.highest_bid)
    }

    #[storage(read)]
    fn is_active(auction_id: AuctionId) -> bool {
        let auction = _get_auction(auction_id);
        
        auction.active
    }
}

impl Ownership for Contract {
    #[storage(read, write)]
    fn initialize(owner: Identity) {
        initialize_ownership(owner);
    }

    #[storage(write)]
    fn transfer_ownership(new_owner: Identity) {
        transfer_ownership(new_owner);
    }
}

impl Pausable for Contract {
    #[storage(write)]
    fn pause() {
        only_owner();
        _pause();
    }

    #[storage(write)]
    fn unpause() {
        only_owner();
        _unpause();
    }

    #[storage(read)]
    fn is_paused() -> bool {
        _is_paused()
    }
}
