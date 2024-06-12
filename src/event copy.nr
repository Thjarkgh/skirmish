// use crate::game::Game;
// use crate::character::Character;
// use crate::EVENT_COUNT;
// use crate::NO_EVENT;
// use crate::SEE_MOVE;
// use crate::SEE_RITUAL;
// use crate::SEE_CAST;
// use crate::SEE_DRAW;
// use crate::SEE_SEARCH_TRAP;
// use crate::RECEIVE_ATTACK;
// use crate::TRIGGERED_TRAP;
// use crate::WIN;
// use crate::FOUND_TRAP;
// use crate::SEE_CHARS;
// use crate::RECEIVE_DAMAGE;
// use crate::DESTROY;
// use crate::DEATH;
// use crate::MAX_TRAPS;
// use crate::map::Map;
// use crate::trap::Trap;
// use crate::WALL;
// use crate::EMPTY;
// use crate::ATTACK_FIREBALL;
// use crate::Result;
// use dep::std;

// // trait Event {
// //     fn to_field(self) -> Field;
// //     fn process<T, U>(self, game: &mut T) where U: Character, T: Game<U>;
// // }

// struct Event {
//     event: u8,
//     actor_id: u8,
//     subtype: u8,
//     x: u8,
//     y: u8,
//     value: u8,
// }

// fn handle_see_move(game: &mut Game, actor_id: u8, x: u8, y: u8) -> bool {
//     let mut result = false;
//     if actor_id < 5 {
//         let mut actor_result = game.get_their_char(actor_id);
//         if actor_result.success {
//             let mut actor = actor_result.value;
//             let is_neighbor_result = Map::is_neighbor(actor.get_x(), actor.get_y(), x, y);
//             if is_neighbor_result.success {
//                 if is_neighbor_result.value {
//                     let can_move_to = game.map.can_move_to(x, y);
//                     if can_move_to.success & can_move_to.value {
//                         result = actor.set_pos(x, y);
//                         //result = true;
//                     }
//                 }
//             }
//         }
//     }
//     result
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

// fn handle_see_progress(game: &mut Game, actor_id: u8, value: u8) -> bool {
//     let mut result = false;
//     if actor_id < 5 {
//         let mut actor_result = Game::get_their_char(*game, actor_id);
//         if actor_result.success {
//             let mut actor = actor_result.value;
//             if (actor.get_status() == 0) | (actor.get_status() + 1 == value) {
//                 result = actor.set_status(*actor.status + 1);
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
//     assert(game.add_my_trap(Trap { x: 1, y: 2, sprung: 0, damage: 64 }));
//     let result = handle_see_search_trap(game, 0, 1, 2);
//     assert(result != 0);
    
//     let not_found = handle_see_search_trap(game, 0, 2, 2);
//     assert(not_found == 0);
// }

// fn handle_receive_attack(game: Game, x: u8, y: u8, dmg: u8, subtype: u8) -> Result<[Field; 8]> {
//     let mut success = true;
//     let mut event_counter = 0;
//     let mut result: [Field; 8] = [0; 8];
//     let splash_dmg: u8 = dmg >> 1;
//     for j in 0..5 {
//         let my_char_result = game.get_my_char(j);
//         success &= my_char_result.success;
//         let my_char = my_char_result.value;

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
//                 result[event_counter & 7] = build_value_event(RECEIVE_DAMAGE, j, x, y, dmg);
//                 event_counter += 1;
//             // }
//         } else {
//             if subtype == ATTACK_FIREBALL {
//                 let is_neighbor_result = Map::is_neighbor(my_char.get_x(), my_char.get_y(), x, y);
//                 success &= is_neighbor_result.success;
//                 if is_neighbor_result.value {
//                     // if !Character::set_status(my_char, 0) { false }
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
//                         result[event_counter & 7] = build_value_event(RECEIVE_DAMAGE, j, my_char.get_x(), my_char.get_y(), splash_dmg);
//                         event_counter += 1;
//                     // }
//                 }
//             }
//         }
//     }

//     let tile_result = game.get_tile(x, y);
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
//     let char1 = game.get_my_char(0).value;
//     let char2 = game.get_my_char(1).value;
//     let char3 = game.get_my_char(2).value;

