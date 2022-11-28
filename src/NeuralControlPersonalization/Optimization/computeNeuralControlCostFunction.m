% function cost = computeNeuralControlCostFunction(secondaryValues, ...
%     primaryValues, isIncluded, experimentalData, params)
%
% values = makeMtpValuesAsStruct(secondaryValues, primaryValues, isIncluded);
% modeledValues = calcNcpModeledValues(values, experimentalData, params);
% cost = calcNcpCost(values, modeledValues, experimentalData, params);
% end

function cost = computeNeuralControlCostFunction(x, inputs, params)

errs = calculateErrors(x, inputs, params);

cost = errs'*errs;

end

function errs = calculateErrors(x, inputs, params)
nJoints = inputs.nJoints; nPts = inputs.nPts; nMuscles = inputs.nMuscles;
nMuscles_legs = inputs.nMuscles_legs; nMuscles_trunk = inputs.nMuscles_trunk;
w_MTrack = inputs.w_MTrack;
w_ActMin = inputs.w_ActMin;
w_ActTrack = inputs.w_ActTrack;
lMTVals = inputs.lMTVals;
vMTVals = inputs.vMTVals;
rVals = inputs.rVals;
IDmomentVals = inputs.IDmomentVals;
% Form muscle activations from design variables
aVals = calcActivationsFromSynergyDesignVariables(x,inputs, params);
EMGact_all = inputs.EMGact_all;

% Calculate torque errors
muscleJointMoments = zeros(nPts,nJoints);
% muscleJointMoments = calcMuscleJointMoments(experimentalData, ...
%     muscleActivations, normalizedFiberLength, normalizedFiberVelocity);
% net moment
for i = 1:nPts
    for j = 1:nJoints
        for k = 1:nMuscles
            FMT = calcMuscleTendonForce(aVals(i,k),lMTVals(i,k),vMTVals(i,k),k,inputs);
            r = rVals(i,k,j);
            muscleJointMoments(i,j) = muscleJointMoments(i,j) + r*FMT;
        end
    end
end
torqueErrors = muscleJointMoments - IDmomentVals;
torqueErrors = torqueErrors(:);



momentTrackAllowErr = inputs.momentTrackAllowErr; % 5 Nm is the allowable error for moment tracking error
actTrackAllowErr = inputs.actTrackAllowErr;%0.05; % 0.05 is the allowablw error for activation tracking error
actMinAllowErr = inputs.actMinAllowErr;
actTrackErr = aVals(:,1:nMuscles_legs) - EMGact_all;
actTrackErr = w_ActTrack^0.5*(actTrackErr(:)/actTrackAllowErr)/(nPts*nMuscles_legs)^0.5;
momentErr = w_MTrack^0.5*(torqueErrors/momentTrackAllowErr)/(nPts*nJoints)^0.5;
actMinErr = reshape(aVals(:,nMuscles_legs+1:end),[inputs.nPts*(nMuscles_trunk),1]);
actMinErr = w_ActMin^0.5*(actMinErr/actMinAllowErr)/(nPts*nMuscles_trunk)^0.5;

errs = 1/sqrt(w_MTrack + w_ActTrack + w_ActMin)*[momentErr; actTrackErr; actMinErr];
end