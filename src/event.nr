use crate::character::Character;
use crate::EVENT_COUNT;
use crate::NO_EVENT;
use crate::SEE_MOVE;
use crate::SEE_RITUAL;
use crate::SEE_CAST;
use crate::SEE_DRAW;
use crate::SEE_SEARCH_TRAP;
use crate::RECEIVE_ATTACK;
use crate::TRIGGERED_TRAP;
use crate::WIN;
use crate::FOUND_TRAP;
use crate::DISCOVER;
use crate::RECEIVE_DAMAGE;
use crate::DESTROY;
// use crate::DEATH;
use crate::MAX_TRAPS;
use crate::WALL;
use crate::EMPTY;
use crate::TRAPS_BUFFER_MASK;
use crate::CLASS_COUNT;
use crate::ATTACK_COUNT;
use crate::action::is_neighbor;
use dep::std;
use crate::character::{ get_attack_damage_to_tile, get_trap_damage_to_tile };
use crate::{ ATTACK_MELEE, ATTACK_RANGED, ATTACK_FIREBALL };
// trait Event {
//     fn to_field(self) -> Field;
//     fn process<T, U>(self, game: &mut T) where U: Character, T: Game<U>;
// }

struct Event {
    event: u8,
    actor_id: u8,
    subtype: u8,
    x: u8,
    y: u8,
    value: u8,
}

// fn handle_see_move(game: &mut Game, actor_id: u8, x: u8, y: u8) -> bool {
//     //assert(actor_id < 5);
//     // let actor_result = game.get_their_char(actor_id);
//     // assert(actor_result.success);
//     true
//     // let mut result = false;
//     // if actor_id < 5 {
//     //     let mut actor_result = game.get_their_char(actor_id);
//     //     if actor_result.success {
//     //         let mut actor = actor_result.value;
//     //         let is_neighbor_result = Map::is_neighbor(actor.get_x(), actor.get_y(), x, y);
//     //         if is_neighbor_result.success {
//     //             if is_neighbor_result.value {
//     //                 let can_move_to = game.map.can_move_to(x, y);
//     //                 if can_move_to.success & can_move_to.value {
//     //                     result = actor.set_pos(x, y);
//     //                     //result = true;
//     //                 }
//     //             }
//     //         }
//     //     }
//     // }
//     // result
// }

// #[test]
// fn test_handle_see_move() {
//     let mut game = crate::game::get_test_game();
//     let their_char = game.get_their_char(0).value;
//     assert(their_char.get_x() == 22);
//     assert(their_char.get_y() == 2);
//     let result = handle_see_move(&mut game, 0, 21, 2);
//     assert(result == true);
// }

// #[test]
// fn test_handle_see_move_fail() {
//     let mut game = crate::game::get_test_game();
//     let result = handle_see_move(&mut game, 5, 1, 2);
//     assert(result == false);
//     let result2 = handle_see_move(&mut game, 0, 1, 2);
//     assert(result2 == false);
// }

// fn get_accumulated_trap_damage(game: &mut Game, x: u8, y: u8) -> u8 {
//     let mut dmg = 0 as u8;
//     let mut traps_count = game.get_trap_count();
//     for i in 0..MAX_TRAPS {
//         let mut trap_result = game.get_trap(i);
//         if i < traps_count {
//             let mut trap = trap_result.value;
//             if (trap.x == x) & (trap.y == y) & (*trap.sprung == 0) {
//                 *trap.sprung = 1;
//                 dmg += trap.damage;
//             }
//         }
//     }
//     dmg
// }

// fn handle_see_progress(game: &mut Game, actor_id: u8, value: u8) -> bool {
//     let mut result = false;
//     if actor_id < 5 {
//         let mut actor_result = Game::get_their_char(*game, actor_id);
//         if actor_result.success {
//             let mut actor = actor_result.value;
//             if (actor.get_status() == 0) | (actor.get_status() + 1 == value) {
//                 result = actor.set_status(actor.status + 1);
//             }
//         }
//     }
//     result
// }

// #[test]
// fn test_handle_see_progress() {
//     let mut game = crate::game::get_test_game();
//     let result = handle_see_progress(&mut game, 0, 1);
//     assert(result == true);
// }