//     let result = handle_receive_attack(game, char2.get_x(), char2.get_y(), 128, ATTACK_FIREBALL);
//     assert(result.success == true);
//     let ev0 = result.value[0];
//     let ev0_should = build_value_event(RECEIVE_DAMAGE, 0, char1.get_x(), char1.get_y(), 64);
//     assert(ev0 == ev0_should, f"event 0: {ev0} != {ev0_should}");
//     let ev1 = result.value[1];
//     let ev1_should = build_value_event(RECEIVE_DAMAGE, 1, char2.get_x(), char2.get_y(), 128); //build_std_event(DEATH, 1, char2.get_x(), char2.get_y());
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

// impl Event {
//     fn to_field(self) -> Field {
//         build_std_event(self.event, self.actor_id, self.x, self.y)
//     }

//     fn process(self, game: &mut Game) -> bool {
//         let mut result = false;
//         if self.event >= EVENT_COUNT { result = false; }
//         if self.event == NO_EVENT {
//             result = true;
//         }
//         if self.event == SEE_MOVE {
//             result = handle_see_move(game, self.actor_id, self.x, self.y);
//         }
//         if (self.event == SEE_RITUAL) | (self.event == SEE_CAST) | (self.event == SEE_DRAW) {
//             result = handle_see_progress(game, self.actor_id, self.value);
//         }
//         if self.event == SEE_SEARCH_TRAP {
//             let result_event = handle_see_search_trap(*game, self.actor_id, self.x, self.y);
//             if result_event != 0 {
//                 result = game.add_event(result_event);
//             }
//         }
//         if self.event == RECEIVE_ATTACK {
//             // for j in 0..5 {
//             //     let my_char_result = Game::get_my_char(*game, j);
//             //     if !my_char_result.success { false }
//             //     let my_char = my_char_result.value;

//             //     if (my_char.get_x() == self.x) & (my_char.get_y() == self.y) { /////////////events and actions: rethink the be/le stuff!
//             //         if !my_char.set_status(0) { false }
//             //         if self.value >= my_char.get_health() {
//             //             if !my_char.set_health(0) { false }
//             //             let add_event_result = game.add_event(build_std_event(DEATH, j, self.x, self.y));
//             //             if !add_event_result { false }
//             //         } else {
//             //             if !Character::set_health(my_char, my_char.get_health() - self.value) { false }
//             //             let add_event_result = game.add_event(build_value_event(RECEIVE_DAMAGE, j, self.x, self.y, self.value));
//             //             if !add_event_result { false }
//             //         }
//             //     }

//             //     if self.subtype == ATTACK_FIREBALL {
//             //         let is_neighbor_result = Map::is_neighbor(my_char.get_x(), my_char.get_y(), self.x, self.y);
//             //         if !is_neighbor_result.success { false }
//             //         if is_neighbor_result.value {
//             //             if !Character::set_status(my_char, 0) { false }
//             //             let dmg = self.value >> 1;
//             //             if dmg >= my_char.get_health() {
//             //                 if !Character::set_health(my_char, 0) { false }
//             //                 let add_event_result = game.add_event(build_std_event(DEATH, j, self.x, self.y));
//             //                 if !add_event_result { false }
//             //             } else {
//             //                 if !Character::set_health(my_char, my_char.get_health() - dmg) { false }
//             //                 let add_event_result = game.add_event(build_value_event(RECEIVE_DAMAGE, j, self.x, self.y, dmg));
//             //                 if !add_event_result { false }
//             //             }
//             //         }
//             //     }
//             // }

//             // let tile_result = (*game).get_tile(self.x, self.y);
//             // if !tile_result.success { false }
//             // let tile = tile_result.value;
//             // if tile == WALL {
//             //     if !game.set_tile(self.x, self.y, EMPTY) { false }
//             //     if !game.add_event(build_std_event(DESTROY, tile, self.x, self.y)) { false }
//             // }
//             true
//         }
//         if self.event == TRIGGERED_TRAP { // actor_id = my_char when receive
//             let my_char_result = Game::get_my_char(*game, self.actor_id);
//             if !my_char_result.success { false }
//             let my_char = my_char_result.value;

//             let traps_count = (*game).get_their_trap_count() as u64;
//             for j in 0..MAX_TRAPS {
//                 if j < traps_count {
//                     let mut trap_result = (*game).get_their_trap(j);
//                     if !trap_result.success { false }
//                     let mut trap = trap_result.value;

