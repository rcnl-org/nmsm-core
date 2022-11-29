%--------------------------------------------------------------------------
function [FMT,FMTpassive] = calcMuscleTendonForce(a,lMT,vMT,k,inputs)

lMtilda = (lMT - inputs.tendonSlackLength(k)) ./ (inputs.optimalFiberLength(k) .* cos(inputs.pennationAngle(k)));
vMtilda = vMT / inputs.vMmax(k);

FMTpassive = (inputs.FMo(k) .* cos(inputs.pennationAngle(k))) .* passiveForceLengthCurve(lMtilda);
FMTactive = (inputs.FMo(k) .* cos(inputs.pennationAngle(k))) .* activeForceLengthCurve(lMtilda) .* forceVelocityCurve(vMtilda);
FMT = a * FMTactive + FMTpassive;

end
