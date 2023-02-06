function muscleJointMoments = calcNcpMuscleJointMoments(inputs)
muscleJointMoments = zeros(inputs.numPoints, inputs.numJoints);
% net moment
for i = 1:inputs.numPoints
    for k = 1:inputs.numMuscles
        normalizedFiberLength = (inputs.muscleTendonLength(i, k) - inputs.tendonSlackLength(k)) ./ (inputs.optimalFiberLength(k) .* cos(inputs.pennationAngle(k)));
        normalizedFiberVelocity = inputs.muscleTendonVelocity(i, k) / (inputs.optimalFiberLength(k) * inputs.vMaxFactor);

        passiveMuscleTendonForce = (inputs.maxIsometricForce(k) .* cos(inputs.pennationAngle(k))) .* passiveForceLengthCurve(normalizedFiberLength);
        activeMuscleTendonForce = (inputs.maxIsometricForce(k) .* cos(inputs.pennationAngle(k))) .* activeForceLengthCurve(normalizedFiberLength) .* forceVelocityCurve(normalizedFiberVelocity);
        muscleTendonForce = activations(i, k) * activeMuscleTendonForce + passiveMuscleTendonForce;
        for j = 1:inputs.numJoints
            momentArm = inputs.momentArms(i, k, j);
            muscleJointMoments(i, j) = muscleJointMoments(i, j) + momentArm * muscleTendonForce;
        end
    end
end
end