// #[test]
// fn test_handle_see_progress_fail() {
//     let mut game = crate::game::get_test_game();
//     let result = handle_see_progress(&mut game, 5, 1);
//     assert(result == false);
//     let result2 = handle_see_progress(&mut game, 0, 1);
//     assert(result2 == true);
//     let result3 = handle_see_progress(&mut game, 0, 3);
//     assert(result3 == false);
// }

// /**
//     * @dev Handles the SEE_SEARCH_TRAP event.
//     * @param game The game instance.
//     * @param actor_id The id of the actor.
//     * @param x The x coordinate of the search location.
//     * @param y The y coordinate of the search location.
//     * @return Event != 0 if the event was successfully processed and a trap was found, 0 otherwise.
//     */
// fn handle_see_search_trap(game: Game, actor_id: u8, x: u8, y: u8) -> Field {
//     let actor_result = game.get_their_char(actor_id);
//     let is_neighbor_result = Map::is_neighbor(actor_result.value.get_x(), actor_result.value.get_y(), x, y);

//     let mut found = false;
//     let mut success = actor_result.success & is_neighbor_result.success;
//     let mut event: Field = 0;
//     for i in 0..MAX_TRAPS {
//         let trap_result = game.get_trap(i);
//         success &= trap_result.success;
//         if success & !found {
//             if (trap_result.value.x == x) & (trap_result.value.y == y) {
//                 found = true;
//                 event = build_std_event(FOUND_TRAP, actor_id, x, y);
//             }
//         }
//     }
//     event
//     // if found {
//     //     success &= game.add_event(event);
//     // }
//     //success & game.add_event(event)
//     // let mut result = false;
//     // let traps_count = (*game).get_trap_count() as u8;
//     // if actor_id < 5 {
//     //     let mut actor_result = (*game).get_their_char(actor_id);
//     //     if actor_result.success {
//     //         let actor = actor_result.value;
//     //         let is_neighbor_result = Map::is_neighbor(*actor, x, y);
//     //         if is_neighbor_result.success {
//     //             if is_neighbor_result.value {
//     //                 let mut found = false;
//     //                 for j in 0..10 {
//     //                     if (j < traps_count & !found) {
//     //                         let trap = (*game).get_trap(j);
//     //                         //let k = _handle_see_search_trap(*game, j, x, y);
//     //                         // if found {
//     //                         //     result = game.add_event(0); //build_std_event(FOUND_TRAP, actor_id, x, y));
//     //                         // }
//     //                         //found = _handle_see_search_trap(*game, j, x, y);
//     //                         result = true;
//     //                     }
//     //                 }
//     //             }
//     //         }
//     //     }
//     // }
//     // result
// }

// #[test]
// fn test_handle_see_search_trap() {
//     let mut game = crate::game::get_test_game();
//     assert(game.add_my_trap(Trap { x: 1, y: 2, sprung: &mut 0, damage: 64 }));
//     let result = handle_see_search_trap(game, 0, 1, 2);
//     assert(result != 0);
    
//     let not_found = handle_see_search_trap(game, 0, 2, 2);
//     assert(not_found == 0);
// }

// fn handle_receive_attack(my_chars: [&mut Character; 5], map: &mut Map, x: u8, y: u8, dmg: u8, subtype: u8) -> Result<[Field; 8]> {
//     let mut success = true;
//     let mut event_counter = 0;
//     let mut result: [Field; 8] = [0; 8];
//     let splash_dmg: u8 = dmg >> 1;
//     for j in 0..5 {
//         // let my_char_result = game.get_my_char(j);
//         // success &= my_char_result.success;
//         // let my_char = my_char_result.value;
//         let my_char = my_chars[j];

