% Joint Model Personalization uses motion tracking data to personalize the
% joint locations and orientations of the model.

% Copyright RCNL *change to actual license in future*

% (struct, struct) -> struct
% Runs the Joint Model Personalization algorithm
function outputModel = JointModelPersonalization(inputs, params)
import org.opensim.modeling.*
optimization = prepareJointModelOptimizations(inputs, params);
outputModel = Model(inputs.model); %copy model
joints = findJointsForJointModel(optimization, inputs, params);
markerPlates = findMarkerPlatesForJointModel(optimization, ...
    inputs, params);
outputModel = computeKinematicCalibration(outputModel, joints, ...
    markerPlates, optimization);
end