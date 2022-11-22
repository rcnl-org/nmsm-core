% function cost = computeNeuralControlCostFunction(secondaryValues, ...
%     primaryValues, isIncluded, experimentalData, params)
%
% values = makeMtpValuesAsStruct(secondaryValues, primaryValues, isIncluded);
% modeledValues = calcNcpModeledValues(values, experimentalData, params);
% cost = calcNcpCost(values, modeledValues, experimentalData, params);
% end

function cost = computeNeuralControlCostFunction(x,params)

cost = calculateCost(x,params);

end
%--------------------------------------------------------------------------
function cost = calculateCost(x,params)

errs = calculateErrors(x,params);

cost = errs'*errs;
end
%--------------------------------------------------------------------------
function errs = calculateErrors(x,params)
nJoints = params.nJoints; nPts = params.nPts; nMuscles = params.nMuscles;
nMuscles_legs = params.nMuscles_legs; nMuscles_trunk = params.nMuscles_trunk;
w_MTrack = params.w_MTrack;
w_ActMin = params.w_ActMin;
w_ActTrack = params.w_ActTrack;
lMTVals = params.lMTVals;
vMTVals = params.vMTVals;
rVals = params.rVals;
IDmomentVals = params.IDmomentVals;
% Form muscle activations from design variables
aVals = calcActivationsFromSynergyDesignVariables(x,params);
EMGact_all = params.EMGact_all;

% Calculate torque errors
muscleJointMoments = zeros(nPts,nJoints);
% muscleJointMoments = calcMuscleJointMoments(experimentalData, ...
%     muscleActivations, normalizedFiberLength, normalizedFiberVelocity);
% net moment
for i = 1:nPts
    for j = 1:nJoints
        for k = 1:nMuscles
            FMT = calcMuscleTendonForce(aVals(i,k),lMTVals(i,k),vMTVals(i,k),k,params);
            r = rVals(i,k,j);
            muscleJointMoments(i,j) = muscleJointMoments(i,j) + r*FMT;
        end
    end
end
torqueErrors = muscleJointMoments - IDmomentVals;
torqueErrors = torqueErrors(:);



momentTr_allow_err = 1; % 1 Nm is the allowable error for moment tracking error
actTr_allow_err = params.actTr_allow_err;%0.05; % 0.05 is the allowablw error for activation tracking error

ActTr_err = aVals(:,1:nMuscles_legs) - EMGact_all;
ActTr_err = w_ActTrack^0.5*(ActTr_err(:)/actTr_allow_err)/(nPts*nMuscles_legs)^0.5;
T_err = w_MTrack^0.5*(torqueErrors/momentTr_allow_err)/(nPts*nJoints)^0.5;
ActMin_err = reshape(aVals(:,nMuscles_legs+1:end),[params.nPts*(nMuscles_trunk),1]);
ActMin_err = w_ActMin^0.5*ActMin_err/(nPts*nMuscles_trunk)^0.5;

errs = 1/sqrt(w_MTrack + w_ActTrack + w_ActMin)*[T_err; ActTr_err; ActMin_err];
end