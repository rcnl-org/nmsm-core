%--------------------------------------------------------------------------
function [FMT,FMTpassive] = calcMuscleTendonForce(a,lMT,vMT,k,params)

FMo = params.muscleparams.FMo(k);
lMo = params.muscleparams.lMo(k);
lTs = params.muscleparams.lTs(k);
alpha = params.muscleparams.alpha(k);
vMmax = params.muscleparams.vMmax(k);

lMtilda = (lMT-lTs)./(lMo.*cos(alpha));
vMtilda = vMT/vMmax;

FMTpassive = (FMo.*cos(alpha)).*passiveForceLengthCurve(lMtilda);
FMTactive = (FMo.*cos(alpha)).*activeForceLengthCurve(lMtilda)...
    .*forceVelocityCurve(vMtilda);
FMT = a*FMTactive + FMTpassive;

