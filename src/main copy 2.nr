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
global DISARM_TRAP = 10 as u8;
global ACTION_COUNT = 11 as u8;

// EVENTS
global NO_EVENT = 0  as u8;
global SEE_MOVE = 1  as u8;// actor_id = their_char when receive
global SEE_RITUAL = 2  as u8; // actor_id = their_char when receive
global SEE_SEARCH_TRAP = 3  as u8; // actor_id = their_char when receive
global RECEIVE_ATTACK = 4  as u8; // actor_id = their_char when receive
global SEE_CAST = 5 as u8; // actor_id = their_char when receive
global SEE_DRAW = 6 as u8; // actor_id = their_char when receive
global TRIGGERED_TRAP = 7 as u8; // actor_id = my_char when receive
global WIN = 8 as u8;
global FOUND_TRAP = 9 as u8; // actor_id = my_char when receive
global SEE_CHARS = 10 as u8; // actor_id = their_char when receive, got health & class
global RECEIVE_DAMAGE = 11 as u8; // actor_id = their_char when receive
global DESTROY = 12 as u8; // actor_id = tile
global DEATH = 13 as u8; // actor_id = their_char when receive
global EVENT_COUNT = 14 as u8;

// ATTACKS
global ATTACK_MELEE = 0 as u8;
global ATTACK_RANGED = 1 as u8;
global ATTACK_FIREBALL = 2 as u8;
global ATTACK_COUNT = 3 as u8;

// TILES
global EMPTY = 0 as u8;
global UNKNOWN_CLASS_TILE = 6 as u8;
global WALL = 7 as u8;
global WATER = 8 as u8;
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
global STATUS_COUNT = 16  as u8; // just to be more in line with the other constants, actually used as a counter

// GAMEPLAY
global MAX_TRAPS = 15; // note: only lowest bit of first byte of field is usable! => ! Field = 1 bit + 31 bytes!
global TRAPS_BUFFER_SIZE = 16;
global TRAPS_BUFFER_MASK = 15; // has to be 2^n - 1
global MAX_ACTIONS = 8;
global MAX_EVENTS = 8;
global EVENTS_BUFFER_SIZE = 8;
global EVENTS_BUFFER_MASK = 7; // has to be 2^n - 1

struct Result<T> {
    value: T,
    success: bool
}

////////////// CHARACTER
mod character;
use character::Character;
use character::get_test_my_character;
use character::get_test_their_character;
mod trap;
use trap::Trap;
use trap::parse_traps;
use trap::serialize_traps;
mod map;
use map::Map;
use map::get_test_map;
mod game;
use game::Game;
mod event;
use event::Event;
use event::build_std_event;
use event::build_value_event;
use event::build_subtype_value_event;
use event::parse_event;

fn move_to(map: &mut Map, actor: &mut Character, energy: &mut u8, to_x: u8, to_y: u8, exec: bool) -> Result<Field> {
    let mut success = true;
    if exec {
    let can_move_to = map.can_move_to(to_x, to_y);
    success = can_move_to.success;
    // let success = can_move_to.success & can_move_to.value &
    //               ((*actor).get_class() > 0) & ((*actor).get_class() < CLASS_COUNT) &
    //               ((*actor).get_x() < WIDTH) & ((*actor).get_y() < HEIGHT) &
    //               (to_x < WIDTH) & (to_y < HEIGHT) &
    //               (map[(*actor).get_y()][(*actor).get_x()] == (*actor).get_class());
    // assert(can_move_to(*map, to_x, to_y) == 1);
    // assert((*actor).get_class() > 0);
    // assert((*actor).get_class() < CLASS_COUNT);
    // assert((*actor).get_x() < WIDTH);
    // assert((*actor).get_y() < HEIGHT);
    // assert(to_x < WIDTH);
    // assert(to_y < HEIGHT);
    // assert(map[(*actor).get_y()][(*actor).get_x()] == (*actor).get_class());
    let current_tile = map.get(actor.get_x(), actor.get_y());
    success &= current_tile.success & (current_tile.value == actor.get_class());

    // assert_neighbor((*actor), to_x, to_y);
    let is_neighbor = Map::is_neighbor(actor.get_x(), actor.get_y(), to_x, to_y);
    success &= is_neighbor.success;

    let energy_cost = actor.get_energy_per_move();
        if energy_cost > *energy {
            *energy = 0;
            success = false;
            //Result { value: 0, success: false }
        } else {
            *energy = *energy - energy_cost;
        }
    //}

    let erase_result = map.set(actor.get_x(), actor.get_y(), 0); // TODO: instead of setting to 0, set to whatever it was before actor moved there!
    let set_map_result = map.set(to_x, to_y, actor.get_class());
    let set_char_result = actor.set_pos(to_x, to_y); //actor=>set_pos(to_x, to_y);
    // if (!erase_result) | (!set_map_result) | (!set_char_result) {
    //     Result { value: 0, success: false }
    // }
    success &= erase_result & set_map_result & set_char_result;
    }
    Result {
        value: build_std_event(SEE_MOVE, actor.get_id(), to_x, to_y),
        success: success
    }
}

