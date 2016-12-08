include <../version.txt>

// White keys geometry
w_width  = 22.65; // x axis
w_height = 20;    // y axis
w_depth  = 150;   // z axis
w_gap    = 1;     // Distance between two white keys

// Black keys geometry
// *_high is at the shape of the top of the black key
// *_low is at the shape of the bottom of the black key
b_width_low   = 15;
b_height_low  = 24;
b_depth_low   = 90;
b_width_high  = 9.5;
b_depth_high  = 50;
b_height_high = 11+(w_height-b_height_low);
b_height      = b_height_low + b_height_high;
b_width       = b_width_low;
b_jitters     = [-2.175 , 2.175 , 0 , -3.35 , 0 , 3.35 , 0]; // Offset on x axis of black keys, starting from middle position

// Pianoled stuff parameters
pl_depth  = 11;       // z axis size
pl_height = 11.5;     // y size, excludes thickness
pl_margin = 0.5;      // x axis margin near black keys
pl_thickness_x = 1.5; // vertical thickness on x axis
pl_thickness_y = 2;   // horizontal thickness on y axis
pl_thickness_z = 2;   // horizontal thickness on z axis (ie bars)

// PCB footprint parameters
fp_width    = 8;
fp_height   = 0.5;
fp_depth    = 10;

// Message definitions (text is read from textcontents.txt)
msg_depth     = 0.5;
msg_font_size = 2.5;

// Define first note and number of white keys
first_note  = 0; // 0 is C, 1 is D, etc...
notes_count = 7; // Number of white keys to draw

2dprojection = false; // Set to true to export a 2D dxf

if (!2dprojection) {
    //draw_keyboard(); // Uncomment to draw keyboard keys below the frame
    draw_pianoled();
}
else projection(cut=true) translate([0, 0, -5]) {
    // 2D projection, useful to export to 2D dxf and check distances
    draw_keyboard();
    draw_pianoled();
}

module draw_pianoled()
{
    difference() {
        frame();
        footprints();
        pl_version();
    }
}

// Draw the whole plastic frame, based on notes_count and first_note
module frame()
{
    union() {
        color("purple") {
            for (i = [0:notes_count-1]) {
                falling = is_prev_black(i);
                rising  = is_next_black(i);

                translate([i * (w_width + w_gap), 0, 0]) {
                    if (falling)
                        draw_part(-1, i, true);
                    else
                        draw_part(0, i, true);
                }

                translate([(i+0.5) * (w_width + w_gap), 0, 0]) {
                    if (rising)
                        draw_part(1, i, false);
                    else
                        draw_part(0, i, false);
                }
            }
            //bars(); // Uncomment this to draw reinforcement bars
        }
    }
}

// determine the height (y axis) where the pianoled touches the keyboard
function low_height() = pl_height > (b_height - w_height) ? w_height : (b_height - pl_height);

// determine the height (y axis) where the pianoled top edge is
function high_height() = pl_height > (b_height - w_height) ? w_height + pl_height : low_height() + pl_height;

// return the x position of left side of black key i
function black_key_x(i) =
    (i+1) * (w_width + w_gap) - b_width_low / 2 + get_b_jitter(i);

// return the x position of left side of white key i, including gap
function white_key_x(i) =
    i * (w_width + w_gap);

// return the x position of left side of white key i, excluding gap
function white_key_x_nogap(i) =
    i * (w_width + w_gap) + w_gap / 2;

// Draw a part of the plastic frame. Called twice per key.
// Each white key is made of two parts :
//  - the first may be falling (if there is a black key on the left), or straight
//  - the second may be rising (if there is a black key on the right), or straight
// direction =  0 : straight
// direction = -1 : falling
// direction =  1 : rising
// i is the number of the associated white key
// is_first_half is true if we are drawing the first part of the key
module draw_part(direction, i, is_first_half)
{
    rising   = (direction ==  1);
    falling  = (direction == -1);
    straight = (direction ==  0);
    