//                     if (trap.x == self.x) & (trap.y == self.y) & (trap.sprung == 0) {
//                         trap.sprung = 1;
//                         if !my_char.set_status(0) { false }
//                         if self.value >= my_char.get_health() {
//                             if !my_char.set_health(0) { false }
//                             game.add_event(build_std_event(DEATH, my_char.get_id(), self.x, self.y))
//                         } else {
//                             if !my_char.set_health(my_char.get_health() - self.value) { false }
//                             game.add_event(build_value_event(RECEIVE_DAMAGE, my_char.get_id(), self.x, self.y, self.value))
//                         }
//                     }
//                 }
//             }
//             if !game.add_their_trap(Trap { x: self.x, y: self.y, sprung: 1, damage: self.value }) { false }
//             if !my_char.set_status(0) { false }
//             if self.value >= my_char.get_health() {
//                 if !my_char.set_health(0) { false }
//                 game.add_event(build_std_event(DEATH, my_char.get_id(), self.x, self.y))
//             } else {
//                 if !my_char.set_health(my_char.get_health() - self.value) { false }
//                 if my_char.get_has_been_seen() == 1 {
//                     game.add_event(build_value_event(RECEIVE_DAMAGE, my_char.get_id(), self.x, self.y, self.value))
//                 }
//                 true
//             }
//         }
//         if self.event == WIN {
//             for i in 0..5 {
//                 let my_char_result = Game::get_my_char(*game, i);
//                 if !my_char_result.success { false }
//                 let my_char = my_char_result.value;

//                 if (my_char.get_health() > 0) {
//                     false //the other one cheated, I did not lose, I still got alive characters!
//                 }
//             }
//             game.lose()
//         }
//         if self.event == FOUND_TRAP { // actor_id = my_char when receive
//             game.add_their_trap(Trap { x: self.x, y: self.y, sprung: 0, damage: self.value })
//         }
//         if self.event == SEE_CHARS { // actor_id = their_char when receive, got health & class
//             let their_char_result = Game::get_their_char(*game, self.actor_id);
//             if !their_char_result.success { false }
//             let their_char = their_char_result.value;

//             if !their_char.set_health(self.value) { false }
//             their_char.set_class(self.subtype)
//         }
//         if self.event == RECEIVE_DAMAGE { // actor_id = their_char when receive
//             let their_char_result = Game::get_their_char(*game, self.actor_id);
//             if !their_char_result.success { false }
//             let their_char = their_char_result.value;

//             if their_char.get_health() <= self.value {
//                 false // something is off
//             } else {
//                 their_char.set_health(their_char.get_health() - self.value)
//             }
//         }
//         if self.event == DESTROY { // actor_id = tile
//             game.set_tile(self.x, self.y, EMPTY)
//         }
//         if self.event == DEATH { // actor_id = their_char when receive
//             let their_char_result = Game::get_their_char(*game, self.actor_id);
//             if !their_char_result.success { false }
//             let their_char = their_char_result.value;

//             their_char.set_health(0)
//         } else {
//             false
//         }
//     }
// }

// pub fn build_std_event(event: u8, actor_id: u8, x: u8, y: u8) -> Field {
//     std::field::bytes32_to_field([
//         0, event, actor_id, x, y, 0, 0, 0,
//         0, 0, 0, 0, 0, 0, 0, 0,
//         0, 0, 0, 0, 0, 0, 0, 0,
//         0, 0, 0, 0, 0, 0, 0, 0
//     ])
// }

// pub fn build_value_event(event: u8, actor_id: u8, x: u8, y: u8, value: u8) -> Field {
//     std::field::bytes32_to_field([
//         0, event, actor_id, x, y, value, 0, 0,
//         0, 0, 0, 0, 0, 0, 0, 0,
//         0, 0, 0, 0, 0, 0, 0, 0,
//         0, 0, 0, 0, 0, 0, 0, 0
//     ])
// }

