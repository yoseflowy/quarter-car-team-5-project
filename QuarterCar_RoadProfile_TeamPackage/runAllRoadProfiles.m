%% Quarter-Car Road Profile Simulink Test Suite
% This live-script-ready file creates every road profile in the project
% folder, converts road distance into simulation time, sends each profile
% into the Simulink model through the variable roadInput, and runs the model.
%
% Place this file in the SAME folder as:
%   quarter_car_tire.slx
%   speedbump.m
%   pothole.m
%   roughroad.m
%   ramp.m
%   curvedramp.m
%
% Open this file in MATLAB, then right-click its tab and choose
% "Open as Live Script" (or Save As a .mlx Live Code file).

%% 1. User settings
modelName = "quarter_car_tire";

% A shorter road keeps the five Simscape runs reasonably fast.
roadLength = 60;       % m
dx = 0.02;             % road-profile spacing, m
vehicleSpeed = 15;     % m/s

% Profile to leave active in the base workspace after all tests finish.
selectedProfile = "speedbump";

% Set false to generate/plot every road without running Simulink.
runSimulink = true;

% Save generated inputs and test status here.
resultsFolder = "road_test_results";

%% 2. Baseline quarter-car parameters
% The values live in suspensionParameters.m at the project root so that this
% test suite, the Simulink model, and any manual runs all share one
% definition. Edit that file to change the design.

scriptPath = mfilename("fullpath");

if strlength(scriptPath) == 0
    projectFolder = string(pwd);
else
    projectFolder = string(fileparts(scriptPath));
end

paramFile = fullfile(projectFolder, "..", "suspensionParameters.m");

if ~isfile(paramFile)
    % Also allow the parameter file to sit next to this script.
    paramFile = fullfile(projectFolder, "suspensionParameters.m");
end

if ~isfile(paramFile)
    error("suspensionParameters.m was not found next to or above %s.", ...
        projectFolder);
end

run(paramFile);   % defines Ks, Cs, ms, mu, Kt, Ct

requiredParameters = ["Ks" "Cs" "ms" "mu" "Kt" "Ct"];
missingParameters = strings(0,1);

for k = 1:numel(requiredParameters)
    if ~exist(requiredParameters(k), "var")
        missingParameters(end+1,1) = requiredParameters(k); %#ok<SAGROW>
    end
end

if ~isempty(missingParameters)
    error("suspensionParameters.m did not define: %s", ...
        strjoin(missingParameters, ", "));
end

%% 3. Locate the project files and check requirements
addpath(projectFolder);

requiredFunctions = [
    "speedbump"
    "pothole"
    "roughroad"
    "ramp"
    "curvedramp"
];

missingFunctions = strings(0,1);

for k = 1:numel(requiredFunctions)
    if exist(requiredFunctions(k), "file") ~= 2
        missingFunctions(end+1,1) = requiredFunctions(k); %#ok<SAGROW>
    end
end

if ~isempty(missingFunctions)
    error("Missing road-profile file(s): %s", strjoin(missingFunctions, ", "));
end

modelFile = fullfile(projectFolder, modelName + ".slx");

if runSimulink && ~isfile(modelFile)
    error("The Simulink model was not found: %s", modelFile);
end

if ~isfolder(resultsFolder)
    mkdir(resultsFolder);
end

%% 4. Generate every road profile
profileNames = [
    "speedbump"
    "pothole"
    "roughroad"
    "ramp"
    "curvedramp"
];

profileDescriptions = [
    "Smooth 0.10 m hump, 2 m long"
    "Smooth 0.08 m dip, 1.5 m long"
    "Repeatable filtered random roughness"
    "Linear 0.10 m rise"
    "Smooth cosine-shaped 0.10 m rise"
];

roadInputs = struct;
roadData = struct;

for k = 1:numel(profileNames)
    name = profileNames(k);

    [x, z] = makeRoadProfile(name, roadLength, dx);

    % Convert displacement versus distance into displacement versus time.
    t = x ./ vehicleSpeed;

    % From Workspace reads this time-based signal.
    roadInputCase = timeseries(z(:), t(:));
    roadInputCase.Name = char(name);

    roadInputs.(name) = roadInputCase;
    roadData.(name) = table(x(:), t(:), z(:), ...
        'VariableNames', {'Distance_m','Time_s','Displacement_m'});
end

%% 5. Preview all generated road inputs
figure("Name", "All Road Profiles");
layout = tiledlayout(3,2, "TileSpacing", "compact", "Padding", "compact");

for k = 1:numel(profileNames)
    name = profileNames(k);
    nexttile;

    profile = roadInputs.(name);
    plot(profile.Time, profile.Data, "LineWidth", 1.2);
    grid on;
    xlabel("Time (s)");
    ylabel("Road z (m)");
    title(name);
end

title(layout, "Road profiles supplied to the quarter-car model");

%% 6. Display profile information
profileTable = table(profileNames, profileDescriptions, ...
    'VariableNames', {'Profile','Description'});

disp(profileTable);

%% 7. Run every profile through Simulink
status = strings(numel(profileNames),1);
errorMessage = strings(numel(profileNames),1);
peakRoad_m = zeros(numel(profileNames),1);
minimumRoad_m = zeros(numel(profileNames),1);
stopTime_s = zeros(numel(profileNames),1);

