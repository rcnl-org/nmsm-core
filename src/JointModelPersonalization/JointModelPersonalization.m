% Joint Model Personalization uses motion tracking data to personalize the
% joint locations and orientations of the model.

% Copyright RCNL *change to actual license in future*

% (struct, struct) -> struct
% Runs the Joint Model Personalization algorithm
function outputModel = JointModelPersonalization(inputs, params)
optimizations = prepareJointModelOptimizations(inputs, params);
outputModel = cloneModel(inputs.model); %copy model
for i=1:length(optimizations) %iterate optimizations
    % retrieve optimization values for this specific optimization
    joints = findJointsForJointModel(optimizations(i), inputs, params);
    markerPlates = findMarkerPlatesForJointModel(optimizations(i), ...
        inputs, params);
    outputModel = computeKinematicCalibration(outputModel, joints, ...
        markerPlates, optimizations(i));
end
end