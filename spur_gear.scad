/*  
===== Gear Design: Spur Gear =====
- Inputs: 
    > Module Value (m) - Determines tooth size
    > Pressure Angle (pa) - Determines the line of action between two teeth
    > Tooth Count (z) - Determines the amount of teeth on a gear

- Compatibility Dependence: Spur Gear Partner
    > Module Value (m)
    > Pressure Angle (pa)

- Parameters: 
    > Pitch Circle: Two meshed gears interact along a common tangent line defined the pitch circle.
        >> D_{p} = mz 

    > Pitch: Length of the arc from a fixed point on the face of two adjacent teeth. 
        >> p = m * π

    > Addendum: Distance from pitch circle to tooth top.
        >> m = p / π

    > Dedendum: Distance from root circle to pitch circle.
        >> b = 1.25 * m

    > Addendum Circle: Circle that circumscribes the gear. 
        >> D = D_{p} + 2*m 
    
    > Root Circle: Circle inscribed by the bottom of the gear teeth.  
        >> D_{r} = D_{p} - 2*b

    > Base Circle: Used to determine the involute tooth profile.
        >> D_{b} = D_{p} * cos(pa)

    > Tooth Height:
        >> h = m + b
*/

/*
===== Tooth Design: Involute =====
The involute tooth profile is designed such that any point of contact between a conjugate pair of 
    involute teeth results in perpendicular points of contact that are tangent to the base circle 
    from which the teeth were defined. With this profile, line of action between the teeth of two 
    meshed gears passes through the pitch point of the gear setup and obeys the Fundamental Law of 
    Gearing.

Steps: 
1) Start at a position on the base circle and mark it as the starting point of the involute. 
2) Move one pitch length along the circle. 
3) Draw a line tangent to the new position on the circle extending one pitch length from that position. 
4) Move one more pitch length along the circle. 
5) Draw a line tangent to the new position on the circle extending two pitch lengths from that position. 
6) Continue steps (4) and (5) until you've completed three cycles of this. 
7) The involute can be drawn using the end of each line as reference points for the function. 
*/

// ========== IMPORTS ========== //


// ========== GLOBAL ========== //
$fn = 100;

// ========== CONSTANTS ========== // 


// ========== VARIABLES ========== //


// ========== LOGIC ========== //
function get_involute_points(rb, max_t = 3, steps = 180) = 
    concat([[0,0]], [
        for (i = [0 : steps]) 
            let (t = i * max_t / steps) 
            [
                rb * (cos(t * 180/PI) + t * sin(t * 180/PI)), 
                rb * (sin(t * 180/PI) - t * cos(t * 180/PI))  
            ]
    ]);

/* 
- Acts along pitch circle tangent. 
- Captures the useful leverage (think Gibbs Free Energy)
- Assumes unit torque
*/
function tangential_force(rb, pa) = cos(pa) / rb;

/* 
- Acts along the radius of the gear towards the center of the shaft. 
- Captures the penalty of the pressure angle (think Entropy)
- Assumes unit torque
*/
function radial_force(rb, pa) = sin(pa) / rb;

/* 
- Acts along the line of action
- Captures the absolute contact load (think Enthalpy)
- Assumes unit torque 

Derivation of Resultant Force, F_{n} = \frac{1}{rb}

F_{t} = \frac{cos(pa)}{rb}
F_{r} = \frac{sin(pa)}{rb}
F_{n}^{2} = F_{t}^{2} + F_{r}^{2}
        = (\frac{cos(pa)}{rb})^{2} + (\frac{sin(pa)}{rb})^{2}
        = (\frac{1}{rb})^{2} * [cos(pa)^{2} + sin(pa)^{2}]
        = (\frac{1}{rb})^{2}

F_{n} = sqrt{(\frac{1}{rb})^{2}}
      = \frac{1}{rb} [QED]
*/
function resultant_force(rb) = 1 / rb;

// ========== STRUCTURES ========== //
// z - number of teeth
// pa - pressure angle
// ra - addendum radius (already shifted)
// x - shift coefficient
module tooth(
    full_involute_points, 
    z, 
    pa, 
    ra, 
    x = 0
) {
    pa_rad = pa * PI / 180;
    shift_angle_rad = ((PI / 2) + (2 * x * tan(pa))) / z;
    
    inv_pa = tan(pa) - pa_rad;    
    tooth_width_angle = (shift_angle_rad + inv_pa) * 180 / PI;

    intersection() {
        circle(ra);
        rotate([0, 0, -tooth_width_angle])
            polygon(full_involute_points);
        mirror([0, 1, 0])
            rotate([0, 0, -tooth_width_angle])
                polygon(full_involute_points);
    }   
}