simOutputs = struct;

if runSimulink
    % Close a previously loaded copy, then load the exact model stored next
    % to this test suite. This reduces shadowed-file confusion.
    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end

    load_system(modelFile);
    open_system(modelName);

    for k = 1:numel(profileNames)
        name = profileNames(k);
        roadInputCase = roadInputs.(name);

        peakRoad_m(k) = max(roadInputCase.Data);
        minimumRoad_m(k) = min(roadInputCase.Data);
        stopTime_s(k) = roadInputCase.Time(end);

        fprintf("\nRunning %s (%d of %d)...\n", ...
            name, k, numel(profileNames));

        try
            simIn = Simulink.SimulationInput(modelName);

            % Supply variables directly to this simulation.
            simIn = simIn.setVariable("roadInput", roadInputCase);
            simIn = simIn.setVariable("Kt", Kt);
            simIn = simIn.setVariable("Ct", Ct);
            simIn = simIn.setVariable("Ks", Ks);
            simIn = simIn.setVariable("Cs", Cs);
            simIn = simIn.setVariable("mu", mu);

            % NOTE: the Sprung Mass block in quarter_car_tire.slx still has a
            % hard-coded mass of 600 kg, so this variable has no effect yet.
            % Set that block's Mass field to ms before doing payload studies.
            simIn = simIn.setVariable("ms", ms);

            simIn = simIn.setModelParameter( ...
                "StopTime", string(roadInputCase.Time(end)));

            simOut = sim(simIn);
            simOutputs.(name) = simOut;

            status(k) = "PASS";
            errorMessage(k) = "";

        catch ME
            status(k) = "ERROR";
            errorMessage(k) = string(ME.message);
            warning("The %s simulation failed:\n%s", name, ME.message);
        end
    end
else
    for k = 1:numel(profileNames)
        name = profileNames(k);
        roadInputCase = roadInputs.(name);

        peakRoad_m(k) = max(roadInputCase.Data);
        minimumRoad_m(k) = min(roadInputCase.Data);
        stopTime_s(k) = roadInputCase.Time(end);
        status(k) = "NOT RUN";
    end
end

summaryTable = table( ...
    profileNames, ...
    peakRoad_m, ...
    minimumRoad_m, ...
    stopTime_s, ...
    status, ...
    errorMessage, ...
    'VariableNames', { ...
        'Profile', ...
        'MaximumRoad_m', ...
        'MinimumRoad_m', ...
        'StopTime_s', ...
        'SimulationStatus', ...
        'ErrorMessage'});

disp(summaryTable);

%% 8. Leave one profile active for a manual Simulink run
if ~isfield(roadInputs, selectedProfile)
    error("selectedProfile must be one of: %s", ...
        strjoin(profileNames, ", "));
end

roadInput = roadInputs.(selectedProfile);

% Put the parameters and selected road signal into the base workspace.
assignin("base", "roadInput", roadInput);
assignin("base", "Kt", Kt);
assignin("base", "Ct", Ct);
assignin("base", "Ks", Ks);
assignin("base", "Cs", Cs);
assignin("base", "mu", mu);
assignin("base", "ms", ms);

fprintf("\nThe active base-workspace input is now: %s\n", selectedProfile);
fprintf("Use Stop Time = %.4g seconds for a manual run.\n", roadInput.Time(end));

%% 9. Save the generated test suite
resultsFile = fullfile(resultsFolder, "allRoadProfileTests.mat");

try
    save(resultsFile, ...
        "roadInputs", ...
        "roadData", ...
        "simOutputs", ...
        "summaryTable", ...
        "profileTable", ...
        "Kt", "Ct", "Ks", "Cs", "mu", "ms", ...
        "-v7.3");

    fprintf("Saved road inputs and test results to:\n%s\n", resultsFile);
catch ME
    warning("Results could not be saved: %s", ME.message);
end

%% 10. Using a different road manually
% Change selectedProfile near the top of this file and rerun the script, or
% run one of these lines after the suite has been generated:
%
% roadInput = roadInputs.speedbump;
% roadInput = roadInputs.pothole;
% roadInput = roadInputs.roughroad;
% roadInput = roadInputs.ramp;
% roadInput = roadInputs.curvedramp;
%
% The From Workspace block in Simulink must contain:
% roadInput

%% Local function: build one distance-based road profile
function [x, z] = makeRoadProfile(profileName, roadLength, dx)
% Keep x and z as row vectors because the existing roughroad.m function
% creates row-vector random data.

x = 0:dx:roadLength;
z = zeros(size(x));

switch lower(string(profileName))
    case "speedbump"
        z = speedbump(x, z, 15, 2, 0.10);

    case "pothole"
        z = pothole(x, z, 15, 1.5, 0.08);

    case "roughroad"
        rng(1); % makes the random road repeatable
        z = roughroad(x, z, 5, 50, 0.01, 25);

    case "ramp"
        z = ramp(x, z, 15, 10, 0.10);

    case "curvedramp"
        z = curvedramp(x, z, 15, 10, 0.10);

    otherwise
        error("Unknown road profile: %s", profileName);
end
end
