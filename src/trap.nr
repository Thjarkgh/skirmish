use crate::MAX_TRAPS;
use crate::TRAPS_BUFFER_SIZE;
use crate::WIDTH;
use crate::HEIGHT;
use dep::std;

struct Trap {
    x: u8, // 5 bits + 1 bit for sprung + 1 bits for damage / 8, 1 bit reserved (for end detection!)
    y: u8, // 4 bits + 4 bit damage / 16
    sprung: &mut u8,
    damage: u8,
}

struct ParseTrapResult {
    success: bool,
    value: [Trap; TRAPS_BUFFER_SIZE],
    count: u64,
}

pub fn parse_traps(data: Field) -> ParseTrapResult {
    let d = data.to_be_bytes(32);
    assert(d.len() == 32);
    let mut success = true;
    let mut result = [Trap {
        x: 255,
        y: 255,
        sprung: &mut 1,
        damage: 0
    }; TRAPS_BUFFER_SIZE];
    let mut found_end = false;
    let mut count = 0 as u64;
    let should_count = d[1] as u64;
    let mut sprung_buffer = [&mut 0; TRAPS_BUFFER_SIZE];
                // assert(success == false, f"fail: {data}");
    for i in 0..MAX_TRAPS {
        let packed_x = d[2 + i * 2];
        let packed_y = d[2 + i * 2 + 1];
        *sprung_buffer[i] = ((packed_x >> 5) & 1);
        result[i] = Trap {
            x: packed_x & 31,
            y: packed_y & 15,
            sprung: sprung_buffer[i],
            damage: (packed_y & 0xf0) | (((packed_x >> 6) & 1) << 3),
        };
        found_end |= (packed_x == 255) & (packed_y == 255);
        success &= found_end | ((result[i].x < WIDTH) & (result[i].y < HEIGHT));
        if !found_end {
            count += 1;
        }
        
        // if (found_end == 0) & (packed_x != 255) & (packed_y != 255) {
        //     let x = packed_x & 31;
        //     let y = packed_y & 15;
        //     if (x >= WIDTH) | (y >= HEIGHT) {
        //         success = false;
        //         // assert(success, f"fail: {i}: {x}, {y} of {data}");
        //     };
        //     result[i] = Trap {
        //         x: x,
        //         y: y,
        //         sprung: sprung_buffer[i],
        //         damage: (packed_y & 0xf0) | (((packed_x >> 6) & 1) << 3),
        //     };
        //     // (*result[i]).x = x;
        //     // (*result[i]).y = y;
        //     // (*result[i]).sprung = ((x >> 5) & 1) as u1;
        //     // (*result[i]).damage = (y & 0xf0) | (((x >> 6) & 3) << 2);
        //     count += 1;
        // } else {
        //     found_end = 1;
        // }
    }
    ParseTrapResult {
        success: success & (count == should_count),
        value: result,
        count: count,
    }
}

pub fn serialize_traps(count: u8, traps: [Trap; TRAPS_BUFFER_SIZE]) -> Field {
    assert(WIDTH <= 32);
    assert(HEIGHT <= 16);
    let mut parts = [0x0 as u8; 32];
    parts[1] = count;
    for i in 0..MAX_TRAPS {
        let y: u8 = traps[i].y;
        //assert((i != 15) | (y == 5), f"fail: {i}: {y}");
        parts[2 + i * 2] = (traps[i].x & 0x1f) | ((*traps[i].sprung) << 5) | (((traps[i].damage >> 3) & 1) << 6);
        parts[2 + i * 2 + 1] = y | (traps[i].damage & 0xf0 as u8);
    }
    std::field::bytes32_to_field(parts)
}

