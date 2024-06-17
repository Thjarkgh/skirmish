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
global NOWHERE = 255;

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
global MOVE = 2 as u8;          // => SEE_COLUMN (depr: MOVE)
global RITUAL = 3 as u8;        // => SEE_RITUAL | WIN
global SEARCH = 4 as u8;        // => SEE_SEARCH_TRAP
global ATTACK = 5 as u8;        // => RECEIVE_ATTACK | DESTROY // affects my obstacles; TODO: with more attack types might also affect other own characters
global SET_TRAP = 6 as u8;
global CAST_FIREBALL = 7 as u8; // => SEE_CAST | SEE_SPELL | DESTROY // affects other characters if status == FIREBALL_ROUNDS_FOR_CAST
global DRAW = 8 as u8;          // => SEE_DRAW
global SHOOT = 9 as u8;         // => RECEIVE_ATTACK
//global TRIGGER_TRAP = 9 as u8;  // => TRIGGERED_TRAP ?????????
global DISARM_TRAP = 10 as u8;  // => DESTROY
global ACTION_COUNT = 11 as u8;

// EVENTS
global NO_EVENT = 0  as u8;
global DESTROY = 1 as u8;          // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client //use coordinates to determine tile or trap that got destroyed and update map
//global DISCOVER = 2 as u8;         // actor_id = their_char or their_object when receive - handle to update enemy positions, got health & class (this is for all chars, not just the active one)
//global SEE_COLUMN = 2  as u8;      // y = the column the player sees => update objects list
global SEE_MOVE = 3  as u8;        // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client //handle to update enemy positions => DISCOVER
//global SEE_SPELL = 4  as u8;       // actor_id = their_char when receive - need to handle effect via coordinates, => RECEIVE_DAMAGE | DESTROY | LOSE // also need to handle my obstacles
global SEE_SEARCH_TRAP = 5  as u8; // actor_id = their_char when receive - need to create found trap event if there is a trap nearby => FOUND_TRAP
global SEE_RITUAL = 6  as u8;      // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
global SEE_CAST = 7 as u8;         // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
global SEE_DRAW = 8 as u8;         // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
//global RECEIVE_DAMAGE = 9 as u8;   // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client
global RECEIVE_ATTACK = 10 as u8;  // actor_id = 0 when receive - need to handle damage => // no need to events ... health of visible assets gets sent anyway and invisible ones will be updated during discovery //RECEIVE_DAMAGE | DESTROY | LOSE // also need to handle in my obstacles
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
global DRAW_ROUNDS_FOR_SHOOT = 1 as u8;
global MIN_DRAW_ROUNDS_FOR_SHOOT = 1 as u8;
global MAX_DRAW_ROUNDS_FOR_SHOOT = 3 as u8;
global STATUS_COUNT = 16  as u8; // just to be more in line with the other constants, actually used as a counter

// GAMEPLAY
global VIEW_DISTANCE = 6;
global MAX_TRAPS = 15; // note: only lowest bit of first byte of field is usable! => ! Field = 1 bit + 31 bytes!
global TRAPS_BUFFER_SIZE = 16;
global TRAPS_BUFFER_MASK = 15; // has to be 2^n - 1
global MAX_ACTIONS = 4;
global MAX_EVENTS = 4; // = MAX_ACTIONS // NO! handle traps in a different way (by passing as argument!)+ 4 (2 FOUND_TRAP + WIN/LOSE + 1 reserved)
global MAX_OBSTACLES = 24;
global MAX_CHARACTERS = 5;
global SERIALIZED_OBSTACLE_BYTE_SIZE = 3;
global SERIALIZED_OBSTACLES_ARRAY_SIZE = 3; // TODO: we take 3 because 3 x 8 = MAX_OBSTACLES ... should assert on this (MAX_OBSTACLES + MAX_CHARACTERS + 7) / 8;
global SERIALIZED_OBSTACLES_PER_FIELD = 8; // TODO: need to verify that SERIALIED_OBSTACLES_ARRAY_SIZE * SERIALIZED_OBSTACLES_PER_FIELD = MAX_OBSTACLES!
global SERIALIZED_EVENT_BYTE_SIZE = 7;
global SERIALIZED_EVENTS_ARRAY_SIZE = 1; // MAX_EVENTS / SERIALIZED_EVENTS_PER_FIELD => 4 / 4 = 1
global SERIALIZED_EVENTS_PER_FIELD = 4; // 31 / 7 = 4
global SERIALIZED_ACTION_BYTE_SIZE = 5;
global SERIALIZED_ACTIONS_ARRAY_SIZE = 1;
global SERIALIZED_ACTIONS_PER_FIELD = 4; // could be up to 6, but we only use 4
global UNREADABLE_BYTES_PER_FIELD = 1;

