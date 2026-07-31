QUARTER-CAR ROAD PROFILE TEAM PACKAGE
=====================================

FILES INCLUDED
--------------
runAllRoadProfiles.m
roadInputForTire.m
speedbump.m
pothole.m
roughroad.m
ramp.m
curvedramp.m

IMPORTANT: SIMULINK MODEL
-------------------------
The Simulink file quarter_car_tire.slx is not included because it is stored
on Anthony's local computer.

Before running the test suite, place quarter_car_tire.slx in this same folder.

The From Workspace block inside the model must use:
    roadInput

HOW TO RUN EVERY ROAD PROFILE
-----------------------------
1. Open MATLAB.
2. Set MATLAB's Current Folder to this extracted folder.
3. Make sure quarter_car_tire.slx is in this folder.
4. Run:
       runAllRoadProfiles

The script generates and tests:
- speed bump
- pothole
- rough road
- ramp
- curved ramp

It runs the Simulink model once for each road and leaves the selected profile
available in the MATLAB base workspace.

HOW TO RUN ONE ROAD MANUALLY
----------------------------
After runAllRoadProfiles has been run, use one of these commands:

    roadInput = roadInputs.speedbump;
    roadInput = roadInputs.pothole;
    roadInput = roadInputs.roughroad;
    roadInput = roadInputs.ramp;
    roadInput = roadInputs.curvedramp;

Then run:
    sim("quarter_car_tire")

QUARTER-CAR PARAMETERS USED
---------------------------
Kt = 250000 N/m
Ct = 200 N*s/m
Ks = 30000 N/m
Cs = 3000 N*s/m
mu = 65 kg
ms = 600 kg

These are preliminary engineering estimates and can be changed by the team.
