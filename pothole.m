
function z_modified = pothole(x, z, startPos, span, depth)

index = (x <= startPos + span & x >= startPos);

z_modified = z;

z_modified(index) = z_modified(index) + (-depth * sin((x(index) - startPos)*pi/span));

end
