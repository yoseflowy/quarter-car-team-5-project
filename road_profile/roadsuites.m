% We are working with a piece of road 200m long, and evaluating data at
% every .25m. This is represented with an 'x' axis:

x = 0:.25:200; 

% The height data is represented with a 'z' axis, 
% defaulted to 0 (level road). 

z = zeros(1, length(x));

% We will be using pre-built road profile functions that can
% add height data to the existing road. 

% For example, speedbump(x, z, 25, 2, 0.2) modifies the 'z' array 
% at position 25m, adding a speed bump that spans 2m and is 0.3m tall.

z = speedbump(x, z, 25, 2, 0.3);
z = curvedramp(x, z, 10, 20, 10);

% Visualizing:
plot(x, z);
axis equal


