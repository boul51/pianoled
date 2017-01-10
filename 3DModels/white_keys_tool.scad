
pcb_size_z = 8;
pcb_size_x = 8;

tool_size_x = 80;
tool_size_y = 1.5;
tool_size_z = 10;

fork_size_x = pcb_size_x;

bridge_size_x = pcb_size_x;
bridge_size_y = 10;
bridge_size_z = tool_size_y;

top_size_x = bridge_size_x;
top_size_y = bridge_size_z;
top_size_z = tool_size_z;

// Offset of hole centers
hole_off_x = 1.5;
hole_off_z = 3;
hole_diameter = 0.5;

hole_centers = [
    [hole_off_x, 0, hole_off_z],
    [pcb_size_x - hole_off_x, 0, hole_off_z],
    [pcb_size_x - hole_off_x, 0, pcb_size_z - hole_off_z],
    [hole_off_x, 0, pcb_size_z - hole_off_z]
];
    

tool();

module tool()
{
    union() {
        fork();
        difference() {
            bridge();
            holes();
        }
    }
}

module fork()
{
    difference() {
        translate([0, 0, -tool_size_z / 2]) {
            cube([tool_size_x, tool_size_y, tool_size_z]);
        }
        translate([tool_size_x - fork_size_x, 0, -pcb_size_z / 2]) {
            cube([fork_size_x, tool_size_y, pcb_size_z]);
        }
    }
}

module bridge()
{
    bridge_pos_x = tool_size_x - fork_size_x;
    bridge_pos_z = -tool_size_z / 2 - bridge_size_z;
    translate([bridge_pos_x, 0, bridge_pos_z]) {
        cube([bridge_size_x, bridge_size_y, bridge_size_z]);
    }
    top_pos_x = bridge_pos_x;
    top_pos_y = bridge_size_y;
    top_pos_z = bridge_pos_z;
    translate([top_pos_x, top_pos_y, top_pos_z]) {
        cube([top_size_x, top_size_y, top_size_z + top_size_y]);
    }
}

module holes()
{
    bridge_pos_x = tool_size_x - fork_size_x;
    bridge_pos_z = -tool_size_z / 2 - bridge_size_z;

    translate([bridge_pos_x, bridge_size_y + top_size_y, -pcb_size_z / 2]) {
        for (i = [0: 3]) {
            translate(hole_centers[i]) {
                rotate([90, 0, 0]) {
                    cylinder(top_size_y, d=hole_diameter, $fn=50);
                }
            }
        }
    }
}