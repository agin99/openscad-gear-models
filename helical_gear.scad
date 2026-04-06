/*  
===== Gear Design: Helical Gear =====
- Inputs: 
    > Module Value (m) - Determines tooth size
    > Pressure Angle (pa) - Determines the line of action between two teeth
    > Helix Angle (ha) - Determines the torsion angle of the gear teeth
    > Tooth Count (z) - Determines the amount of teeth on a gear

- Compatibility Dependence: Right-Left Gear
    > 

- Parameters: 
    > 
*/

/*
===== Tooth Design:  =====
Steps: 
1) Start with a projection of a spur gear.
2) Linear extrude with height set at the desired thickness and twist set at the torsion angle.
*/

// ========== IMPORTS ========== //
use <spur_gear.scad>;

// ========== GLOBAL ========== //
$fn = 100;

// ========== CONSTANTS ========== // 


// ========== VARIABLES ========== //


// ========== LOGIC ========== //


// ========== STRUCTURES ========== //
module transverse_helical_gear(
    shaft_d,
    thickness,
    module_val, 
    pressure_angle,
    helix_angle,
    number_of_teeth,
    shift_coefficient,
    key_shaft_d,
    key_width
) {
    twist_angle = 360 * thickness * tan(helix_angle) / (PI * module_val * number_of_teeth);
    transverse_pressure_angle = atan(tan(pressure_angle) / cos(helix_angle));

    difference() {
        linear_extrude(height = thickness, twist = twist_angle)
        projection(cut = true)
            union() {
                translate([0, 0, thickness / 2])
                union() {
                    key_shaft(key_shaft_d, thickness, key_width);
                    translate([key_shaft_d / 3, 0, 0])
                        key(thickness, key_width);
                }
                spur_gear(
                    thickness = thickness, 
                    module_val = module_val, 
                    pressure_angle = transverse_pressure_angle, 
                    number_of_teeth = number_of_teeth, 
                    shift_coefficient = 0,
                    key_shaft_d = key_shaft_d,
                    key_width = key_width
                );
            }
        translate([0, 0, thickness / 2])
            union() {
                key_shaft(key_shaft_d, thickness, key_width);
                translate([key_shaft_d / 3, 0, 0])
                    key(thickness, key_width);
            }
    }
}

module normal_helical_gear(
    shaft_d,
    thickness,
    module_val, 
    pressure_angle,
    helix_angle,
    number_of_teeth,
    shift_coefficient,
    key_shaft_d,
    key_width
) {
    twist_angle = 360 * thickness * sin(helix_angle) / (PI * module_val * number_of_teeth);
    transverse_pressure_angle = atan(tan(pressure_angle) / cos(helix_angle));

    difference() {
        linear_extrude(height = thickness, twist = twist_angle)
        projection(cut = true)
            union() {
                translate([0, 0, thickness / 2])
                union() {
                    key_shaft(key_shaft_d, thickness, key_width);
                    translate([key_shaft_d / 3, 0, 0])
                        key(thickness, key_width);
                }
                spur_gear(
                    thickness = thickness, 
                    module_val = module_val / cos(helix_angle), 
                    pressure_angle = transverse_pressure_angle, 
                    number_of_teeth = number_of_teeth, 
                    shift_coefficient = 0,
                    key_shaft_d = key_shaft_d,
                    key_width = key_width
                );
            }
        translate([0, 0, thickness / 2])
            union() {
                key_shaft(key_shaft_d, thickness, key_width);
                translate([key_shaft_d / 3, 0, 0])
                    key(thickness, key_width);
            }
    }
}

// ========== ASSEMBLY ========== //
//Left hand
*transverse_helical_gear(
    shaft_d = 5.25, //Remove if using shaft key 
    thickness = 10, 
    module_val = 2, 
    pressure_angle = 20, 
    helix_angle = 20,
    number_of_teeth = 24, 
    shift_coefficient = 0,
    key_shaft_d = 17,
    key_width = 17 / 2
);

//Right hand
*transverse_helical_gear(
    shaft_d = 5.25, //Remove if using shaft key 
    thickness = 10, 
    module_val = 2, 
    pressure_angle = 20, 
    helix_angle = -20,
    number_of_teeth = 24, 
    shift_coefficient = 0,
    key_shaft_d = 17,
    key_width = 17 / 2
);

//Left hand
*normal_helical_gear(
    shaft_d = 5.25, //Remove if using shaft key 
    thickness = 10, 
    module_val = 2, 
    pressure_angle = 20, 
    helix_angle = 20,
    number_of_teeth = 24, 
    shift_coefficient = 0,
    key_shaft_d = 17,
    key_width = 17 / 2
);

//Right hand
*normal_helical_gear(
    shaft_d = 5.25, //Remove if using shaft key 
    thickness = 10, 
    module_val = 2, 
    pressure_angle = 20, 
    helix_angle = -20,
    number_of_teeth = 24, 
    shift_coefficient = 0,
    key_shaft_d = 17,
    key_width = 17 / 2
);