#[test]
fn test_parse_traps() {
    //       0x0039 652c a0ae c3ce f481 7ac5 642f 5788 18da 39c1 77df 2b3f a5be 22da 8ff2 5000
    //       0x6102 0212 6312 0422 2022 0632 6732 0642 6842 0a52 6b52 0c62 2d82 0e02 6ff2 5005
    let nr = 0x000210020300FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;// 0xFF00030210; //255; //1002055755;
    let parts = nr.to_be_bytes(32);
    assert(parts.len() == 32);
    assert(parts[2] == 16);
    assert(parts[3] == 2);
    assert(parts[4] == 3);
    assert(parts[5] == 0);
    assert(parts[24] == 255);
    assert(parts[7] == 255);

    let r_result = parse_traps(nr);
    assert(r_result.count == 2);
    assert(r_result.success);
    let r = r_result.value;
    assert(r.len() == TRAPS_BUFFER_SIZE);
    assert(r[0].x == 16);
    assert(r[0].y == 2);
    assert(r[1].x == 3);
    assert(r[1].y == 0);

    // let ser = serialize_traps(r);
    // assert(ser == nr);
}

#[test]
fn test_serialize_traps() {
    let traps = [
        Trap { x: 1, y: 2, sprung: &mut 1, damage: 8 },
        Trap { x: 2, y: 2, sprung: &mut 0, damage: 16 },
        Trap { x: 3, y: 2, sprung: &mut 1, damage: 24 },
        Trap { x: 4, y: 2, sprung: &mut 0, damage: 32 },
        Trap { x: 5, y: 2, sprung: &mut 1, damage: 40 },
        Trap { x: 6, y: 2, sprung: &mut 0, damage: 48 },
        Trap { x: 7, y: 2, sprung: &mut 1, damage: 56 },
        Trap { x: 8, y: 2, sprung: &mut 0, damage: 64 },
        Trap { x: 9, y: 2, sprung: &mut 1, damage: 72 },
        Trap { x: 10, y: 2, sprung: &mut 0, damage: 80 },
        Trap { x: 11, y: 2, sprung: &mut 1, damage: 88 },
        Trap { x: 13, y: 2, sprung: &mut 1, damage: 128 },
        Trap { x: 14, y: 2, sprung: &mut 0, damage: 0 },
        Trap { x: 15, y: 2, sprung: &mut 1, damage: 248 },
        Trap { x: 16, y: 5, sprung: &mut 0, damage: 8 },
        Trap { x: 17, y: 5, sprung: &mut 1, damage: 16},
    ];
    assert(traps.len() == TRAPS_BUFFER_SIZE);
    assert(MAX_TRAPS <= TRAPS_BUFFER_SIZE);
    let r = serialize_traps(MAX_TRAPS as u8, traps);
    let parts = r.to_be_bytes(32);
    //assert((16 & 0x1f) | (0 << 5) | (((8 >> 3) & 1) << 6) == 0x50);
    //assert((2 & 15) | (8 & 0xf0) == 2);
    //assert(traps[15].y == 5);
    //assert(r == 0x0039652ca0aec3cef4817ac5642f578818da39c177df2b3fa5be22da8ff25000, f"serialized {r}");
    //assert(r == 0x00006102021263120422202206326732064268420a526b522d820e026ff25005, f"serialized {r}");
    assert(parts.len() == 32);

    //let x: Field = 0x1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff; //6102021263120422202206326732064268420a526b520c622d820e026ff25005;
    // assert(x == 0x6102021263120422202206326732064268420a526b520c622d820e026ff25005);
    let parsed = parse_traps(r);
    assert(parsed.success);
    assert(parsed.count == MAX_TRAPS);
    let p = parsed.value;
    for i in 0..MAX_TRAPS {
        assert(p[i].x == traps[i].x);
        assert(p[i].y == traps[i].y);
        let should_sprung = *traps[i].sprung;
        let should_damage = traps[i].damage;
        let sprung = *p[i].sprung;
        let damage = p[i].damage;
        let sprung_data = parts[2 + i * 2];
        let damage_data = parts[2 + i * 2 + 1];
        let sprung_calc = ((sprung_data >> 5) & 1);
        let damage_calc = (damage_data & 0xf0) | (((sprung_data >> 6) & 1) << 3);
        assert(sprung == should_sprung, f"{i}: {sprung} != {should_sprung}: {sprung_data} => {sprung_calc}");
        assert(damage == should_damage, f"{i}: {damage} != {should_damage}: {damage_data} => {damage_calc}");
    }
}