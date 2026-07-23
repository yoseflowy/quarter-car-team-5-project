
% We are working with a piece of road 200m long, and evaluating data at
% every .25m. This is represented with an 'x' axis:

x = 0:.25:200; 

% The height data is represented with a 'z' axis, 
% defaulted to 0 (level road). 

z = zeros(5, length(x));

% We will be using pre-built road profile functions that can
% add height data to the existing road. 

% For example, speedbump(x, z, 25, 2, 0.2) modifies the 'z' array 
% at position 25m, adding a speed bump that spans 2m and is 0.3m tall.
profiles = {'curvedramp' 'pothole' 'ramp' 'roughroad' 'speedbump'};

% curvedramp(x, z, startPos, span, height)
z(1,:) = curvedramp(x, z(1,:), 30, 150, 5);
% pothole(x, z, startPos, span, depth)
z(2,:)= pothole(x, z(3,:), 50, .5, 0.3);
% ramp(x, z, startPos, span, height)
z(3,:) = ramp(x, z(4,:), 25,100, 0.3);
% roughroad(x, z, startPos, span, displacement, smoothness)
z(4,:) = roughroad(x, z(4,:),0, 200, 0.3, 5);
% speedbump(x, z, startPos, span, height)
z(5,:) = speedbump(x, z(5,:), 25, 2, 0.3);

% Plots Profiles
for i = 1:5
    subplot(2,3,i)
    plot(x,z(i,:))
    title(profiles(i))
end


%% Functions that generate Road Profiles

% curved Ramp
function z_modified = curvedramp(x, z, startPos, span, height)

index = (x <= startPos + span & x >= startPos);
end_ramp_idx = (x > startPos + span);


z_modified = z;


z_modified(index) = z_modified(index) + ... 
    height * (1 - cos(pi * (x(index) - startPos) / span)) / 2;


z_modified(end_ramp_idx) = z_modified(end_ramp_idx) + height;
end

% Pothole 
function z_modified = pothole(x, z, startPos, span, depth)

index = (x <= startPos + span & x >= startPos);

z_modified = z;

z_modified(index) = z_modified(index) + (-depth * sin((x(index) - startPos)*pi/span));

end

% Ramp
function z_modified = ramp(x, z, startPos, span, height)

index = (x <= startPos + span & x >= startPos);
end_ramp_idx = (x > startPos + span);


z_modified = z;

z_modified(index) = z_modified(index) + ... 
    (height * ((x(index) - startPos)/ span));

z_modified(end_ramp_idx) = z_modified(end_ramp_idx) + height;

end

% Rough Road
function z_modified = roughroad(x, z, startPos, span, displacement, smoothness)

index = (x <= startPos + span & x >= startPos);

z_modified = z;

z_modified(index) = z_modified(index) + (movmean(randn(1, sum(index)), smoothness) * displacement);

end

% Speed Bump
function z_modified = speedbump(x, z, startPos, span, height)

index = (x <= startPos + span & x >= startPos);

z_modified = z;

z_modified(index) = z_modified(index) + (height * sin((x(index) - startPos)*pi/span));

end