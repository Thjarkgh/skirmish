use crate::character::Character;
use crate::trap::Trap;
use crate::trap::parse_traps;
use crate::trap::serialize_traps;
use crate::map::Map;
use crate::Result;
use crate::WIDTH;
use crate::HEIGHT;
use crate::MAX_EVENTS;
use crate::EVENTS_BUFFER_SIZE;
use crate::EVENTS_BUFFER_MASK;
use crate::MAX_TRAPS;
use crate::TRAPS_BUFFER_SIZE;
use crate::TRAPS_BUFFER_MASK;
use crate::character::get_test_my_character;
use crate::character::get_test_their_character;
use crate::map::get_test_map;
use crate::ARCHER;
use crate::KNIGHT;
use crate::MAGE;
use crate::ROGUE;
use crate::RITUALIST;
use crate::UNKNOWN_CLASS;
use crate::TRAP;
use crate::TRAP_FOUND;
use crate::TRAP_USED;
use dep::std;

struct Game {
    my_chars: [&mut Character; 5],
    their_chars: [&mut Character; 5],
    traps: &mut [Trap; TRAPS_BUFFER_SIZE],
    searched_traps: &mut [Trap; TRAPS_BUFFER_SIZE],
    map: &mut Map,
    events: &mut [Field; EVENTS_BUFFER_SIZE],
    events_count: &mut u64,
    won: &mut bool,
    lost: &mut bool,
    trap_count: &mut u64,
    searched_trap_count: &mut u64,
}

impl Game {
    pub fn lose(mut self) -> bool {
        let success = !(*self.lost) & !(*self.won);
        *self.lost = true;
        // if !self.lost & !self.won {
        //     self.lost = true;
        //     success = true;
        // }
        success
    }
    pub fn win(mut self) -> bool {
        let success = !(*self.lost) & !(*self.won);
        *self.won = true;
        success ////////////////////////////////////////////// TODO & (*self).add_event(crate::build_std_event(crate::WIN, 0, 0, 0))
        //success// let mut success = false;
        // if !self.lost & !self.won {
        //     self.won = true;
        //     success = true;
        //     //(*self).add_event(crate::build_std_event(crate::WIN, 0, 0, 0))
        // }
        // success
    }
    pub fn add_event(mut self, event: Field) -> bool {
        //assert(MAX_EVENTS == 8);
        // let mut success = false;
        let ec = *self.events_count;
        self.events[ec & EVENTS_BUFFER_MASK] = event;
        *self.events_count = ec + 1;
        ec < MAX_EVENTS
        // if ec < MAX_EVENTS {
        //     self.events[ec] = event;
        //     *self.events_count = ec + 1;
        //     success = true;
        // }
        // success
    }

    pub fn get_my_char(self, id: u8) -> crate::Result<&mut Character> {
        if id < 5 {
            crate::Result {
                value: self.my_chars[id],
                success: true
            }
        } else {
            crate::Result {
                value: self.my_chars[0],
                success: false
            }
        }
    }

    pub fn get_their_char(self, id: u8) -> Result<&mut Character> {
        if id < 5 {
            Result {
                value: self.their_chars[id],
                success: true
            }
        } else {
            Result {
                value: self.their_chars[0],
                success: false
            }
        }
    }
    
    pub fn get_trap_count(self) -> u64 {
        *self.trap_count
    }

    pub fn get_trap(self, id: u64) -> Result<Trap> {
        // let mut trap = self.traps[0];
        // let mut success = false;
        // if (id as u64) < *self.trap_count {
        //     trap = self.traps[id];
        //     success = true;
        // }
        Result {
            value: self.traps[id & TRAPS_BUFFER_MASK],
            success: id < *self.trap_count
        }
    }