module spur_gear_base(
    module_val,
    pressure_angle,
    number_of_teeth,
    shift_coefficient
) {
    pitch_d = module_val * number_of_teeth;
    pitch_r = pitch_d / 2;
    addendum = module_val;
    dedendum = 1.25 * module_val;
    
    addendum_r = pitch_r + (1 + shift_coefficient) * addendum;
    root_r = pitch_r - dedendum + shift_coefficient * module_val;
    base_r = pitch_r * cos(pressure_angle);
    
    full_involute_points = get_involute_points(base_r);

    circle(root_r);
    
    for (i = [0 : number_of_teeth - 1]) {
        angle = i * 360 / number_of_teeth;
        rotate([0, 0, angle])
            tooth(full_involute_points, number_of_teeth, pressure_angle, addendum_r, shift_coefficient);
    }
}

module spur_gear(
    thickness,
    module_val, 
    pressure_angle,
    number_of_teeth,
    shift_coefficient,
    key_shaft_d,
    key_width
) {
    difference() {
        linear_extrude(thickness, convexity = 10)
            spur_gear_base(module_val, pressure_angle, number_of_teeth, shift_coefficient);
        translate([0, 0, thickness / 2])
            union() {
                key_shaft(key_shaft_d, thickness, key_width);
                translate([key_shaft_d / 3, 0, 0])
                    key(thickness, key_width);
            }
    }
}

module spur_gear_force_overlay(
    thickness,
    module_val, 
    pressure_angle,
    number_of_teeth,
    shift_coefficient,
    key_shaft_d,
    key_width,
    min_ft = 0,
    max_fr = 1, 
    max_fn = 1
) {
    pitch_d = module_val * number_of_teeth;
    pitch_r = pitch_d / 2;
    addendum = module_val;
    dedendum = 1.25 * module_val;
    
    addendum_r = pitch_r + (1 + shift_coefficient) * addendum;
    root_r = pitch_r - dedendum + shift_coefficient * module_val;
    base_r = pitch_r * cos(pressure_angle);

    assert(tangential_force(base_r, pressure_angle) > min_ft, "Tangential force too small.");
    assert(radial_force(base_r, pressure_angle) < max_fr, "Radial force too large.");
    assert(resultant_force(base_r) < max_fn, "Resultant force too large.");

    rotate([0, 0, (360 / 4) / number_of_teeth])
        spur_gear(
            thickness, 
            module_val, 
            pressure_angle, 
            number_of_teeth, 
            shift_coefficient,
            key_shaft_d,
            key_width
        );

    translate([module_val * number_of_teeth, 0, 0])
        rotate([0, 0, (360 / 4) / number_of_teeth])
            spur_gear(
                thickness, 
                module_val, 
                pressure_angle, 
                number_of_teeth, 
                shift_coefficient,
                key_shaft_d,
                key_width
            );

    rotate([0, 0, -pressure_angle]) {
        %color("blue", 0.5)
            translate([base_r, -base_r])
                linear_extrude(20)
                    square([0.05, 2 * base_r]);
    }

    %color("green", 0.5)
        translate([pitch_r, -pitch_r])
            linear_extrude(20)
                square([0.05, 2 * pitch_r]);
}

module key_shaft(
    shaft_d, 
    shaft_height, 
    key_width
) {
    difference() {
        cylinder(d = shaft_d, h = shaft_height, center = true);
        translate([shaft_d / 3, 0, 0])
            cube([key_width, key_width, shaft_height], center = true);
    }
}

module key(
    shaft_height, 
    key_width
) {
    cube([key_width, key_width, shaft_height], center = true);
}


// Positive: High-performance, high-strength, but "fussy" (requires high precision for initial mesh)
// Negative: Low-performance, lower-strength, but "compliant" (high tolerance for automated assembly errors).
module profile_shifted_spur_gear(
    thickness,
    module_val, 
    pressure_angle,
    number_of_teeth,
    shift_coefficient,
    key_shaft_d,
    key_width
) {
    z_min = 2 / pow(sin(pressure_angle), 2);
    x_min = (z_min - number_of_teeth) / z_min;

    assert(shift_coefficient > x_min, "Risk of undercutting, adjust shift_coefficient");

    spur_gear(
        thickness = thickness, 
        module_val = module_val, 
        pressure_angle = pressure_angle, 
        number_of_teeth = number_of_teeth, 
        shift_coefficient = shift_coefficient,
        key_shaft_d = key_shaft_d,
        key_width = key_width
    );
}

// ========== ASSEMBLY ========== //
*spur_gear(
    thickness = 10, 
    module_val = 2, 
    pressure_angle = 20, 
    number_of_teeth = 24, 
    shift_coefficient = 0,
    key_shaft_d = 17,
    key_width = 17 / 2
);

*profile_shifted_spur_gear(
    thickness = 10, 
    module_val = 2, 
    pressure_angle = 20, 
    number_of_teeth = 24, 
    shift_coefficient = 0.25,
    key_shaft_d = 17,
    key_width = 17 / 2
);

*key_shaft(
    shaft_d = 17,
    shaft_height = 40, 
    key_width = 16.75 / 2
);

*key(
    shaft_height = 20, 
    key_width = 16.75 / 2
);

spur_gear_force_overlay(
    thickness = 10, 
    module_val = 2, 
    pressure_angle = 20, 
    number_of_teeth = 24, 
    shift_coefficient = 0,
    key_shaft_d = 17,
    key_width = 17 / 2
);