include <parameters.scad>
include <common_modules.scad>

// disable footprints on white keys
enable_w_footprints = false;
thickness_y = pl_thickness_y;

tool_size_x = notes_count * w_width + (notes_count - 1) * w_gap;
tool_size_z = pl_depth * 2;
tool_size_y = 2.5;
fp_height   = 2.5; // Override depth of footprints. Must be equal to tool_size_y

dy = high_height() + pl_thickness_y - fp_height;
dz = (pl_depth) / 2;

difference() {
    translate([0, 0, -tool_size_z / 2]) {
        cube([tool_size_x, tool_size_y, tool_size_z]);
    }
    translate([0, -dy, -dz]) {
        footprints();
    }
}
