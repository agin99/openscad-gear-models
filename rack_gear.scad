/*  
===== Gear Design: Rack Gear =====
- Inputs: 
    > Module Value (m) - Determines tooth size
    > Pressure Angle (pa) - Determines the line of action between two teeth
    > Tooth Count (z) - Determines the amount of teeth on a gear

- Compatibility Dependence: Pinion Partner
    > Module Value (m)
    > Pressure Angle (pa)

- Parameters: 
    > Pitch: Distance between a fixed position on two adjacent teeth.
    > Pitch line: Tangent to the pitch circle of a pinion partner. 
        >> *NOTE* "Line" not "Circle" because the rack is effectively a gear with an infinite pitch radius.
    > Dedendum: The distance from the bottom tooth face to the pitch line.
    > Addendum: The distance from the pitch line to the top of the tooth face. 
*/

/*
===== Tooth Design: =====
Tooth width at the pitch line: πm/2
Pressure angle is 20º (convention)

Split tooth into addendum (module, m) and dedendum (1.25 * m) defined parts: 
Given the height and pa we know the base of each right triangle
> b = m * tan(pa)
the tooth tip then has a width: 
> πm/2 - 2*b

Applying the same procedure to find the bottom of the rack tooth: 
> b = (1.25*m) * tan(pa)
> πm / 2 + 2b

Therefore, the trapezoidal rack tooth profile is defined by:
> b1 = πm/2 - 2 * m * tan(pa)
> b2 = πm / 2 + 2 * (1.25*m) * tan(pa)
*/

// ========== IMPORTS ========== //
use <spur_gear.scad>;

// ========== GLOBAL ========== //
$fn = 100;

// ========== CONSTANTS ========== // 
// TODO: Include relevant build items in stock

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
/*
The rack gear works to convert rotational motion into linear motion. Due to the pressure angle 
*/
function radial_force(pa) = sin(pa);
function tangential_force(pa) = cos(pa);
function resultant_force() = 1;

// ========== STRUCTURES ========== //

/*
The rack gear tooth has a trapezoidal shape with straight edge interactions because the radius of the
    rack is considered to be effectively infinite. Calling on the Fundamental Law of Gearing to guide 
    our understanding of the interaction between a pinion and the gear, we know the interaction needs 
    to happen along a line of action that is aligned with the pinion. If we approximate the 
    rack gear 'face' as planar then we can approximate it as the pitch plane and assume the equivalent
    involute angle will be reliant on a base circle with a surface effectively parallel to the pitch plane. 
    We'd design for the rack gear tooth to have a perpendicular that makes an angle equivalent
    to the pressure angle with the base cylinder, which in this case is a plane. Therefore, the rack gear 
    tooth is straight edged with a trapezoidal form. 
*/

// m := module value
// pa := pressure angle
module rack_tooth(
    m,
    pa
) {
    tooth_height = 2.25 * m;
    top_width = PI * m / 2 - 2 * m * tan(pa);
    bottom_width = PI * m / 2 + 2 * (1.25*m) * tan(pa);
    
    polygon([
        [-top_width / 2, tooth_height],
        [top_width / 2, tooth_height],
        [bottom_width / 2, 0],
        [-bottom_width / 2, 0]
    ]);
}

// m := module value
// z := tooth count
// pa := pressure angle
module rack_2D(
    rack_width,
    m,
    z, 
    pa
) {
    pitch = PI * m;
    bottom_width = PI * m / 2 + 2 * (1.25*m) * tan(pa);
    rack_length = pitch * z;

    assert(rack_length % pitch == 0, "Choose compatible rack_length and pitch!");
    union() {
        square([rack_length, rack_width], center = true);
        for(i = [-rack_length / 2 + bottom_width / 2: pitch: rack_length / 2 - bottom_width / 2]) {
            translate([i, rack_width / 2, 0])
                rack_tooth(
                    m, 
                    pa
                );
        }
    }
}

module rack_3D(
    rack_thickness,
    rack_width,
    m,
    z, 
    pa
) {
    linear_extrude(height = rack_thickness) {
        rack_2D(rack_width, m, z, pa);
    }
}

// ========== BUILD ========== //

// ========== ASSEMBLY ========== //
m = 2;
pa = 20;
gear_z = 24;
rack_z = 20;

rack_gap = 10;
rack_thickness = 10;
rack_width = 2.5;