#[test]
fn test_move_to() {
    let mut map_result = Map::build([
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
    ]);
    assert(map_result.success == true);
    let mut map = map_result.value;
    let mut class = KNIGHT;
    let mut c = Character {
        id: 0,
        x: &mut 2,
        y: &mut 4,
        status: &mut 0,
        health: &mut 100,
        class: &mut class,
        has_been_seen: &mut 0,
        target_x: &mut 0,
        target_y: &mut 0,
        damage: 123,
    };
    let mut energy = 12;
    let result = move_to(&mut map, &mut c, &mut energy, 2, 3, true);
    assert(result.success == true);
    assert(result.value == build_std_event(SEE_MOVE, 0, 2, 3));
}

fn sneak_to(map: &mut Map, actor: &mut Character, energy: &mut u8, to_x: u8, to_y: u8, exec: bool) -> bool {
    let mut success = true;
    if exec {
        let can_move_to = map.can_move_to(to_x, to_y);
        success &= can_move_to.success;
        let current_tile = map.get(actor.get_x(), actor.get_y());
        success &= current_tile.success & (current_tile.value == actor.get_class());
        // assert(can_move_to(*map, to_x, to_y) == 1);
        // assert((*actor).get_class() == ROGUE);
        // assert(((*actor).get_x() < WIDTH) & ((*actor).get_y() < HEIGHT));
        // assert((to_x < WIDTH) & (to_y < HEIGHT));
        // assert(*energy >= 6);
        
        // assert_neighbor((*actor), to_x, to_y);
        let is_neighbor = Map::is_neighbor(actor.get_x(), actor.get_y(), to_x, to_y);
        success &= is_neighbor.success;

        let can_sneak = actor.can_sneak();
        success &= can_sneak;

        let energy_cost = (*actor).get_energy_per_sneak();
        if energy_cost > *energy {
            *energy = 0;
            success = false;
            //Result { value: 0, success: false }
        } else {
            *energy = *energy - energy_cost;
        }

        let erase_result = map.set(actor.get_x(), actor.get_y(), 0); // TODO: instead of setting to 0, set to whatever it was before actor moved there!
        let set_map_result = map.set(to_x, to_y, actor.get_class());
        let set_char_result = actor.set_pos(to_x, to_y); //actor=>set_pos(to_x, to_y);
        success &= erase_result & set_map_result & set_char_result;
    }

    success
}

fn get_actor_from_move(mut move: u32) -> u8 {
    if (move % 2) == 1 {
        move -= 1; //((move % 10) - 1) >> 1 // actually not needed ... but clearer this way
    }
    let single_digit: u32 = (move % 10 as u32) >> 1;
    single_digit as u8
}