//         if (my_char.get_x() == x) & (my_char.get_y() == y) { /////////////events and actions: rethink the be/le stuff!
//             //if !Character::set_status(my_char, 0) { false }
//             // if dmg >= my_char.get_health() {
//             //     //if !Character::set_health(my_char, 0) { false }
//             //     //let add_event_result = game.add_event(build_std_event(DEATH, j, self.x, self.y));
//             //     //if !add_event_result { false }
//             //     result[event_counter & 7] = build_std_event(DEATH, j, x, y);
//             //     event_counter += 1;
//             // } else {
//                 // if !Character::set_health(my_char, my_char.get_health() - self.value) { false }
//                 // let add_event_result = game.add_event(build_value_event(RECEIVE_DAMAGE, j, self.x, self.y, self.value));
//                 // if !add_event_result { false }
//                 success &= my_char.set_status(0);
//                 if dmg >= my_char.get_health() {
//                     success &= my_char.set_health(0);
//                     result[event_counter & 7] = build_std_event(DEATH, j, x, y);
//                 } else {
//                     success &= my_char.set_health(my_char.get_health() - dmg);
//                     result[event_counter & 7] = build_value_event(RECEIVE_DAMAGE, j, x, y, dmg);
//                 }
//                 event_counter += 1;
//             // }
//         } else {
//             if subtype == ATTACK_FIREBALL {
//                 let is_neighbor_result = Map::is_neighbor(my_char.get_x(), my_char.get_y(), x, y);
//                 success &= is_neighbor_result.success;
//                 if is_neighbor_result.value {
//                     success &= my_char.set_status(0);
//                     if splash_dmg >= my_char.get_health() {
//                         success &= my_char.set_health(0);
//                         result[event_counter & 7] = build_std_event(DEATH, j, my_char.get_x(), my_char.get_y());
//                     } else {
//                         success &= my_char.set_health(my_char.get_health() - splash_dmg);
//                         result[event_counter & 7] = build_value_event(RECEIVE_DAMAGE, j, my_char.get_x(), my_char.get_y(), splash_dmg);
//                     }
//                     // if splash_dmg >= my_char.get_health() {
//                     //     // if !Character::set_health(my_char, 0) { false }
//                     //     // let add_event_result = game.add_event(build_std_event(DEATH, j, x, y));
//                     //     // if !add_event_result { false }
//                     //     result[event_counter & 7] = build_std_event(DEATH, j, my_char.get_x(), my_char.get_y());
//                     //     event_counter += 1;
//                     // } else {
//                         // if !Character::set_health(my_char, my_char.get_health() - splash_dmg) { false }
//                         // let add_event_result = game.add_event(build_value_event(RECEIVE_DAMAGE, j, self.x, self.y, splash_dmg));
//                         // if !add_event_result { false }
//                         // result[event_counter & 7] = build_value_event(RECEIVE_DAMAGE, j, my_char.get_x(), my_char.get_y(), splash_dmg);
//                         event_counter += 1;
//                     // }
//                 }
//             }
//         }
//     }

//     let tile_result = map.get(x, y);
//     success &= tile_result.success;
//     if tile_result.value == WALL {
//         //if !game.set_tile(self.x, self.y, EMPTY) { false }
//         //if !game.add_event(build_std_event(DESTROY, tile, self.x, self.y)) { false }
//         result[event_counter & 7] = build_std_event(DESTROY, tile_result.value, x, y);
//     }
//     Result {
//         success: success,
//         value: result
//     }
// }

// #[test]
// fn test_handle_receive_attack() {
//     let mut game = crate::game::get_test_game();
//     let mut my_chars = crate::game::get_test_my_chars();
//     let char1 = my_chars[0]; //game.get_my_char(0).value;
//     let char2 = my_chars[1]; //game.get_my_char(1).value;
//     let char3 = my_chars[2]; //game.get_my_char(2).value;

//     let result = handle_receive_attack(my_chars, game.map, char2.get_x(), char2.get_y(), 128, ATTACK_FIREBALL);
//     assert(result.success == true);
//     let ev0 = result.value[0];
//     let ev0_should = build_value_event(RECEIVE_DAMAGE, 0, char1.get_x(), char1.get_y(), 64);
//     assert(ev0 == ev0_should, f"event 0: {ev0} != {ev0_should}");
//     let ev1 = result.value[1];
//     let ev1_should = build_std_event(DEATH, 1, char2.get_x(), char2.get_y());
//     assert(ev1 == ev1_should, f"event 1: {ev1} != {ev1_should}");
//     let ev2 = result.value[2];
//     let ev2_should = build_value_event(RECEIVE_DAMAGE, 2, char3.get_x(), char3.get_y(), 64);
//     assert(ev2 == ev2_should, f"event 2: {ev2} != {ev2_should}");
//     assert(result.value[3] == 0);
//     assert(result.value[4] == 0);
//     assert(result.value[5] == 0);
//     assert(result.value[6] == 0);
//     assert(result.value[7] == 0);
// }