fn get_actor_from_move(mut move: u32) -> u8 {
    if (move % 2) == 1 {
        move -= 1; //((move % 10) - 1) >> 1 // actually not needed ... but clearer this way
    }
    let single_digit: u32 = (move % 10 as u32) >> 1;
    single_digit as u8
}

fn main(
    // My Secret State
    secret: Field,
    my_chars: Field,
    my_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE],
    actions: [Field; SERIALIZED_ACTIONS_ARRAY_SIZE],
    // Common Inputs
    move: pub u32,
    // Enemy Inputs
    enemy_advance: pub u8,
    enemy_objects: pub [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1],
    events: pub [Field; SERIALIZED_EVENTS_ARRAY_SIZE], //MAX_EVENTS],
    // My Results
    my_advance: pub u8, // 1 bit win, 1 bit lose, 1 bit reserved, 5 bits advance
    my_result_events: pub [Field; SERIALIZED_EVENTS_ARRAY_SIZE],
    my_result_objects: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1],
    // Gamestate Hashes
    gamestate_before_hash: pub Field,
    gamestate_after_hash: pub Field,
) {
    // Validate global constants (to make sure one didn't change one without updating dependet ones)
    assert(SERIALIZED_EVENTS_PER_FIELD * SERIALIZED_EVENTS_ARRAY_SIZE == MAX_EVENTS);
    assert(SERIALIZED_OBSTACLES_PER_FIELD * SERIALIZED_OBSTACLES_ARRAY_SIZE == MAX_OBSTACLES);

    let gamestate_before_hash_calculated = get_data_hash(secret.to_be_bytes(32), my_chars.to_be_bytes(32), my_obstacles);
    let gamestate_before_hash_calculated_field = std::field::bytes32_to_field(gamestate_before_hash_calculated);
    assert(gamestate_before_hash == gamestate_before_hash_calculated_field, f"{gamestate_before_hash} != {gamestate_before_hash_calculated_field}");

    // TODO: Validate map => check that initial setup is ok => unique ids and no coordination overlaps!

    let events: [Event; MAX_EVENTS] = Event::parse_events(events);
    
    let side = move as u1;
    let mut my_chars = parse_characters(my_chars, events, enemy_advance, side);

    let actor_id = get_actor_from_move(move);
    let mut actor = my_chars[actor_id]; //Character::parse(actor_id, my_chars, events);
    
    let actions = Action::parse_actions(actions); // actions.map(|action| Action::from_field(action));
    
    assert(MAX_OBSTACLES == 24);
    let mut my_obstacles_parsed = Obstacle::parse_my_obstacles(my_obstacles, events).as_array();
    // TODO: validate obstacles => check that initial setup is ok => unique ids and no coordination overlaps!

    // Note: no need to validate enemy obstacles => opponent proof verifies that they are correct already!
    let enemy_objects_parsed = Obstacle::parse_their_obstacles(enemy_objects);

    let mut energy: u8 = 12;
    let mut result_events_calculated: [Event] = &[];
    for i in 0..MAX_ACTIONS {
        // TODO: ensure that if actor committed suicide, it is not allowed to do any more actions
        let action = actions[i];
        let result = action.execute(actor, energy, my_obstacles_parsed, enemy_objects_parsed);
        let result_event = result.0;
        actor = result.1;
        energy = result.2;
        
        my_chars = my_chars.map(|c| wb_apply_damage_to_char(c, result_event, actor));
        my_obstacles_parsed = my_obstacles_parsed.map(|obstacle| update_my_obstacle(obstacle, result_event));

        result_events_calculated = result_events_calculated.push_back(result_event);
    }
    let result_events_calculated = Event::serialize_events(result_events_calculated);
    assert(result_events_calculated.len() == SERIALIZED_EVENTS_ARRAY_SIZE);
    for i in 0..SERIALIZED_EVENTS_ARRAY_SIZE {
        let result_event_calculated = result_events_calculated[i];
        let result_event_should = my_result_events[i];
        assert(result_event_should == result_event_calculated, f"Invalid result event {i}: {result_event_should} != {result_event_calculated}");
    }

    // send death events => no need

    // determine view range
    let mut my_advance_calculated = 0;
    if side == 0 {
        for i in 0..MAX_CHARACTERS {
            if my_chars[i].x > my_advance_calculated {
                my_advance_calculated = my_chars[i].x;
            }
        }
        my_advance_calculated += VIEW_DISTANCE;
    } else {
        my_advance_calculated = WIDTH - 1;
        for i in 0..MAX_CHARACTERS {
            if my_chars[i].x < my_advance_calculated {
                my_advance_calculated = my_chars[i].x;
            }
        }
        my_advance_calculated -= VIEW_DISTANCE;
    }
    assert(my_advance == my_advance_calculated, f"{my_advance} != {my_advance_calculated}");

    // validate result
    let serialized_characters = serialize_chars(my_chars);
    let serialized_obstacles: [Field] = Obstacle::serialize_obstacles(my_obstacles_parsed);
    assert(serialized_obstacles.len() == SERIALIZED_OBSTACLES_ARRAY_SIZE);
    let new_hash_bytes = get_data_hash(secret.to_be_bytes(32), serialized_characters.to_be_bytes(32), serialized_obstacles.as_array());
    let new_hash = std::field::bytes32_to_field(new_hash_bytes);
    let serialized_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1] = serialized_obstacles.push_back(serialize_chars_as_obstacles(my_chars)).as_array();
    for i in 0..my_result_objects.len() {
        let my_result_object = my_result_objects[i];
        let serialized_obstacle = serialized_obstacles[i];
        assert(my_result_object == serialized_obstacle, f"{i}: {my_result_object} != {serialized_obstacle}");
    }
    assert(new_hash == gamestate_after_hash, f"{new_hash} != {gamestate_after_hash}");
}

