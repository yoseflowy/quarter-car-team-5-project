function z_modified = roughroad(x, z, startPos, span, displacement, smoothness)
%ROUGHROAD Add filtered random road displacement over a selected interval.
%
% The noise is created with exactly the same dimensions as
% z_modified(index), so this works for both row and column road vectors.

index = (x <= startPos + span & x >= startPos);

z_modified = z;

% Extract the exact section that will be modified.
roadSection = z_modified(index);

% Generate noise with the same row/column shape as roadSection.
noise = randn(size(roadSection));

% Smooth and scale the noise.
noise = movmean(noise, smoothness) * displacement;

z_modified(index) = roadSection + noise;

end
