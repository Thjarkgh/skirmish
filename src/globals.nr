// // MAP
// pub fn get_max_width() -> u8 { 32 }
// pub fn get_max_height() -> u8 { 10 }

// // CLASSES
// pub fn get_unknown_class() -> u8 { 0 }
// pub fn get_archer() -> u8 { 1 }
// pub fn get_ritualist() -> u8 { 2 }
// pub fn get_rogue() -> u8 { 3 }
// pub fn get_knight() -> u8 { 4 }
// pub fn get_mage() -> u8 { 5 }
// pub fn get_class_count() -> u8 { 6 }
// // global UNKNOWN_CLASS = 0 as u8;
// // global ARCHER = 1 as u8;
// // global RITUALIST = 2 as u8;
// // global ROGUE = 3 as u8;
// // global KNIGHT = 4 as u8;
// // global MAGE = 5 as u8;
// // global CLASS_COUNT = 6 as u8;

// // ACTIONS
// pub fn get_wait() -> u8 { 0 }
// pub fn get_sneak() -> u8 { 1 }
// pub fn get_move() -> u8 { 2 }
// pub fn get_ritual() -> u8 { 3 }
// pub fn get_search() -> u8 { 4 }
// pub fn get_attack() -> u8 { 5 }
// pub fn get_set_trap() -> u8 { 6 }
// pub fn get_cast_fireball() -> u8 { 7 }
// pub fn get_draw() -> u8 { 8 }
// pub fn get_trigger_trap() -> u8 { 9 }
// pub fn get_action_count() -> u8 { 10 }

// // global WAIT = 0 as u8;
// // global SNEAK = 1 as u8;
// // global MOVE = 2 as u8;
// // global RITUAL = 3 as u8;
// // global SEARCH = 4 as u8;
// // global ATTACK = 5 as u8;
// // global SET_TRAP = 6 as u8;
// // global CAST_FIREBALL = 7 as u8;
// // global DRAW = 8 as u8;
// // global TRIGGER_TRAP = 9 as u8;
// // global ACTION_COUNT = 10 as u8;

// // EVENTS
// pub fn get_no_event() -> u8 { 0 }
// pub fn get_see_move() -> u8 { 1 }
// pub fn get_see_ritual() -> u8 { 2 }
// pub fn get_see_search_trap() -> u8 { 3 }
// pub fn get_receive_attack() -> u8 { 4 }
// pub fn get_see_cast() -> u8 { 5 }
// pub fn get_see_draw() -> u8 { 6 }
// pub fn get_triggered_trap() -> u8 { 7 }
// pub fn get_win() -> u8 { 8 }
// pub fn get_found_trap() -> u8 { 9 }
// pub fn get_see_chars() -> u8 { 10 }
// pub fn get_event_count() -> u8 { 11 }

// // global NO_EVENT = 0  as u8;
// // global SEE_MOVE = 1  as u8;
// // global SEE_RITUAL = 2  as u8;
// // global SEE_SEARCH_TRAP = 3  as u8;
// // global RECEIVE_ATTACK = 4  as u8;
// // global SEE_CAST = 5 as u8;
// // global SEE_DRAW = 6 as u8;
// // global TRIGGERED_TRAP = 7 as u8;
// // global WIN = 8 as u8;
// // global FOUND_TRAP = 9 as u8;
// // global SEE_CHARS = 10 as u8;
// // global EVENT_COUNT = 11 as u8;

// // ATTACKS
// pub fn get_attack_melee() -> u8 { 0 }
// pub fn get_attack_ranged() -> u8 { 1 }
// pub fn get_attack_fireball() -> u8 { 2 }
// pub fn get_attack_count() -> u8 { 3 }

// // global ATTACK_MELEE = 0 as u8;
// // global ATTACK_RANGED = 1 as u8;
// // global ATTACK_FIREBALL = 2 as u8;
// // global ATTACK_COUNT = 3 as u8;

// // TILES
// pub fn get_tile_empty() -> u8 { 0 }
// pub fn get_tile_unknown_class() -> u8 { get_unknown_class() }
// pub fn get_tile_archer() -> u8 { get_archer() }
// pub fn get_tile_ritualist() -> u8 { get_ritualist() }
// pub fn get_tile_rogue() -> u8 { get_rogue() }
// pub fn get_tile_knight() -> u8 { get_knight() }
// pub fn get_tile_mage() -> u8 { get_mage() }
// pub fn get_tile_wall() -> u8 { 6 }
// pub fn get_tile_water() -> u8 { 7 }
// pub fn get_tile_flag() -> u8 { 8 }
// pub fn get_tile_trap() -> u8 { 9 }
// pub fn get_tile_trap_used() -> u8 { 10 }
// pub fn get_tile_body() -> u8 { 11 }
// pub fn get_tile_body_looted() -> u8 { 12 }
// pub fn get_tile_fog() -> u8 { 15 }

// // global EMPTY = 0 as u8;
// // global WALL = 6 as u8;
// // global WATER = 7 as u8;
// // global FLAG = 8 as u8;
// // global TRAP = 9 as u8;
// // global TRAP_USED = 10 as u8;
// // global BODY = 11 as u8;
// // global BODY_LOOTED = 12 as u8;
// // global FOG = 15 as u8;

// // STATUS
// pub fn get_status_count() -> u8 { 16 }
// //global STATUS_COUNT = 16  as u8; // just to be more in line with the other constants, actually used as a counter