fn wb_apply_damage_to_char(mut c: Character, event: Event, actor: Character) -> Character {
    if c.id == actor.id {
        c = actor;
    }
    apply_damage_to_char(c, event)
}

fn apply_damage_to_char(c: Character, event: Event) -> Character {
    let dmg = event.get_applied_damage_to_my_asset(c.x, c.y, c.class);
    Character {
        id: c.id,
        x: c.x,
        y: c.y,
        class: c.class,
        health: safe_subtract_dmg(c.health, dmg),
        status: c.status,
        target_x: c.target_x,
        target_y: c.target_y,
        has_been_seen: c.has_been_seen,
        is_hidden: c.is_hidden,
        damage_mod: c.damage_mod,
    }
}
fn update_my_obstacle(obstacle: Obstacle, event: Event) -> Obstacle {
    let dmg = event.get_applied_damage_to_my_asset(obstacle.x, obstacle.y, obstacle.obstacle_type);
    Obstacle {
        health: safe_subtract_dmg(obstacle.health, dmg),
        id: obstacle.id,
        x: obstacle.x,
        y: obstacle.y,
        obstacle_type: obstacle.obstacle_type,
    }
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

fn serialize_chars(chars: [Character; MAX_CHARACTERS]) -> Field {
    assert(MAX_CHARACTERS <= 5);
    let mut result: [u8; 32] = [0; 32];
    for i in 0..MAX_CHARACTERS {
        let serialized = chars[i].serialize();
        for j in 0..6 {
            result[2 + i * 6 + j] = serialized[j];
        }
    }
    std::field::bytes32_to_field(result)
}

fn serialize_chars_as_obstacles(chars: [Character; MAX_CHARACTERS]) -> Field {
    let mut result: [u8; 32] = [0; 32];
    for i in 0..MAX_CHARACTERS {
        let char_as_obstacle = chars[i].to_obstacle();
        let serialized = char_as_obstacle.serialize();
        result[2 + i * 3] = serialized[0];
        result[2 + i * 3 + 1] = serialized[1];
        result[2 + i * 3 + 2] = serialized[2];
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

fn test_result_object_builder(chars: [Character; MAX_CHARACTERS], obs: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE]) -> [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1] {
    let mut result: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1] = [0; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1];
    for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
        result[i] = obs[i];
    }
    result[SERIALIZED_OBSTACLES_ARRAY_SIZE] = serialize_chars_as_obstacles(chars);
    result
}

