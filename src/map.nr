use crate::HEIGHT;
use crate::WIDTH;
use crate::NON_EMPTY_WALKABLE_TILE_MIN;
use crate::Result;
use crate::TILE_COUNT;
use crate::WALL;
use crate::WATER;
use crate::EMPTY;
use crate::UNKNOWN_CLASS_TILE;
use crate::UNKNOWN_CLASS;
use crate::character::Character;
use crate::TRAP;
use crate::TRAP_USED;
use crate::TRAP_FOUND;
use crate::MAX_TRAPS;
use crate::TRAPS_BUFFER_SIZE;
use crate::trap::Trap;
use crate::character::get_test_my_character;
use crate::character::get_test_their_character;
use crate::ROGUE;
use crate::KNIGHT;
use crate::MAGE;
use crate::RITUALIST;
use crate::ARCHER;

struct Map {
    _data: [[&mut u8; WIDTH]; 16],
}

impl Map {
    pub fn build(data: [[u8; WIDTH]; HEIGHT]) -> Result<Map> {
        let mut d = [[&mut 0; WIDTH]; 16];
        let mut success = true;

        for y in 0..HEIGHT {
            for x in 0..WIDTH {
                let tile = data[y][x];  
                if tile >= TILE_COUNT {
                    success = false;
                };
                *d[y][x] = tile;
            }
        }
        Result {
            value: Map {
                _data: d
            },
            success: success,
        }
    }

    /**
     * Get the tile at the given coordinates.
     * 
     * @param x The x coordinate.
     * @param y The y coordinate.
     * @return The tile at the given coordinates.
     */
    pub fn get(self, x: u8, y: u8) -> Result<u8> {
        Result {
            value: *self._data[y & 15][x & 31],
            success: (y < HEIGHT) & (x < WIDTH),
        }
        // if (y >= HEIGHT) | (x >= WIDTH) {
        //     Result {
        //         value: 0,
        //         success: false
        //     }
        // } else {
        //     Result {
        //         value: *self._data[y][x],
        //         success: true
        //     }
        // }
    }

    pub fn set(mut self, x: u8, y: u8, value: u8) -> bool {
        *self._data[y & 15][x & 31] = value;
        (y < HEIGHT) & (x < WIDTH) & (value < TILE_COUNT)
        // if (y >= HEIGHT) | (x >= WIDTH) | value >= TILE_COUNT {
        //     false
        // } else {
        //     *self._data[y][x] = value;
        //     true
        // }
    }

    pub fn can_move_to(self, x: u8, y: u8) -> Result<bool> {
        let tile = *self._data[y & 15][x & 31];
        Result {
            value: (y < HEIGHT) & (x < WIDTH) & (tile == 0) | (tile >= NON_EMPTY_WALKABLE_TILE_MIN),
            success: (y < HEIGHT) & (x < WIDTH),
        }
        // if (y >= HEIGHT) | (x >= WIDTH) {
        //     Result {
        //         value: false,
        //         success: false
        //     }
        // } else {
        //     let tile_result = self.get(x, y);
        //     if !tile_result.success {
        //         Result {
        //             value: false,
        //             success: false
        //         }
        //     }
        //     let tile = tile_result.value;
        //     if (tile == 0) | (tile >= NON_EMPTY_WALKABLE_TILE_MIN) {
        //         Result {
        //             value: true,
        //             success: true
        //         }
        //     } else {
        //         Result {
        //             value: false,
        //             success: true
        //         }
        //     }
        // }
    }

    pub fn is_neighbor(curr_x: u8, curr_y: u8, x: u8, y: u8) -> Result<bool> {
        // let curr_x = actor.get_x();
        // let curr_y = actor.get_y();
        let success = (curr_x < WIDTH) & (curr_y < HEIGHT) & (x < WIDTH) & (y < HEIGHT); // & ((curr_x == x) | (curr_y == y)); // & ((actor.get_x() != x) | (actor.get_y() != y));

        if curr_x == x {
            if (curr_y == 0) {
                Result { success: success, value: y <= 1 }
            } else {
                Result { success: success, value: (y >= curr_y - 1) & (y <= curr_y + 1) }
            }
        } else {
            if (curr_x == 0) {
                Result { success: success, value: x <= 1 }
            } else {
                Result { success: success, value: (x >= curr_x - 1) & (x <= curr_x + 1) }
            }
        }
    }
}

