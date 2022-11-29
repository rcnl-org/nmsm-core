% function cost = computeNeuralControlCostFunction(secondaryValues, ...
%     primaryValues, isIncluded, experimentalData, params)
%
% values = makeMtpValuesAsStruct(secondaryValues, primaryValues, isIncluded);
% modeledValues = calcNcpModeledValues(values, experimentalData, params);
% cost = calcNcpCost(values, modeledValues, experimentalData, params);
% end

function cost = computeNeuralControlCostFunction(x, inputs, params)
aVals = calcActivationsFromSynergyDesignVariables(x,inputs, params);
errs = calculateErrors(aVals, inputs, params);
cost = errs'*errs;
end

function errs = calculateErrors(aVals, inputs, params)
% Form muscle activations from design variables

% Calculate torque errors
muscleJointMoments = zeros(inputs.nPts,inputs.nJoints);
% net moment
for i = 1:inputs.nPts
    for j = 1:inputs.nJoints
        for k = 1:inputs.numMuscles
            FMT = calcMuscleTendonForce(aVals(i,k),inputs.muscleTendonLength(i,k),inputs.muscleTendonVelocity(i,k),k,inputs);
            r = inputs.rVals(i,k,j);
            muscleJointMoments(i,j) = muscleJointMoments(i,j) + r*FMT;
        end
    end
end
torqueErrors = muscleJointMoments - inputs.IDmomentVals;

actTrackErr = aVals(:,1:inputs.numMuscles_legs) - inputs.EMGact_all;
actTrackErr = inputs.w_ActTrack^0.5*(actTrackErr(:)/inputs.actTrackAllowErr)/(inputs.nPts*inputs.numMuscles_legs)^0.5;
momentErr = inputs.w_MTrack^0.5*(torqueErrors(:)/inputs.momentTrackAllowErr)/(inputs.nPts*inputs.nJoints)^0.5;
actMinErr = reshape(aVals(:,inputs.numMuscles_legs+1:end),[inputs.nPts*(inputs.numMuscles_trunk),1]);
actMinErr = inputs.w_ActMin^0.5*(actMinErr/inputs.actMinAllowErr)/(inputs.nPts*inputs.numMuscles_trunk)^0.5;

errs = 1/sqrt(inputs.w_MTrack + inputs.w_ActTrack + inputs.w_ActMin)*[momentErr; actTrackErr; actMinErr];
end