#[test]
fn test_main() {
    let mut chars = [ character::get_default_characters(0), character::get_default_characters(1) ];
    let mut obs = [ Obstacle::get_default_obstacles(0), Obstacle::get_default_obstacles(1) ];
    let actions = &[
        Action { action: MOVE, actor: 0, target_x: 2, target_y: 1 },
        Action { action: MOVE, actor: 0, target_x: 3, target_y: 1 },
        Action { action: MOVE, actor: 0, target_x: 4, target_y: 1 },
        Action { action: MOVE, actor: 0, target_x: 5, target_y: 1 },
    ];
    let mut move = 0;
    let mut char_0 = chars[0][0].move(5, 1);
    let mut last_hashes = [ 0x266a56eeca3c428d06ac08bc2741290db9d5b0714cdc96cd7330781e2f06c2b3, 0x168c5ee3c58a94477b8739bd1ac67564f7474e181e3948594d5317243c024da3 ];
    let mut current_hashes = [ 0x0d66c10ceaf16643f43c3273d57568a18ba7c74494703772fa79e4ed46144f6a, 0x0297cb9d021ad39ad6aa0a2644cfabe8a83036c05e66cc96da94e0ede5c393a9 ];
    let mut advances = [2 + VIEW_DISTANCE, 29 - VIEW_DISTANCE];
    advances[0] = 5 + VIEW_DISTANCE;
    main(
        123456789,
        character::serialize_chars(chars[0]),
        Obstacle::serialize_obstacles(obs[0]),
        Action::serialize_actions(actions),
        move,
        advances[1],
        [0, 0, 0, 0], // enemy objects
        Event::serialize_events(&[ Event::empty(); MAX_EVENTS]).as_array(), // events
        advances[0], // result advance
        Event::serialize_events(&[ Event::empty(); MAX_EVENTS]).as_array(), // my result events (should)
        test_result_object_builder([ char_0, chars[0][1], chars[0][2], chars[0][3], chars[0][4] ], Obstacle::serialize_obstacles(obs[0])), // my visible objects
        last_hashes[0],
        current_hashes[0]
    );
    chars[0][0] = char_0;
    last_hashes[0] = current_hashes[0];

    let actions = &[
        Action { action: MOVE, actor: 0, target_x: 29, target_y: 1 },
        Action { action: MOVE, actor: 0, target_x: 28, target_y: 1 },
        Action { action: MOVE, actor: 0, target_x: 28, target_y: 0 },
        Action { action: MOVE, actor: 0, target_x: 27, target_y: 0 },
    ];
    move = 1;
    char_0 = chars[1][0].move(27, 0);
    advances[1] = 27 - VIEW_DISTANCE;
    main(
        9876543210,
        character::serialize_chars(chars[1]),
        Obstacle::serialize_obstacles(obs[1]),
        Action::serialize_actions(actions),
        move,
        advances[0],
        [0, 0, 0, 0], // enemy objects
        Event::serialize_events(&[ Event::empty(); MAX_EVENTS]).as_array(), // events
        advances[1], // result advance
        Event::serialize_events(&[ Event::empty(); MAX_EVENTS]).as_array(), // my result events (should)
        test_result_object_builder([ char_0, chars[1][1], chars[1][2], chars[1][3], chars[1][4] ], Obstacle::serialize_obstacles(obs[1])), // my visible objects
        last_hashes[1],
        current_hashes[1]
    );
    chars[1][0] = char_0;
    last_hashes[1] = current_hashes[1];
}