    // Will black or white keys support the stuff ?
    h_high = high_height();
    h_low  = low_height();

    if (straight) {
        if (is_first_white(i) && is_first_half) {
            // Avoid to cover the gap on the left for the first white key
            translate([w_gap/2, h_low, 0]) {
                cube([w_width / 2, pl_thickness_y, pl_depth]);
                // Add the vertical part at the back of the key
                cube([w_width / 2, pl_height + pl_thickness_y, pl_thickness_z]);
            }
        }
        else if (is_last_white(i) && !is_first_half) {
            // Avoid to cover the gap on the right for the last white key
            translate([0, h_low, 0]) {
                cube([w_width / 2, pl_thickness_y, pl_depth]);
                // Add the vertical part at the back of the key
                cube([w_width / 2, pl_height + pl_thickness_y, pl_thickness_z]);
            }
        }
        else {
            translate([0, h_low, 0]) {
                cube([(w_width + w_gap) / 2, pl_thickness_y, pl_depth]);
                // Add the vertical part at the back of the key
                cube([(w_width + w_gap) / 2, pl_height + pl_thickness_y, pl_thickness_z]);
            }
        }
    }
    else if (falling) {
        w1  = b_width / 2 + pl_margin + pl_thickness_x + get_b_jitter(i-1);
        w2  = (w_width + w_gap) / 2 - w1;
        translate([0, h_high, 0]) {
            cube([w1, pl_thickness_y, pl_depth]);
        }
        translate([w1 - pl_thickness_x, h_low, 0]) {
            cube([pl_thickness_x, pl_height, pl_depth]);
        }
        translate([w1, h_low, 0]) {
            cube([w2, pl_thickness_y, pl_depth]);
            // Add the vertical part at the back of the key
            cube([w2, pl_height + pl_thickness_y, pl_thickness_z]);
        }
    }
    else {
        w2  = b_width / 2 + pl_margin + pl_thickness_x - get_b_jitter(i);
        w1  = (w_width + w_gap) / 2 - w2;
        translate([0, h_low, 0]) {
            cube([w1, pl_thickness_y, pl_depth]);
            // Add the vertical part at the back of the key
            cube([w1, pl_height + pl_thickness_y, pl_thickness_z]);
        }
        translate([w1, h_low, 0]) {
            cube([pl_thickness_x, pl_height, pl_depth]);
        }
        translate([w1, h_high, 0]) {
            cube([w2, pl_thickness_y, pl_depth]);
        }
    }
}

// Draw reinforcement bars (not used anymore)
module bars()
{
    x0 = is_next_black(0) ? black_key_x(0) : is_next_black(1) ? black_key_x(1) : -1;
    x1 = is_prev_black(notes_count-1) ? black_key_x(notes_count-2) : is_next_black(notes_count-2) ? black_key_x(notes_count-3) : -1;

    if (x0 != -1 && x1 != -1)
    {
        translate([x0 - pl_thickness_x - pl_margin, high_height(), 0]) {
            cube([x1-x0 + 2 * (pl_thickness_x + pl_margin) + b_width, pl_thickness_y, pl_thickness_z]);
        }
        translate([x0 - pl_thickness_x - pl_margin, high_height(), pl_depth - pl_thickness_z]) {
            cube([x1-x0 + 2 * (pl_thickness_x + pl_margin) + b_width, pl_thickness_y, pl_thickness_z]);
        }
    }

}

