function force = calcBrakingForce(modeledValues, values, contactSurfaces)
force = zeros(length(values.time), length(contactSurfaces));
for i = 1:length(contactSurfaces)
    force(:, i) = -modeledValues.groundReactionsLab.forces{i}(:,1);
end
force = real(sqrt(force)) .^ 2;
end
