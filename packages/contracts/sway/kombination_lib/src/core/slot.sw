library;

use std::hash::{Hash, Hasher};
use std::string::String;

const BASE_STR: str[4] = __to_str_array("Base");
const PIECE_STR: str[5] = __to_str_array("Piece");

pub enum Slot {
    BASE: (),
    PIECE: (),
}

impl PartialEq for Slot {
    fn eq(self, other: Self) -> bool {
        match (self, other) {
            (Slot::BASE, Slot::BASE) => true,
            (Slot::PIECE, Slot::PIECE) => true,
            _ => false,
        }
    }
}

impl From<Slot> for String {
    fn from(slot: Slot) -> Self {
        match slot {
            Slot::BASE => String::from_ascii_str(from_str_array(BASE_STR)),
            Slot::PIECE => String::from_ascii_str(from_str_array(PIECE_STR)),
        }
    }
}

impl Hash for Slot {
    fn hash(self, ref mut state: Hasher) {
        let slot_str: String = self.into();
        state.write(slot_str.as_bytes());
    }
}

pub type SlotID = b256;

#[test]
fn test_slot_from() {
    let base = Slot::BASE;
    let piece = Slot::PIECE;

    let base_str = String::from_ascii_str("Base");
    let piece_str = String::from_ascii_str("Piece");

    let base: String = base.into();
    let piece: String = piece.into();

    assert(base == base_str);
    assert(piece == piece_str);
}