// // TODO: handle multiple traps on the same field!
// fn handle_trigger_trap(game: &mut Game, my_char: &mut Character, x: u8, y: u8, value: u8) -> Result<Field> {
//     // let my_char_result = game.get_my_char(actor_id);
//     // //if !my_char_result.success { false }
//     let mut success = true; //my_char_result.success;
//     // let my_char = my_char_result.value;
//     let mut found: u8 = 0;
//     let mut not_found: u8 = 1;

//     let traps_count = game.get_their_trap_count();
//     for j in 0..MAX_TRAPS {
//         let mut trap_result = game.get_their_trap(j);
//         if j < traps_count {
//             success &= trap_result.success;
//             // if !trap_result.success { false }
//             let mut trap = trap_result.value;

//             if (trap.x == x) & (trap.y == y) & (*trap.sprung == 0) {
//                 *trap.sprung = 1;
//                 found = 1;
//                 not_found = 0;
//                 // if !my_char.set_status(0) { false }
//                 // if value >= my_char.get_health() {
//                 //     if !my_char.set_health(0) { false }
//                 //     game.add_event(build_std_event(DEATH, my_char.get_id(), x, y))
//                 // } else {
//                 //     if !my_char.set_health(my_char.get_health() - value) { false }
//                 //     game.add_event(build_value_event(RECEIVE_DAMAGE, my_char.get_id(), x, y, value))
//                 // }
//             }
//         }
//     }
//     let searched_trap_count = game.searched_trap_count;
//     let next_trap_pos = TRAPS_BUFFER_MASK & searched_trap_count;
//     let old_trap = game.searched_traps[next_trap_pos];
//     let mut sprung = not_found | (*old_trap.sprung & found);
//     let perhaps_missing_trap = Trap {
//         x: (x * not_found) | (old_trap.x * found),
//         y: (y * not_found) | (old_trap.y * found),
//         sprung: &mut sprung,
//         damage: (value * not_found) | (old_trap.damage * found),
//     };
//     game.searched_traps[next_trap_pos] = perhaps_missing_trap;
//     (*game).searched_trap_count = searched_trap_count + not_found as u64;

//     // if !found {
//     //     perhaps_missing_trap.x = x;
//     //     perhaps_missing_trap.y = y;
//     //     //*perhaps_missing_trap.sprung = 1;
//     //     perhaps_missing_trap.damage = value;
//     //     //*game.searched_trap_count = searched_trap_count + 1;
//     // }
//     //game.searched_traps[next_trap_pos] = perhaps_missing_trap;
//     //     assert(MAX_TRAPS <= TRAPS_BUFFER_SIZE);
//     //     let tc = *self.searched_trap_count;
//     //     self.searched_traps[tc & TRAPS_BUFFER_MASK] = trap;
//     //     *self.searched_trap_count = tc + 1;
//     //     tc < MAX_TRAPS
//     // let mut perhaps_missing_trap = Trap { x: x, y: y, sprung: &mut 1, damage: value };
//     // if !found {
//     //     success &= game.add_their_trap(perhaps_missing_trap);
//     // }

//     success &= (found == 1) | (searched_trap_count < MAX_TRAPS);
//     success &= my_char.set_status(0);
//     if value >= my_char.get_health() {
//         //success &= my_char.set_health(0);
//         //game.add_event(build_std_event(DEATH, my_char.get_id(), x, y))
//         Result {
//             success: success,
//             value: build_std_event(DEATH, my_char.get_id(), x, y)
//         }
//     } else {
//         success &= my_char.set_health(my_char.get_health() - value);
//         if my_char.get_has_been_seen() == 1 {
//             //game.add_event(build_value_event(RECEIVE_DAMAGE, my_char.get_id(), x, y, value))
//             Result {
//                 success: success,
//                 value: build_value_event(RECEIVE_DAMAGE, my_char.get_id(), x, y, value)
//             }
//         } else {
//             Result {
//                 success: success,
//                 value: 0
//             }
//         }
//     }
// }

