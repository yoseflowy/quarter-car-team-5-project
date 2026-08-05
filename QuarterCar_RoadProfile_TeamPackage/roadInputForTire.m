function [roadInput, x, z, t] = roadInputForTire(profileName, vehicleSpeed)
%ROADINPUTFORTIRE Create a time-based road displacement input for Simulink.
%
%   [roadInput, x, z, t] = roadInputForTire(profileName, vehicleSpeed)
%
% Inputs
%   profileName  - "speedbump", "pothole", "roughroad",
%                  "ramp", or "curvedramp"
%   vehicleSpeed - vehicle speed in m/s
%
% Output
%   roadInput    - MATLAB timeseries for a From Workspace block
%   x            - road distance vector, m
%   z            - road displacement vector, m
%   t            - simulation time vector, s
%
% Keep this file in the same folder as:
% speedbump.m, pothole.m, roughroad.m, ramp.m, curvedramp.m

if nargin < 1 || strlength(string(profileName)) == 0
    profileName = "speedbump";
end

if nargin < 2
    vehicleSpeed = 15; % m/s
end

validateattributes(vehicleSpeed, {'numeric'}, ...
    {'scalar','real','finite','positive'}, mfilename, 'vehicleSpeed');

profileName = lower(string(profileName));

% Use a finer spacing than the original 0.25 m so short road features
% do not become only a few points in Simulink.
x = (0:0.01:200).';
z = zeros(size(x));

switch profileName
    case "speedbump"
        % Starts at 25 m, spans 2 m, and reaches 0.10 m.
        z = speedbump(x, z, 25, 2, 0.10);

    case "pothole"
        % Starts at 25 m, spans 1.5 m, and reaches -0.08 m.
        z = pothole(x, z, 25, 1.5, 0.08);

    case "roughroad"
        % Starts at 10 m and continues for 80 m.
        rng(1); % repeatable random profile
        z = roughroad(x, z, 10, 80, 0.01, 25);

    case "ramp"
        % Starts at 20 m, spans 10 m, and rises 0.10 m.
        z = ramp(x, z, 20, 10, 0.10);

    case "curvedramp"
        % Starts at 20 m, spans 10 m, and rises 0.10 m smoothly.
        z = curvedramp(x, z, 20, 10, 0.10);

    otherwise
        error(['Unknown profile "%s". Choose speedbump, pothole, ', ...
               'roughroad, ramp, or curvedramp.'], profileName);
end

% Convert the road from displacement-versus-distance to
% displacement-versus-time using t = x / vehicleSpeed.
t = x / vehicleSpeed;

% Simulink From Workspace can read this timeseries.
roadInput = timeseries(z, t);
roadInput.Name = char(profileName);

% Preview the input.
figure;
plot(t, z, 'LineWidth', 1.2);
xlabel('Time (s)');
ylabel('Road displacement (m)');
title("Road input: " + profileName);
grid on;

end
