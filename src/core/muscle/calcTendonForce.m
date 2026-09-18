function tendonForce = calcTendonForce(normalizedFiberLength, ...
    normalizedFiberVelocity, maxIsometricForce, muscleActivation, ...
    pennationAngle)

[~, ~, totalMuscleForce] = calcMuscleForce(normalizedFiberLength, ...
    normalizedFiberVelocity, maxIsometricForce, muscleActivation);

tendonForce = totalMuscleForce .* cos(pennationAngle);

end