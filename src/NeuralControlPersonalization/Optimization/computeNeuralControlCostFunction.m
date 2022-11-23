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



momentTrackAllowErr = params.momentTrackAllowErr; % 5 Nm is the allowable error for moment tracking error
actTrackAllowErr = params.actTrackAllowErr;%0.05; % 0.05 is the allowablw error for activation tracking error
actMinAllowErr = params.actMinAllowErr;
actTrackErr = aVals(:,1:nMuscles_legs) - EMGact_all;
actTrackErr = w_ActTrack^0.5*(actTrackErr(:)/actTrackAllowErr)/(nPts*nMuscles_legs)^0.5;
momentErr = w_MTrack^0.5*(torqueErrors/momentTrackAllowErr)/(nPts*nJoints)^0.5;
actMinErr = reshape(aVals(:,nMuscles_legs+1:end),[params.nPts*(nMuscles_trunk),1]);
actMinErr = w_ActMin^0.5*(actMinErr/actMinAllowErr)/(nPts*nMuscles_trunk)^0.5;

errs = 1/sqrt(w_MTrack + w_ActTrack + w_ActMin)*[momentErr; actTrackErr; actMinErr];
end