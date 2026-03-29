READY, FIRE, AIM

Stress Test
Purpose: Test for the maximum torque of a 3D printed spur gear. 

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
5) Compute torque T = |r x F|.

================================================

======== Analysis of Stress Test Mk. 1: ========
TODO: Complete build of Stress Test Unit Mk. 1 in OpenSCAD script

DESIGN:  
>> Core mechanical system properly aligned which indicates center distance and key shaft expectations of spacing were correct.
>> The tight fit is necessary for the shaft itself. The key is a different story because it may be that the width of the key is the primary driver of lock-in as long as a certain radial distance into the shaft is cleared by the key height.
>>> Question: How does the clearance between the key and the top of the key shaft opening in the spur gear impact the lock in performance? 

ASSEMBLY:
>> The tight fit of the key shaft components (shaft and key) with the opening in the gear make slow down the assembly time.  
>>> Question: How is assembly impacted by minimal clearance width and increased clearance height? 
>> Consider embedding the key shaft into the support block for a structural coupling (on both sides of the driven gear).

PERFORMANCE:
>> Low density infill for the shaft key caused it to deform before the gears were forced to deform while I applied a force to the edge of the lever arm on the drive gear. I noticed this because I say the gear starting slightly rotating due to the force but the gear structure hadn't given out yet. The test ended prematurely because the part of the key in the gear ended up getting sheared off and the gears driven gear started outright rotating while driven by the drive gear. 
>> The test was administered imprecisely because the current lever arm setup was not conducive to applying a force with the Force Gauge equivalent to the force I was able to apply by simply pushing down on the lever arm manually. 
>>> Question: What is the best way to couple the force gauge to the lever arm? 
>>> Question: What is the best way to record the 'snap' force recorded by the force gauge when a component of the gear gives out? 

================================================

======== Analysis of Stress Test Mk. 2: ========
Mk. 1 --> Mk. 2 Changes: 

DESIGN: 

ASSEMBLY: 

PERFORMANCE: 

================================================