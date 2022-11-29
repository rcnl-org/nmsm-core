%--------------------------------------------------------------------------
function [FMT,FMTpassive] = calcMuscleTendonForce(a,lMT,vMT,k,inputs)

lMtilda = (lMT - inputs.tendonSlackLength(k)) ./ (inputs.optimalFiberLength(k) .* cos(inputs.alpha(k)));
vMtilda = vMT / inputs.vMmax(k);

FMTpassive = (inputs.FMo(k) .* cos(inputs.alpha(k))) .* passiveForceLengthCurve(lMtilda);
FMTactive = (inputs.FMo(k) .* cos(inputs.alpha(k))) .* activeForceLengthCurve(lMtilda) .* forceVelocityCurve(vMtilda);
FMT = a * FMTactive + FMTpassive;

end

