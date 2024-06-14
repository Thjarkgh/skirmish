mod action;
use action::Action;
mod character;
use character::Character;
use character::parse_characters;
mod event;
use event::Event;
mod obstacle;
use obstacle::Obstacle;
mod map;
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
global MOVE = 2 as u8;          // => SEE_MOVE
global RITUAL = 3 as u8;        // => SEE_RITUAL | WIN
global SEARCH = 4 as u8;        // => SEE_SEARCH_TRAP
global ATTACK = 5 as u8;        // => RECEIVE_ATTACK | DESTROY // affects my obstacles; TODO: with more attack types might also affect other own characters
global SET_TRAP = 6 as u8;
global CAST_FIREBALL = 7 as u8; // => SEE_CAST | SEE_SPELL | DESTROY // affects other characters if status == FIREBALL_ROUNDS_FOR_CAST
global DRAW = 8 as u8;          // => SEE_DRAW
//global TRIGGER_TRAP = 9 as u8;  // => TRIGGERED_TRAP ?????????
global DISARM_TRAP = 10 as u8;  // => DESTROY
global ACTION_COUNT = 11 as u8;

// EVENTS
global NO_EVENT = 0  as u8;
global DESTROY = 1 as u8;          // actor_id = their_char or their_object when receive - use coordinates to determine tile or trap that got destroyed and update map
global DISCOVER = 2 as u8;         // actor_id = their_char or their_object when receive - handle to update enemy positions, got health & class (this is for all chars, not just the active one)
global SEE_MOVE = 3  as u8;        // actor_id = their_char or their_object when receive - handle to update enemy positions => DISCOVER
//global SEE_SPELL = 4  as u8;       // actor_id = their_char when receive - need to handle effect via coordinates, => RECEIVE_DAMAGE | DESTROY | LOSE // also need to handle my obstacles
global SEE_SEARCH_TRAP = 5  as u8; // actor_id = their_char when receive - need to create found trap event if there is a trap nearby => FOUND_TRAP
global SEE_RITUAL = 6  as u8;      // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
global SEE_CAST = 7 as u8;         // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
global SEE_DRAW = 8 as u8;         // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
global RECEIVE_DAMAGE = 9 as u8;   // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client
global RECEIVE_ATTACK = 10 as u8;  // actor_id = 0 when receive - need to handle damage => RECEIVE_DAMAGE | DESTROY | LOSE // also need to handle in my obstacles
global TRIGGERED_TRAP = 11 as u8;  // actor_id = my_char when receive - need to handle damage (for now, later on we might want to handle other effects as well) => RECEIVE_DAMAGE
global FOUND_TRAP = 12 as u8;      // actor_id = my_char when receive - no need to handle, only important to have on-chain for the client
global WIN = 13 as u8;
global LOSE = 14 as u8;
global EVENT_COUNT = 15 as u8;

// ATTACKS
global ATTACK_MELEE = 0 as u8;
global ATTACK_RANGED = 1 as u8;
global ATTACK_FIREBALL = 2 as u8;
global ATTACK_COUNT = 3 as u8;
// TODO: instead of enum, use a global array of structs with damage, range, etc.


// TILES
global EMPTY = 0 as u8;
global WALL = 6 as u8;
global WATER = 7 as u8;
global UNKNOWN_CLASS_TILE = 8 as u8;
global NON_EMPTY_WALKABLE_TILE_MIN = 9 as u8;
global FLAG = 9 as u8;
global TRAP = 10 as u8;
global TRAP_USED = 11 as u8;
global TRAP_FOUND = 12 as u8;
global BODY = 13 as u8;
global BODY_LOOTED = 14 as u8;
global FOG = 15 as u8;
global TILE_COUNT = 16 as u8;

// STATUS
global RITUAL_ROUNDS_FOR_WIN = 16 as u8;
global FIREBALL_ROUNDS_FOR_CAST = 3 as u8;
global STATUS_COUNT = 16  as u8; // just to be more in line with the other constants, actually used as a counter

