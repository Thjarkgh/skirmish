use dep::std;

// MAP
global WIDTH = 32;
global HEIGHT = 10;

// CLASSES
global UNKNOWN_CLASS = 0 as u8;
global ARCHER = 1 as u8;
global RITUALIST = 2 as u8;
global ROGUE = 3 as u8;
global KNIGHT = 4 as u8;
global MAGE = 5 as u8;
global CLASS_COUNT = 6 as u8;

// ACTIONS
global WAIT = 0 as u8;
global SNEAK = 1 as u8;
global MOVE = 2 as u8;
global RITUAL = 3 as u8;
global SEARCH = 4 as u8;
global ATTACK = 5 as u8;
global SET_TRAP = 6 as u8;
global CAST_FIREBALL = 7 as u8;
global DRAW = 8 as u8;
global TRIGGER_TRAP = 9 as u8;
global ACTION_COUNT = 10 as u8;

// EVENTS
global NO_EVENT = 0  as u8;
global SEE_MOVE = 1  as u8;
global SEE_RITUAL = 2  as u8;
global SEE_SEARCH_TRAP = 3  as u8;
global RECEIVE_ATTACK = 4  as u8;
global SEE_CAST = 5 as u8;
global SEE_DRAW = 6 as u8;
global TRIGGERED_TRAP = 7 as u8;
global WIN = 8 as u8;
global FOUND_TRAP = 9 as u8;
global SEE_CHARS = 10 as u8;
global EVENT_COUNT = 11 as u8;

// ATTACKS
global ATTACK_MELEE = 0 as u8;
global ATTACK_RANGED = 1 as u8;
global ATTACK_FIREBALL = 2 as u8;
global ATTACK_COUNT = 3 as u8;

// TILES
global EMPTY = 0 as u8;
global WALL = 6 as u8;
global WATER = 7 as u8;
global FLAG = 8 as u8;
global TRAP = 9 as u8;
global TRAP_USED = 10 as u8;
global BODY = 11 as u8;
global BODY_LOOTED = 12 as u8;
global FOG = 15 as u8;

// STATUS
global STATUS_COUNT = 16  as u8; // just to be more in line with the other constants, actually used as a counter

// GAMEPLAY
global MAX_TRAPS = 10;
global MAX_ACTIONS = 10;
global MAX_EVENTS = 10;

////////////// CHARACTER
struct CharacterData {
    id: u8,
    x: u8, // 5 bit
    y: u8, // 4 bit
    class: u8, // 3 bit
    status: u8, // 0 = idle, 1-15 = continuing action => 4 bit
    health: u8,
    has_been_seen: u1,
    target_x: u8,
    target_y: u8
}

trait Character {
    fn get_id(self) -> u8;
    fn get_x(self) -> u8;
    fn get_y(self) -> u8;
    fn get_class(self) -> u8;
    fn get_status(self) -> u8;
    fn get_health(self) -> u8;
    fn get_has_been_seen(self) -> u1;
    fn get_target_x(self) -> u8;
    fn get_target_y(self) -> u8;
    fn set_pos(&mut self, x: u8, y: u8);
    fn set_class(&mut self, class: u8);
    fn set_status(&mut self, status: u8);
    fn set_health(&mut self, health: u8);
    fn set_has_been_seen(&mut self, has_been_seen: u1);
    fn set_target(&mut self, target_x: u8, target_y: u8);

    fn serialize(self) -> [u8; 6] {
        let packed_x = self.x | (self.class << 5);
        let packed_y = self.y | (self.status << 4);
        let packed_target_x = self.target_x;
        let packed_target_y = self.target_y;
        [packed_x, packed_y, self.health, packed_target_x, packed_target_y, 0]
    }

    fn create_character(id: u8, x: u8, y: u8, class: u8)-> impl Character;
    fn parse_character(id: u8, data: Field) -> &mut impl Character;
}

impl Character for CharacterData {
    fn get_id(self) -> u8 {
        self.id
    }

    fn get_x(self) -> u8 {
        self.x
    }

    fn get_y(self) -> u8 {
        self.y
    }