    pub fn add_my_trap(mut self, trap: Trap) -> bool {
        assert(MAX_TRAPS <= TRAPS_BUFFER_SIZE);
        let tc = *self.trap_count;
        self.traps[tc & TRAPS_BUFFER_MASK] = trap;
        *self.trap_count = tc + 1;
        
        // if success {
        //     self.traps[self.trap_count] = trap;
        //     //self.trap_count += 1;
        // }
        let mut tile = TRAP;
        if *trap.sprung == 1 {
            tile = TRAP_USED;
        }
        tc < MAX_TRAPS & self.map.set(trap.x, trap.y, tile)
    }
    
    pub fn get_their_trap_count(self) -> u64 {
        *self.searched_trap_count
    }

    pub fn get_their_trap(self, id: u64) -> Result<Trap> {
        Result {
            value: self.searched_traps[id & TRAPS_BUFFER_MASK],
            success: id < *self.searched_trap_count
        }
        // if (id as u64) < *self.searched_trap_count {
        //     Result {
        //         value: self.searched_traps[id],
        //         success: true
        //     }
        // } else {
        //     Result {
        //         value: Trap { x: 0, y: 0, sprung: &mut 0, damage: 0 },
        //         success: false
        //     }
        // }
    }

    pub fn add_their_trap(mut self, trap: Trap) -> bool {
        assert(MAX_TRAPS <= TRAPS_BUFFER_SIZE);
        let tc = *self.searched_trap_count;
        self.searched_traps[tc & TRAPS_BUFFER_MASK] = trap;
        *self.searched_trap_count = tc + 1;
        let mut tile = TRAP_FOUND;
        if *trap.sprung == 1 {
            tile = TRAP_USED;
        }
        tc < MAX_TRAPS & self.map.set(trap.x, trap.y, tile)
    }

    pub fn get_tile(self, x: u8, y: u8) -> Result<u8> {
        self.map.get(x, y)
    }

    pub fn set_tile(mut self, x: u8, y: u8, tile: u8) -> bool {
        //if (x < WIDTH) & (y < HEIGHT) {
            self.map.set(x, y, tile)
        // } else {
        //     false
        // }
    }

    fn serialize_chars(chars: [&mut Character; 5]) -> Result<Field> {
        let mut success = true;
        let mut result: [u8; 32] = [0; 32];
        for i in 0..5 {
            let serialized_result = chars[i].serialize();
            success &= serialized_result.success;
            let serialized = serialized_result.value;
            for j in 0..6 {
                result[2 + i * 6 + j] = serialized[j];
            }
        }
        Result {
            value: std::field::bytes32_to_field(result),
            success: success
        }
    }

    pub fn serialize_my_chars(self) -> Result<Field> {
        Game::serialize_chars(self.my_chars)
    }

    pub fn serialize_their_chars(self) -> Result<Field> {
        Game::serialize_chars(self.their_chars)
    }

    pub fn is_valid(self) -> bool {
        false
    }

    pub fn build(my_chars: Field, their_chars: Field, my_traps: Field, their_traps: Field, map: [[u8; WIDTH]; HEIGHT]) -> Game {
        let mut success = true;
        let mut c0_result = Character::parse_character(0, my_chars);
        let mut c0 = &mut c0_result.value;
        let mut c1_result = Character::parse_character(1, my_chars);
        let mut c1 = &mut c1_result.value;
        let mut c2_result = Character::parse_character(2, my_chars);
        let mut c2 = &mut c2_result.value;
        let mut c3_result = Character::parse_character(3, my_chars);
        let mut c3 = &mut c3_result.value;
        let mut c4_result = Character::parse_character(4, my_chars);
        let mut c4 = &mut c4_result.value;
        success &= c0_result.success & c1_result.success & c2_result.success & c3_result.success & c4_result.success;

        let mut e0_result = Character::parse_character(0, their_chars);
        let mut e0 = &mut e0_result.value;
        let mut e1_result = Character::parse_character(1, their_chars);
        let mut e1 = &mut e1_result.value;
        let mut e2_result = Character::parse_character(2, their_chars);
        let mut e2 = &mut e2_result.value;
        let mut e3_result = Character::parse_character(3, their_chars);
        let mut e3 = &mut e3_result.value;
        let mut e4_result = Character::parse_character(4, their_chars);
        let mut e4 = &mut e4_result.value;
        success &= e0_result.success & e1_result.success & e2_result.success & e3_result.success & e4_result.success;

        let mut my_traps_result = parse_traps(my_traps);
        let mut my_traps = my_traps_result.value;
        let mut their_traps_result = parse_traps(their_traps);
        let mut their_traps = their_traps_result.value;
        success &= my_traps_result.success & their_traps_result.success;
        
        let mut map_result = Map::build(map);
        let mut my_map = &mut map_result.value;
        success &= map_result.success;

        Game {
            my_chars: [c0, c1, c2, c3, c4],
            their_chars: [e0, e1, e2, e3, e4],
            traps: &mut my_traps,
            searched_traps: &mut their_traps,
            map: my_map,
            events: &mut [0; MAX_EVENTS],
            events_count: &mut 0,
            won: &mut false,
            lost: &mut false,
            trap_count: &mut my_traps_result.count,
            searched_trap_count: &mut their_traps_result.count,
        }
    }
}

