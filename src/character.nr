use dep::std;
use crate::KNIGHT;
use crate::MAGE;
use crate::RITUALIST;
use crate::ROGUE;
use crate::WIDTH;
use crate::HEIGHT;
use crate::CLASS_COUNT;
use crate::STATUS_COUNT;

global class_damage = [
    0, // UNKNOWN_CLASS
    32, //ARCHER
    8, // RITUALIST
    24, // ROGUE
    40, // KNIGHT
    16, // MAGE
];

struct Character {
    id: u8,
    x: &mut u8, // 5 bit
    y: &mut u8, // 4 bit
    class: &mut u8, // 3 bit
    status: &mut u8, // 0 = idle, 1-15 = continuing action => 4 bit
    health: &mut u8,
    has_been_seen: &mut u1,
    target_x: &mut u8,
    target_y: &mut u8,
    damage: u8,
}

impl Character {
    pub fn get_id(self) -> u8 {
        self.id
    }

    pub fn get_x(self) -> u8 {
        *self.x
    }

    pub fn get_y(self) -> u8 {
        *self.y
    }

    pub fn get_class(self) -> u8 {
        *self.class
    }

    pub fn get_status(self) -> u8 {
        *self.status
    }

    pub fn get_health(self) -> u8 {
        *self.health
    }

    pub fn get_has_been_seen(self) -> u1 {
        *self.has_been_seen
    }

    pub fn get_target_x(self) -> u8 {
        *self.target_x
    }

    pub fn get_target_y(self) -> u8 {
        *self.target_y
    }

    pub fn get_energy_per_move(self) -> u8 {
        if (*self.class == KNIGHT) | (*self.class == MAGE) | (*self.class == RITUALIST) {
            4
        } else {
            3
        }
    }

    pub fn can_sneak(self) -> bool {
        *self.class == ROGUE
    }

    pub fn get_energy_per_sneak(self) -> u8 {
        if self.can_sneak() {
            6
        } else {
            255
        }
    }

    pub fn set_pos(mut self, x: u8, y: u8) -> bool {
        let success = ((x < WIDTH) & (y < HEIGHT)) | ((x == 255) | (y == 255));
        if success {
            *self.x = x;
            *self.y = y;
        }
        success
    }

    pub fn set_class(mut self, class: u8) -> bool {
        let success = (class < crate::CLASS_COUNT) & ((*self.class == crate::UNKNOWN_CLASS) | (*self.class == class));
        if success {
            *self.class = class;
        }
        success
    }

    pub fn set_status(mut self, status: u8) -> bool {
        let success = (status < crate::STATUS_COUNT) & ((*self.status == 0) | (status == 0) | (*self.status + 1 == status));
        if success {
            *self.status = status;
        }
        success
    }

    pub fn set_health(mut self, health: u8) -> bool {
        *self.health = health;
        true
    }

    pub fn set_has_been_seen(mut self, has_been_seen: u1) -> bool {
        let success = (*self.has_been_seen == has_been_seen) | (*self.has_been_seen == 0);
        if success {
            *self.has_been_seen = has_been_seen;
        }
        success
    }

    pub fn set_target(mut self, target_x: u8, target_y: u8) -> bool {
        let success = ((target_x < WIDTH) & (target_y < HEIGHT)) | ((target_x == 255) & (target_y == 255));
        if success {
            *self.target_x = target_x;
            *self.target_y = target_y;
        }
        success
    }

    pub fn is_valid(self) -> bool {
        ((*self.x < WIDTH) & (*self.y < HEIGHT)) | ((*self.x == 255) & (*self.y == 255)) &
        ((*self.class < CLASS_COUNT) & (*self.status < STATUS_COUNT)) &
        ((*self.target_x < WIDTH) & (*self.target_y < HEIGHT)) | ((*self.target_x == 255) & (*self.target_y == 255))
    }

    pub fn has_known_pos(self) -> u8 {
        if (*self.x != 255) & (*self.y != 255) {
            1
        } else {
            0
        }
    }

    pub fn has_known_target(self) -> u8 {
        if (*self.target_x != 255) & (*self.target_y != 255) {
            1
        } else {
            0
        }
    }