    fn get_class(self) -> u8 {
        self.class
    }

    fn get_status(self) -> u8 {
        self.status
    }

    fn get_health(self) -> u8 {
        self.health
    }

    fn get_has_been_seen(self) -> u1 {
        self.has_been_seen
    }

    fn get_target_x(self) -> u8 {
        self.target_x
    }

    fn get_target_y(self) -> u8 {
        self.target_y
    }

    fn set_pos(&mut self, x: u8, y: u8) {
        assert(((x < WIDTH) & (y < HEIGHT)) | ((x == 255) & (y == 255)));
        self.x = x;
        self.y = y;
    }

    fn set_class(&mut self, class: u8) {
        assert(class < CLASS_COUNT);
        assert((class == self.class) | (self.class == UNKNOWN_CLASS));
        self.class = class;
    }

    fn set_status(&mut self, status: u8) {
        assert(status < STATUS_COUNT);
        self.status = status;
    }

    fn set_health(&mut self, health: u8) {
        self.health = health;
    }

    fn set_has_been_seen(&mut self, has_been_seen: u1) {
        if (self.has_been_seen != has_been_seen) {
            assert(self.has_been_seen == 0);
            self.has_been_seen = has_been_seen;
        }
    }

    fn set_target(&mut self, target_x: u8, target_y: u8) {
        assert(((target_x < WIDTH) & (target_y < HEIGHT)) | ((target_x == 255) & (target_y == 255)));
        self.target_x = target_x;
        self.target_y = target_y;
    }

    fn create_character(id: u8, x: u8, y: u8, class: u8)-> impl Character {
        assert((x < WIDTH) & (y < HEIGHT));
        assert(class < CLASS_COUNT);
        CharacterData {
            id: id,
            x: x,
            y: y,
            class: class,
            status: 0,
            health: 0,
            has_been_seen: 0,
            target_x: 255,
            target_y: 255
        }
    }

    fn parse_character(id: u8, data: Field) -> &mut impl Character {
        // these asserts could be disabled for production
        assert(WIDTH <= 32 as u8);
        assert(HEIGHT <= 16);
        assert(CLASS_COUNT <= 8);
        assert(STATUS_COUNT <= 16);

        let split = data.to_be_bytes(32);
        let x_packed = split[id * 6]; // 5 bit x, 3 bit class
        let y_packed = split[id * 6 + 1]; // 4 bit y, 4 bit status
        let target_x_packed = split[id * 6 + 3]; // 5 bit target x, 3 bit unused
        let target_y_packed = split[id * 6 + 4]; // 4 bit target y, 4 bit unused
        // one byte left for future use

        let mut result: &mut impl Character = &mut CharacterData {
            id: id,
            x: x_packed & 31,
            y: y_packed & 15,
            class: (x_packed >> 5) & 7,
            status: (y_packed >> 4) & 15,
            health: split[id * 6 + 2],
            has_been_seen: 0,
            target_x: target_x_packed & 31,
            target_y: target_y_packed & 15
        };
        if (*result).get_health() == 255 {
            (*result).set_pos(255, 255);
            // assert(result.x == 255);
            // assert(result.y == 255);
        } else {
            assert((result.x < WIDTH) | (result.x == 255));
            assert((result.y < HEIGHT) | (result.y == 255));
        }
        result
    }
}


#[test]
fn test_serialize_character() {
    let mut character = CharacterData {
        id: 4,
        x: 21,
        y: 9,
        class: 5,
        status: 9,
        health: 129,
        has_been_seen: 0,
        target_x: 31,
        target_y: 15
    };
    let field = character.serialize();
    assert(field[0] == (21 | (5 << 5)));
    assert(field[1] == (9 | (9 << 4)));
    assert(field[2] == 129);
    assert(field[3] == 31);
    assert(field[4] == 15);
    assert(field[5] == 0);

    character.set_pos(1, 1);
    character.set_status(1);
    character.set_health(1);
    character.set_has_been_seen(1);
    character.set_target(1, 1);
    let field1 = character.serialize();
    assert(field1[0] == (1 | (5 << 5)));
    assert(field1[1] == (1 | (1 << 4)));
    assert(field1[2] == 1);
    assert(field1[3] == 1);
    assert(field1[4] == 1);
    assert(field1[5] == 0);
}

