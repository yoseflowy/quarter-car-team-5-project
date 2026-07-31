function z_modified = speedbump(x, z, startPos, span, height)

index = (x <= startPos + span & x >= startPos);

z_modified = z;

z_modified(index) = z_modified(index) + (height * sin((x(index) - startPos)*pi/span));

end
