// ========== IMPORTS ========== //
include <BOSL2/std.scad>
include <BOSL2/gears.scad>

// ========== GLOBAL ========== //
$fn = 100;

// ========== CONSTANTS ========== // 
// TODO: Include relevant build items in stock


// ========== VARIABLES ========== //


// ========== LOGIC ========== //
function w_radial_force(pa, la) = sin(pa);
function w_tangential_force(pa, la) = cos(pa) * sin(la);
function w_axial_force(pa, la) = cos(pa) * cos(la);

/* Self-Locking Criteria
    tan(la) < µ 

    Intuition: tan(la) = w_tangential_force / w_axial_force which means the 
        self-locking criteria is based on the relationship between the tangential
        and axial forces of the worm. The inequality can be re-written as 

        µ * w_axial_force > w_tangential_force 

        If tangential force isn't strong enough to overcome the friction force
            caused by the axial force pressing the worm thread onto the face of 
            the worm gear tooth then the gear won't be able to rotate backwards
            without being explicitly driven by an external force. 
*/
// ========== STRUCTURES ========== //
/* Parameters (From BOSL2 Wiki): 
    > circ_pitch        The circular pitch, the distance between teeth centers around the pitch circle. Default: 5
    > d                 The diameter of the worm. Default: 30
    > l                 The length of the worm. Default: 100
    > starts            The number of lead starts. Default: 1
    > left_handed       If true, the gear returned will have a left-handed spiral. Default: false
    > pressure_angle    Controls how straight or bulged the tooth sides are. In degrees. Default: 20
    > backlash          Gap between two meshing teeth, in the direction along the circumference of the pitch circle. Default: 0 
    > clearance         Clearance gap at the bottom of the inter-tooth valleys. Default: module/4
    > diam_pitch        The diametral pitch, or number of teeth per inch of pitch diameter. The diametral pitch is a completely different thing than the pitch diameter.
    > mod               The module of the gear (pitch diameter / teeth)
*/
module mod_worm(
    circ_pitch,
    d,
    l
) {
    worm(circ_pitch=circ_pitch, d=d, l=l, $fn=72);
}

module worm_forces(
    circ_pitch,
    d,
    l,
    starts = 1,
    left_handed = false,
    pressure_angle = 20,
) {
    lead = starts * circ_pitch;
    lead_angle = atan(lead / (PI * d));

    %worm(
        circ_pitch=circ_pitch, 
        d=d, 
        l=l, 
        starts = starts, 
        left_handed = left_handed,
        pressure_angle = pressure_angle,
        $fn=72
    );

    /* Forces: 
        > (red) Worm Radial = Gear Radial
        > (blue) Worm Tangential = Gear Axial 
        > (green) Worm Axial = Gear Tangential
        > (purple) Resultant
    */

    translate([-d / 2, 0, 0]) {
        vector_scale = 15;
        mag_rad = vector_scale * w_radial_force(pressure_angle, lead_angle);
        mag_tan = vector_scale * w_tangential_force(pressure_angle, lead_angle);
        mag_ax  = vector_scale * w_axial_force(pressure_angle, lead_angle);
        rot_y = -atan2(mag_rad, mag_ax);
        rot_x = atan2(mag_tan, sqrt(pow(mag_rad, 2) + pow(mag_ax, 2)));

        color("red") 
            rotate([0, -90, 0]) cylinder(h = mag_rad, r = 0.5);
        color("blue") 
            rotate([90, 0, 0]) cylinder(h = mag_tan, r = 0.5);
        color("green") 
            rotate([0, 0, 0]) cylinder(h = mag_ax, r = 0.5);
        color("purple")
            rotate([rot_x, rot_y, 0])
                cylinder(h = vector_scale, r = 0.8);
    }
}

