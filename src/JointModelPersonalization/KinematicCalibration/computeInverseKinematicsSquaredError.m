% This function computes the sum of the squared error of the markers over
% the given frames

% Copyright RCNL *change later*

% (Model, InverseKinematicsSolver, struct) -> (number)
% Computes the sum of the squared error of the markers through all frames
function error = computeInverseKinematicsSquaredError(model, ikSolver, ...
    markersReference, params)
import org.opensim.modeling.*
[state, numFrames, frequency, finishTime] = prepareFrameIterations(model, ikSolver, ...
    markersReference, params);
markerTable = markersReference.getMarkerTable();
times = markerTable.getIndependentColumn();
error = 0;
for i=1:numFrames - 1 %start time is set so start with recording error
    ikSolver.track(state);
    error = error + calculateFrameSquaredError(ikSolver);
    state.setTime(times.get(markerTable.getNearestRowIndexForTime( ...
        state.getTime() + 1/frequency)))
    if(finishTime);if(state.getTime() > finishTime);break;end;end
end
end

% (Model, InverseKinematicsSolver, MarkersReference, struct) =>
% (State, number, number, number)
% Parses params for the IKSolver
function [state, numFrames, frequency, finishTime] = ...
        prepareFrameIterations(model, ikSolver, markersReference, params)
state = model.initSystem();
state.setTime(valueOrAlternate(params, 'startTime', ...
    markersReference.getValidTimeRange().get(0)));
ikSolver.assemble(state);
numFrames = valueOrAlternate(params, 'numFrames', ...
    markersReference.getNumFrames());
frequency = valueOrAlternate(params, 'frequency', ...
    markersReference.getSamplingFrequency());
finishTime = valueOrZero(params, 'finishTime');
end
