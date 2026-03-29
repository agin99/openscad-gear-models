/*  
===== Gear Design: Worm Gear =====
- Inputs: 
    > Module Value (m) - Determines tooth size
    > Pressure Angle (pa) - Determines the line of action between two teeth
    > Tooth Count (z) - Determines the amount of teeth on a gear
    
- Compatibility Dependence: Worm Wheel Partner
    > 

- Parameters: 
    > 
*/

/*
===== Tooth Design: =====

*/

// ========== IMPORTS ========== //
use <rack_pinion.scad>; // two_sided_rack_2D()

// ========== GLOBAL ========== //
$fn = 100;

// ========== CONSTANTS ========== // 


// ========== VARIABLES ========== //


// ========== LOGIC ========== //


// ========== STRUCTURES ========== //
// A worm gear is effectively a helically extended two-sided rack gear.
module worm_gear() {}

// 
module worm_wheel() {}

// ========== ASSEMBLY ========== //