// pub fn build_subtype_value_event(event: u8, actor_id: u8, x: u8, y: u8, value: u8, subtype: u8) -> Field {
//     std::field::bytes32_to_field([
//         0, event, actor_id, x, y, value, subtype, 0,
//         0, 0, 0, 0, 0, 0, 0, 0,
//         0, 0, 0, 0, 0, 0, 0, 0,
//         0, 0, 0, 0, 0, 0, 0, 0
//     ])
// }

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
//     // let eventType = split[0];
//     // if event == SEE_MOVE {
//     //     // TODO: I would like to only reveal class once line of sight has been established: todo for later
//     //     assert(split[1] < 5);
//     //     assert_neighbor(their_chars[split[1]], split[2], split[3]);
//     //     their_chars[split[1]].x = split[2];
//     //     their_chars[split[1]].y = split[3];
//     // } else if event == SEE_RITUAL {
//     //     their_chars[split[1]].status += 1;
//     // } else if event == SEE_SEARCH_TRAP {
//     //     for j in 0..10 {
//     //         if j < my_traps.len() {
//     //             if (my_traps[j].x == split[2]) & (my_traps[j].y == split[3]) {
//     //                 assert(actions.any(|a| {
//     //                     let s = a.to_be_bytes(32);
//     //                     (s[0] == TRIGGER_TRAP) & (s[1] == split[1]) & (s[2] == split[2]) & (s[3] == split[3])
//     //                 }));
//     //             }
//     //         }
//     //     }
//     // } else if event == RECEIVE_ATTACK {
//     //     for j in 0..5 {
//     //         if (my_chars[j].x == ) /////////////events and actions: rethink the be/le stuff!
//     //     }
//     // }
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
// ///////////////////////////////
// // pub fn build_std_event(event: u8, actor_id: u8, x: u8, y: u8) -> Field {
// //     let result = ((event as u64 << 24) | (actor_id as u64 << 16) | (x as u64 << 8) | (y as u64));
// //     result as Field
// // }

// // trait Event {
// //     fn to_field(self) -> Field;
// //     fn process(self, game: &mut impl crate::game::Game);
// // }

// // struct StdEvent {
// //     event: u8,
// //     actor_id: u8,
// //     x: u8,
// //     y: u8,
// // }

// // impl Event for StdEvent {
// //     fn to_field(self) -> Field {
// //         build_std_event(self.event, self.actor_id, self.x, self.y)
// //     }

// //     fn process(self, game: &mut impl crate::game::Game) {
// //         if self.event == crate::globals::SEE_MOVE {
// //             assert(self.actor_id < 5);
// //             assert_neighbor(game.their_chars[self.actor_id], self.x, self.y);
// //             game.their_chars[self.actor_id].x = self.x;
// //             game.their_chars[self.actor_id].y = self.y;
// //         } else if self.event == crate::globals::SEE_RITUAL {
// //             game.their_chars[self.actor_id].status += 1;
// //         } else if self.event == crate::globals::SEE_SEARCH_TRAP {
// //             for j in 0..10 {
// //                 if j < game.my_traps.len() {
// //                     if (game.my_traps[j].x == self.x) & (game.my_traps[j].y == self.y) {
// //                         assert(game.actions.any(|a| {
// //                             let s = a.to_be_bytes(32);
// //                             (s[0] == crate::globals::TRIGGER_TRAP) & (s[1] == self.actor_id) & (s[2] == self.x) & (s[3] == self.y)
// //                         }));
// //                     }
// //                 }
// //             }
// //         } else if self.event == crate::globals::RECEIVE_ATTACK {
// //             for j in 0..5 {
// //                 if (game.my_chars[j].x == ) /////////////events and actions: rethink the be/le stuff!
// //             }
// //         }
// //     }
// // }

// // pub fn parse_event(event: Field) -> Event {
// //     let split = event.to_be_bytes(32);
// //     let eventType = split[0];
// //     if event == crate::globals::SEE_MOVE {
// //         // TODO: I would like to only reveal class once line of sight has been established: todo for later
// //         assert(split[1] < 5);
// //         assert_neighbor(their_chars[split[1]], split[2], split[3]);
// //         their_chars[split[1]].x = split[2];
// //         their_chars[split[1]].y = split[3];
// //     } else if event == crate::globals::SEE_RITUAL {
// //         their_chars[split[1]].status += 1;
// //     } else if event == crate::globals::SEE_SEARCH_TRAP {
// //         for j in 0..10 {
// //             if j < my_traps.len() {
// //                 if (my_traps[j].x == split[2]) & (my_traps[j].y == split[3]) {
// //                     assert(actions.any(|a| {
// //                         let s = a.to_be_bytes(32);
// //                         (s[0] == crate::globals::TRIGGER_TRAP) & (s[1] == split[1]) & (s[2] == split[2]) & (s[3] == split[3])
// //                     }));
// //                 }
// //             }
// //         }
// //     } else if event == crate::globals::RECEIVE_ATTACK {
// //         for j in 0..5 {
// //             if (my_chars[j].x == ) /////////////events and actions: rethink the be/le stuff!
// //         }
// //     }
// // }