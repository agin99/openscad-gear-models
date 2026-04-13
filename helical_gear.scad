/*  
===== Gear Design: Helical Gear =====
- Inputs: 
    > Module Value (m) - Determines tooth size
    > Pressure Angle (pa) - Determines the line of action between two teeth
    > Helix Angle (ha) - Determines the torsion angle of the gear teeth
    > Tooth Count (z) - Determines the amount of teeth on a gear

- Compatibility Dependence: Right-Left Gear
    > Opposite Hand
    > Module Value (m)
    > Pressure Angle (pa)
    > Helix Angle (ha)
*/

// ========== IMPORTS ========== //
use <spur_gear.scad>;

// ========== GLOBAL ========== //
$fn = 100;

// ========== CONSTANTS ========== // 
// TODO: Include relevant build items in stock


// ========== VARIABLES ========== //


// ========== LOGIC ========== //
function get_twist_angle(m, z, ha, thickness) = 
    let(
        arc_length = thickness * tan(ha),
        angular_conversion = 360 / (PI * m * z),
        twist_angle = arc_length * angular_conversion
    )
    twist_angle;

/*
Derivation for tan(transverse pressure angle) = tan(pressure angle) / cos(helix angle)

Start with consideration of a spur gear:
F_{r} = F_{n} sin(pressure angle)
F_{t} = F_{n} cos(pressure angle)

Therefore, the direction of the resultant force for a spur gear is 
    F_{r} / F_{t} = sin(pressure angle) / cos(pressure angle)
                    = tan(pressure angle)

If we now tilt the tooth by the helical angle:
F_{r} = F_{n} sin(pressure angle) 
remains the same because the radial component of interaction between the teeth hasn't changed.

F_{t} = F_{n} cos(pressure angle) cos(helix angle)
because the usable force that moves in the direction of transmission (think Gibbs Free Energy 
    analogy from spur gear file) needs to be diluted again to account for the force in the 
    axial direction. 

Therefore, the direction of the resultant force for a helical gear is 
    F_{r} / F_{t} = (F_{n} sin(pressure angle)) / (F_{n} cos(pressure angle) cos(helix angle))
                    = (sin(pressure angle) / cos(pressure angle)) * (1 / cos(helix angle))
                    = tan(pressure angle) / cos(helix angle) [QED]
*/
function get_transverse_pressure_angle(pa, ha) = atan(tan(pa) / cos(ha));

/* 
- Acts along the radius of the gear towards the center of the shaft. 
- Captures the penalty of the pressure angle (think Entropy)
- Assumes unit torque
*/
function radial_force(rb, pa) = sin(pa) / rb;

/*
- Acts along the plane of action (tangent to the base cylinder)
- Captures the penalty of the helix angle (think Entropy)
- Assumes unit torque 
*/
function axial_force(rb, pa, ha) = cos(pa) * sin(ha) / rb;

/*
- Acts along the plane of action (tangent to the pitch cylinder)
- Captures the useful leverage (think Gibbs Free Energy)
- Assumes unit torque
*/
function tangential_force(rb, pa, ha) = cos(pa) * cos(ha) / rb;

/*
- Acts along the plane of action (tangent to the base cylinder)
- Captures the absolute contact load (think Enthalpy)
- Assumes unit torque 

Derivation of resultant force F_{n} = \frac{1}{rb} 
    F_{r} = \frac{sin(pa)}{rb}
    F_{a} = \frac{cos(pa) * sin(ha)}{rb}
    F_{t} = \frac{cos(pa) * cos(ha)}{rb}
    
    F_{n}^{2} = F_{r}^{2} + F_{a}^{2} + F_{t}^{2}
              = (\frac{sin(pa)}{rb})^{2} + (\frac{cos(pa) * sin(ha)}{rb})^{2} + (\frac{cos(pa) * cos(ha)}{rb})^{2}
              = (\frac{1}{rb})^{2} * [sin(pa)^{2} + cos(pa)^{2} * sin(ha)^{2} + cos(pa)^{2} * cos(ha)^{2}]
              = (\frac{1}{rb})^{2} * [sin(pa)^{2} + cos(pa)^{2}]
              = \frac{1}{rb})^{2}

    F_{n} = \sqrt{\frac{1}{rb}^{2}} 
          = \frac{1}{rb} [QED]
*/
function resultant_force(rb) = 1 / rb;

