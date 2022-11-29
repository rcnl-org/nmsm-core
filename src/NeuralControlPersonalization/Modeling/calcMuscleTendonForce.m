function [muscleTendonForce, passiveMuscleTendonForce] = calcMuscleTendonForce(a, muscleTendonLength, muscleTendonVelocity, k, inputs)

normalizedFiberLength = (muscleTendonLength - inputs.tendonSlackLength(k)) ./ (inputs.optimalFiberLength(k) .* cos(inputs.pennationAngle(k)));
normalizedFiberVelocity = muscleTendonVelocity / (inputs.optimalFiberLength(k) * inputs.vMaxFactor);

passiveMuscleTendonForce = (inputs.maxIsometricForce(k) .* cos(inputs.pennationAngle(k))) .* passiveForceLengthCurve(normalizedFiberLength);
activeMuscleTendonForce = (inputs.maxIsometricForce(k) .* cos(inputs.pennationAngle(k))) .* activeForceLengthCurve(normalizedFiberLength) .* forceVelocityCurve(normalizedFiberVelocity);
muscleTendonForce = a * activeMuscleTendonForce + passiveMuscleTendonForce;

end