#[test]
fn test_parse_character() {
    let data_array: [u8; 32] = [
        0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
        0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
        255 as u8, 255 as u8, 255 as u8, 255 as u8, 255 as u8, 255 as u8,
        181 as u8, 153 as u8, 129 as u8, 31 as u8, 15 as u8, 0 as u8,
        0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
        0 as u8, 0 as u8
    ];
    let data: Field = std::field::bytes32_to_field(data_array);
    println(data);
    println("hallo"); // 0xffffffffffffb599811f0f000000000000000000 != 
                      // 0xffffffffffff b599811f0f00 000000000000 0000000000
    assert(data == 0xffffffffffffb599811f0f000000000000000000, f"Failed assumption: data: {data} != 0x000000000000000000f1f8199b5ffffffffffff000000000000000000000000");
    let character = CharacterData::parse_character(3, data);
    assert(character.get_id() == 3);
    assert(character.get_x() == 21);
    assert(character.get_y() == 9);
    assert(character.get_class() == 5);
    assert(character.get_status() == 9);
    assert(character.get_health() == 129);
    assert(character.get_has_been_seen() == 0);
    assert(character.get_target_x() == 31);
    assert(character.get_target_y() == 15);

    let character_max = CharacterData::parse_character(2, data);
    assert(character_max.get_id() == 2);
    assert(character_max.get_x() == 31);
    assert(character_max.get_y() == 15);
    assert(character_max.get_class() == 7);
    assert(character_max.get_status() == 15);
    assert(character_max.get_health() == 255);
    assert(character_max.get_has_been_seen() == 0);
    assert(character_max.get_target_x() == 31);
    assert(character_max.get_target_y() == 15);

    let character_min = CharacterData::parse_character(0, data);
    assert(character_min.get_id() == 0);
    assert(character_min.get_x() == 0);
    assert(character_min.get_y() == 0);
    assert(character_min.get_class() == 0);
    assert(character_min.get_status() == 0);
    assert(character_min.get_health() == 0);
    assert(character_min.get_has_been_seen() == 0);
    assert(character_min.get_target_x() == 0);
    assert(character_min.get_target_y() == 0);
}

////////////// GAME
struct GameData {
    my_char_0: &mut impl Character,
    their_chars: [&mut impl Character; 5],
    traps: [Trap; MAX_TRAPS],
    searched_traps: [u32; MAX_TRAPS],
    map: [[&mut u8; WIDTH]; HEIGHT],
}

trait Game<T> where T: Character {
    fn get_my_char(&mut self, id: u8) -> &mut T;
    fn get_their_char(&mut self, id: u8) -> &mut T;
    fn get_trap(self, id: u8) -> Trap;
    fn get_tile(self, x: u8, y: u8) -> u8;
    fn set_tile(&mut self, x: u8, y: u8, tile: u8);

    fn serialize_my_chars(self) -> Field;
    fn serialize_their_chars(self) -> Field;
    fn serialize_my_traps(self) -> Field;
    fn serialize_their_traps(self) -> Field;
    fn serialize_map(self) -> [[u8; WIDTH]; HEIGHT];

    fn build(my_chars: Field, their_chars: Field, my_traps: Field, their_traps: Field, map: [[u8; WIDTH]; HEIGHT]) -> Game<T> {
        let mut my_char_0: &mut impl Character = CharacterData::parse_character(0, my_chars);
        let mut their_chars: [&mut impl Character; 5] = [
            parse_character(0, their_chars),
            parse_character(1, their_chars),
            parse_character(2, their_chars),
            parse_character(3, their_chars),
            parse_character(4, their_chars)
        ]
    }
}