// ========== STRUCTURES ========== //
module helical_gear(
    thickness,
    module_val, 
    pressure_angle,
    helix_angle,
    number_of_teeth,
    shift_coefficient,
    key_shaft_d,
    key_width
) {
    transverse_module_val = module_val / cos(helix_angle);
    twist_angle = get_twist_angle(module_val, number_of_teeth, helix_angle, thickness);
    transverse_pressure_angle = get_transverse_pressure_angle(pressure_angle, helix_angle);

    difference() {
        linear_extrude(
            height = thickness, 
            twist = twist_angle, 
            convexity = 10
        )
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
                    module_val = transverse_module_val, 
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

module helical_gear_force_overlay(
    thickness,
    module_val, 
    pressure_angle,
    helix_angle,
    number_of_teeth,
    shift_coefficient,
    key_shaft_d,
    key_width
) {
    transverse_module_val = module_val / cos(helix_angle);
    twist_angle = get_twist_angle(module_val, number_of_teeth, helix_angle, thickness);
    transverse_pressure_angle = get_transverse_pressure_angle(pressure_angle, helix_angle);

    difference() {
        linear_extrude(
            height = thickness, 
            twist = twist_angle, 
            convexity = 10
        )
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
                    module_val = transverse_module_val, 
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

    pitch_d = transverse_module_val * number_of_teeth;
    pitch_r = pitch_d / 2;
    addendum = transverse_module_val;
    dedendum = 1.25 * transverse_module_val;
    
    addendum_r = pitch_r + (1 + shift_coefficient) * addendum;
    root_r = pitch_r - dedendum + shift_coefficient * transverse_module_val;
    
    /*
    To understand the base radius adjustment, one must first understand the role of the base cylinder: 
        By the Fundamental Law of Gearing the plane of action needs to be tangent to the base cylinder and run through 
            a fixed pitch line on the pitch circle. To derive this radius, imagine a right triangle with the hypotenuse
            extending from the center of the gear to the pitch circle. Rotate by the transverse pressure angle and draw 
            a line extending to the point where it can be connected to the hypotenuse at a right angle (completing the
            imaginary right triangle). This radius is the adjusted radius of the base circle where the plane of action 
            must be tangent. The length of this radius is the hypotenuse * cos(transverse_pressure_angle). 
    */
    base_r = pitch_r * cos(transverse_pressure_angle);

    /*
    To understand the role of the base helix angle, we lean on the logic of the adjusted base radius and the computation
        of the transverse pressure angle: 
        The value tan(helix angle) is used to determine the arc length along the pitch circle that the tooth twists across. This 
            is why we use it in the twist angle calculation when computing the arc length that a single tooth takes up. The base
            cylinder has a smaller radius than the pitch circle and as a result, we need to scale it down by the ratio of the base 
            cylinder to pitch cylinder radius. Since this value is already accounted for in cos(transverse_pressure_angle), we scale 
            tan(helix_angle) by this ratio and find the effective helix angle along the base cylinder. 
    */
    base_helix_angle = atan(tan(helix_angle) * cos(transverse_pressure_angle));

    /*
        Planes and Line of Contact
        - Pitch Plane
        - Plane of action 
        - Line of Contact
    */
    %color("green", 0.5)
        translate([pitch_r, -pitch_r])
            linear_extrude(thickness)
                square([0.05, 2 * pitch_r]);

    rotate([0, 0, -transverse_pressure_angle]) {
        %color("blue", 0.5)
            translate([base_r, -pitch_r]) 
                linear_extrude(thickness)
                    square([0.05, 2 * pitch_r]);
    }

    /*
        Forces: 
        - Radial 
        - Axial
        - Tangential 
        - Resultant 
    */
    translate([pitch_r, 0, thickness / 2]) {
        vector_scale = 15;
        color("blue") 
            rotate([0, -90, 0]) cylinder(h = vector_scale * base_r * radial_force(base_r, pressure_angle), r = 0.5);
        color("yellow") 
            cylinder(h = vector_scale * base_r * axial_force(base_r, pressure_angle, helix_angle), r = 0.5);
        color("green") 
            rotate([-90, 0, 0]) cylinder(h = vector_scale * base_r * tangential_force(base_r, pressure_angle, helix_angle), r = 0.5);
        color("purple")
            rotate([-90, 0, base_helix_angle]) 
                cylinder(h = vector_scale, r = 0.8);
    }
}

// ========== ASSEMBLY ========== //
//Left hand
helical_gear(
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
*helical_gear(
    thickness = 10, 
    module_val = 2, 
    pressure_angle = 20, 
    helix_angle = -20,
    number_of_teeth = 24, 
    shift_coefficient = 0,
    key_shaft_d = 17,
    key_width = 17 / 2
);