// GAMEPLAY
global MAX_TRAPS = 15; // note: only lowest bit of first byte of field is usable! => ! Field = 1 bit + 31 bytes!
global TRAPS_BUFFER_SIZE = 16;
global TRAPS_BUFFER_MASK = 15; // has to be 2^n - 1
global MAX_ACTIONS = 8;
global MAX_EVENTS = 8;
global EVENTS_BUFFER_SIZE = 8;
global EVENTS_BUFFER_MASK = 7; // has to be 2^n - 1
global MAX_OBSTACLES = 24;
global MAX_CHARACTERS = 5;
global SERIALIZED_OBSTACLES_ARRAY_SIZE = 3; // TODO: (MAX_OBSTACLES + 9) / 10;
global SERIALIZED_OBSTACLES_PER_FIELD = 8; // TODO: need to verify that SERIALIED_OBSTACLES_ARRAY_SIZE * SERIALIZED_OBSTACLES_PER_FIELD = MAX_OBSTACLES!

fn get_actor_from_move(mut move: u32) -> u8 {
    if (move % 2) == 1 {
        move -= 1; //((move % 10) - 1) >> 1 // actually not needed ... but clearer this way
    }
    let single_digit: u32 = (move % 10 as u32) >> 1;
    single_digit as u8
}