// #[test]
// fn test_handle_trigger_trap() {
//     let mut game = crate::game::get_test_game();
//     let mut char2 = crate::character::get_test_my_character(1, 2, 3, 4); // game.get_my_char(1).value;

//     let result = handle_trigger_trap(&mut game, &mut char2, char2.get_x(), char2.get_y(), 32);
//     assert(result.success == true);
//     assert(result.value == 0); // we have not been spotted yet!
//     assert(char2.get_health() == 68);

//     assert(char2.set_has_been_seen(1));
//     let result2 = handle_trigger_trap(&mut game, &mut char2, char2.get_x(), char2.get_y(), 32);
//     assert(result2.success == true);
//     assert(result2.value == build_value_event(RECEIVE_DAMAGE, 1, char2.get_x(), char2.get_y(), 32));
//     assert(char2.get_health() == 36);

//     let result3 = handle_trigger_trap(&mut game, &mut char2, char2.get_x(), char2.get_y(), 64);
//     let ev0 = result3.value;
//     let ev0_should = build_std_event(DEATH, 1, char2.get_x(), char2.get_y());
//     assert(ev0 == ev0_should, f"event 3: {ev0} != {ev0_should}");
// }


impl Event {
    fn to_field(self) -> Field {
        std::field::bytes32_to_field([
            0, self.event, self.actor_id, self.x, self.y, self.value, self.subtype, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0
        ])
    }

    fn affects_my_character(self, x: u8, y: u8) -> bool {
        ((self.x == x) & (self.y == y)) | ((self.event == RECEIVE_ATTACK) & (self.subtype == ATTACK_FIREBALL) & is_neighbor(self.x, self.y, x, y))
    }

    fn affects_my_obstacle(self, x: u8, y: u8) -> bool {
        (self.x == x) & (self.y == y)
    }

    fn may_affect_my_other_characters(self) -> bool {
        (self.event == RECEIVE_ATTACK) & (self.subtype == ATTACK_FIREBALL)
    }

    fn may_affect_my_obstacles(self) -> bool {
        self.event == RECEIVE_ATTACK
    }

    // pub fn apply_as_friendly_fire(self, character: Character) -> Character {
    //     assert(self.affects_my_character(character.get_x(), character.get_y()));
    //     let damage = 
    //     let mut new_char = character;
    //     if self.event == RECEIVE_ATTACK {
    //         let new_health = character.get_health() - self.value;
    //         new_char.set_health(new_health);
    //     }
    //     new_char
    // }

    // pub fn get_damage_to_obstacle(self, x: u8, y: u8) -> u8 {
    //     let mut damage = 0;
    //     let subtype = self.subtype;
    //     if (self.event == RECEIVE_ATTACK) & (self.x == x) & (self.y == y) {
    //         if subtype == ATTACK_MELEE {
    //             damage = self.value / 2;
    //         } else if subtype == ATTACK_RANGED {
    //             damage = self.value / 10;
    //         } else if subtype == ATTACK_FIREBALL {
    //             if (self.x == x) & (self.y == y) {
    //                 // TODO: Moar spells
    //                 damage = self.value / 4 * 3;
    //             } else if (is_neighbor(self.x, self.y, x, y)) {
    //                 damage = self.value / 4;
    //             }
    //         } else {
    //             assert(1 == 2, f"Unknown attack subtype {subtype}");
    //         }
    //     }
    //     damage
    // }

    /**
    * For now we will only take class into account.
    */
    pub fn get_applied_damage(self, x: u8, y: u8, tile: u8) -> u16 {
        let mut damage = 0;
    
        if self.event == RECEIVE_ATTACK {
            if (self.x == x) & (self.y == y) {
                damage = get_attack_damage_to_tile(self.subtype, self.value as u16, tile);
            } else if (self.subtype == ATTACK_FIREBALL) & is_neighbor(self.x, self.y, x, y) {
                damage = get_attack_damage_to_tile(self.subtype, self.value as u16, tile) / 2;
            }
        }
        if self.event == TRIGGERED_TRAP {
            damage = get_trap_damage_to_tile(self.value as u16, tile);
        }
        damage as u16
    }

