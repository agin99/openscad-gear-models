/*  
===== Gear Design: =====
- Inputs: 
    > Module Value (m) - Determines tooth size
    > Pressure Angle (pa) - Determines the line of action between two teeth
    > Tooth Count (z) - Determines the amount of teeth on a gear
- Compatible Spur Gears must have the same Module Value (m) and Pressure Angle (pa)

- Pitch Circle: *NOTE* One of the first parameters to decide upon.
> D_{p} = mz 

- Pitch: Length of the arc from any given face or point of one tooth on the pitch circle to the corresponding face or point of the next tooth. 
> p = m * π

- Addendum: Distance from pitch circle to tooth top.
> m = p / π

- Dedendum: Distance from root circle to pitch circle.
> b = 1.25 * m

- Addendum Circle: Circle that circumscribes the gear. 
> D = D_{p} + 2*m 
    
- Root Circle: Circle inscribed by the bottom of the gear teeth.  
> D_{r} = D_{p} - 2*b

- Base Circle: Used to determine the involute tooth profile.
> D_{b} = D_{p} * cos(pa)

- Tooth Height:
> h = m + b
*/

/*
===== Involute Design: =====
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
    
    //tooth_width_angle = (360 / (4 * n)) + (inv_pa * 180 / PI);
    
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
    root_r = pitch_r - (1.25 - shift_coefficient) * dedendum;
    base_r = pitch_r * cos(pressure_angle);
    
    full_involute_points = get_involute_points(base_r);

    circle(root_r);
    
    for (i = [0 : number_of_teeth - 1]) {
        angle = i * 360 / number_of_teeth;
        rotate([0, 0, angle])
            tooth(full_involute_points, number_of_teeth, pressure_angle, addendum_r);
    }
}

module spur_gear(
    shaft_d,
    thickness,
    module_val, 
    pressure_angle,
    number_of_teeth,
    shift_coefficient
) {
    difference() {
        linear_extrude(thickness)
            spur_gear_base(module_val, pressure_angle, number_of_teeth, shift_coefficient);
        /*
        Key Shaft
        */
    }
}

// ========== ASSEMBLY ========== //
spur_gear(
    shaft_d = 5.25, 
    thickness = 15, 
    module_val = 1, 
    pressure_angle = 20, 
    number_of_teeth = 20, 
    shift_coefficient = 0
);