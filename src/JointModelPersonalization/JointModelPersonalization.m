% Joint Model Personalization uses motion tracking data to personalize the
% joint centers of the model.

% Copyright RCNL *change to actual license in future*

% (struct, struct) -> struct
% Runs the Joint Model Personalization algorithm
function outputModel = JointModelPersonalization(inputs, params)
%prepare optimizations
optimizations = prepareJointModelOptimizations(inputs, params);

outputModel = cloneModel(inputs.Model); %copy model
for i=1:length(optimizations) %iterate optimizations
    % retreive optimization values for this specific optimization
    [jointArray, markerPlateArray, optimizerParams] = ...
        findJointModelOptimizationValues(optimizations(i), inputs, params);
    outputModel = computeKinematicCalibration(outputModel, jointArray, ...
        markerPlateArray, optimizerParams);
end
end