include <parameters.scad>

// Draw the WS8212 PCBs footprints in the frame
module footprints()
{
    union() {
        for (i = [0:notes_count-1]) {
            falling = is_prev_black(i);
            rising  = is_next_black(i);

            // White key alone
            if (!falling && !rising && enable_w_footprints)
            {
                dx = (white_key_x(i+1) + white_key_x(i) - fp_width) / 2;
                dy = low_height() + pl_thickness_y - fp_height;
                dz = (pl_depth - fp_depth) / 2;
                translate([dx, dy, dz]) cube([fp_width, fp_height, fp_depth]);
            }

            // White key followed by black key, print footprint on white key
            if (!falling && rising  && enable_w_footprints)
            {
                w_key_x = white_key_x_nogap(i);
                dx = (black_key_x(i) + w_key_x - pl_thickness_x - pl_margin - fp_width) / 2;
                dy = low_height() + pl_thickness_y - fp_height;
                dz = (pl_depth - fp_depth) / 2;
                translate([dx, dy, dz]) cube([fp_width, fp_height, fp_depth]);
            }

            // White key precedeed by black key, print footprint on white key
            if (falling && !rising  && enable_w_footprints)
            {
                w_key_x = white_key_x(i+1) - w_gap/2;
                dx = (w_key_x + black_key_x(i-1) + b_width_low + pl_thickness_x + pl_margin - fp_width) / 2;
                dy = low_height() + pl_thickness_y - fp_height;
                dz = (pl_depth - fp_depth) / 2;
                translate([dx, dy, dz]) cube([fp_width, fp_height, fp_depth]);
            }

            // White key between two black keys, print footprint on white key
            if (falling && rising && enable_w_footprints)
            {
                // Position to the middle of black keys:
                dx = (black_key_x(i) + black_key_x(i-1) + b_width_low - fp_width) / 2;
                dy = low_height() + pl_thickness_y - fp_height;
                dz = (pl_depth - fp_depth) / 2;
                translate([dx, dy, dz]) cube([fp_width, fp_height, fp_depth]);
            }

            // Print footprint on black key
            if (rising && enable_b_footprints)
            {
                // Footprint on black key
                dx2 = black_key_x(i) + (b_width_low - fp_width)/ 2;
                dy2 = high_height() + pl_thickness_y_top - fp_height;
                dz2 = (pl_depth - fp_depth) / 2;
                translate([dx2, dy2, dz2]) cube([fp_width, fp_height, fp_depth]);
            }
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