    pub fn serialize(self) -> crate::Result<[u8; 6]> {
        let is_valid = self.is_valid();
        let has_known_pos = self.has_known_pos();
        let has_known_target = self.has_known_target();
        let packed_x = *self.x | (*self.class << 5);
        let packed_y = *self.y | (*self.status << 4);
        let packed_target_x = (*self.target_x & 31) | (has_known_pos << 5) | (has_known_target << 6);
        let packed_target_y = *self.target_y & 15;
        crate::Result {
            value: [packed_x, packed_y, *self.health, packed_target_x, packed_target_y, 0],
            success: is_valid
        }
    }

    pub fn create_character(id: u8, x: u8, y: u8, class: u8) -> crate::Result<Character> {
        let mut xx = x;
        let mut yy = y;
        let mut cc = class;
        let c = Character {
            id: id,
            x: &mut xx,
            y: &mut yy,
            class: &mut cc,
            status: &mut 0,
            health: &mut 0,
            has_been_seen: &mut 0,
            target_x: &mut 255,
            target_y: &mut 255,
            damage: class_damage[class],
        };
        crate::Result {
            value: c,
            success: c.is_valid()
        }
    }

    pub fn parse_character(id: u8, data: Field) -> crate::Result<Character> {
        // these asserts could be disabled for production
        assert(WIDTH <= 32);
        assert(HEIGHT <= 16);
        assert(CLASS_COUNT <= 8);
        assert(STATUS_COUNT <= 16);

        let split = data.to_be_bytes(32);
        let x_packed = split[2 + id * 6]; // 5 bit x, 3 bit class
        let y_packed = split[2 + id * 6 + 1]; // 4 bit y, 4 bit status
        let target_x_packed = split[2 + id * 6 + 3]; // 5 bit target x, 1 bit visible, 1 bit has target, 1 bit unused
        let target_y_packed = split[2 + id * 6 + 4]; // 4 bit target y, 4 bit unused
        // one byte left for future use

        let is_visible = (target_x_packed >> 5) & 1;

        let mut x = x_packed & 31;
        let mut y = y_packed & 15;
        let mut class = (x_packed >> 5) & 7;
        let mut status = (y_packed >> 4) & 15;
        let mut health = split[2 + id * 6 + 2];
        let mut target_x = target_x_packed & 31;
        let mut target_y = target_y_packed & 15;

        let mut result = Character {
            id: id,
            x: &mut x,
            y: &mut y,
            class: &mut class,
            status: &mut status,
            health: &mut health,
            has_been_seen: &mut 0, // TODO 
            target_x: &mut target_x,
            target_y: &mut target_y,
            damage: class_damage[class],
        };

        let mut success = true;
        let has_target = (target_x_packed >> 5) & 1;
        if has_target != 1 {
            success &= result.set_target(255, 255);
        }

        if is_visible != 1 {
            success &= result.set_pos(255, 255);
        }
        if result.get_health() == 255 {
            success &= (is_visible != 1);
            // result.set_pos(255, 255);
            // assert(result.x == 255);
            // assert(result.y == 255);
        } /*else {
            assert((result.x < crate::WIDTH) | (result.x == 255));
            assert((result.y < crate::HEIGHT) | (result.y == 255));
        }*/
        success &= result.is_valid();
        crate::Result {
            value: result,
            success: success
        }
    }
}

pub fn get_test_my_character(id: u8, x: u8, y: u8, class: u8) -> Character {
    assert(id < 5);
    assert(class < CLASS_COUNT);
    assert(x < WIDTH);
    assert(y < HEIGHT);

    let mut xx = x;
    let mut yy = y;
    let mut cc = class;

    Character {
        id: id,
        x: &mut xx,
        y: &mut yy,
        class: &mut cc,
        status: &mut 0,
        health: &mut 100,
        has_been_seen: &mut 0,
        target_x: &mut 255,
        target_y: &mut 255,
        damage: class_damage[class],
    }
}

