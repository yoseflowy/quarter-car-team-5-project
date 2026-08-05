QUARTER-CAR ROAD PROFILE TEAM PACKAGE
=====================================

FILES IN THIS FOLDER
--------------------
quarter_car_tire.slx     the current quarter-car model (Simscape Multibody)
runAllRoadProfiles.m     test suite: builds every road and runs the model
roadInputForTire.m       builds ONE road profile as a timeseries
speedbump.m              road-profile functions, all with the signature
pothole.m                    z = f(x, z, startPos, span, height)
roughroad.m
ramp.m
curvedramp.m

Suspension parameters live one level up, in suspensionParameters.m.
runAllRoadProfiles.m loads that file, so it is the only place to edit
Ks, Cs, ms, mu, Kt and Ct. The current baseline is:

    Kt = 250000 N/m      Ks = 30000 N/m      mu = 65 kg
    Ct = 200 N*s/m       Cs = 3000 N*s/m     ms = 600 kg

These are preliminary engineering estimates and can be changed by the team.

The From Workspace block inside the model reads the variable:
    roadInput

HOW TO RUN EVERY ROAD PROFILE
-----------------------------
1. Open MATLAB.
2. Set MATLAB's Current Folder to this folder.
3. Run:
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

KNOWN GAPS (not done yet)
-------------------------
- The model has Scope blocks only. Nothing is logged back to the workspace,
  so simOutputs comes back empty and no metrics can be computed yet.
- The Sprung Mass block has a hard-coded mass of 600 kg instead of ms, so
  changing ms currently has no effect on the simulation.
- No scoring function, parameter sweep, or robustness study exists yet.

OLDER MODELS
------------
Two earlier Simulink models were moved to the archive folder at the project
root. Neither is used by this test suite:
    quarter_car_suspension.slx   2-body baseline, no tire and no road input
    Simscape_suspension_model.slx  early experiment, tire stiffness set to 0