    // fn process(self, game: &mut Game) -> bool {
    //     let mut result = true;
    //         assert(self.actor_id < 5);
    //     let actor = game.their_chars[self.actor_id];
    //     if self.event >= EVENT_COUNT { result = false; }
    //     if self.event == NO_EVENT {
    //         result = true;
    //     }
    //     if self.event == SEE_MOVE {
    //         let is_neighbor_result = Map::is_neighbor(actor.get_x(), actor.get_y(), self.x, self.y);
    //         if is_neighbor_result.success {
    //             if is_neighbor_result.value {
    //                 let can_move_to = game.map.can_move_to(self.x, self.y);
    //                 if can_move_to.success & can_move_to.value {
    //                     result = actor.set_pos(self.x, self.y);
    //                 }
    //             }
    //         }
    //         //let actor_result = game.get_their_char(self.actor_id);
    //         // assert(actor_result.success);
    //     // let mut result = false;
    //     // if actor_id < 5 {
    //     //     let mut actor_result = game.get_their_char(actor_id);
    //     //     if actor_result.success {
    //     //         let mut actor = actor_result.value;
    //     //         let is_neighbor_result = Map::is_neighbor(actor.get_x(), actor.get_y(), x, y);
    //     //         if is_neighbor_result.success {
    //     //             if is_neighbor_result.value {
    //     //                 let can_move_to = game.map.can_move_to(x, y);
    //     //                 if can_move_to.success & can_move_to.value {
    //     //                     result = actor.set_pos(x, y);
    //     //                     //result = true;
    //     //                 }
    //     //             }
    //     //         }
    //     //     }
    //     // }
    //     // result
    //         //assert(game.handle_see_move(self.actor_id, self.x, self.y));
    //         // let trap_dmg = get_accumulated_trap_damage(game, self.x, self.y);
    //         // if trap_dmg > 0 {
    //         //     result &= game.add_event(build_value_event(TRIGGERED_TRAP, self.actor_id, self.x, self.y, trap_dmg));
    //         // }
    //     }
        // if (self.event == SEE_RITUAL) | (self.event == SEE_CAST) | (self.event == SEE_DRAW) {
        //     result &= handle_see_progress(game, self.actor_id, self.value);
        // }
        // if self.event == SEE_SEARCH_TRAP {
        //     let result_event = handle_see_search_trap(*game, self.actor_id, self.x, self.y);
        //     if result_event != 0 {
        //         result &= game.add_event(result_event);
        //     }
        // }
        // if self.event == RECEIVE_ATTACK {
        //     let result_event = handle_receive_attack(game.my_chars, game.map, self.x, self.y, self.value, self.subtype);
        //     if result_event.success {
        //         for i in 0..8 {
        //             if result_event.value[i] != 0 {
        //                 result &= game.add_event(result_event.value[i]);
        //             }
        //         }
        //     } else {
        //         result = false;
        //     }
        // }
        // if self.event == TRIGGERED_TRAP { // actor_id = my_char when receive
        //     let result_event = handle_trigger_trap(game, game.my_chars[self.actor_id], self.x, self.y, self.value);
        //     if result_event.success {
        //         result &= game.add_event(result_event.value);
        //     } else {
        //         result = false;
        //     }
        // }
        // if self.event == WIN {
        //     for i in 0..5 {
        //         // let my_char_result = Game::get_my_char(*game, i);
        //         // if !my_char_result.success { false }
        //         // let my_char = my_char_result.value;
        //         let my_char = game.my_chars[i];

        //         if (my_char.get_health() > 0) {
        //             false //the other one cheated, I did not lose, I still got alive characters!
        //         }
        //     }
        //     result &= game.lose();
        // }
        // if self.event == FOUND_TRAP { // actor_id = my_char when receive
        //     result &= game.add_their_trap(Trap { x: self.x, y: self.y, sprung: &mut 0, damage: self.value });
        // }
        // if self.event == SEE_CHARS { // actor_id = their_char when receive, got health & class
        //     let their_char_result = game.get_their_char(self.actor_id);
        //     result = their_char_result.success;
        //     let their_char = their_char_result.value;

        //     result &= their_char.get_has_been_seen() == 0;
        //     result &= their_char.set_health(self.value);
        //     result &= their_char.set_class(self.subtype);
        // }
        // if self.event == RECEIVE_DAMAGE { // actor_id = their_char when receive
        //     let their_char_result = game.get_their_char(self.actor_id);
        //     let their_health = their_char_result.value.get_health();