fn get_data_hash(secret: [u8], characters: [u8], their_characters: [u8], traps: [u8], map: [[u8; WIDTH]; HEIGHT], searched_traps: [u8]) -> [u8; 32] {
    assert(secret.len() == 32);
    assert(characters.len() == 32);
    assert(traps.len() == 32);
    assert(their_characters.len() == 32);

    let mut data: [u8; WIDTH * HEIGHT + 32 * 5] = [0; WIDTH * HEIGHT + 32 * 5];
    for i in 0..HEIGHT {
        for j in 0..WIDTH {
            assert(i < 10);
            assert(j < WIDTH);
            let index = (i as u64) * (WIDTH as u64) + (j as u64);
            data[index] = map[i][j];
        }
    }
    let offset = (WIDTH as u64) * (HEIGHT as u64);
    for i in 0..32 {
        data[offset + i] = secret[i];
        data[offset + i + 32] = characters[i];
        data[offset + i + 64] = traps[i];
        data[offset + i + 96] = searched_traps[i];
        data[offset + i + 128] = their_characters[i];
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


fn main(
    secret: Field,
    my_characters: Field,
    their_characters: Field,
    actions: [Field; 5],
    traps: Field,
    searched_traps: Field, // [u32; HEIGHT],
    move: pub u32,
    map_old: [[u8; WIDTH]; HEIGHT],
    map_new: [[u8; WIDTH]; HEIGHT],
    received_events: pub [Field; MAX_EVENTS],
    sending_events: pub [Field; MAX_EVENTS],
    gamestate_before_hash: pub Field,
    gamestate_after_hash: pub Field
) {
    let old_hash = get_data_hash(secret.to_be_bytes(32), my_characters.to_be_bytes(32), their_characters.to_be_bytes(32), traps.to_be_bytes(32), map_old, searched_traps.to_be_bytes(32));
    // let old_gamestate_bytes = gamestate_before_hash.to_be_bytes(32);
    let argh = std::field::bytes32_to_field(old_hash);
    // assert(old_gamestate_bytes.len() == 32);
    // for i in 0..32 {
    //     assert(old_hash[i] == old_gamestate_bytes[i], f"{argh} != {gamestate_before_hash}");
    // }
    assert(argh == gamestate_before_hash, f"{argh} != {gamestate_before_hash}");

    let actor_id = get_actor_from_move(move);
    assert(actor_id < 5);

    let mut game = Game::build(my_characters, their_characters, traps, searched_traps, map_old);
    // assert(*game.won == false);
    // assert(*game.lost == false);
    // assert(game.my_chars[2].get_status() == 2);
    // println(game.my_chars[2].get_status());

    for i in 0..MAX_EVENTS {
        let event = parse_event(received_events[i]);
        assert(event.process(&mut game));
    }
    //println(game.my_chars[2].get_status());

    //let mut actor = &mut game.my_chars[actor_id];
    // let class = actor.get_class();
    // let id = actor.get_id();
    // assert(1 == 2,f"{id} {class}");
    // assert(actor_result.success);
    // let mut actor = actor_result.value;
    let mut game_events = game.events.map(|event| event);
    let mut energy: u8 = 12;
    for j in 0..5 {
        let split = actions[j].to_be_bytes(32);
        let action = split[1];
        let move_to_result = move_to(game.map, game.my_chars[actor_id], &mut energy, split[3], split[4], action == MOVE);
        let sneak_result = sneak_to(game.map, game.my_chars[actor_id], &mut energy, split[3], split[4], action == SNEAK);
        let mut ec = *game.events_count;
        let mut tc = *game.trap_count;
        //let new_trap = Trap { x: split[3], y: split[4], sprung: &mut 0, damage: 64 };
        if action == SNEAK {
            // hide: y|x|actor|0
            assert(split[2] == actor_id); // for the most parts, only current actor may do stuff
            assert(sneak_result);
            // assert(game.add_event(sneak_result.value));
            assert(game.my_chars[actor_id].set_status(0));
        }
        else if action == MOVE {
            // movey|x|actor|0
            assert(split[2] == actor_id);// for the most parts, only current actor may do stuff
            //action_event_result = move_to(game.map, actor, &mut energy, split[3], split[4]);
            assert(move_to_result.success);
            // assert(game.add_event(move_to_result.value));
        game_events[ec & EVENTS_BUFFER_MASK] = move_to_result.value;
        assert(ec < MAX_EVENTS);
        ec += 1;
        *game.events_count = ec;
            assert(game.my_chars[actor_id].set_status(0));
        }
        else if action == RITUAL {
            assert(split[2] == game.my_chars[actor_id].id); // for the most parts, only current actor may do stuff
            assert(game.my_chars[actor_id].get_class() == RITUALIST);
            assert(energy == 12);
            energy = 0;
            if game.my_chars[actor_id].get_status() < 7 {
                *game.my_chars[actor_id].status += 1;
        game_events[ec & EVENTS_BUFFER_MASK] = build_std_event(RITUAL, game.my_chars[actor_id].id, game.my_chars[actor_id].get_x(), game.my_chars[actor_id].get_y());
        assert(ec < MAX_EVENTS);
        ec += 1;
        *game.events_count = ec;
                // assert(game.add_event(build_std_event(RITUAL, actor.id, actor.get_x(), actor.get_y())));
            } else {
        game_events[ec & EVENTS_BUFFER_MASK] = build_std_event(WIN, game.my_chars[actor_id].id, game.my_chars[actor_id].get_x(), game.my_chars[actor_id].get_y());
        assert(ec < MAX_EVENTS);
        ec += 1;
        *game.events_count = ec;
                // assert(game.add_event(build_std_event(WIN, actor.id, actor.get_x(), actor.get_y())));
            }
            assert(game.my_chars[actor_id].set_status(0));
        }
        else if action == SEARCH {
            assert(split[2] == game.my_chars[actor_id].id);
            assert(game.my_chars[actor_id].get_class() == ROGUE);
            let x = split[3];
            let y = split[4];
            assert(x < WIDTH);
            assert(y < HEIGHT);
            assert(energy >= 6);
            let is_neighbor_result = Map::is_neighbor(game.my_chars[actor_id].get_x(), game.my_chars[actor_id].get_y(), x, y);
            assert(is_neighbor_result.success);
            assert(is_neighbor_result.value);
            // assert(((x == actor.x) & ((y == actor.y + 1) | (y == actor.y - 1))) | ((y == actor.x) & ((x == actor.x + 1) | (x == actor.x - 1))));
            // assert(game.add_event(build_std_event(NO_EVENT, 0, 0, 0)));
            energy -= 6;
            assert(game.my_chars[actor_id].set_status(0));
        }
        else if action == CAST_FIREBALL {
            assert(split[2] == game.my_chars[actor_id].id);// for the most parts, only current actor may do stuff
            assert(game.my_chars[actor_id].get_class() == MAGE, f"{actor_id}");
            assert(energy == 12);
            // TODO: Validate split = target!
            energy = 0;
            // assert(game.my_chars[actor_id].get_status() == 2);
            if game.my_chars[actor_id].get_status() == 0 {
                //println("start cast");
                assert(game.my_chars[actor_id].set_target(split[3], split[4]));
            } else {
                // println("continue cast");
                // println(game.my_chars[actor_id].get_target_x());
                // println(game.my_chars[actor_id].get_target_y());
                // println(split[3]);
                // println(split[4]);
                assert(game.my_chars[actor_id].get_target_x() == split[3]);
                assert(game.my_chars[actor_id].get_target_y() == split[4]);
            }

                // println(actor_id);
                // println(game.my_chars[actor_id].get_status());
            if game.my_chars[actor_id].get_status() < 2 {
                *game.my_chars[actor_id].status += 1;
        game_events[ec & EVENTS_BUFFER_MASK] = build_std_event(SEE_CAST, game.my_chars[actor_id].id, game.my_chars[actor_id].get_x(), game.my_chars[actor_id].get_y());
        assert(ec < MAX_EVENTS);
        ec += 1;
        *game.events_count = ec;
                // assert(game.add_event(build_std_event(SEE_CAST, actor.id, actor.get_x(), actor.get_y())));
            } else {
        game_events[ec & EVENTS_BUFFER_MASK] = build_subtype_value_event(RECEIVE_ATTACK, actor_id, split[3], split[4], 48, ATTACK_FIREBALL);
        // assert(ec == 0);
        // assert(game_events[0] ==0);
            assert(game_events[0] != 0);
        assert(ec < MAX_EVENTS);
        ec += 1;
        *game.events_count = ec;
                // assert(game.add_event(build_subtype_value_event(RECEIVE_ATTACK, actor_id, actor.get_x(), actor.get_y(), 48, ATTACK_FIREBALL)));
            }
        }
        else if action == SET_TRAP {
            assert(split[2] == game.my_chars[actor_id].id);
            assert(game.my_chars[actor_id].set_status(0));
            // assert(game.add_my_trap(new_trap)); // TODO: add more trap types ... for now all do 64 damage

            assert(MAX_TRAPS <= TRAPS_BUFFER_SIZE);
            // game.traps[tc & TRAPS_BUFFER_MASK] = new_trap;/////////TODO: no idea how to make compiler accept this
            tc += 1;
            *game.trap_count = tc;
            
            //let mut tile = TRAP;
            // assert(tc < MAX_TRAPS & game.map.set(new_trap.x, new_trap.y, tile));
            // if my_traps.len() >= 10 {
            //     let (_popped, rest) = my_traps.pop_front();
            //     my_traps = rest.push_back(Trap { x: split[3], y: split[4]});
            // }
        }
        else if action == ATTACK {
            assert(split[2] == game.my_chars[actor_id].id);
            if game.my_chars[actor_id].get_class() == ARCHER {
                assert(game.my_chars[actor_id].get_status() == 1);
                // assert(game.add_event(build_subtype_value_event(RECEIVE_ATTACK, actor_id, split[3], split[4], actor.damage, ATTACK_RANGED)));
        game_events[ec & EVENTS_BUFFER_MASK] = build_subtype_value_event(RECEIVE_ATTACK, actor_id, split[3], split[4], game.my_chars[actor_id].damage, ATTACK_RANGED);
        assert(ec < MAX_EVENTS);
        ec += 1;
        *game.events_count = ec;
            } else {
                let is_neighbor_result = Map::is_neighbor(game.my_chars[actor_id].get_x(), game.my_chars[actor_id].get_y(), split[3], split[4]);
                assert(is_neighbor_result.success);
                assert(is_neighbor_result.value);
                // assert_neighbor(actor, split[3], split[4]);
                // assert(game.add_event(build_subtype_value_event(RECEIVE_ATTACK, actor_id, split[3], split[4], actor.damage, ATTACK_MELEE)));
        game_events[ec & EVENTS_BUFFER_MASK] = build_subtype_value_event(RECEIVE_ATTACK, actor_id, split[3], split[4], game.my_chars[actor_id].damage, ATTACK_MELEE);
        assert(ec < MAX_EVENTS);
        ec += 1;
        *game.events_count = ec;
                // let tile_result = game.get_tile(split[3], split[4]);
                // assert(tile_result.success);
                // if (actor.get_class() == KNIGHT) & (tile_result.value == WALL) {
                //     assert(game.set_tile(split[3], split[4], EMPTY));
                // }
            }
            assert(game.my_chars[actor_id].set_status(0));
        }
    //     else if action == DRAW {
    //         assert(split[2] == actor.id);
    //         assert(actor.get_class() == ARCHER);
    //         assert(actor.set_status(1));
    //         assert(game.add_event(build_std_event(SEE_DRAW, actor.id, split[3], split[4])));
    //     }
    //     // else if action == TRIGGER_TRAP {
    //     //     let target = split[2];
    //     //     assert(game.add_event(build_value_event(TRIGGERED_TRAP, target, split[3], split[4]));
    //     //     i += 1;
    //     // }
    //     else if action == WAIT {
    //         // assert(game.add_event(build_event(NO_EVENT, split[2], 255, 255));
    //         assert(actor.set_status(0));
    //     }
    //     else {
    //         assert(1 == 2); // basically, invalid action code
    //     }
    }

    for i in 0..MAX_EVENTS {
        let v0 = sending_events[i];
        let v1 = game_events[i];
        assert(sending_events[i] == game_events[i], f"{i}: {v0} != {v1}");
    }

    for i in 0..HEIGHT {
        for j in 0..WIDTH {
            let tile_result = game.map.get(j, i);
            assert(tile_result.success);
            assert(map_new[i][j] == tile_result.value);
        }
    }
    // if their_char[0].health + their_char[1].health + their_char[2].health + their_char[3].health + their_char[4].health == 0 {
    //     // won0x04021604300200000000000000000000000000000000000000000000000000
    // }         0x04020216300200000000000000000000000000000000000000000000000000
    let map_after = [
        game.map._data[0].map(|cell| *cell),
        game.map._data[1].map(|cell| *cell),
        game.map._data[2].map(|cell| *cell),
        game.map._data[3].map(|cell| *cell),
        game.map._data[4].map(|cell| *cell),
        game.map._data[5].map(|cell| *cell),
        game.map._data[6].map(|cell| *cell),
        game.map._data[7].map(|cell| *cell),
        game.map._data[8].map(|cell| *cell),
        game.map._data[9].map(|cell| *cell),
    ];
    let my_chars_after = game.serialize_my_chars();
    assert(my_chars_after.success);
    let their_chars_after = game.serialize_their_chars();
    assert(their_chars_after.success);
    let traps_after = serialize_traps(game.get_trap_count() as u8, *game.traps);
    let searched_traps_after = serialize_traps(game.get_their_trap_count() as u8, *game.searched_traps);

    let new_hash_bytes = get_data_hash(secret.to_be_bytes(32), my_chars_after.value.to_be_bytes(32), their_chars_after.value.to_be_bytes(32), traps_after.to_be_bytes(32), map_after, searched_traps_after.to_be_bytes(32));
    let new_hash = std::field::bytes32_to_field(new_hash_bytes);
    assert(new_hash == gamestate_after_hash, f"{new_hash} != {gamestate_after_hash}");
    // let new_gamestate_bytes = gamestate_after_hash.to_be_bytes(32);
    // assert(new_gamestate_bytes.len() == 32);
    // for i in 0..32 {
    //     assert(new_hash[i] == new_gamestate_bytes[i]);
    // }
}

#[test]
fn get_demo_game() {
    let mut c0 = get_test_my_character(0, 2, 2, ARCHER);
    let mut c1 = get_test_my_character(1, 2, 3, KNIGHT);
    let mut c2 = get_test_my_character(2, 2, 4, MAGE);
    let mut c3 = get_test_my_character(3, 2, 5, ROGUE);
    let mut c4 = get_test_my_character(4, 2, 6, RITUALIST);

    let mut e0 = get_test_their_character(0, 22, 2, UNKNOWN_CLASS);
    let mut e1 = get_test_their_character(1, 22, 3, UNKNOWN_CLASS);
    let mut e2 = get_test_their_character(2, 22, 4, UNKNOWN_CLASS);
    let mut e3 = get_test_their_character(3, 22, 5, UNKNOWN_CLASS);
    let mut e4 = get_test_their_character(4, 22, 6, UNKNOWN_CLASS);

    *c2.status = 2;

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

    let game = Game {
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
    };

    let map_after = [
        game.map._data[0].map(|cell| *cell),
        game.map._data[1].map(|cell| *cell),
        game.map._data[2].map(|cell| *cell),
        game.map._data[3].map(|cell| *cell),
        game.map._data[4].map(|cell| *cell),
        game.map._data[5].map(|cell| *cell),
        game.map._data[6].map(|cell| *cell),
        game.map._data[7].map(|cell| *cell),
        game.map._data[8].map(|cell| *cell),
        game.map._data[9].map(|cell| *cell),
    ];
    assert(map_after.len() == 10);
    for i in 0..10 {
        assert(map_after[i].len() == 32);
    }
    let my_chars_after = game.serialize_my_chars();
    assert(my_chars_after.success);
    let their_chars_after = game.serialize_their_chars();
    assert(their_chars_after.success);
    let traps_after = serialize_traps(game.get_trap_count() as u8, *game.traps);
    let searched_traps_after = serialize_traps(game.get_their_trap_count() as u8, *game.searched_traps);

    let my_chars = my_chars_after.value;
    let their_chars = their_chars_after.value;

    assert(map_after[2][22] == UNKNOWN_CLASS_TILE);

    let secret: Field = 1234567890;
    let new_hash_array = get_data_hash(secret.to_be_bytes(32), my_chars_after.value.to_be_bytes(32), their_chars.to_be_bytes(32), traps_after.to_be_bytes(32), [
        [0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, ARCHER, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, UNKNOWN_CLASS_TILE, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [WALL, WALL, KNIGHT,WALL, WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,    UNKNOWN_CLASS_TILE, 0, WALL, 0, 0, WALL, WALL, EMPTY,WALL, WALL],
        [WALL, EMPTY,MAGE,  EMPTY,WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,    UNKNOWN_CLASS_TILE, 0, WALL, 0, 0, WALL, EMPTY,EMPTY,EMPTY,WALL],
        [WALL, EMPTY,ROGUE,EMPTY,WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     UNKNOWN_CLASS_TILE, 0, WALL, 0, 0, WALL, EMPTY,EMPTY,EMPTY,WALL],
        [WALL, WALL, RITUALIST,WALL, WALL, 0, 0, EMPTY,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, UNKNOWN_CLASS_TILE, 0, EMPTY,0, 0, WALL, WALL, EMPTY,WALL, WALL],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, WATER, WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WATER, WATER, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, WATER, WATER, WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WATER, WATER, WATER, 0, 0, 0, 0, 0],
    ], searched_traps_after.to_be_bytes(32));
    let new_hash = std::field::bytes32_to_field(new_hash_array);

    assert(new_hash == 0x0716ac88cc4d1abab6ed2c00278573908bc1b360c955eab19e5822c1d107cdcc, f"hash: {new_hash}, secret: {secret}, my_chars: {my_chars}, their_chars: {their_chars}, traps: {traps_after}, searched_traps: {searched_traps_after}");
}

#[test]
fn test_main() {
    main(
        1234567890,
        0x2202643f0f008203643f0f00a224643604006205643f0f004206643f0f00,
        0x1602ff3f0f001603ff3f0f001604ff3f0f001605ff3f0f001606ff3f0f00,
        [ std::field::bytes32_to_field([0, CAST_FIREBALL, 2, 22, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), 0, 0, 0, 0],
        0x7fff00000000000000000000000000000000000000000000000000000000,
        0x7fff00000000000000000000000000000000000000000000000000000000,
        4,
        [
        [0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, ARCHER, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,               UNKNOWN_CLASS_TILE, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [WALL, WALL, KNIGHT,WALL, WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,    UNKNOWN_CLASS_TILE, 0, WALL, 0, 0, WALL, WALL, EMPTY,WALL, WALL],
        [WALL, EMPTY,MAGE,  EMPTY,WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,    UNKNOWN_CLASS_TILE, 0, WALL, 0, 0, WALL, EMPTY,EMPTY,EMPTY,WALL],
        [WALL, EMPTY,ROGUE,EMPTY,WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     UNKNOWN_CLASS_TILE, 0, WALL, 0, 0, WALL, EMPTY,EMPTY,EMPTY,WALL],
        [WALL, WALL, RITUALIST,WALL, WALL, 0, 0, EMPTY,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, UNKNOWN_CLASS_TILE, 0, EMPTY,0, 0, WALL, WALL, EMPTY,WALL, WALL],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, WATER, WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WATER, WATER, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, WATER, WATER, WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WATER, WATER, WATER, 0, 0, 0, 0, 0],
    ],
        [
        [0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, ARCHER, 0, 0, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, UNKNOWN_CLASS_TILE, 0, WALL, 0, 0, 0, 0, 0, 0, 0],
        [WALL, WALL, KNIGHT,WALL, WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,    UNKNOWN_CLASS_TILE, 0, WALL, 0, 0, WALL, WALL, EMPTY,WALL, WALL],
        [WALL, EMPTY,MAGE,  EMPTY,WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,    UNKNOWN_CLASS_TILE, 0, WALL, 0, 0, WALL, EMPTY,EMPTY,EMPTY,WALL],
        [WALL, EMPTY,ROGUE,EMPTY,WALL, 0, 0, WALL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     UNKNOWN_CLASS_TILE, 0, WALL, 0, 0, WALL, EMPTY,EMPTY,EMPTY,WALL],
        [WALL, WALL, RITUALIST,WALL, WALL, 0, 0, EMPTY,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, UNKNOWN_CLASS_TILE, 0, EMPTY,0, 0, WALL, WALL, EMPTY,WALL, WALL],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, WATER, WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WATER, WATER, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, WATER, WATER, WATER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, WATER, WATER, WATER, 0, 0, 0, 0, 0],
    ],
        [0; MAX_EVENTS],
        [build_subtype_value_event(RECEIVE_ATTACK, 2, 22, 4, 48, ATTACK_FIREBALL), 0, 0, 0, 0, 0, 0, 0],
        0x196e3d671362ffbde73689e61ceea8b962a9dfdade4d439be62cfb3bcbdec380, //0x0716ac88cc4d1abab6ed2c00278573908bc1b360c955eab19e5822c1d107cdcc,
        0x0a824dd1c049066a192d49045e50814708070119ff93e13bb3805b1074ccaff6
    )
}