pub fn get_test_game() -> Game {
    let mut c0 = get_test_my_character(0, 2, 2, ARCHER);
    let mut c1 = get_test_my_character(1, 2, 3, KNIGHT);
    let mut c2 = get_test_my_character(2, 2, 4, MAGE);
    let mut c3 = get_test_my_character(3, 2, 5, ROGUE);
    let mut c4 = get_test_my_character(4, 2, 6, RITUALIST);

    let mut e0 = get_test_their_character(0, 22, 2, ARCHER);
    let mut e1 = get_test_their_character(1, 22, 3, KNIGHT);
    let mut e2 = get_test_their_character(2, 22, 4, MAGE);
    let mut e3 = get_test_their_character(3, 22, 5, ROGUE);
    let mut e4 = get_test_their_character(4, 22, 6, RITUALIST);

    // let my_traps = [0; 32];
    // let their_traps = [0; 32];
    let mut my_traps_result = parse_traps(0x0000ffff00000000000000000000000000000000000000000000000000000000);
    let mut my_traps = my_traps_result.value;
    let mut their_traps_result = parse_traps(0x0000ffff00000000000000000000000000000000000000000000000000000000);
    let mut their_traps = their_traps_result.value;
    //let mut map = get_test_map([c0, c1, c2, c3, c4], [e0, e1, e2, e3, e4], my_traps, their_traps);

    let mut map = get_test_map(
        [c0, c1, c2, c3, c4], //[get_test_my_character(0, 2, 2, ROGUE), get_test_my_character(1, 2, 3, KNIGHT), get_test_my_character(2, 2, 4, MAGE), get_test_my_character(3, 2, 5, RITUALIST), get_test_my_character(4, 2, 6, ARCHER)],
        [e0, e1, e2, e3, e4], //[get_test_their_character(0, 22, 2, UNKNOWN_CLASS), get_test_their_character(1, 22, 3, UNKNOWN_CLASS), get_test_their_character(2, 22, 4, UNKNOWN_CLASS), get_test_their_character(3, 22, 5, UNKNOWN_CLASS), get_test_their_character(4, 22, 6, UNKNOWN_CLASS)],
        [Trap { x: 255, y: 255, sprung: &mut 0, damage: 0 }; TRAPS_BUFFER_SIZE], /// TODO: using my_traps here causes exception on compile
        [Trap { x: 255, y: 255, sprung: &mut 0, damage: 0 }; TRAPS_BUFFER_SIZE],
    );

    Game {
        my_chars: [&mut c0, &mut c1, &mut c2, &mut c3, &mut c4],
        their_chars: [&mut e0, &mut e1, &mut e2, &mut e3, &mut e4],
        traps: &mut my_traps,
        searched_traps: &mut their_traps,
        map: map,
        events: &mut [0; MAX_EVENTS],
        events_count: &mut 0,
        won: &mut false,
        lost: &mut false,
        trap_count: &mut my_traps_result.count,
        searched_trap_count: &mut their_traps_result.count,
    }
}

