% This function computes the sum of the squared error of the markers over
% the given frames

% Copyright RCNL *change later*

% (Model, InverseKinematicsSolver, struct) -> (number)
% Computes the sum of the squared error of the markers through all frames
function error = computeInverseKinematicsSquaredError(model, ikSolver, ...
    markersReference, params)
import org.opensim.modeling.*
[state, numFrames, frequency] = prepareFrameIterations(model, ikSolver, ...
    markersReference, params);
error = 0;
for i=1:numFrames %start time is set so start with recording error
    ikSolver.track(state);
    error = error + calculateFrameSquaredError(ikSolver);
    state.setTime(state.getTime() + 1/frequency); %MSS: This is dangerous if the frequency is not a round number like 100. We'd better extract time data from the markersReference.getMarkerTable() that is already called in computeInnerOptimizationHeuristic.
end
end

function [state, numFrames, frequency] = prepareFrameIterations(model, ...
    ikSolver, markersReference, params)
state = model.initSystem();
state.setTime(valueOrAlternate(params, 'startTime', ...
    markersReference.getValidTimeRange().get(0)));
ikSolver.assemble(state);
numFrames = valueOrAlternate(params, 'numFrames', ...
    markersReference.getNumFrames());
frequency = valueOrAlternate(params, 'frequency', ...
    markersReference.getSamplingFrequency());
end