pub fn get_test_their_character(id: u8, x: u8, y: u8, class: u8) -> Character {
    assert(id < 5);
    assert(class < CLASS_COUNT);
    assert(x < WIDTH);
    assert(y < HEIGHT);

    let mut xx = x;
    let mut yy = y;
    let mut cc = class;

    Character {
        id: id,
        x: &mut xx,
        y: &mut yy,
        class: &mut cc,
        status: &mut 0,
        health: &mut 255,
        has_been_seen: &mut 0,
        target_x: &mut 255,
        target_y: &mut 255,
        damage: class_damage[class],
    }
}

#[test]
fn test_serialize_character() {
    let mut character = Character {
        id: 4,
        x: &mut 21,
        y: &mut 9,
        class: &mut 5,
        status: &mut 9,
        health: &mut 129,
        has_been_seen: &mut 0,
        target_x: &mut 31,
        target_y: &mut 15,
        damage: class_damage[0],
    };
    let field_result = character.serialize();
    assert(field_result.success);
    let field = field_result.value;
    assert(field[0] == (21 | (5 << 5)));
    assert(field[1] == (9 | (9 << 4)));
    assert(field[2] == 129);
    assert(field[3] == 127);
    assert(field[4] == 15);
    assert(field[5] == 0);

    assert(character.set_pos(1, 1));
    assert(character.set_status(0));
    assert(character.set_status(1));
    assert(character.set_health(1));
    assert(character.set_has_been_seen(1));
    assert(character.set_target(255, 255));
    let field1_result = character.serialize();
    assert(field1_result.success);
    let field1 = field1_result.value;
    assert(field1[0] == (1 | (5 << 5)));
    assert(field1[1] == (1 | (1 << 4)));
    assert(field1[2] == 1);
    assert(field1[3] == 63);
    assert(field1[4] == 15);
    assert(field1[5] == 0);
}

#[test]
fn test_parse_character() {
    let data_array: [u8; 32] = [
        0 as u8, 0 as u8,
        0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
        0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
        255 as u8, 255 as u8, 255 as u8, 255 as u8, 255 as u8, 255 as u8,
        181 as u8, 153 as u8, 129 as u8, 127 as u8, 15 as u8, 0 as u8,
        0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
    ];
    let data: Field = std::field::bytes32_to_field(data_array);
    println(data);
    println("hallo"); // 0xffffffffffffb599811f0f000000000000000000 != 
                      // 0xffffffffffff b599811f0f00 000000000000 0000000000
    assert(data == 0xffffffffffffb599817f0f00000000000000, f"Failed assumption: data: {data} != 0xffffffffffffb599817f0f000000000000000000");
    let character_result = Character::parse_character(3, data);
    assert(character_result.success);
    let character = character_result.value;
    assert(character.get_id() == 3);
    assert(character.get_x() == 21);
    assert(character.get_y() == 9);
    assert(character.get_class() == 5);
    assert(character.get_status() == 9);
    assert(character.get_health() == 129);
    assert(character.get_has_been_seen() == 0);
    assert(character.get_target_x() == 31);
    assert(character.get_target_y() == 15);

    let character_max_result = Character::parse_character(2, data);
    assert(!character_max_result.success); // yep this one should fail!
    let character_max = character_max_result.value;
    assert(character_max.get_id() == 2);
    assert(character_max.get_x() == 31);
    assert(character_max.get_y() == 15);
    assert(character_max.get_class() == 7);
    assert(character_max.get_status() == 15);
    assert(character_max.get_health() == 255);
    assert(character_max.get_has_been_seen() == 0);
    assert(character_max.get_target_x() == 31);
    assert(character_max.get_target_y() == 15);

    let character_min_result = Character::parse_character(0, data);
    assert(character_min_result.success);
    let character_min = character_min_result.value;
    assert(character_min.get_id() == 0);
    assert(character_min.get_x() == 255);
    assert(character_min.get_y() == 255);
    assert(character_min.get_class() == 0);
    assert(character_min.get_status() == 0);
    assert(character_min.get_health() == 0);
    assert(character_min.get_has_been_seen() == 0);
    assert(character_min.get_target_x() == 255);
    assert(character_min.get_target_y() == 255);
}

