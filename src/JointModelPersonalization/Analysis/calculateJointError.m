
% error = calculateError('Patient3', 0.002, {'hip_r'}, 'trc/r_hip.trc')

% (string or Model, number, cellArray of string, string) -> (number)
% Returns the calculated cost function error for the given inputs
function error = calculateJointError(model, desiredError, jointNames, ...
    markerFileName, accuracy)
model = Model(model);
params.markerNames = {};
params.desiredError = desiredError;
params.accuracy = accuracy;
for i=1:length(jointNames)
    newMarkerNames = getMarkersFromJoint(model, jointNames{i});
    for j=1:length(newMarkerNames)
        params.markerNames{length(params.markerNames)+1} = ...
            newMarkerNames{j};
    end
end
error = computeInnerOptimization([], {}, model, markerFileName, params);
error = sum(error.^2);
end