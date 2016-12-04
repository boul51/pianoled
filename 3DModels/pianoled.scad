
// White keys geometry
w_width  = 22.65;
w_depth  = 150;
w_height = 20;
w_gap    = 1; // Distance between two white keys

// Black keys geometry
// *_high is at the shape of the top of the black key
// *_low is at the shape of the bottom of the black key
b_width_low   = 15;
b_depth_low   = 90;
b_height_low  = 24;
b_width_high  = 10;
b_depth_high  = 50;
b_height_high = 11+(w_height-b_height_low);
b_height      = b_height_low + b_height_high;
b_width       = b_width_low;

// Pianoled stuff parameters
pl_depth  = 20;   // z axis size
pl_height = 12;   // y size, excludes thickness
pl_margin = 0.5;    // x axis margin near black keys
pl_thickness = 1; //

// Define first note and number of white keys
first_note  = 5;   // 0 is C, 1 is D, etc...
note_counts = 52; // Number of white keys to draw

draw_keyboard();
draw_pianoled();

module draw_pianoled()
{
    union() {
        for (i = [0:note_counts-1]) {
            falling = is_prev_black(i);
            rising  = is_next_black(i);
            
            color("purple") {
                    
                translate([i * (w_width + w_gap), 0, 0]) {
                    if (falling)
                        draw_part(-1);
                    else
                        draw_part(0);
                }
        
                translate([(i+0.5) * (w_width + w_gap), 0, 0]) {
                    if (rising)
                        draw_part(1);
                    else
                        draw_part(0);
                }
            }
        }
    }
}

// determine the height (y axis) where the pianoled touches the keyboard
function low_height() = pl_height > (b_height - w_height) ? w_height : (b_height - pl_height);

// determine the height (y axis) where the pianoled top edge is
function high_height() = pl_height > (b_height - w_height) ? w_height + pl_height : low_height() + pl_height;

// direction =  0 : straight
// direction = -1 : falling
// direction =  1 : rising
module draw_part(direction)
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
        w1  = b_width / 2 + pl_margin + pl_thickness;
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
        w2  = b_width / 2 + pl_margin + pl_thickness;
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

module draw_keyboard()
{
    for (i = [0:note_counts-1]) {
        white_key(i);
        
        if (is_next_black(i))
            black_key(i);
    }
}

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

function is_c(i) =
(
    ((i+first_note)%7 == 0)
);

function is_e(i) =
(
    ((i+first_note)%7 == 2)
);

function is_f(i) =
(
    ((i+first_note)%7 == 3)
);

function is_b(i) =
(
    ((i+first_note)%7 == 6)
);

function is_last_white(i) =
(
    (i + 1 == note_counts)
);

function is_first_white(i) =
(
    (i == 0)
);

function is_prev_black(i) =
(
    (!is_first_white(i) && !is_c(i) && !is_f(i))
);

function is_next_black(i) =
(
    (!is_last_white(i) && !is_e(i) && !is_b(i))
);

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
    
    translate([(i+1) * (w_width + w_gap) - b_width_low / 2, 0, 0]) {
        color("DarkSlateGray", 1) {
            polyhedron(bk_points, bk_faces);
        }
    }
}
