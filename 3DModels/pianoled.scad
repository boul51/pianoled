
// White keys geometry
w_width  = 22.65; // x axis
w_height = 20;    // y axis
w_depth  = 150;   // z axis
w_gap    = 1; // Distance between two white keys

// Black keys geometry
// *_high is at the shape of the top of the black key
// *_low is at the shape of the bottom of the black key
b_width_low   = 15;
b_height_low  = 24;
b_depth_low   = 90;
b_width_high  = 10;
b_depth_high  = 50;
b_height_high = 11+(w_height-b_height_low);
b_height      = b_height_low + b_height_high;
b_width       = b_width_low;
b_jitter      = 2; // Offset on x axis of black keys, starting from middle position

// Pianoled stuff parameters
pl_depth  = 20;   // z axis size
pl_height = 12;   // y size, excludes thickness
pl_margin = 0.5;  // x axis margin near black keys
pl_thickness = 1; // thickness of plastic

// Define first note and number of white keys
first_note  = 0; // 0 is C, 1 is D, etc...
note_counts = 7; // Number of white keys to draw

//draw_keyboard(); // Uncomment to draw keyboard keys below the frame
draw_pianoled();

// Draw the whole plastic frame, based on notes_count and first_note
module draw_pianoled()
{
    union() {
        for (i = [0:note_counts-1]) {
            falling = is_prev_black(i);
            rising  = is_next_black(i);
            
            color("purple") {
                    
                translate([i * (w_width + w_gap), 0, 0]) {
                    if (falling)
                        draw_part(-1, i);
                    else
                        draw_part(0, i);
                }
        
                translate([(i+0.5) * (w_width + w_gap), 0, 0]) {
                    if (rising)
                        draw_part(1, i);
                    else
                        draw_part(0, i);
                }
            }
        }
    }
}

// determine the height (y axis) where the pianoled touches the keyboard
function low_height() = pl_height > (b_height - w_height) ? w_height : (b_height - pl_height);

// determine the height (y axis) where the pianoled top edge is
function high_height() = pl_height > (b_height - w_height) ? w_height + pl_height : low_height() + pl_height;

// Draw a part of the plastic frame.
// Each white key is made of two parts :
//  - the first may be falling (if there is a black key on the left), or straight
//  - the second may be rising (if there is a black key on the right), or straight
// direction =  0 : straight
// direction = -1 : falling
// direction =  1 : rising
// i is the number of the associated white key
module draw_part(direction, i)
{
    rising   = (direction ==  1);
    falling  = (direction == -1);
    straight = (direction ==  0);
    
    // Will black or white keys support the stuff ?
    h_high = high_height();
    h_low  = low_height();

    if (straight) {
        translate([0, h_low, 0]) {
            cube([(w_width + w_gap) / 2, pl_thickness, pl_depth]);
        }
    }
    else if (falling) {
        w1  = b_width / 2 + pl_margin + pl_thickness + get_b_jitter(i-1);
        w2  = (w_width + w_gap) / 2 - w1;
        translate([0, h_high, 0]) {
            cube([w1, pl_thickness, pl_depth]);
        }
        translate([w1 - pl_thickness, h_low, 0]) {
            cube([pl_thickness, pl_height, pl_depth]);
        }
        translate([w1, h_low, 0]) {
            cube([w2, pl_thickness, pl_depth]);
        }
    }
    else
    {
        w2  = b_width / 2 + pl_margin + pl_thickness - get_b_jitter(i);
        w1  = (w_width + w_gap) / 2 - w2;
        translate([0, h_low, 0]) {
            cube([w1, pl_thickness, pl_depth]);
        }
        translate([w1, h_low, 0]) {
            cube([pl_thickness, pl_height, pl_depth]);
        }
        translate([w1, h_high, 0]) {
            cube([w2, pl_thickness, pl_depth]);
        }
    }
}

// Draw the whole keyboard, based on note_counts and first_note
module draw_keyboard()
{
    for (i = [0:note_counts-1]) {
        white_key(i);
        
        if (is_next_black(i))
            black_key(i);
    }
}

// Draw white key i
module white_key(i) {
    difference() {
        color("White") {
        translate([i * (w_width + w_gap), 0, 0]) cube([w_width, w_height, w_depth]);
        }
        union() {
            if (is_prev_black(i))
                black_key(i-1);
            if (is_next_black(i))
                black_key(i);
        }
    }
}

// return true if white key i a C
function is_c(i) =
(
    ((i+first_note)%7 == 0)
);

// return true if white key i a E
function is_e(i) =
(
    ((i+first_note)%7 == 2)
);

// return true if white key i a F
function is_f(i) =
(
    ((i+first_note)%7 == 3)
);

// return true if white key i a B
function is_b(i) =
(
    ((i+first_note)%7 == 6)
);

// return true if this is white key i the last of the keyboard
function is_last_white(i) =
(
    (i + 1 == note_counts)
);

// return true if this is white key i the first of the keyboard
function is_first_white(i) =
(
    (i == 0)
);

// return true if there is a black key before white key i
function is_prev_black(i) =
(
    (!is_first_white(i) && !is_c(i) && !is_f(i))
);

// return true if there is a black key after white key i
function is_next_black(i) =
(
    (!is_last_white(i) && !is_e(i) && !is_b(i))
);

// calculate x offset of black key
function get_b_jitter(i) =
(
    is_c(i) || is_f(i)) ? -b_jitter : (is_e(i+1) || is_b(i+1) ? b_jitter : 0
);

// draw black key following white key i
module black_key(i) {
    wl = b_width_low;   // low  width , x axis
    wh = b_width_high;  // high width , x axis
    hl = b_height_low;  // low  height, y axis
    hh = b_height_high; // high height, y axis
    dl = b_depth_low;   // low  depth , z axis
    dh = b_depth_high;  // high depth , z axis
    
    // Black key shape, starting from 0
    bk_points = [
        [ 0, 0, 0], // 0
        [ 0, 0,dl], // 1
        [wl, 0,dl], // 2
        [wl, 0, 0], // 3
        [ 0,hl, 0], // 4
        [ 0,hl,dl], // 5
        [wl,hl,dl], // 6
        [wl,hl, 0], // 7
        [(wl-wh)/2,hl+hh, 0], // 8
        [(wl-wh)/2,hl+hh,dh], // 9
        [(wl+wh)/2,hl+hh,dh], // 10
        [(wl+wh)/2,hl+hh, 0]  // 11
    ];
    
    bk_faces = [
        [0, 1, 2, 3],
        [0, 4, 5, 1],
        [5, 6, 2, 1],
        [2, 6, 7, 3],
        [4, 8, 9, 5],
        [9, 10, 6, 5],
        [6, 10, 11, 7],
        [8, 11, 10, 9],
        [0, 3, 7, 11, 8, 4]
    ];
    
    translate([(i+1) * (w_width + w_gap) - b_width_low / 2 + get_b_jitter(i), 0, 0]) {
        color("DarkSlateGray", 1) {
            polyhedron(bk_points, bk_faces);
        }
    }
}