#[test]
fn test_character_setters() {
    let mut class = ROGUE;
    let mut character = Character {
        id: 4,
        x: &mut 21,
        y: &mut 9,
        class: &mut class,
        status: &mut 9,
        health: &mut 129,
        has_been_seen: &mut 0,
        target_x: &mut 31,
        target_y: &mut 15,
        damage: class_damage[class],
    };
    assert(character.get_x() == 21);
    assert(character.get_y() == 9);
    assert(character.has_known_pos() == 1);
    assert(character.set_pos(21, 8));
    assert(character.get_x() == 21);
    assert(character.get_y() == 8);
    assert(character.has_known_pos() == 1);
    assert(character.set_pos(255, 255));
    assert(character.get_x() == 255);
    assert(character.get_y() == 255);
    assert(character.has_known_pos() == 0);

    assert(character.get_class() == ROGUE);
    assert(character.can_sneak());
    assert(character.get_energy_per_sneak() == 6);
    assert(character.get_energy_per_move() == 3);
    assert(!character.set_class(KNIGHT));
    *character.class = crate::UNKNOWN_CLASS;
    assert(character.set_class(KNIGHT));
    assert(character.get_class() == KNIGHT);
    assert(!character.can_sneak());
    assert(character.get_energy_per_sneak() == 255);
    assert(character.get_energy_per_move() == 4);

    assert(character.get_status() == 9);
    assert(character.set_status(10));
    assert(character.get_status() == 10);
    assert(!character.set_status(8));
    assert(character.get_status() == 10);

    assert(character.get_health() == 129);
    assert(character.set_health(130));
    assert(character.get_health() == 130);

    assert(character.get_has_been_seen() == 0);
    assert(character.set_has_been_seen(1));
    assert(character.get_has_been_seen() == 1);
    assert(character.set_has_been_seen(1));
    assert(character.get_has_been_seen() == 1);
    assert(!character.set_has_been_seen(0));
    assert(character.get_has_been_seen() == 1);

    assert(character.get_target_x() == 31);
    assert(character.get_target_y() == 15);
    assert(character.has_known_target() == 1);
    assert(character.set_target(1, 1));
    assert(character.get_target_x() == 1);
    assert(character.get_target_y() == 1);
    assert(character.has_known_target() == 1);
    assert(character.set_target(255, 255));
    assert(character.get_target_x() == 255);
    assert(character.get_target_y() == 255);
    assert(character.has_known_target() == 0);
}


// //crate globals;
// use crate::globals;

// use globals::get_max_width as max_width;
// use globals::get_max_height as max_height;
// use globals::get_class_count as class_count;
// use globals::get_status_count as status_count;
// use globals::get_unknown_class as unknown_class;

// struct CharacterData {
//     id: u8,
//     x: u8, // 5 bit
//     y: u8, // 4 bit
//     class: u8, // 3 bit
//     status: u8, // 0 = idle, 1-15 = continuing action => 4 bit
//     health: u8,
//     has_been_seen: u1,
//     target_x: u8,
//     target_y: u8
// }

// trait Character {
//     fn get_id(self) -> u8;
//     fn get_x(self) -> u8;
//     fn get_y(self) -> u8;
//     fn get_class(self) -> u8;
//     fn get_status(self) -> u8;
//     fn get_health(self) -> u8;
//     fn get_has_been_seen(self) -> u1;
//     fn get_target_x(self) -> u8;
//     fn get_target_y(self) -> u8;
//     fn set_pos(&mut self, x: u8, y: u8);
//     fn set_class(&mut self, class: u8);
//     fn set_status(&mut self, status: u8);
//     fn set_health(&mut self, health: u8);
//     fn set_has_been_seen(&mut self, has_been_seen: u1);
//     fn set_target(&mut self, target_x: u8, target_y: u8);

//     fn serialize(self) -> [u8; 6] {
//         let packed_x = self.x | (self.class << 5);
//         let packed_y = self.y | (self.status << 4);
//         let packed_target_x = self.target_x;
//         let packed_target_y = self.target_y;
//         [packed_x, packed_y, self.health, packed_target_x, packed_target_y, 0]
//     }
// }

// impl Character for CharacterData {
//     fn get_id(self) -> u8 {
//         self.id
//     }

