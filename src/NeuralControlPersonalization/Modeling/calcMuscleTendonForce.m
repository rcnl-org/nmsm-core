function [muscleTendonForce, passiveMuscleTendonForce] = calcMuscleTendonForce(a,lMT,vMT,k,inputs)

normalizedFiberLength = (lMT - inputs.tendonSlackLength(k)) ./ (inputs.optimalFiberLength(k) .* cos(inputs.pennationAngle(k)));
normalizedFiberVelocity = muscleTendonVelocity / inputs.vMmax(k);

passiveMuscleTendonForce = (inputs.maxIsometricForce(k) .* cos(inputs.pennationAngle(k))) .* passiveForceLengthCurve(normalizedFiberLength);
activeMuscleTendonForce = (inputs.maxIsometricForce(k) .* cos(inputs.pennationAngle(k))) .* activeForceLengthCurve(normalizedFiberLength) .* forceVelocityCurve(normalizedFiberVelocity);
muscleTendonForce = a * activeMuscleTendonForce + passiveMuscleTendonForce;

end

