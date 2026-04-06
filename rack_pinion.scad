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

// TODO: Base line in the rack gear to determine the line of action 
// TODO: Mention why this change in the base line leads to straight line rack gear teeth 

// ========== IMPORTS ========== //
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

module pinion_frame(
    m,
    pa,
    gear_z, 
    rack_z,
    rack_thickness,
    rack_width,
    bb_od,
    bb_h
) {
    module support_block() {
        difference() {
            //base
            translate([0, 0, (m * gear_z + PI * m) / 2])
                cube([m * gear_z, bb_h, m * gear_z + PI * m], center = true);

            //driver 
            translate([0, 0, m * gear_z / 2 + PI * m])
                rotate([90, 0, 0])
                    cylinder(d = bb_od, h = bb_h * 2, center = true);
        }    
    }
    
    clearance = 0.5;
    translate([0, (rack_thickness + bb_h) / 2 + clearance, 0])
        support_block();
    translate([0, -(rack_thickness + bb_h) / 2 - clearance, 0])
        support_block();

    translate([0, 0, -2.5])
        cube([m * gear_z, rack_thickness + 2 * (bb_h + clearance), 5], center = true);
}

module two_sided_rack_2D(
    gap,
    rack_width,
    m,
    z, 
    pa
) {
    rack_length = PI * m * z;
    square([rack_length, gap], center = true);
    translate([0, -(gap + rack_width) / 2, 0])
        rotate([180, 0])
            rack_2D(rack_width, m, z, pa);
    translate([0, (gap + rack_width) / 2, 0])
        rack_2D(rack_width, m, z, pa);
}

module two_sided_rack_3D(
    gap,
    rack_thickness,
    rack_width,
    m,
    z, 
    pa
) {
    linear_extrude(height = rack_thickness) {
        two_sided_rack_2D(gap, rack_width, m, z, pa);
    }
}

module dual_support_block(
    m,
    pa,
    gear_z, 
    rack_z,
    rack_gap,
    rack_thickness,
    rack_width,
    bb_od,
    bb_h
) {
    difference() {
        translate([0, 0, 0])
            rotate([90, 0, 0])
                cube([m * gear_z, bb_h, 2 * (m * gear_z + PI * m)], center = true);

        translate([0, ((m * gear_z + rack_gap) / 2 + rack_width + 1.25 * m), 0])
            rotate([0, 0, 0])
                cylinder(d = bb_od, h = bb_h * 2, center = true);
        
        translate([0, -((m * gear_z + rack_gap) / 2 + rack_width + 1.25 * m), 0])
            rotate([0, 0, 0])
                cylinder(d = bb_od, h = bb_h * 2, center = true);
    }
}

module dual_pinion_frame(
    m,
    pa,
    gear_z, 
    rack_z,
    rack_gap,
    rack_thickness,
    rack_width,
    bb_od,
    bb_h
) { 
    clearance = 0.5;
    translate([0, 0, -bb_h / 2])
        dual_support_block(
            m,
            pa,
            gear_z, 
            rack_z,
            rack_gap,
            rack_thickness,
            rack_width,
            bb_od,
            bb_h
        );
}

// ========== BUILD ========== //
module rack_pinion(
    m,
    pa,
    gear_z, 
    rack_z,
    rack_thickness,
    rack_width,
    bb_od,
    bb_h
) {
    translate([0, rack_thickness / 2, rack_width / 2])
    rotate([90, 0, 0])
        rack_3D(
            rack_thickness,
            rack_width, 
            m, 
            rack_z, 
            pa
        );

    translate([0, rack_thickness / 2, m * gear_z / 2 + PI * m])
        rotate([90, 0, 0])
            spur_gear(
                thickness = rack_thickness, 
                module_val = m, 
                pressure_angle = pa, 
                number_of_teeth = gear_z, 
                shift_coefficient = 0,
                key_shaft_d = 17,
                key_width = 17 / 2
            );
    
    pinion_frame(
        m,
        pa,
        gear_z, 
        rack_z,
        rack_thickness,
        rack_width,
        bb_od,
        bb_h
    );
}

module dual_rack_pinion(
    m,
    pa,
    gear_z, 
    rack_z,
    rack_gap,
    rack_thickness,
    rack_width,
    bb_od,
    bb_h
) {
    translate([0, (rack_thickness - rack_gap) / 2, 0])
        two_sided_rack_3D(
            rack_gap,
            rack_thickness,
            rack_width, 
            m, 
            rack_z, 
            pa
        );
    
    translate([0, ((m * gear_z + rack_gap) / 2 + rack_width + 1.25 * m), 0])
        spur_gear(
            thickness = rack_thickness, 
            module_val = m, 
            pressure_angle = pa, 
            number_of_teeth = gear_z, 
            shift_coefficient = 0,
            key_shaft_d = 17,
            key_width = 17 / 2
        );

    translate([0, -((m * gear_z + rack_gap) / 2 + rack_width + 1.25 * m), 0])
        spur_gear(
            thickness = rack_thickness, 
            module_val = m, 
            pressure_angle = pa, 
            number_of_teeth = gear_z, 
            shift_coefficient = 0,
            key_shaft_d = 17,
            key_width = 17 / 2
        );

    dual_pinion_frame(
        m,
        pa,
        gear_z, 
        rack_z,
        rack_gap,
        rack_thickness,
        rack_width,
        bb_od,
        bb_h
    );
}

// ========== ASSEMBLY ========== //
m = 2;
pa = 20;
gear_z = 24;
rack_z = 20;

rack_gap = 10;
rack_thickness = 10;
rack_width = 2.5;

*two_sided_rack_3D(
    rack_gap,
    rack_thickness,
    rack_width, 
    m, 
    rack_z, 
    pa
);

*dual_support_block(
    m,
    pa, 
    gear_z, 
    rack_z,
    rack_gap,
    rack_thickness,
    rack_width,
    bb_6903_od,
    bb_6903_h
);

*dual_rack_pinion(
    m,
    pa, 
    gear_z, 
    rack_z,
    rack_gap,
    rack_thickness,
    rack_width,
    bb_6903_od,
    bb_6903_h
);

*spur_gear(
    thickness = rack_thickness, 
    module_val = m, 
    pressure_angle = pa, 
    number_of_teeth = gear_z, 
    shift_coefficient = 0,
    key_shaft_d = 17,
    key_width = 17 / 2
);

*rack_3D(
    rack_thickness,
    rack_width, 
    m, 
    rack_z, 
    pa
);

*pinion_frame(
    m,
    pa, 
    gear_z, 
    rack_z,
    rack_thickness,
    rack_width,
    bb_6903_od,
    bb_6903_h
);
