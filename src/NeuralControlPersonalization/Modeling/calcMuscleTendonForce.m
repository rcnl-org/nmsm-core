%--------------------------------------------------------------------------
function [FMT,FMTpassive] = calcMuscleTendonForce(a,lMT,vMT,k,params)

FMo = params.FMo(k);
lMo = params.lMo(k);
lTs = params.lTs(k);
alpha = params.alpha(k);
vMmax = params.vMmax(k);

lMtilda = (lMT-lTs)./(lMo.*cos(alpha));
vMtilda = vMT/vMmax;

FMTpassive = (FMo.*cos(alpha)).*passiveForceLengthCurve(lMtilda);
FMTactive = (FMo.*cos(alpha)).*activeForceLengthCurve(lMtilda)...
    .*forceVelocityCurve(vMtilda);
FMT = a*FMTactive + FMTpassive;

