% function cost = computeNeuralControlCostFunction(secondaryValues, ...
%     primaryValues, isIncluded, experimentalData, params)
%
% values = makeMtpValuesAsStruct(secondaryValues, primaryValues, isIncluded);
% modeledValues = calcNcpModeledValues(values, experimentalData, params);
% cost = calcNcpCost(values, modeledValues, experimentalData, params);
% end

function cost = computeNeuralControlCostFunction(x, inputs, params)
activations = calcActivationsFromSynergyDesignVariables(x,inputs, params);
errs = calculateErrors(activations, inputs, params);
cost = errs'*errs;
end

function errs = calculateErrors(activations, inputs, params)
% Form muscle activations from design variables

% Calculate torque errors
muscleJointMoments = zeros(inputs.numPoints,inputs.numJoints);
% net moment
for i = 1:inputs.numPoints
    for j = 1:inputs.numJoints
        for k = 1:inputs.numMuscles
            FMT = calcMuscleTendonForce(activations(i,k),inputs.muscleTendonLength(i,k),inputs.muscleTendonVelocity(i,k),k,inputs);
            r = inputs.rVals(i,k,j);
            muscleJointMoments(i,j) = muscleJointMoments(i,j) + r*FMT;
        end
    end
end
torqueErrors = muscleJointMoments - inputs.IDmomentVals;

actTrackErr = activations(:,1:inputs.numMuscles_legs) - inputs.EMGact_all;
actTrackErr = inputs.w_ActTrack^0.5*(actTrackErr(:)/inputs.actTrackAllowErr)/(inputs.numPoints*inputs.numMuscles_legs)^0.5;
momentErr = inputs.w_MTrack^0.5*(torqueErrors(:)/inputs.momentTrackAllowErr)/(inputs.numPoints*inputs.numJoints)^0.5;
actMinErr = reshape(activations(:,inputs.numMuscles_legs+1:end),[inputs.numPoints*(inputs.numMuscles_trunk),1]);
actMinErr = inputs.w_ActMin^0.5*(actMinErr/inputs.actMinAllowErr)/(inputs.numPoints*inputs.numMuscles_trunk)^0.5;

errs = 1/sqrt(inputs.w_MTrack + inputs.w_ActTrack + inputs.w_ActMin)*[momentErr; actTrackErr; actMinErr];
end