fn main(
    // my_char_0: Character,
    // my_char_1: Character,
    // my_char_2: Character,
    // my_char_3: Character,
    // my_char_4: Character,
    // their_char_0: Character,
    // their_char_1: Character,
    // their_char_2: Character,
    // their_char_3: Character,
    // their_char_4: Character,
    // my_chars: Roster,
    // their_chars: Roster,
    // action_0: Action,
    // action_1: Action,
    // action_2: Action,
    // action_3: Action,
    // action_4: Action,
    secret: Field,
    my_chars: Field,
    my_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE],
    enemy_objects: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE + MAX_CHARACTERS],
    actions: [Field; MAX_ACTIONS],
    move: pub u32,
    events: pub [Field; MAX_EVENTS],
    result_events: pub [Field; MAX_EVENTS],
    gamestate_after_hash: pub Field,
    // event_0: pub Event,
    // event_1: pub Event,
    // event_2: pub Event,
    // event_3: pub Event,
    // event_4: pub Event,
    // event_5: pub Event,
    // event_6: pub Event,
    // event_7: pub Event,
) {
    let events: [Event; MAX_EVENTS] = events.map(|event| Event::from_field(event));
    let mut my_char_0 = Character::parse(0, my_chars, events);
    let mut my_char_1 = Character::parse(1, my_chars, events);
    let mut my_char_2 = Character::parse(2, my_chars, events);
    let mut my_char_3 = Character::parse(3, my_chars, events);
    let mut my_char_4 = Character::parse(4, my_chars, events);

    let actor_id = get_actor_from_move(move);
    let mut actor = Character::parse(actor_id, my_chars, events);
    
    let actions = actions.map(|action| Action::from_field(action));
    
    assert(MAX_OBSTACLES == 24);
    let my_obstacles_parsed = parse_obstacles(my_obstacles, events);
    let mut my_obstacle_0 = my_obstacles_parsed[0];
    let mut my_obstacle_1 = my_obstacles_parsed[1];
    let mut my_obstacle_2 = my_obstacles_parsed[2];
    let mut my_obstacle_3 = my_obstacles_parsed[3];
    let mut my_obstacle_4 = my_obstacles_parsed[4];
    let mut my_obstacle_5 = my_obstacles_parsed[5];
    let mut my_obstacle_6 = my_obstacles_parsed[6];
    let mut my_obstacle_7 = my_obstacles_parsed[7];
    let mut my_obstacle_8 = my_obstacles_parsed[8];
    let mut my_obstacle_9 = my_obstacles_parsed[9];
    let mut my_obstacle_10 = my_obstacles_parsed[10];
    let mut my_obstacle_11 = my_obstacles_parsed[11];
    let mut my_obstacle_12 = my_obstacles_parsed[12];
    let mut my_obstacle_13 = my_obstacles_parsed[13];
    let mut my_obstacle_14 = my_obstacles_parsed[14];
    let mut my_obstacle_15 = my_obstacles_parsed[15];
    let mut my_obstacle_16 = my_obstacles_parsed[16];
    let mut my_obstacle_17 = my_obstacles_parsed[17];
    let mut my_obstacle_18 = my_obstacles_parsed[18];
    let mut my_obstacle_19 = my_obstacles_parsed[19];
    let mut my_obstacle_20 = my_obstacles_parsed[20];
    let mut my_obstacle_21 = my_obstacles_parsed[21];
    let mut my_obstacle_22 = my_obstacles_parsed[22];
    let mut my_obstacle_23 = my_obstacles_parsed[23];

    // let mut my_obstacle_0 = Obstacle::parse(0, my_obstacles[0], events);
    // let mut my_obstacle_1 = Obstacle::parse(1, my_obstacles[1], events);
    // let mut my_obstacle_2 = Obstacle::parse(2, my_obstacles[2], events);
    // let mut my_obstacle_3 = Obstacle::parse(3, my_obstacles[3], events);
    // let mut my_obstacle_4 = Obstacle::parse(4, my_obstacles[4], events);
    // let mut my_obstacle_5 = Obstacle::parse(5, my_obstacles[5], events);
    // let mut my_obstacle_6 = Obstacle::parse(6, my_obstacles[6], events);
    // let mut my_obstacle_7 = Obstacle::parse(7, my_obstacles[7], events);
    // let mut my_obstacle_8 = Obstacle::parse(8, my_obstacles[8], events);
    // let mut my_obstacle_9 = Obstacle::parse(9, my_obstacles[9], events);
    // let mut my_obstacle_10 = Obstacle::parse(10, my_obstacles[10], events);
    // let mut my_obstacle_11 = Obstacle::parse(11, my_obstacles[11], events);
    // let mut my_obstacle_12 = Obstacle::parse(12, my_obstacles[12], events);
    // let mut my_obstacle_13 = Obstacle::parse(13, my_obstacles[13], events);
    // let mut my_obstacle_14 = Obstacle::parse(14, my_obstacles[14], events);
    // let mut my_obstacle_15 = Obstacle::parse(15, my_obstacles[15], events);
    // let mut my_obstacle_16 = Obstacle::parse(16, my_obstacles[16], events);
    // let mut my_obstacle_17 = Obstacle::parse(17, my_obstacles[17], events);
    // let mut my_obstacle_18 = Obstacle::parse(18, my_obstacles[18], events);
    // let mut my_obstacle_19 = Obstacle::parse(19, my_obstacles[19], events);
    // let mut my_obstacle_20 = Obstacle::parse(20, my_obstacles[20], events);
    // let mut my_obstacle_21 = Obstacle::parse(21, my_obstacles[21], events);
    // let mut my_obstacle_22 = Obstacle::parse(22, my_obstacles[22], events);
    // let mut my_obstacle_23 = Obstacle::parse(23, my_obstacles[23], events);

    let mut energy: u8 = 12;
    for i in 0..MAX_ACTIONS {
        let action = actions[i];
        let result = action.execute(actor, energy);
        let result_event = result.0;
        actor = result.1;
        energy = result.2;
        
        if result_event.may_affect_my_other_characters() {
            // no mutable arrays, so have to do copy-paste
            let dmg = result_event.get_applied_damage(my_char_0.x, my_char_0.y, my_char_0.class);
            if dmg > (my_char_0.health as u16) {
                my_char_0.health = 0;
            } else if dmg > 0 {
                my_char_0.health -= (dmg as u8);
            }
            let dmg = result_event.get_applied_damage(my_char_1.x, my_char_1.y, my_char_1.class);
            if dmg > (my_char_1.health as u16) {
                my_char_1.health = 0;
            } else if dmg > 0 {
                my_char_1.health -= (dmg as u8);
            }
            let dmg = result_event.get_applied_damage(my_char_2.x, my_char_2.y, my_char_2.class);
            if dmg > (my_char_2.health as u16) {
                my_char_2.health = 0;
            } else if dmg > 0 {
                my_char_2.health -= (dmg as u8);
            }
            let dmg = result_event.get_applied_damage(my_char_3.x, my_char_3.y, my_char_3.class);
            if dmg > (my_char_3.health as u16) {
                my_char_3.health = 0;
            } else if dmg > 0 {
                my_char_3.health -= (dmg as u8);
            }
            let dmg = result_event.get_applied_damage(my_char_4.x, my_char_4.y, my_char_4.class);
            if dmg > (my_char_4.health as u16) {
                my_char_4.health = 0;
            } else if dmg > 0 {
                my_char_4.health -= (dmg as u8);
            }
        }

        if result_event.may_affect_my_obstacles() {
            let dmg = result_event.get_applied_damage(my_obstacle_0.x, my_obstacle_0.y, my_obstacle_0.obstacle_type);
            if dmg > 0 { my_obstacle_0.health = safe_subtract_dmg(my_obstacle_0.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_1.x, my_obstacle_1.y, my_obstacle_1.obstacle_type);
            if dmg > 0 { my_obstacle_1.health = safe_subtract_dmg(my_obstacle_1.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_2.x, my_obstacle_2.y, my_obstacle_2.obstacle_type);
            if dmg > 0 { my_obstacle_2.health = safe_subtract_dmg(my_obstacle_2.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_3.x, my_obstacle_3.y, my_obstacle_3.obstacle_type);
            if dmg > 0 { my_obstacle_3.health = safe_subtract_dmg(my_obstacle_3.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_4.x, my_obstacle_4.y, my_obstacle_4.obstacle_type);
            if dmg > 0 { my_obstacle_4.health = safe_subtract_dmg(my_obstacle_4.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_5.x, my_obstacle_5.y, my_obstacle_5.obstacle_type);
            if dmg > 0 { my_obstacle_5.health = safe_subtract_dmg(my_obstacle_5.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_6.x, my_obstacle_6.y, my_obstacle_6.obstacle_type);
            if dmg > 0 { my_obstacle_6.health = safe_subtract_dmg(my_obstacle_6.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_7.x, my_obstacle_7.y, my_obstacle_7.obstacle_type);
            if dmg > 0 { my_obstacle_7.health = safe_subtract_dmg(my_obstacle_7.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_8.x, my_obstacle_8.y, my_obstacle_8.obstacle_type);
            if dmg > 0 { my_obstacle_8.health = safe_subtract_dmg(my_obstacle_8.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_9.x, my_obstacle_9.y, my_obstacle_9.obstacle_type);
            if dmg > 0 { my_obstacle_9.health = safe_subtract_dmg(my_obstacle_9.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_10.x, my_obstacle_10.y, my_obstacle_10.obstacle_type);
            if dmg > 0 { my_obstacle_10.health = safe_subtract_dmg(my_obstacle_10.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_11.x, my_obstacle_11.y, my_obstacle_11.obstacle_type);
            if dmg > 0 { my_obstacle_11.health = safe_subtract_dmg(my_obstacle_11.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_12.x, my_obstacle_12.y, my_obstacle_12.obstacle_type);
            if dmg > 0 { my_obstacle_12.health = safe_subtract_dmg(my_obstacle_12.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_13.x, my_obstacle_13.y, my_obstacle_13.obstacle_type);
            if dmg > 0 { my_obstacle_13.health = safe_subtract_dmg(my_obstacle_13.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_14.x, my_obstacle_14.y, my_obstacle_14.obstacle_type);
            if dmg > 0 { my_obstacle_14.health = safe_subtract_dmg(my_obstacle_14.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_15.x, my_obstacle_15.y, my_obstacle_15.obstacle_type);
            if dmg > 0 { my_obstacle_15.health = safe_subtract_dmg(my_obstacle_15.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_16.x, my_obstacle_16.y, my_obstacle_16.obstacle_type);
            if dmg > 0 { my_obstacle_16.health = safe_subtract_dmg(my_obstacle_16.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_17.x, my_obstacle_17.y, my_obstacle_17.obstacle_type);
            if dmg > 0 { my_obstacle_17.health = safe_subtract_dmg(my_obstacle_17.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_18.x, my_obstacle_18.y, my_obstacle_18.obstacle_type);
            if dmg > 0 { my_obstacle_18.health = safe_subtract_dmg(my_obstacle_18.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_19.x, my_obstacle_19.y, my_obstacle_19.obstacle_type);
            if dmg > 0 { my_obstacle_19.health = safe_subtract_dmg(my_obstacle_19.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_20.x, my_obstacle_20.y, my_obstacle_20.obstacle_type);
            if dmg > 0 { my_obstacle_20.health = safe_subtract_dmg(my_obstacle_20.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_21.x, my_obstacle_21.y, my_obstacle_21.obstacle_type);
            if dmg > 0 { my_obstacle_21.health = safe_subtract_dmg(my_obstacle_21.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_22.x, my_obstacle_22.y, my_obstacle_22.obstacle_type);
            if dmg > 0 { my_obstacle_22.health = safe_subtract_dmg(my_obstacle_22.health, dmg); }
            let dmg = result_event.get_applied_damage(my_obstacle_23.x, my_obstacle_23.y, my_obstacle_23.obstacle_type);
            if dmg > 0 { my_obstacle_23.health = safe_subtract_dmg(my_obstacle_23.health, dmg); }
        }
    }

    // write-back actor
    if actor_id == 0 { my_char_0 = actor; }
    if actor_id == 1 { my_char_1 = actor; }
    if actor_id == 2 { my_char_2 = actor; }
    if actor_id == 3 { my_char_3 = actor; }
    if actor_id == 4 { my_char_4 = actor; }

    // send death events

    // validate result
    let serialized_characters = serialize_chars([my_char_0, my_char_1, my_char_2, my_char_3, my_char_4]);
    let serialized_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE] = serialize_obstacles([my_obstacle_0, my_obstacle_1, my_obstacle_2, my_obstacle_3, my_obstacle_4, my_obstacle_5, my_obstacle_6, my_obstacle_7, my_obstacle_8, my_obstacle_9, my_obstacle_10, my_obstacle_11, my_obstacle_12, my_obstacle_13, my_obstacle_14, my_obstacle_15, my_obstacle_16, my_obstacle_17, my_obstacle_18, my_obstacle_19, my_obstacle_20, my_obstacle_21, my_obstacle_22, my_obstacle_23]);
    // let serialized_obstacles: [[u8]; SERIALIZED_OBSTACLES_ARRAY_SIZE] = serialized_obstacles.map(|o| Field.to_be_bytes(o, 32));
    let new_hash_bytes = get_data_hash(secret.to_be_bytes(32), serialized_characters.to_be_bytes(32), serialized_obstacles);
    let new_hash = std::field::bytes32_to_field(new_hash_bytes);
    assert(new_hash == gamestate_after_hash, f"{new_hash} != {gamestate_after_hash}");
}

fn get_data_hash(secret: [u8], characters: [u8], obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE]) -> [u8; 32] {
    assert(secret.len() == 32);
    assert(characters.len() == 32);

    let mut data: [u8; 32 + 32 + SERIALIZED_OBSTACLES_ARRAY_SIZE * 32] = [0; 32 + 32 + SERIALIZED_OBSTACLES_ARRAY_SIZE * 32];
    for i in 0..32 {
        data[i] = secret[i];
        data[i + 32] = characters[i];
    }
    let offset = 32 + 32;
    for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
        let obstacle = obstacles[i].to_be_bytes(32);
        assert(obstacle.len() == 32);
        for j in 0..32 {
            data[offset + i * 32 + j] = obstacle[j];
        }
    }
    // let offset = WIDTH * HEIGHT + 32 * 3;
    // for i in 0..10 {
    //     data[offset + i * 4] = (searched_traps[i] & 255) as u8;
    //     data[offset + i * 4 + 1] = ((searched_traps[i] >> 8) & 255) as u8;
    //     data[offset + i * 4 + 2] = ((searched_traps[i] >> 16) & 255) as u8;
    //     data[offset + i * 4 + 3] = ((searched_traps[i] >> 24) & 255) as u8;
    // }
    std::hash::blake3(data)
}

fn serialize_chars(chars: [Character; 5]) -> Field {
    let mut result: [u8; 32] = [0; 32];
    for i in 0..5 {
        let serialized = chars[i].serialize();
        for j in 0..6 {
            result[2 + i * 6 + j] = serialized[j];
        }
    }
    std::field::bytes32_to_field(result)
}

fn safe_subtract_dmg(a: u8, b: u16) -> u8 {
    let mut result = 0;
    if (a as u16) > b {
        result = a - (b as u8);
    }
    result
}

#[test]
fn test_main() {
    let chars = [
        Character { id: 0, x: 2, y: 2, class: ARCHER, health: 100, status: 0, target_x: 255, target_y: 255, has_been_seen: 0, damage: 100 },
        Character { id: 1, x: 2, y: 3, class: RITUALIST, health: 60, status: 0, target_x: 255, target_y: 255, has_been_seen: 0, damage: 20 },
        Character { id: 2, x: 2, y: 4, class: ROGUE, health: 80, status: 0, target_x: 255, target_y: 255, has_been_seen: 0, damage: 40 },
        Character { id: 3, x: 2, y: 5, class: KNIGHT, health: 120, status: 0, target_x: 255, target_y: 255, has_been_seen: 0, damage: 60 },
        Character { id: 4, x: 2, y: 6, class: MAGE, health: 40, status: 0, target_x: 255, target_y: 255, has_been_seen: 0, damage: 80 },
    ];
    let chars_serialized = character::serialize_chars(chars);
    let obs: [Obstacle; MAX_OBSTACLES] = obstacle::get_default_obstacles();
    let obs_serialized: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE] = serialize_obstacles(obs);
    main(
        123456789,
        chars_serialized,
        obs_serialized,
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
        0,
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
        0);

    // Uncomment to make test fail
    // main(1, 1);
}
