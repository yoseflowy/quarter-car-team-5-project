function z_modified = curvedramp(x, z, startPos, span, height)

index = (x <= startPos + span & x >= startPos);
end_ramp_idx = (x > startPos + span);


z_modified = z;


z_modified(index) = z_modified(index) + ... 
    height * (1 - cos(pi * (x(index) - startPos) / span)) / 2;


z_modified(end_ramp_idx) = z_modified(end_ramp_idx) + height;


end
