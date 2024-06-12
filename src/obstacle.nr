use crate::MAX_OBSTACLES;
use crate::HEIGHT;
use crate::WIDTH;
use crate::WALL;
use crate::WATER;
use crate::MAX_CHARACTERS;
use crate::MAX_EVENTS;
use crate::event::Event;
use crate::{ RECEIVE_ATTACK };
use crate::{ ATTACK_MELEE, ATTACK_RANGED, ATTACK_FIREBALL };
use crate::map::is_neighbor;
use crate::{ SERIALIZED_OBSTACLES_PER_FIELD, SERIALIZED_OBSTACLES_ARRAY_SIZE };
use dep::std;

struct Obstacle {
    id: u8,
    x: u8,             // 5 bit
    y: u8,             // 4 bit
    health: u8,        // 8 bit
    obstacle_type: u8, // 4 bit
    was_alive: bool,
}

impl Obstacle {
    fn serialize(self) -> [u8; 3] {
        assert(self.y < 0x10, f"Obstacle y is too large");
        assert(self.obstacle_type < 0x10, f"Obstacle type is too large");

        let packed_y = self.obstacle_type * 0x10 + self.y;
        //(self.x as Field) + ((packed_y as Field) * 0x10000) + ((self.obstacle_type as Field) * 0x1000000)
        [ self.x, packed_y, self.health]
    }

    fn parse(id: u8, field: [u8; 3], events: [Event; MAX_EVENTS]) -> Obstacle {
        // let serialized_id = field as u8;
        // assert(serialized_id == id, f"Obstacle id does not match serialized id {serialized_id} != {id}");
        assert(id >= MAX_CHARACTERS, f"Obstacle id is lower than minimum {id}");
        let x = field[0];
        let y = field[1] & 0x0F;
        let obstacle_type = (field[1] & 0xF0) / 0x10;
        let mut health = field[2];
        let was_alive = health > 0;
        if (obstacle_type == WALL) | (obstacle_type == WATER) {
            let mut damage = 0;
            for i in 0..MAX_EVENTS {
                damage += events[i].get_applied_damage(x, y, obstacle_type);
            }
            if damage > (health as u16) {
                health = 0;
            } else {
                health -= (damage as u8);
            }
        }
        let o = Obstacle {
            id: id,
            x: x,
            y: y,
            health: health,
            obstacle_type: obstacle_type,
            was_alive: was_alive,
        };
        assert(o.is_valid());
        o
    }

    fn is_valid(self) -> bool {
        (self.x < WIDTH) & (self.y < HEIGHT)
    }
}

pub fn parse_obstacles(serialized_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE], events: [Event; MAX_EVENTS]) -> [Obstacle; MAX_OBSTACLES] {
    let mut obstacles: [Obstacle] = &[];
    for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
        let serialized_obstacle_field = serialized_obstacles[i].to_be_bytes(32);
        for j in 0..SERIALIZED_OBSTACLES_PER_FIELD {
            let serialized_obstacle = [serialized_obstacle_field[2 + j * 3], serialized_obstacle_field[2 + j * 3 + 1], serialized_obstacle_field[2 + j * 3 + 2]];
            let id = (i * SERIALIZED_OBSTACLES_PER_FIELD + j) as u8;
            obstacles = obstacles.push_back(Obstacle::parse(id, serialized_obstacle, events));
        }
    }
    obstacles.as_array()
}

pub fn serialize_obstacles(obstacles: [Obstacle; MAX_OBSTACLES]) -> [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE] {
    let mut serialized_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE] = [0; SERIALIZED_OBSTACLES_ARRAY_SIZE];
    for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
        let mut serialized_obstacle_field: [u8; 32] = [0; 32];
        for j in 0..SERIALIZED_OBSTACLES_PER_FIELD {
            let serialized_obstacle = obstacles[i * SERIALIZED_OBSTACLES_PER_FIELD + j].serialize();
            for k in 0..3 {
                serialized_obstacle_field[2 + j * 3 + k] = serialized_obstacle[k];
            }
        }
        serialized_obstacles[i] = std::field::bytes32_to_field(serialized_obstacle_field);
    }
    serialized_obstacles
}

pub fn get_default_obstacles() -> [Obstacle; MAX_OBSTACLES] {
    [
        Obstacle { id:  0, x: 0, y: 2, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id:  1, x: 0, y: 3, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id:  2, x: 0, y: 4, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id:  3, x: 0, y: 5, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id:  4, x: 1, y: 2, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id:  5, x: 3, y: 2, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id:  6, x: 4, y: 2, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id:  7, x: 4, y: 3, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id:  8, x: 4, y: 4, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id:  9, x: 4, y: 5, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id: 10, x: 1, y: 4, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id: 11, x: 3, y: 4, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id: 12, x: 7, y: 0, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id: 13, x: 7, y: 1, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id: 14, x: 7, y: 2, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id: 15, x: 7, y: 3, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id: 16, x: 7, y: 4, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id: 17, x: 7, y: 5, obstacle_type: WALL,  health: 200, was_alive: true },
        Obstacle { id: 18, x: 6, y: 8, obstacle_type: WATER, health: 255, was_alive: true },
        Obstacle { id: 19, x: 7, y: 8, obstacle_type: WATER, health: 255, was_alive: true },
        Obstacle { id: 20, x: 5, y: 9, obstacle_type: WATER, health: 255, was_alive: true },
        Obstacle { id: 21, x: 6, y: 9, obstacle_type: WATER, health: 255, was_alive: true },
        Obstacle { id: 22, x: 7, y: 9, obstacle_type: WATER, health: 255, was_alive: true },
        Obstacle { id: 23, x: 8, y: 9, obstacle_type: WATER, health: 255, was_alive: true },
    ]
}