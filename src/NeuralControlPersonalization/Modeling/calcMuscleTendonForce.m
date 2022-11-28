%--------------------------------------------------------------------------
function [FMT,FMTpassive] = calcMuscleTendonForce(a,lMT,vMT,k,params)

lMtilda = (lMT - params.lTs(k)) ./ (params.lMo(k) .* cos(params.alpha(k)));
vMtilda = vMT / params.vMmax(k);

FMTpassive = (params.FMo(k) .* cos(params.alpha(k))) .* passiveForceLengthCurve(lMtilda);
FMTactive = (params.FMo(k) .* cos(params.alpha(k))) .* activeForceLengthCurve(lMtilda) .* forceVelocityCurve(vMtilda);
FMT = a * FMTactive + FMTpassive;

end

