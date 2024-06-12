use crate::{ WIDTH, HEIGHT };

pub fn is_neighbor(curr_x: u8, curr_y: u8, x: u8, y: u8) -> bool {
    assert(curr_x < WIDTH);
    assert(curr_y < HEIGHT);
    assert(x < WIDTH);
    assert(y < HEIGHT);

    let shifted_curr_x = curr_x + 1;
    let shifted_curr_y = curr_y + 1;
    let shifted_x = x + 1;
    let shifted_y = y + 1;

    ((shifted_curr_x == shifted_x) & (shifted_curr_y + 1 >= shifted_y) & (shifted_curr_y <= shifted_y + 1)) |
    ((shifted_curr_y == shifted_y) & (shifted_curr_x + 1 >= shifted_x) & (shifted_curr_x <= shifted_x + 1))
}