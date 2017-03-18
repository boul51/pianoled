include <../version.txt>
include <parameters.scad>
include <common_modules.scad>

// disable footprints on white/black keys
enable_w_footprints = false;
enable_b_footprints = false;

// Message definitions (text is read from textcontents.txt)
msg_depth     = 1;
msg_font_size = 6;

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
        cable_guides();
        pl_version();
    }
}

// Draw the whole plastic frame, based on notes_count and first_note
module frame()
{
    union() {
        color("purple") {
            translate([w_gap/2, low_height(), 0]) {
                cube([pl_thickness_x, pl_height+pl_thickness_y, pl_depth]);
            }
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
            translate([7*(w_width + w_gap)-w_gap/2-pl_thickness_x, low_height(), 0]) {
                cube([pl_thickness_x, pl_height+pl_thickness_y, pl_depth]);
            }
            //bars(); // Uncomment this to draw reinforcement bars
        }
        color("grey") {
            translate([7,light_guide_height+low_height()+1,pl_depth/2]){
                light_guide();
            }
            translate([35.5,light_guide_height+low_height()+1,pl_depth/2]){
                light_guide();
            }
            translate([64,light_guide_height+low_height()+1,pl_depth/2]){
                light_guide();
            }
            translate([76,light_guide_height+low_height()+1,pl_depth/2]){
                light_guide();
            }
            translate([104.75,light_guide_height+low_height()+1,pl_depth/2]){
                light_guide();
            }
            translate([131.75,light_guide_height+low_height()+1,pl_depth/2]){
                light_guide();
            }
            translate([159,light_guide_height+low_height()+1,pl_depth/2]){
                light_guide();
            }
        }
    }
}

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
                // TODO INSERT GUIDE
                
                cube([w_width / 2, pl_thickness_y, pl_depth]);
                
                // Add the vertical part at the back of the key
                cube([w_width / 2, pl_height + pl_thickness_y_top, pl_thickness_z]);
            }
        }
        else if (is_last_white(i) && !is_first_half) {
            // Avoid to cover the gap on the right for the last white key
            translate([0, h_low, 0]) {
                cube([w_width / 2, pl_thickness_y, pl_depth]);
                
                // Add the vertical part at the back of the key
                cube([w_width / 2, pl_height + pl_thickness_y_top, pl_thickness_z]);
            }
        }
        else {
            translate([0, h_low, 0]) {
                cube([(w_width + w_gap) / 2, pl_thickness_y, pl_depth]);
                
                // Add the vertical part at the back of the key
                cube([(w_width + w_gap) / 2, pl_height + pl_thickness_y_top, pl_thickness_z]);
            }
        }
    }
    else if (falling) {
        w1  = b_width / 2 + pl_margin + pl_thickness_x + get_b_jitter(i-1);
        w2  = (w_width + w_gap) / 2 - w1;
        translate([0, h_high, 0]) {
            cube([w1, pl_thickness_y_top, pl_depth]);
        }
        translate([w1 - pl_thickness_x, h_low, 0]) {
            cube([pl_thickness_x, pl_height, pl_depth]);
        }
        translate([w1, h_low, 0]) {
            cube([w2, pl_thickness_y, pl_depth]);
            // Add the vertical part at the back of the key
            cube([w2, pl_height + pl_thickness_y_top, pl_thickness_z]);
        }
    }
    else {
        w2  = b_width / 2 + pl_margin + pl_thickness_x - get_b_jitter(i);
        w1  = (w_width + w_gap) / 2 - w2;
        translate([0, h_low, 0]) {
            cube([w1, pl_thickness_y, pl_depth]);
            // Add the vertical part at the back of the key
            cube([w1, pl_height + pl_thickness_y_top, pl_thickness_z]);
        }
        translate([w1, h_low, 0]) {
            cube([pl_thickness_x, pl_height, pl_depth]);
        }
        translate([w1, h_high, 0]) {
            cube([w2, pl_thickness_y_top, pl_depth]);
        }
    }
}

module light_guide()
{
  
    rotate([90,0,0]){
        difference(){
            cylinder(light_guide_height, d1=light_guide_dout, 
                d2=light_guide_dout, center=false, $fn=light_guide_fn);
            cylinder(light_guide_height, d1=light_guide_din, 
            d2=light_guide_din, center=false, $fn=light_guide_fn);
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

// Draw guides for ribbon
module cable_guides()
{
    dx = 0;
    dy = high_height()+ pl_thickness_y_top - cable_height ;
    
    union(){    
        dz = 2;
        translate([dx, dy, dz]) cube([cable_length, cable_height, cable_width]);
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
