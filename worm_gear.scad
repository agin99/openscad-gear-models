/*
===== Gear Design: Worm Gear =====
- Inputs:
    > Module Value (m) - Determines tooth size and strength
    > Pressure Angle (pa) - Determines the force transmission and contact
    Worm Diameter Factor (q) - Determines the worm pitch diameter
    > Number of Turns (n_turns) - Determines the physical length of the worm shaft
    > Number of Starts (n_starts) - Determines the speed and efficiency 
    > Number of Wheel Teeth (n_wheel) - Determines the gear reduction ratio

- Compatibility Dependence: Worm Wheel Partner
    > Center Distance () - 

- Parameters:

*/

/*
===== Tooth Design:  =====

*/

// ========== IMPORTS ========== //
use <spur_gear.scad>;
use <rack_pinion.scad>;

// ========== GLOBAL ========== //
$fn = 100;

// ========== CONSTANTS ========== // 


// ========== VARIABLES ========== //


// ========== LOGIC ========== //


// ========== STRUCTURES ========== //
module worm_tooth(
    m, 
    pa,
    r
) {
    translate([r, 0, 0])
        rotate([0, 90, 0])
            rotate([90, 0, 0])
                linear_extrude(1)
                    rack_tooth(
                        m, 
                        pa
                    );
}

// m - module value
// pa - pressure angle
// r - center distance
// n_turns - number of turns
// n_starts - number of starts (only supports 1 to start)
module worm_gear(
    m,
    pa,
    q,
    n_turns,
    n_starts
) {
    assert(n_starts == 1, "Only supports single helix worm gear for now");

    r = m * q / 2;
    lead = PI * m * n_starts;

    intersection() {
        translate([0, 0, lead * n_turns / 2])
            cylinder(r = r * 2, h = lead * n_turns, center = true);
        union() {
            translate([0, 0, lead * n_turns / 2])
                cylinder(r = r + m, h = lead * n_turns, center = true);
            for(i = [0 : 360 * n_turns]) {
                hull() {
                    translate([0, 0, i * lead / 360])
                        rotate([0, 0, i])
                            worm_tooth(m, pa, r);
                    translate([0, 0, (i + 1) * lead / 360])
                        rotate([0, 0, (i + 1)])
                            worm_tooth(m, pa, r);
                }
            }
        }
    }
}

module worm_gear_key_shaft(
    m,
    pa,
    q,
    n_turns,
    n_starts,
    key_shaft_d,
    key_width
) {
    lead = PI * m * n_starts;
    difference() {
        worm_gear(
            m,
            pa,
            q,
            n_turns,
            n_starts
        );
        translate([0, 0, lead * n_turns / 2])
        union() {
            key_shaft(key_shaft_d, lead * n_turns, key_width);
            translate([key_shaft_d / 3, 0, 0])
                key(lead * n_turns, key_width);
        }
    }
}

module worm_wheel(
    wheel_thickness,
    key_shaft_d, 
    m,
    pa,
    q,
    n_starts,
    n_wheel
) {
    worm_wheel_pitch_r = m * n_wheel / 2;
    worm_gear_pitch_r = m * q / 2; 

    center_distance = worm_gear_pitch_r + worm_wheel_pitch_r; 

    difference() {
        translate([0, 0, -wheel_thickness / 2])
            spur_gear(
                thickness = wheel_thickness, 
                module_val = m, 
                pressure_angle = pa, 
                number_of_teeth = n_wheel, 
                shift_coefficient = 0,
                key_shaft_d = key_shaft_d,
                key_width = key_shaft_d / 2
            );

        rotate_extrude(angle=360)
            translate([center_distance, 0, 0])
                circle(r = worm_gear_pitch_r);
    }
}

// ========== BUILD ========== //


// ========== ASSEMBLY ========== //
wheel_thickness = 10;
key_shaft_d = 17;
m = 2;
pa = 20;
q = 10;
n_turns = 5;
n_starts = 1;
n_wheel = 24;

worm_gear(
    m, 
    pa, 
    q, 
    n_turns,
    n_starts
);

worm_wheel(
    wheel_thickness,
    key_shaft_d,
    m,
    pa,
    q,
    n_starts,
    n_wheel
);

!worm_gear_key_shaft(
    m, 
    pa, 
    q, 
    n_turns,
    n_starts,
    key_shaft_d,
    key_shaft_d / 2
);