pub fn get_test_map(my_chars: [Character; 5], their_chars: [Character; 5], my_traps: [Trap; TRAPS_BUFFER_SIZE], their_traps: [Trap; TRAPS_BUFFER_SIZE]) -> &mut Map {
    let mut map_result = Map::build([
        [0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [WALL, WALL, EMPTY,WALL, WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, WALL, WALL, EMPTY,WALL, WALL],
        [WALL, EMPTY,EMPTY,EMPTY,WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, WALL, EMPTY,EMPTY,EMPTY,WALL],
        [WALL, EMPTY,EMPTY,EMPTY,WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, WALL, EMPTY,EMPTY,EMPTY,WALL],
        [WALL, WALL, EMPTY,WALL, WALL, 0, 0, EMPTY,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, EMPTY,0, 0, WALL, WALL, EMPTY,WALL, WALL],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, WATER, WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WATER, WATER, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, WATER, WATER, WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WATER, WATER, WATER, 0, 0, 0, 0, 0],
    ]);

    // let my_trap_tiles = [TRAP, TRAP_USED];
    // for i in 0..MAX_TRAPS {
    //     let my_trap = my_traps[i];
    //     // let tile = TRAP; //if my_trap.sprung == 1 { TRAP_USED } else { TRAP };
    //     let old_tile = map_result.value.get(my_trap.x, my_trap.y);
    //     assert(old_tile.success);
    //     assert(old_tile.value == EMPTY);
    //     //*(map_result.value._data[my_trap.y][my_trap.x]) = 0;
    //     assert(map_result.value.set(my_trap.x, my_trap.y, my_trap_tiles[my_trap.sprung & 1]));
    // }
    // let their_trap_tiles = [TRAP_FOUND, TRAP_USED];
    // for i in 0..MAX_TRAPS {
    //     let my_trap = their_traps[i];
    //     // let mut tile: u8 = TRAP_FOUND;
    //     // if my_trap.sprung == 1 {
    //     //     tile = TRAP_USED;
    //     // }
    //     let old_tile = map_result.value.get(my_trap.x, my_trap.y);
    //     assert(old_tile.success);
    //     assert(old_tile.value == EMPTY);
    //     assert(map_result.value.set(my_trap.x, my_trap.y, their_trap_tiles[my_trap.sprung & 1]));
    // }
    for i in 0..5 {
        let my_char = my_chars[i];
        let mut tile = my_char.get_class();
        assert(tile > 0);
        let old_tile = map_result.value.get(my_char.get_x(), my_char.get_y());
        assert((old_tile.success) & ((old_tile.value == EMPTY) | (old_tile.value >= NON_EMPTY_WALKABLE_TILE_MIN)));
        assert(map_result.value.set(my_char.get_x(), my_char.get_y(), tile));
    }
    for i in 0..5 {
        let my_char = their_chars[i];
        let mut tile = my_char.get_class();
        if tile == UNKNOWN_CLASS {
            tile = UNKNOWN_CLASS_TILE;
        }
        let old_tile = map_result.value.get(my_char.get_x(), my_char.get_y());
        assert((old_tile.success) & ((old_tile.value == EMPTY) | (old_tile.value >= NON_EMPTY_WALKABLE_TILE_MIN)));
        assert(map_result.value.set(my_char.get_x(), my_char.get_y(), tile));
    }

    assert(map_result.success);
    &mut map_result.value
}

#[test]
fn test_can_move() {
    let mut map = get_test_map(
        [get_test_my_character(0, 2, 2, ROGUE), get_test_my_character(1, 2, 3, KNIGHT), get_test_my_character(2, 2, 4, MAGE), get_test_my_character(3, 2, 5, RITUALIST), get_test_my_character(4, 2, 6, ARCHER)],
        [get_test_their_character(0, 22, 2, UNKNOWN_CLASS), get_test_their_character(1, 22, 3, UNKNOWN_CLASS), get_test_their_character(2, 22, 4, UNKNOWN_CLASS), get_test_their_character(3, 22, 5, UNKNOWN_CLASS), get_test_their_character(4, 22, 6, UNKNOWN_CLASS)],
        [Trap { x: 255, y: 255, sprung: &mut 0, damage: 0 }; TRAPS_BUFFER_SIZE],
        [Trap { x: 255, y: 255, sprung: &mut 0, damage: 0 }; TRAPS_BUFFER_SIZE],
    );

    let r1_result = map.can_move_to(7, 0);
    assert(r1_result.success);
    assert(r1_result.value == false);

    let r2_result = map.can_move_to(6, 0);
    assert(r2_result.success);
    assert(r2_result.value == true);

    let r3_result = map.can_move_to(0, 6);
    assert(r3_result.success);
    assert(r3_result.value == false);
}



