
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
pl_thickness_y = 4;   // horizontal thickness on y axis
pl_thickness_y_top = 6;   // horizontal thickness on y axis
pl_thickness_z = 2;   // horizontal thickness on z axis (ie bars)

// PCB footprint parameters
fp_width    = 10;
fp_height   = 4;
fp_depth    = 10;

// Cable guides parameters
cable_width = 1; // width of the guide
cable_height = 2; // height of the guide
cable_length = 168; // length of the guide

// Define first note and number of white keys
first_note  = 0; // 0 is C, 1 is D, etc...
notes_count = 7; // Number of white keys to draw