#[test]
fn test_lose() {
    let mut game = get_test_game();
    assert(game.lose());
    assert(*game.lost);
    assert(!(*game.won));
    assert(!game.lose());
    assert(!game.win());
}

#[test]
fn test_win() {
    let mut game = get_test_game();
    assert(game.win());
    assert(*game.won);
    assert(!(*game.lost));
    assert(!game.win());
    assert(!game.lose());
}

#[test]
fn test_get_update_my_char() {
    let mut game = get_test_game();
    let mut char_result = game.get_my_char(0);
    assert(char_result.success);
    let mut c0 = char_result.value;
    
    let old_x = c0.get_x();
    let old_y = c0.get_y();

    assert(c0.set_pos(old_x + 3, old_y + 3));

    assert(game.get_my_char(0).value.get_x() == old_x + 3);
    assert(game.get_my_char(0).value.get_y() == old_y + 3);
}

#[test]
fn test_get_update_their_char() {
    let mut game = get_test_game();
    let mut char_result = game.get_their_char(0);
    assert(char_result.success);
    let mut c0 = char_result.value;
    
    let old_x = c0.get_x();
    let old_y = c0.get_y();

    assert(c0.set_pos(old_x + 3, old_y + 3));

    assert(game.get_their_char(0).value.get_x() == old_x + 3);
    assert(game.get_their_char(0).value.get_y() == old_y + 3);
}

#[test]
fn test_get_traps() {
    let mut game = get_test_game();
    let trap_count = game.get_trap_count();
    assert(trap_count == 0, f"trap count: {trap_count}");

    assert(game.add_my_trap(Trap { x: 1, y: 1, sprung: &mut 0, damage: 60 }));
    assert(game.get_trap_count() == 1);

    let mut trap_result = game.get_trap(0);
    assert(trap_result.success);
    assert(trap_result.value.damage == 60);

    for i in 1..MAX_TRAPS {
        assert(game.add_my_trap(Trap { x: 1, y: 1, sprung: &mut 0, damage: 60 }));
        assert(game.get_trap_count() == i + 1);
    }

    assert(!game.add_my_trap(Trap { x: 1, y: 1, sprung: &mut 0, damage: 60 }));
}

#[test]
fn test_get_their_traps() {
    let mut game = get_test_game();
    let trap_count = game.get_their_trap_count();
    assert(trap_count == 0, f"trap count: {trap_count}");

    assert(game.add_their_trap(Trap { x: 1, y: 1, sprung: &mut 0, damage: 60 }));
    assert(game.get_their_trap_count() == 1);

    let mut trap_result = game.get_their_trap(0);
    assert(trap_result.success);
    assert(trap_result.value.damage == 60);

    for i in 1..MAX_TRAPS {
        assert(game.add_their_trap(Trap { x: 1, y: 1, sprung: &mut 0, damage: 60 }));
        assert(game.get_their_trap_count() == i + 1);
    }

    assert(!game.add_their_trap(Trap { x: 1, y: 1, sprung: &mut 0, damage: 60 }));
}

#[test]
fn test_get_tile() {
    let mut game = get_test_game();
    let mut tile_result = game.get_tile(0, 0);
    assert(tile_result.success);
    assert(tile_result.value == 0);

    assert(game.set_tile(0, 0, 1));
    let mut tile_result = game.get_tile(0, 0);
    assert(tile_result.success);
    assert(tile_result.value == 1);

    assert(game.set_tile(WIDTH - 1 as u8, 0, 1));
    assert(game.set_tile(0, HEIGHT - 1 as u8, 1));
    assert(!game.set_tile(WIDTH as u8, 0, 1));
    assert(!game.set_tile(0, HEIGHT as u8, 1));
}
