library;

pub struct StartAuction {
    pub end_time: u64,
    pub asset_id: AssetId,
    pub initial_bid: u64,
}

pub type AuctionId = b256;

pub struct Auction {
    // Asset being auctioned
    pub asset_id: AssetId,

    // time when the auction ends
    pub end_time: u64,

    // Initial bid amount
    pub initial_bid: u64,

    // Status of the auction
    pub active: bool,

    // highest bidder and bid amount
    pub highest_bidder: Address,
    pub highest_bid: u64,

    // Bidders map with their bid amounts
    pub bidders: StorageMap<Address, u64>,
}

impl Auction {
    pub fn new(asset_id: AssetId, end_time: u64, initial_bid: u64) -> Self {
        Auction {
            asset_id,
            end_time,
            initial_bid,
            active: true,
            highest_bidder: Address::zero(),
            highest_bid: 0,
            bidders: StorageMap {},
        }
    }
}