/* Parameters (From BOSL2 Wiki): 
    > circ_pitch	    The circular pitch, the distance between teeth centers around the pitch circle. Default: 5
    > teeth	            Total number of teeth along the rack. Default: 30
    > worm_diam	        The pitch diameter of the worm gear to match to. Default: 30
    > worm_starts	    The number of lead starts on the worm gear to match to. Default: 1
    > worm_arc	        The arc of the worm to mate with, in degrees. Default: 45 degrees
    > crowning	        The amount to oversize the virtual hobbing cutter used to make the teeth, to add a slight crowning to the teeth to make them fit the work easier. Default: 1
    > left_handed	    If true, the gear returned will have a left-handed spiral. Default: false
    > pressure_angle    Controls how straight or bulged the tooth sides are. In degrees. Default: 20
    > backlash	        Gap between two meshing teeth, in the direction along the circumference of the pitch circle. Default: 0
    > clearance	        Clearance gap at the bottom of the inter-tooth valleys. Default: module/4
    > profile_shift	    Profile shift factor x. Default: "auto"
    > slices	        The number of vertical slices to refine the curve of the worm throat. Default: 10
    > diam_pitch	    The diametral pitch, or number of teeth per inch of pitch diameter. The diametral pitch is a completely different thing than the pitch diameter.
    > mod	            The module of the gear (pitch diameter / teeth)
*/
module mod_worm_gear(
    circ_pitch,
    teeth,
    worm_diam,
    worm_starts
) {
    difference() { 
        worm_gear(
            circ_pitch=circ_pitch, 
            teeth=teeth, 
            worm_diam=worm_diam, 
            worm_starts=worm_starts
        );
        
        cylinder(d = 5.25, h = 20, center = true);
    }
}

module worm_gear_forces(
    circ_pitch,
    teeth,
    worm_diam,
    worm_starts,
    worm_arc = 45, 
    crowning = 1, 
    left_handed = false, 
    pressure_angle = 20, 
    profile_shift = "auto",
    slices = 10
) {
    pitch_d = circ_pitch * teeth / PI;
    lead = worm_starts * circ_pitch;
    lead_angle = atan(lead / (PI * worm_diam));
    rotate([0, 0, 180 / (2 * teeth)])
        %worm_gear(
            circ_pitch=circ_pitch, 
            teeth=teeth, 
            worm_diam=worm_diam, 
            worm_starts=worm_starts
        );

    /* Forces: 
        > (red) Gear Radial = Worm Radial
        > (green) Gear Tangential = Worm Axial
        > (blue) Gear Axial = Worm Tangential
        > (purple) Resultant
    */

    translate([pitch_d / 2, 0, 0]) {
        vector_scale = 15;
        mag_rad = vector_scale * w_radial_force(pressure_angle, lead_angle);
        mag_ax = vector_scale * w_tangential_force(pressure_angle, lead_angle);
        mag_tan  = vector_scale * w_axial_force(pressure_angle, lead_angle);
        rot_y = atan2(mag_rad, mag_ax);
        rot_x = -atan2(mag_tan, sqrt(pow(mag_rad, 2) + pow(mag_ax, 2)));

        color("red") 
            rotate([0, 90, 0]) cylinder(h = mag_rad, r = 0.5);
        color("blue") 
            rotate([0, 0, 0]) cylinder(h = mag_ax, r = 0.5);
        color("green") 
            rotate([-90, 0, 0]) cylinder(h = mag_tan, r = 0.5);
        color("purple")
            rotate([rot_x, rot_y, 0])
                cylinder(h = vector_scale, r = 0.8);
    }
}

// ========== BUILD ========== //
module worm_gear_fbd(
    worm_length,
    worm_starts,
    worm_diam,
    circ_pitch,
    teeth
) {
    center_distance = worm_diam/2 + (circ_pitch * teeth) / (2 * PI);
    lead = worm_starts * circ_pitch;
    lead_angle = atan(lead / (PI * worm_diam));

    translate([center_distance, 0, 0])
        rotate([90, 0, 0])
            worm_forces(circ_pitch=circ_pitch, d=worm_diam, l=worm_length, $fn=72);
    worm_gear_forces(
        circ_pitch=circ_pitch, 
        teeth=teeth, 
        worm_diam=worm_diam, 
        worm_starts=worm_starts
    ); 
}

// ========== ASSEMBLY ========== //
worm_length = 30;
worm_starts = 1;
worm_diam = 30;
circ_pitch = 5; 
teeth = 24; 

worm_gear_fbd(
    worm_length,
    worm_starts,
    worm_diam,
    circ_pitch,
    teeth
);