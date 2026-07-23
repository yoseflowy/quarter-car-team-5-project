function z_modified = roughroad(x, z, startPos, span, displacement, smoothness)

index = (x <= startPos + span & x >= startPos);

z_modified = z;

z_modified(index) = z_modified(index) + ... 
    (movmean(randn(1, sum(index)), smoothness) * displacement);

end