// fn assert_neighbor(actor: T, x: u8, y: u8) where T: Character {
//     assert(is_neighbor(actor, x, y));
// }

#[test]
fn test_is_neighbor() {
    let mut class = KNIGHT;
    let c = Character {
        id: 0,
        x: 0,
        y: 4,
        status: 0,
        health: 100,
        class: class,
        has_been_seen: 0,
        target_x: 0,
        target_y: 0,
        damage: 123,
    };

    let r1_result = Map::is_neighbor(c.get_x(), c.get_y(), 0, 3);
    assert(r1_result.success);
    assert(r1_result.value == true);

    let r2_result = Map::is_neighbor(c.get_x(), c.get_y(), 0, 5);
    assert(r2_result.success);
    assert(r2_result.value == true);

    let r3_result = Map::is_neighbor(c.get_x(), c.get_y(), 1, 4);
    assert(r3_result.success);
    assert(r3_result.value == true);
}

// fn can_move_to(map: [[u8; globals::WIDTH]; globals::HEIGHT], x: u8, y: u8) -> u1 {
//     assert(y < globals::HEIGHT);
//     assert(x < globals::WIDTH);
//     let tile = map[y][x];
//     if (tile == 0) | (tile >= FLAG) { 1 }
//     else { 0 }
// }

// #[test]
// fn test_can_move() {
//     let map = [
//         [0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0],
//         [0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0],
//         [0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0],
//         [globals::WALL, globals::WALL, EMPTY,globals::WALL, globals::WALL, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, globals::WALL, globals::WALL, EMPTY,globals::WALL, globals::WALL],
//         [globals::WALL, EMPTY,EMPTY,EMPTY,globals::WALL, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, globals::WALL, EMPTY,EMPTY,EMPTY,globals::WALL],
//         [globals::WALL, EMPTY,EMPTY,EMPTY,globals::WALL, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, globals::WALL, EMPTY,EMPTY,EMPTY,globals::WALL],
//         [globals::WALL, globals::WALL, EMPTY,globals::WALL, globals::WALL, 0, 0, EMPTY,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, EMPTY,0, 0, globals::WALL, globals::WALL, EMPTY,globals::WALL, globals::WALL],
//         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
//         [0, 0, 0, 0, 0, 0, globals::WATER, globals::WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WATER, globals::WATER, 0, 0, 0, 0, 0, 0],
//         [0, 0, 0, 0, 0, globals::WATER, globals::WATER, globals::WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WATER, globals::WATER, globals::WATER, 0, 0, 0, 0, 0],
//     ];

//     assert(can_move_to(map, 7, 0) == 0);
//     assert(can_move_to(map, 6, 0) == 1);
//     assert(can_move_to(map, 0, 6) == 0);
// }


// fn is_neighbor(actor: impl character::Character, x: u8, y: u8) -> bool {
//     assert((actor.x < globals::WIDTH) & (actor.y < globals::HEIGHT) & (x < globals::WIDTH) & (y < globals::HEIGHT));
//     assert((actor.x == x) | (actor.y == y));
//     assert((actor.x != x) | (actor.y != y));
//     if actor.x == x {
//         if (actor.y == 0) {
//             y == 1
//         } else {
//             (y == actor.y - 1) | (y == actor.y + 1)
//         }
//     } else {
//         if (actor.x == 0) {
//             x == 1
//         } else {
//             (x == actor.x - 1) | (x == actor.x + 1)
//         }
//     }
// }
// fn assert_neighbor(actor: Character, x: u8, y: u8) {
//     assert(is_neighbor(actor, x, y));
// }