impl Game<Character> for GameData {
    fn get_my_char(&mut self, id: u8) -> &mut impl Character {
        assert(id == 0);
        self.my_char_0
    }
    fn get_their_char(&mut self, id: u8) -> &mut impl Character {
        assert(id < 5);
        self.their_chars[id]
    }
    fn get_trap(self, id: u8) -> Trap {
        assert(id < MAX_TRAPS);
        self.traps[id]
    }
    fn get_tile(mut self, x: u8, y: u8) -> u8 {
        assert((x < WIDTH) & (y < HEIGHT));
        *self.map[y][x]
    }
    fn set_tile(&mut self, x: u8, y: u8, tile: u8) {
        assert((x < WIDTH) & (y < HEIGHT));
        *self.map[y][x] = tile;
    }

    fn serialize_my_chars(self) -> Field {
        self.my_char_0.serialize()
    }
    fn serialize_their_chars(self) -> Field {
        let mut result: [u8; 32] = [0; 32];
        for i in 0..5 {
            let serialized = self.their_chars[i].serialize();
            for j in 0..6 {
                result[i * 6 + j] = serialized[j];
            }
        }
        std::field::bytes32_to_field(result)
    }
}

////////////// MAP

fn can_move_to(map: [[u8; WIDTH]; HEIGHT], x: u8, y: u8) -> u1 {
    assert(y < HEIGHT);
    assert(x < WIDTH);
    let tile = map[y][x];
    if (tile == 0) | (tile >= FLAG) { 1 }
    else { 0 }
}

#[test]
fn test_can_move() {
    let map = [
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
    ];

    assert(can_move_to(map, 7, 0) == 0);
    assert(can_move_to(map, 6, 0) == 1);
    assert(can_move_to(map, 0, 6) == 0);
}


fn is_neighbor<T>(actor: T, x: u8, y: u8) -> bool where T: Character {
    assert((actor.get_x() < WIDTH) & (actor.get_y() < HEIGHT) & (x < WIDTH) & (y < HEIGHT));
    assert((actor.get_x() == x) | (actor.get_y() == y));
    assert((actor.get_x() != x) | (actor.get_y() != y));
    if actor.get_x() == x {
        if (actor.get_y() == 0) {
            y == 1
        } else {
            (y == actor.get_y() - 1) | (y == actor.get_y() + 1)
        }
    } else {
        if (actor.get_x() == 0) {
            x == 1
        } else {
            (x == actor.get_x() - 1) | (x == actor.get_x() + 1)
        }
    }
}
fn assert_neighbor<T>(actor: T, x: u8, y: u8) where T: Character {
    assert(is_neighbor(actor, x, y));
}

#[test]
fn test_assert_neighbor() {
    let c = CharacterData {
        id: 0,
        x: 0,
        y: 4,
        status: 0,
        health: 100,
        class: KNIGHT,
        has_been_seen: 0,
        target_x: 0,
        target_y: 0
    };
    assert_neighbor(c, 0, 3);
    assert_neighbor(c, 0, 5);
    assert_neighbor(c, 1, 4);
}

struct Trap {
    x: u8,
    y: u8
}

fn parse_traps(data: Field) -> [Trap] {
    let d = data.to_be_bytes(32);
    assert(d.len() == 32);
    let mut result: [Trap] = &[];
    let mut found_end = 0;
    for i in 0..16 {
        if (found_end == 0) & (d[i * 2] < WIDTH) & (d[i * 2 + 1] < HEIGHT) {
            result = result.push_back(Trap { x: d[i * 2], y: d[i * 2 + 1] });
        } else {
            found_end = 1;
        }
    }
    result
}

#[test]
fn test_parse_traps() {
    let nr = 0x10020300FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;// 0xFF00030210; //255; //1002055755;
    let parts = nr.to_be_bytes(32);
    assert(parts.len() == 32);
    assert(parts[0] == 16);
    assert(parts[1] == 2);
    assert(parts[2] == 3);
    assert(parts[3] == 0);
    assert(parts[22] == 255);
    assert(parts[5] == 255);

    let r = parse_traps(nr);
    assert(r.len() == 2);
    assert(r[0].x == 16);
    assert(r[0].y == 2);
    assert(r[1].x == 3);
    assert(r[1].y == 0);
}