// Draw the WS8212 PCBs footprints in the frame
module footprints()
{
    union() {
        for (i = [0:notes_count-1]) {
            falling = is_prev_black(i);
            rising  = is_next_black(i);

            // White key alone
            if (!falling && !rising)
            {
                dx = (white_key_x(i+1) + white_key_x(i) - fp_width) / 2;
                dy = low_height() + pl_thickness_y - fp_height;
                dz = (pl_depth - fp_depth) / 2;
                translate([dx, dy, dz]) cube([fp_width, fp_height, fp_depth]);
            }

            // White key followed by black key, print footprint on white key
            if (!falling && rising)
            {
                w_key_x = white_key_x_nogap(i);
                dx = (black_key_x(i) + w_key_x - pl_thickness_x - pl_margin - fp_width) / 2;
                dy = low_height() + pl_thickness_y - fp_height;
                dz = (pl_depth - fp_depth) / 2;
                translate([dx, dy, dz]) cube([fp_width, fp_height, fp_depth]);
            }

            // White key precedeed by black key, print footprint on white key
            if (falling && !rising)
            {
                w_key_x = white_key_x(i+1) - w_gap/2;
                dx = (w_key_x + black_key_x(i-1) + b_width_low + pl_thickness_x + pl_margin - fp_width) / 2;
                dy = low_height() + pl_thickness_y - fp_height;
                dz = (pl_depth - fp_depth) / 2;
                translate([dx, dy, dz]) cube([fp_width, fp_height, fp_depth]);
            }

            // White key between two black keys, print footprint on white key
            if (falling && rising)
            {
                // Position to the middle of black keys:
                dx = (black_key_x(i) + black_key_x(i-1) + b_width_low - fp_width) / 2;
                dy = low_height() + pl_thickness_y - fp_height;
                dz = (pl_depth - fp_depth) / 2;
                translate([dx, dy, dz]) cube([fp_width, fp_height, fp_depth]);
            }

            // Print footprint on black key
            if (rising)
            {
                // Footprint on black key
                dx2 = black_key_x(i) + (b_width_low - fp_width)/ 2;
                dy2 = high_height() + pl_thickness_y - fp_height;
                dz2 = (pl_depth - fp_depth) / 2;
                translate([dx2, dy2, dz2]) cube([fp_width, fp_height, fp_depth]);
            }
        }
    }
}

// Draw message from version.txt file under E and F notes. If not present, draw nothing
// pl_version_string is read from ../version.txt
module pl_version()
{
    // Find position of F & E notes, this is where we'll have enough room to write
    first_e = (7 + 2 - first_note) % 7;
    next_f = first_e + 1;

    if (next_f >= notes_count) {
        picawarning();
        echo("E and F notes are needed to print version string !");
    }
    else {
        // Center text between beginning of E low part and end of F low part
        e_low_part = is_first_white(first_e) ? w_gap : black_key_x(first_e - 1) + b_width_low + pl_margin;
        f_low_part = is_last_white(next_f) ? white_key_x(next_f) + w_width : black_key_x(next_f);
        dx = (e_low_part + f_low_part) / 2;
        dz = (pl_depth - msg_font_size) / 2;
        translate([dx, low_height() + msg_depth, dz]) {
            rotate([90, 0, 0]) {
                linear_extrude(height=msg_depth) {
                    text(pl_version_string , font = "Liberation Sans", size=msg_font_size, halign="center");
                }
            }
        }
    }
}

// Draw the whole keyboard, based on notes_count and first_note
module draw_keyboard()
{
    for (i = [0:notes_count-1]) {
        white_key(i);
        
        if (is_next_black(i))
            black_key(i);
    }
}

// Draw white key i
module white_key(i) {
    difference() {
        color("White") {
        translate([w_gap/2 + i * (w_width + w_gap), 0, 0]) cube([w_width, w_height, w_depth]);
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
    (i + 1 == notes_count)
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
    b_jitters[(i+first_note)%7]
);

// draw black key following white key i
module black_key(i) {
    wl = b_width_low;   // low  width , x axis
    wh = b_width_high;  // high width , x axis
    hl = b_height_low;  // low  height, y axis
    hh = b_height_high; // high height, y axis
    dl = b_depth_low;   // low  depth , z axis
    dh = b_depth_high;  // high depth , z axis
    
    dy = 0; // Starting height of black keys (debug)
    
    // Black key shape, starting from 0
    bk_points = [
        [ 0, dy, 0], // 0
        [ 0, dy,dl], // 1
        [wl, dy,dl], // 2
        [wl, dy, 0], // 3
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