        //     if their_health <= self.value {
        //         result = false; // something is off
        //     } else {
        //         result = their_char_result.success & their_char_result.value.set_health(their_health - self.value);
        //     }
        // }
        // if self.event == DESTROY { // actor_id = tile
        //     result = game.set_tile(self.x, self.y, EMPTY);
        // }
        // if self.event == DEATH { // actor_id = their_char when receive
        //     let their_char_result = game.get_their_char(self.actor_id);
        //     result = their_char_result.success & their_char_result.value.set_health(0);
        // }
    //     result
    // }

    fn from_field(field: Field) -> Event {
        let split = field.to_be_bytes(32);
        Event {
            event: split[1],
            actor_id: split[2],
            x: split[3],
            y: split[4],
            value: split[5],
            subtype: split[6],
        }
    }
}

pub fn build_std_event(event: u8, actor_id: u8, x: u8, y: u8) -> Event {
    Event {
        event: event,
        actor_id: actor_id,
        x: x,
        y: y,
        value: 0,
        subtype: 0,
    }
}

pub fn build_value_event(event: u8, actor_id: u8, x: u8, y: u8, value: u8) -> Event {
    Event {
        event: event,
        actor_id: actor_id,
        x: x,
        y: y,
        value: value,
        subtype: 0,
    }
}

pub fn build_subtype_value_event(event: u8, actor_id: u8, x: u8, y: u8, value: u8, subtype: u8) -> Event {
    Event {
        event: event,
        actor_id: actor_id,
        x: x,
        y: y,
        value: value,
        subtype: subtype,
    }
}

pub fn build_test_std_event(event: u8, actor_id: u8, x: u8, y: u8) -> Field {
    std::field::bytes32_to_field([
        0, event, actor_id, x, y, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0
    ])
}

pub fn build_test_value_event(event: u8, actor_id: u8, x: u8, y: u8, value: u8) -> Field {
    std::field::bytes32_to_field([
        0, event, actor_id, x, y, value, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0
    ])
}

pub fn build_test_subtype_value_event(event: u8, actor_id: u8, x: u8, y: u8, value: u8, subtype: u8) -> Field {
    std::field::bytes32_to_field([
        0, event, actor_id, x, y, value, subtype, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0
    ])
}

// pub fn parse_event(event: Field) -> Event {
//     let split = event.to_be_bytes(32);
//     Event {
//         event: split[1],
//         actor_id: split[2],
//         x: split[3],
//         y: split[4],
//         value: split[5],
//         subtype: split[6],
//     }
// }

// #[test]
// fn test_build_std_event() {
//     let event = build_std_event(SEE_MOVE, 1, 2, 3);
//     let parsed = parse_event(event);
//     assert(parsed.event == SEE_MOVE);
//     assert(parsed.actor_id == 1);
//     assert(parsed.x == 2);
//     assert(parsed.y == 3);
// }

// #[test]
// fn test_build_value_event() {
//     let event = build_value_event(RECEIVE_DAMAGE, 1, 2, 3, 4);
//     let parsed = parse_event(event);
//     assert(parsed.event == RECEIVE_DAMAGE);
//     assert(parsed.actor_id == 1);
//     assert(parsed.x == 2);
//     assert(parsed.y == 3);
//     assert(parsed.value == 4);
// }

// #[test]
// fn test_build_subtype_value_event() {
//     let event = build_subtype_value_event(SEE_CAST, 1, 2, 3, 4, 5);
//     let parsed = parse_event(event);
//     assert(parsed.event == SEE_CAST);
//     assert(parsed.actor_id == 1);
//     assert(parsed.x == 2);
//     assert(parsed.y == 3);
//     assert(parsed.value == 4);
//     assert(parsed.subtype == 5);
// }

// #[test]
// fn test_event_no_event() {
//     let mut game = crate::game::get_test_game();
//     //let my_chars = crate::game::get_test_my_chars();
//     let event = Event {
//         event: NO_EVENT,
//         actor_id: 0,
//         x: 0,
//         y: 0,
//         value: 0,
//         subtype: 0,
//     };
//     assert(event.event == NO_EVENT);
//     let result = event.process(&mut game);
//     assert(result == true);
// }