fn move_to<T>(map: &mut [[u8; WIDTH]; HEIGHT], actor: &mut T, energy: &mut u8, to_x: u8, to_y: u8) -> Field where T: Character {
    assert(can_move_to(*map, to_x, to_y) == 1);
    assert((*actor).get_class() > 0);
    assert((*actor).get_class() < CLASS_COUNT);
    assert((*actor).get_x() < WIDTH);
    assert((*actor).get_y() < HEIGHT);
    assert(to_x < WIDTH);
    assert(to_y < HEIGHT);
    assert(map[(*actor).get_y()][(*actor).get_x()] == (*actor).get_class());
    assert_neighbor((*actor), to_x, to_y);
    if ((*actor).get_class() == KNIGHT) | ((*actor).get_class() == MAGE) | ((*actor).get_class() == RITUALIST) {
        assert(*energy >= 4);
        *energy -= (4 as u8);
    } else {
        assert(*energy >= 3);
        *energy -= 3;
    }

    map[(*actor).get_y()][(*actor).get_x()] = 0; // TODO: instead of setting to 0, set to whatever it was before actor moved there!
    map[to_y][to_x] = (*actor).get_class();
    Character::set_pos(actor, to_x, to_y); //actor=>set_pos(to_x, to_y);
    build_std_event(SEE_MOVE, (*actor).get_id(), to_x, to_y)
}

#[test]
fn test_move_to() {
    let mut map = [
        [0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [WALL, WALL, EMPTY,WALL, WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, WALL, WALL, EMPTY,WALL, WALL],
        [WALL, EMPTY,KNIGHT,EMPTY,WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, WALL, EMPTY,EMPTY,EMPTY,WALL],
        [WALL, EMPTY,EMPTY,EMPTY,WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, WALL, EMPTY,EMPTY,EMPTY,WALL],
        [WALL, WALL, EMPTY,WALL, WALL, 0, 0, EMPTY,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, EMPTY,0, 0, WALL, WALL, EMPTY,WALL, WALL],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, WATER, WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WATER, WATER, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, WATER, WATER, WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WATER, WATER, WATER, 0, 0, 0, 0, 0],
    ];
    let mut c = CharacterData {
        id: 0,
        x: 2,
        y: 4,
        status: 0,
        health: 100,
        class: KNIGHT,
        has_been_seen: 0,
        target_x: 0,
        target_y: 0
    };
    let mut energy = 12;
    assert(move_to(&mut map, &mut c, &mut energy, 2, 3) == build_std_event(SEE_MOVE, 0, 2, 3));
}

fn sneak_to<T>(map: &mut [[u8; WIDTH]; HEIGHT], actor: &mut T, energy: &mut u8, to_x: u8, to_y: u8) -> Field where T: Character {
    assert(can_move_to(*map, to_x, to_y) == 1);
    assert((*actor).get_class() == ROGUE);
    assert(((*actor).get_x() < WIDTH) & ((*actor).get_y() < HEIGHT));
    assert((to_x < WIDTH) & (to_y < HEIGHT));
    assert(*energy >= 6);
    *energy -= 6;

    if map[(*actor).get_y()][(*actor).get_x()] == ROGUE { map[(*actor).get_y()][(*actor).get_x()] = 0; } // TODO: instead of setting to 0, set to whatever it was before actor moved there!
    //map[to_y][to_x] = actor.class;
    Character::set_pos(actor, to_x, to_y);
    build_std_event(NO_EVENT, (*actor).get_id(), 255, 255)
}


// ////////////// EVENT

pub fn build_std_event(event: u8, actor_id: u8, x: u8, y: u8) -> Field {
    let result = ((event as u64 << 24) | (actor_id as u64 << 16) | (x as u64 << 8) | (y as u64));
    result as Field
}

trait Event {
    fn to_field(self) -> Field;
    fn process<T, U>(self, game: &mut T) where U: Character, T: Game<U>;
}

struct StdEvent {
    event: u8,
    actor_id: u8,
    x: u8,
    y: u8,
}

// impl Event for StdEvent {
//     fn to_field(self) -> Field {
//         build_std_event(self.event, self.actor_id, self.x, self.y)
//     }

