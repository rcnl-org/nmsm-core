% function cost = computeNeuralControlCostFunction(secondaryValues, ...
%     primaryValues, isIncluded, experimentalData, params)
%
% values = makeMtpValuesAsStruct(secondaryValues, primaryValues, isIncluded);
% modeledValues = calcNcpModeledValues(values, experimentalData, params);
% cost = calcNcpCost(values, modeledValues, experimentalData, params);
% end

function cost = computeNeuralControlCostFunction(x, inputs, params)
activations = calcActivationsFromSynergyDesignVariables(x, inputs, params);
errs = calculateErrors(activations, inputs, params);
cost = errs' * errs;
end

function errs = calculateErrors(activations, inputs, params)
% Form muscle activations from design variables

% Calculate torque errors
muscleJointMoments = zeros(inputs.numPoints, inputs.numJoints);
% net moment
for i = 1:inputs.numPoints
    for j = 1:inputs.numJoints
        FMT = calcMuscleTendonForce(activations(i, j), inputs.muscleTendonLength(i, j), inputs.muscleTendonVelocity(i, j), j, inputs);
        for k = 1:inputs.numMuscles
            r = inputs.momentArms(i, k, j);
            muscleJointMoments(i, j) = muscleJointMoments(i, j) + r * FMT;
        end
    end
end

torqueErrors = muscleJointMoments - inputs.inverseDynamicsMoments;

actTrackErr = activations(:, 1:inputs.numLegMuscles) - inputs.emgActivation;
actTrackErr = inputs.activationTrackingWeight^0.5 * (actTrackErr(:) / inputs.activationTrackingAllowableError) / (inputs.numPoints * inputs.numLegMuscles)^0.5;
momentErr = inputs.momentTrackingWeight^0.5 * (torqueErrors(:) / inputs.momentTrackingAllowableError) / (inputs.numPoints * inputs.numJoints)^0.5;
actMinErr = reshape(activations(:, inputs.numLegMuscles + 1:end), [inputs.numPoints * (inputs.numTrunkMuscles), 1]);
actMinErr = inputs.activationMinimizationWeight^0.5 * (actMinErr / inputs.activationMinimizationAllowableError) / (inputs.numPoints * inputs.numTrunkMuscles)^0.5;

errs = 1 / sqrt(inputs.momentTrackingWeight + inputs.activationTrackingWeight + inputs.activationMinimizationWeight) * [momentErr; actTrackErr; actMinErr];
end
