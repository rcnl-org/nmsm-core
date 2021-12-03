
% error = calculateError('Patient3', 0.002, {'hip_r'}, 'trc/r_hip.trc')

% (string or Model, number, cellArray of string, string) -> (number)
% Returns the calculated cost function error for the given inputs
function error = calculateJointError(model, desiredError, jointNames, ...
    markerFileName)
model = Model(model);
markerNames = {};
params.desiredError = desiredError;
for i=1:length(jointNames)
    newMarkerNames = getMarkersFromJoint(model, jointNames{i});
    markerNames = {markerNames, newMarkerNames};
end
params.markerNames = cat(2, markerNames{:});
error = computeInnerOptimization([], {}, model, markerFileName, params);
error = sum(error.^2);
end