//     fn process(self, game: &mut impl Game) {
//         if self.event == SEE_MOVE {
//             assert(self.actor_id < 5);
//             assert_neighbor(game.their_chars[self.actor_id], self.x, self.y);
//             game.their_chars[self.actor_id].x = self.x;
//             game.their_chars[self.actor_id].y = self.y;
//         } else if self.event == SEE_RITUAL {
//             game.their_chars[self.actor_id].status += 1;
//         } else if self.event == SEE_SEARCH_TRAP {
//             for j in 0..10 {
//                 if j < game.my_traps.len() {
//                     if (game.my_traps[j].x == self.x) & (game.my_traps[j].y == self.y) {
//                         assert(game.actions.any(|a| {
//                             let s = a.to_be_bytes(32);
//                             (s[0] == TRIGGER_TRAP) & (s[1] == self.actor_id) & (s[2] == self.x) & (s[3] == self.y)
//                         }));
//                     }
//                 }
//             }
//         } else if self.event == RECEIVE_ATTACK {
//             for j in 0..5 {
//                 if (game.my_chars[j].x == ) /////////////events and actions: rethink the be/le stuff!
//             }
//         }
//     }
// }

// pub fn parse_event(event: Field) -> Event {
//     let split = event.to_be_bytes(32);
//     let eventType = split[0];
//     if event == SEE_MOVE {
//         // TODO: I would like to only reveal class once line of sight has been established: todo for later
//         assert(split[1] < 5);
//         assert_neighbor(their_chars[split[1]], split[2], split[3]);
//         their_chars[split[1]].x = split[2];
//         their_chars[split[1]].y = split[3];
//     } else if event == SEE_RITUAL {
//         their_chars[split[1]].status += 1;
//     } else if event == SEE_SEARCH_TRAP {
//         for j in 0..10 {
//             if j < my_traps.len() {
//                 if (my_traps[j].x == split[2]) & (my_traps[j].y == split[3]) {
//                     assert(actions.any(|a| {
//                         let s = a.to_be_bytes(32);
//                         (s[0] == TRIGGER_TRAP) & (s[1] == split[1]) & (s[2] == split[2]) & (s[3] == split[3])
//                     }));
//                 }
//             }
//         }
//     } else if event == RECEIVE_ATTACK {
//         for j in 0..5 {
//             if (my_chars[j].x == ) /////////////events and actions: rethink the be/le stuff!
//         }
//     }
// }

// //////////////////
// fn get_actor_from_move(move: u32) -> u32 {
//     if (move % 2) == 1 {
//         ((move % 10) - 1) >> 1 // actually not needed ... but clearer this way
//     } else {
//         (move % 10) >> 1
//     }
// }

// fn get_data_hash(secret: [u8], characters: [u8], traps: [u8], map: [[u8; WIDTH]; HEIGHT], searched_traps: [u32; 10]) -> [u8; 32] {
//     assert(secret.len() == 32);
//     assert(characters.len() == 32);
//     assert(traps.len() == 32);

//     let mut data: [u8; WIDTH * HEIGHT + 32 * 3 + 40] = [0; WIDTH * HEIGHT + 32 * 3 + 40];
//     for i in 0..HEIGHT {
//         for j in 0..WIDTH {
//             data[i * WIDTH + j] = map[j][i];
//         }
//     }
//     let offset = WIDTH * HEIGHT;
//     for i in 0..32 {
//         data[offset + i] = secret[i];
//         data[offset + i + 32] = characters[i];
//         data[offset + i + 64] = traps[i];
//     }
//     let offset = WIDTH * HEIGHT + 32 * 3;
//     for i in 0..10 {
//         data[offset + i * 4] = (searched_traps[i] & 255) as u8;
//         data[offset + i * 4 + 1] = ((searched_traps[i] >> 8) & 255) as u8;
//         data[offset + i * 4 + 2] = ((searched_traps[i] >> 16) & 255) as u8;
//         data[offset + i * 4 + 3] = ((searched_traps[i] >> 24) & 255) as u8;
//     }
//     std::hash::blake3(data)
// }


