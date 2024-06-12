use crate::WIDTH;
use crate::HEIGHT;
use crate::character::Character;
use crate::{ SNEAK, MOVE, RITUAL, SEARCH, ATTACK, CAST_FIREBALL, DRAW, DISARM_TRAP };
use crate::event::{ build_std_event, build_subtype_value_event, build_value_event };
use crate::{ WAIT, SEE_MOVE, WIN, SEE_RITUAL, SEE_SEARCH_TRAP, RECEIVE_ATTACK, ATTACK_MELEE, SEE_CAST, SEE_DRAW, DESTROY, ATTACK_FIREBALL };
use crate::{ FIREBALL_ROUNDS_FOR_CAST, RITUAL_ROUNDS_FOR_WIN };
use crate::map::is_neighbor;
use crate::event::Event;

struct Action {
    action: u8,
    actor: u8,
    target_x: u8,
    target_y: u8,
}
// TODO: action type as global struct & impl
impl Action {
    fn from_field(field: Field) -> Action {
        Action {
            action: field as u8,
            actor: (field / 0x100) as u8,
            target_x: (field / 0x10000) as u8,
            target_y: (field / 0x1000000) as u8,
        }
    }

    fn to_field(self) -> Field {
        self.action as Field + (self.actor as Field) * 0x100 + (self.target_x as Field) * 0x10000 + (self.target_y as Field) * 0x1000000
    }

    // fn affects_my_other_character(self, result_event_type: u8, result_event_subtype: u8, x: u8, y: u8) -> bool {
    //     (result_event_type == RECEIVE_ATTACK) & (result_event_subtype == ATTACK_FIREBALL) & is_neighbor(self.target_x, self.target_y, x, y)
    // }

    // fn affects_my_obstacle(self, result_event_type: u8, result_event_subtype: u8, x: u8, y: u8) -> bool {
    //     (result_event_type == RECEIVE_ATTACK) & (((self.target_x == x) & (self.target_y == y)) | ((result_event_subtype == ATTACK_FIREBALL) & is_neighbor(self.target_x, self.target_y, x, y)))
    // }

    fn execute(self, c: Character, mut energy: u8) -> (Event, Character, u8) {
        // WAIT: Do nothing

        let mut result_event: Event = build_std_event(WAIT, c.id, 0, 0);
        let mut result_char = c;
        let mut required_energy = 0;

        if self.action == SNEAK {
            assert(c.can_sneak());
            // TODO: can_move_to check
            assert(is_neighbor(c.x, c.y, self.target_x, self.target_y));
            result_char.x = self.target_x;  
            result_char.y = self.target_y;
            required_energy = c.get_energy_per_sneak();
        }
        if self.action == MOVE {
            // TODO: can_move_to check
            assert(is_neighbor(c.x, c.y, self.target_x, self.target_y));
            result_char.x = self.target_x;
            result_char.y = self.target_y;
            required_energy = c.get_energy_per_move();
            result_event = build_std_event(SEE_MOVE, c.id, self.target_x, self.target_y);
        }
        if self.action == RITUAL {
            assert(c.can_ritual());
            result_char.status += 1;
            if result_char.status >= RITUAL_ROUNDS_FOR_WIN {
                result_event = build_std_event(WIN, c.id, 0, 0);
            } else {
                result_event = build_std_event(SEE_RITUAL, c.id, 0, 0);
            }
            required_energy = c.get_energy_per_ritual();
        }
        if self.action == SEARCH {
            assert(c.can_search());
            assert(is_neighbor(c.x, c.y, self.target_x, self.target_y));
            result_event = build_std_event(SEE_SEARCH_TRAP, c.id, self.target_x, self.target_y);
            required_energy = c.get_energy_per_search();
        }
        if self.action == ATTACK {
            assert(is_neighbor(c.x, c.y, self.target_x, self.target_y));
            result_event = build_subtype_value_event(RECEIVE_ATTACK, c.id, self.target_x, self.target_y, c.get_damage(), ATTACK_MELEE);
            required_energy = c.get_energy_per_attack();
        }
        // TODO: global SET_TRAP = 6 as u8;
        if self.action == CAST_FIREBALL {
            assert(c.can_cast_fireball());
            result_char.status += 1;
            if c.status >= FIREBALL_ROUNDS_FOR_CAST {
                // TODO: handle friendly fire and destruction of own walls and own traps
                result_event = build_subtype_value_event(RECEIVE_ATTACK, c.id, self.target_x, self.target_y, c.get_damage(), ATTACK_FIREBALL);
            } else {
                if c.get_has_been_seen() == 1 {
                    result_event = build_subtype_value_event(SEE_CAST, c.id, self.target_x, self.target_y, c.get_damage(), ATTACK_FIREBALL);
                }
            }
            required_energy = c.get_energy_per_cast();
        }
        if self.action == DRAW {
            assert(c.can_shoot());
            if c.get_has_been_seen() == 1 {
                result_event = build_std_event(SEE_DRAW, c.id, self.target_x, self.target_y);
            }
        }
//global TRIGGER_TRAP = 9 as u8;  // => TRIGGERED_TRAP ?????????
        if self.action == DISARM_TRAP {
            assert(c.can_disarm());
            assert(is_neighbor(c.x, c.y, self.target_x, self.target_y));
            result_event = build_std_event(DESTROY, c.id, self.target_x, self.target_y);
            required_energy = c.get_energy_per_disarm();
        }
        
        assert(energy >= required_energy);
        energy -= required_energy;
        (result_event, result_char, energy)
    }
}