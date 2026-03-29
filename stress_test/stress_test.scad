/* 
Stress Test
Purpose: Test for the max torque of a 3D printed spur gear. 

Components: 
> G1: Driven Gear 
> G2: Drive Gear
> S: Fixed structure
> R: Lever Arm Metal Rod

Method: 
1) Connect the shaft key of G1 to a shaft key opening in S. 
2) Add a hole in the shaft key of G2 with enough opening for a tight hold on R. 
3) Connect a force gauge to a measured length along R. 
4) Pull downwards on the force gauge and record the force at which the gear breaks. 
5) Compute torque T = r x F.
*/

// ========== IMPORTS ========== //
/*
spur_gear(
    shaft_d,
    thickness,
    module_val, 
    pressure_angle,
    number_of_teeth,
    shift_coefficient,
    key_shaft_d,
    key_width
)
key_shaft(
    shaft_d, 
    shaft_height, 
    key_width
)
key(
    shaft_height, 
    key_width
)
*/
use <spur_gear.scad>;

// ========== GLOBAL ========== //
$fn = 100;

// ========== CONSTANTS ========== // 
/*
Ball Bearing Stock: 
    > 3.175mm
        > ID: 3.175mm | OD: 9.525mm | H: 3.6875mm |
    > 5mm
        > ID: 5mm | OD: 14mm | H: 5mm |
    > 6.35mm 
        > ID: 6.35mm | OD: 15.875mm | H: 4.9784mm
    > 8mm 
        > Model 698 -- ID: 8mm | OD: 19mm | H: 6mm <--
        > Model 608 -- ID: 8mm | OD: 22mm | H: 7mm
        > Model 628 -- ID: 8mm | OD: 24mm | H: 8mm
    > 17mm 
        > Model 6903 -- ID: 17mm | OD: 30mm | H: 7mm <--
        > Model 6003 -- ID: 17mm | OD: 35mm | H: 10mm
        > Model 6203 -- ID: 17mm | OD: 40mm | H: 12mm
*/
bb_698_id = 8;
bb_698_od = 19;
bb_698_h = 6;

bb_6903_id = 17;
bb_6903_od = 30;
bb_6903_h = 7;
// ========== VARIABLES ========== //


// ========== LOGIC ========== //


// ========== STRUCTURES ========== //
module base_structure_frame(
    length, //center distance of the chosen gears
    height, //must be greater than the addendum diameter of the chosen gears
    support_rod_d = 5.25,
    key_shaft_d,
    key_width,
    bb_id,
    bb_od,
    bb_h
) {
    //driver
    difference() {
        //base
        cube([2 * length, bb_h, height], center = true);

        //driver 
        translate([length / 2, 0, 0])
            rotate([90, 0, 0])
                cylinder(d = bb_od, h = bb_h * 2, center = true);

        //driven 
        translate([-length / 2, 0, 0])
            rotate([90, 0, 0])
                    union() {
                        key_shaft(key_shaft_d, bb_h, key_width);
                        translate([key_shaft_d / 3, 0, 0])
                            key(bb_h, key_width);
                    }

        //support 
        translate([-length + support_rod_d, 0, -height / 2 + support_rod_d])
            rotate([90, 0, 0])
                cylinder(d = support_rod_d, h = 100, center = true);
        translate([length - support_rod_d, 0, -height / 2 + support_rod_d])
            rotate([90, 0, 0])
                cylinder(d = support_rod_d, h = 100, center = true);                
    }
}

//Print with 100% infill
module modified_key_shaft(
    key_shaft_height,
    key_shaft_d,
    key_width
) {
    difference() {
        key_shaft(key_shaft_d, key_shaft_height, key_width);
        // Use three for positioning optionality
        translate([0, 0, key_shaft_height / 2 - 5.25])
            rotate([0, 90, 0])
                cylinder(d = 5.25, h = 100, center = true);
        translate([0, 0, 0])
            rotate([0, 90, 0])
                cylinder(d = 5.25, h = 100, center = true);
        translate([0, 0, -key_shaft_height / 2 + 5.25])
            rotate([0, 90, 0])
                cylinder(d = 5.25, h = 100, center = true);
    }
}

// ========== ASSEMBLY ========== //
gear_thickness = 10;
m = 2;
z = 24;
pa = 20;
key_shaft_d = 17;
key_width = 17 / 2;

spur_gear(
    shaft_d = 5.25, //Remove if using shaft key
    thickness = gear_thickness, 
    module_val = m, 
    pressure_angle = pa, 
    number_of_teeth = z, 
    shift_coefficient = 0,
    key_shaft_d = key_shaft_d,
    key_width = key_width
);

spur_gear(
    shaft_d = 5.25, //Remove if using shaft key
    thickness = gear_thickness, 
    module_val = m, 
    pressure_angle = pa, 
    number_of_teeth = z, 
    shift_coefficient = 0,
    key_shaft_d = key_shaft_d,
    key_width = key_width
);

/* 
Thoughts: 
Consider that the shaft of the driven gear needs to extend through either a thrust bearing 
    or a ball bearing to allow for rotation while trying to drive the fixed shaft driven gear. 

This means the key shaft (the key doesn't matter because the shaft can extend beyond) needs to 
    have a radius compatible with an in-stock bearing.

    Choice 1: Model 698 -- ID: 8mm | OD: 19mm | H: 6mm
    Choice 2: Model 6903 -- ID: 17mm | OD: 30mm | H: 7mm

GOOD GENERAL RULE: 
> Key shafts and keys should be printed with a high infill  
*/
center_distance = m*z;
addendum_radius = m * (z + 1);

base_structure_frame(
    center_distance,
    addendum_radius + 10,
    5.25,
    key_shaft_d,
    key_width, 
    bb_698_id,
    bb_698_od,
    bb_698_h
);

base_structure_frame(
    center_distance,
    addendum_radius + 10,
    5.25,
    key_shaft_d,
    key_width, 
    bb_6903_id,
    bb_6903_od,
    bb_6903_h
);

!modified_key_shaft(
    50,
    key_shaft_d,
    key_width
);