// fn main(
//     secret: Field,
//     my_characters: Field,
//     their_characters: Field,
//     actions: [Field; 5],
//     traps: Field,
//     searched_traps: [u32; HEIGHT],
//     move: pub u32,
//     map_old: pub [[u8; WIDTH]; HEIGHT],
//     map_new: pub [[u8; WIDTH]; HEIGHT],
//     received_events: pub [Field; 10],
//     sending_events: pub [Field; 10],
//     gamestate_before_hash: pub Field,
//     gamestate_after_hash: pub Field
// ) {
//     let old_hash = get_data_hash(secret.to_be_bytes(32), characters.to_be_bytes(32), traps.to_be_bytes(32), map_old, searched_traps);
//     let old_gamestate_bytes = gamestate_before_hash.to_be_bytes(32);
//     assert(old_gamestate_bytes.len() == 32);
//     for i in 0..32 {
//         assert(old_hash[i] == old_gamestate_bytes[i]);
//     }

//     let mut my_traps = parse_traps(traps);
//     let mut my_chars = [
//         parse_character(0, characters),
//         parse_character(1, characters),
//         parse_character(2, characters),
//         parse_character(3, characters),
//         parse_character(4, characters)
//     ];
//     let their_chars = [
//         parse_character(5, characters),
//         parse_character(6, characters),
//         parse_character(7, characters),
//         parse_character(8, characters),
//         parse_character(9, characters)
//     ];

//     let actor_id = get_actor_from_move(move) as u8;
//     assert(actor_id < 5);
//     let mut actor = parse_character(actor_id, characters);

//     let mut map = [ // apparently no clone support
//         map_old[0].map(|cell| cell),
//         map_old[1].map(|cell| cell),
//         map_old[2].map(|cell| cell),
//         map_old[3].map(|cell| cell),
//         map_old[4].map(|cell| cell),
//         map_old[5].map(|cell| cell),
//         map_old[6].map(|cell| cell),
//         map_old[7].map(|cell| cell),
//         map_old[8].map(|cell| cell),
//         map_old[9].map(|cell| cell)
//     ];

//     for i in 0..10 {
//         let split = received_events[i].to_be_bytes(32);
//         let event = split[0];
//         if event == SEE_MOVE {
//             // TODO: I would like to only reveal class once line of sight has been established: todo for later
//             assert(split[1] < 5);
//             assert_neighbor(their_chars[split[1]], split[2], split[3]);
//             their_chars[split[1]].x = split[2];
//             their_chars[split[1]].y = split[3];
//         } else if event == SEE_RITUAL {
//             their_chars[split[1]].status += 1;
//         } else if event == SEE_SEARCH_TRAP {
//             for j in 0..10 {
//                 if j < my_traps.len() {
//                     if (my_traps[j].x == split[2]) & (my_traps[j].y == split[3]) {
//                         assert(actions.any(|a| {
//                             let s = a.to_be_bytes(32);
//                             (s[0] == TRIGGER_TRAP) & (s[1] == split[1]) & (s[2] == split[2]) & (s[3] == split[3])
//                         }));
//                     }
//                 }
//             }
//         } else if event == RECEIVE_ATTACK {
//             for j in 0..5 {
//                 if (my_chars[j].x == ) /////////////events and actions: rethink the be/le stuff!
//             }
//         }
// // global NO_EVENT = 0;
// // global SEE_MOVE = 1;
// // global SEE_RITUAL = 2;
// // global SEE_SEARCH_TRAP = 3;
// // global RECEIVE_ATTACK = 4;
// // global SEE_CAST = 5;
// // global SEE_DRAW = 6;
// // global TRIGGERED_TRAP = 7;
// // global WIN = 8;
// // global FOUND_TRAP = 9;
//     }