//     fn get_x(self) -> u8 {
//         self.x
//     }

//     fn get_y(self) -> u8 {
//         self.y
//     }

//     fn get_class(self) -> u8 {
//         self.class
//     }

//     fn get_status(self) -> u8 {
//         self.status
//     }

//     fn get_health(self) -> u8 {
//         self.health
//     }

//     fn get_has_been_seen(self) -> u1 {
//         self.has_been_seen
//     }

//     fn get_target_x(self) -> u8 {
//         self.target_x
//     }

//     fn get_target_y(self) -> u8 {
//         self.target_y
//     }

//     fn set_pos(&mut self, x: u8, y: u8) {
//         assert(((x < max_width()) & (y < max_height())) | ((x == 255) & (y == 255)));
//         self.x = x;
//         self.y = y;
//     }

//     fn set_class(&mut self, class: u8) {
//         assert(class < class_count());
//         assert((class == self.class) | (self.class == unknown_class()));
//         self.class = class;
//     }

//     fn set_status(&mut self, status: u8) {
//         assert(status < status_count());
//         self.status = status;
//     }

//     fn set_health(&mut self, health: u8) {
//         self.health = health;
//     }

//     fn set_has_been_seen(&mut self, has_been_seen: u1) {
//         if (self.has_been_seen != has_been_seen) {
//             assert(self.has_been_seen == 0);
//             self.has_been_seen = has_been_seen;
//         }
//     }

//     fn set_target(&mut self, target_x: u8, target_y: u8) {
//         assert(((target_x < max_width()) & (target_y < max_height())) | ((target_x == 255) & (target_y == 255)));
//         self.target_x = target_x;
//         self.target_y = target_y;
//     }
// }

// pub fn create_character(id: u8, x: u8, y: u8, class: u8)-> impl Character {
//     assert((x < max_width()) & (y < max_height()));
//     assert(class < class_count());
//     CharacterData {
//         id: id,
//         x: x,
//         y: y,
//         class: class,
//         status: 0,
//         health: 0,
//         has_been_seen: 0,
//         target_x: 255,
//         target_y: 255
//     }
// }

// pub fn parse_character(id: u8, data: Field) -> impl Character {
//     // these asserts could be disabled for production
//     assert(max_width() <= 32 as u8);
//     assert(max_height() <= 16);
//     assert(class_count() <= 8);
//     assert(status_count() <= 16);

//     let split = data.to_be_bytes(32);
//     let x_packed = split[id * 6]; // 5 bit x, 3 bit class
//     let y_packed = split[id * 6 + 1]; // 4 bit y, 4 bit status
//     let target_x_packed = split[id * 6 + 3]; // 5 bit target x, 3 bit unused
//     let target_y_packed = split[id * 6 + 4]; // 4 bit target y, 4 bit unused
//     // one byte left for future use

//     let result = CharacterData {
//         id: id,
//         x: x_packed & 31,
//         y: y_packed & 15,
//         class: (x_packed >> 5) & 7,
//         status: (y_packed >> 4) & 15,
//         health: split[id * 6 + 2],
//         has_been_seen: 0,
//         target_x: target_x_packed & 31,
//         target_y: target_y_packed & 15
//     };
//     if result.health == 255 {
//         assert(result.x == 255);
//         assert(result.y == 255);
//     } else {
//         assert((result.x < max_width()) | (result.x == 255));
//         assert((result.y < max_height()) | (result.y == 255));
//     }
//     result
// }

// #[test]
// fn test_serialize_character() {
//     let character = CharacterData {
//         id: 4,
//         x: 21,
//         y: 9,
//         class: 5,
//         status: 9,
//         health: 129,
//         has_been_seen: 0,
//         target_x: 31,
//         target_y: 15
//     };
//     let field = character.serialize();
//     assert(field[0] == (21 | (5 << 5)));
//     assert(field[1] == (9 | (9 << 4)));
//     assert(field[2] == 129);
//     assert(field[3] == 31);
//     assert(field[4] == 15);
//     assert(field[5] == 0);
// }

// #[test]
// fn test_parse_character() {}