// #[test]
// fn test_assert_neighbor() {
//     let c = Character {
//         id: 0,
//         x: 0,
//         y: 4,
//         status: 0,
//         health: 100,
//         class: KNIGHT
//     };
//     assert_neighbor(c, 0, 3);
//     assert_neighbor(c, 0, 5);
//     assert_neighbor(c, 1, 4);
// }

// fn move_to(map: &mut [[u8; globals::WIDTH]; globals::HEIGHT], actor: &mut Character, energy: &mut u8, to_x: u8, to_y: u8) -> Field {
//     assert(can_move_to(*map, to_x, to_y) == 1);
//     assert(actor.class > 0);
//     assert(actor.class < CLASS_COUNT);
//     assert(actor.x < globals::WIDTH);
//     assert(actor.y < globals::HEIGHT);
//     assert(to_x < globals::WIDTH);
//     assert(to_y < globals::HEIGHT);
//     assert(map[actor.y][actor.x] == actor.class);
//     assert_neighbor(*actor, to_x, to_y);
//     if (actor.class == KNIGHT) | (actor.class == MAGE) | (actor.class == RITUALIST) {
//         assert(*energy >= 4);
//         *energy -= (4 as u8);
//     } else {
//         assert(*energy >= 3);
//         *energy -= 3;
//     }

//     map[actor.y][actor.x] = 0; // TODO: instead of setting to 0, set to whatever it was before actor moved there!
//     map[to_y][to_x] = actor.class;
//     actor.x = to_x;
//     actor.y = to_y;
//     build_event(SEE_MOVE, actor.id, to_x, to_y)
// }

// #[test]
// fn test_move_to() {
//     let mut map = [
//         [0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0],
//         [0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0],
//         [0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0],
//         [globals::WALL, globals::WALL, EMPTY,globals::WALL, globals::WALL, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, globals::WALL, globals::WALL, EMPTY,globals::WALL, globals::WALL],
//         [globals::WALL, EMPTY,KNIGHT,EMPTY,globals::WALL, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, globals::WALL, EMPTY,EMPTY,EMPTY,globals::WALL],
//         [globals::WALL, EMPTY,EMPTY,EMPTY,globals::WALL, 0, 0, globals::WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WALL, 0, 0, globals::WALL, EMPTY,EMPTY,EMPTY,globals::WALL],
//         [globals::WALL, globals::WALL, EMPTY,globals::WALL, globals::WALL, 0, 0, EMPTY,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, EMPTY,0, 0, globals::WALL, globals::WALL, EMPTY,globals::WALL, globals::WALL],
//         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
//         [0, 0, 0, 0, 0, 0, globals::WATER, globals::WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WATER, globals::WATER, 0, 0, 0, 0, 0, 0],
//         [0, 0, 0, 0, 0, globals::WATER, globals::WATER, globals::WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals::WATER, globals::WATER, globals::WATER, 0, 0, 0, 0, 0],
//     ];
//     let mut c = Character {
//         id: 0,
//         x: 2,
//         y: 4,
//         status: 0,
//         health: 100,
//         class: KNIGHT
//     };
//     let mut energy = 12;
//     assert(move_to(&mut map, &mut c, &mut energy, 2, 3) == build_event(SEE_MOVE, 0, 2, 3));
// }

// fn sneak_to(map: &mut [[u8; globals::WIDTH]; globals::HEIGHT], actor: &mut Character, energy: &mut u8, to_x: u8, to_y: u8) -> Field {
//     assert(can_move_to(*map, to_x, to_y) == 1);
//     assert(actor.class == ROGUE);
//     assert(actor.x < globals::WIDTH);
//     assert(actor.y < globals::HEIGHT);
//     assert(to_x < globals::WIDTH);
//     assert(to_y < globals::HEIGHT);
//     assert(*energy >= 6);
//     *energy -= 6;

//     if map[actor.y][actor.x] == ROGUE { map[actor.y][actor.x] = 0; } // TODO: instead of setting to 0, set to whatever it was before actor moved there!
//     //map[to_y][to_x] = actor.class;
//     actor.x = to_x;
//     actor.y = to_y;
//     build_event(NO_EVENT, actor.id, 255, 255)
// }