//     let mut energy: u8 = 12;
//     for i in 0..10 {
//         let split = actions[i].to_be_bytes(32);
//         let action = split[0];
//         if action == SNEAK {
//             // hide: y|x|actor|0
//             assert(split[1] == actor.id); // for the most parts, only current actor may do stuff
//             assert(sending_events[i] == sneak_to(&mut map, &mut actor, &mut energy, split[2], split[3]));
//             actor.status = 0;
//         }
//         else if action == MOVE {
//             // movey|x|actor|0
//             assert(split[1] == actor.id);// for the most parts, only current actor may do stuff
//             assert(sending_events[i] == move_to(&mut map, &mut actor, &mut energy, split[2], split[3]));
//             actor.status = 0;
//         }
//         else if action == RITUAL {
//             assert(split[1] == actor.id); // for the most parts, only current actor may do stuff
//             assert(actor.class == RITUALIST);
//             assert(energy == 12);
//             energy = 0;
//             if actor.status < 7 {
//                 actor.status += 1;
//                 assert(sending_events[i] == build_event(RITUAL, actor.id, actor.x, actor.y));
//             } else {
//                 assert(sending_events[i] == build_event(WIN, actor.id, actor.x, actor.y));
//             }
//             actor.status = 0;
//         }
//         else if action == SEARCH {
//             assert(split[1] == actor.id);
//             assert(actor.class == ROGUE);
//             let x = split[2];
//             let y = split[3];
//             assert(x < WIDTH);
//             assert(y < HEIGHT);
//             assert(energy >= 6);
//             assert(((x == actor.x) & ((y == actor.y + 1) | (y == actor.y - 1))) | ((y == actor.x) & ((x == actor.x + 1) | (x == actor.x - 1))));
//             assert(sending_events[i] == build_event(NO_EVENT, 0, 0, 0));
//             energy -= 6;
//             actor.status = 0;
//         }
//         else if action == CAST_FIREBALL {
//             assert(split[1] == actor.id);// for the most parts, only current actor may do stuff
//             assert(actor.class == MAGE);
//             assert(energy == 12);
//             energy = 0;
//             if actor.status < 2 {
//                 actor.status += 1;
//                 assert(sending_events[i] == build_event(SEE_CAST, actor.id, actor.x, actor.y));
//             } else {
//                 assert(sending_events[i] == build_event(RECEIVE_ATTACK, ATTACK_FIREBALL, actor.x, actor.y));
//             }
//         }
//         else if action == SET_TRAP {
//             assert(split[1] == actor.id);
//             actor.status = 0;
//             if my_traps.len() >= 10 {
//                 let (_popped, rest) = my_traps.pop_front();
//                 my_traps = rest.push_back(Trap { x: split[2], y: split[3]});
//             }
//         }
//         else if action == ATTACK {
//             assert(split[1] == actor.id);
//             if actor.class == ARCHER {
//                 assert(actor.status == 1);
//                 assert(sending_events[i] == build_event(RECEIVE_ATTACK, ATTACK_RANGED, split[2], split[3]));
//             } else {
//                 assert_neighbor(actor, split[2], split[3]);
//                 assert(sending_events[i] == build_event(RECEIVE_ATTACK, ATTACK_MELEE, split[2], split[3]));
//                 if (actor.class == KNIGHT) & (map[split[3]][split[2]] == WALL) {
//                     map[split[3]][split[2]] = EMPTY;
//                 }
//             }
//             actor.status = 0;
//         }
//         else if action == DRAW {
//             assert(split[1] == actor.id);
//             assert(actor.class == ARCHER);
//             actor.status = 1;
//             assert(sending_events[i] == build_event(SEE_DRAW, actor.id, split[2], split[3]));
//         }
//         else if action == TRIGGER_TRAP {
//             let target = split[1];
//             assert(sending_events[i] == build_event(TRIGGERED_TRAP, target, split[2], split[3]));
//         }
//         else if action == WAIT {
//             assert(sending_events[i] == build_event(NO_EVENT, split[1], 255, 255));
//             actor.status = 0;
//         }
//         else {
//             assert(1 == 2); // basically, invalid action code
//         }
//     }
//     // if their_char[0].health + their_char[1].health + their_char[2].health + their_char[3].health + their_char[4].health == 0 {
//     //     // won
//     // }    
// }

// #[test]
// fn test_main() {
//     // main(1, 2);

//     // Uncomment to make test fail
//     // main(1, 1);
// }

fn main () {
    assert(1 == 1);
}