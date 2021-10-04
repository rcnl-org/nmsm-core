% Compute the heuristic value of the inner optimization for kinematic
% calibration

% copyright RCNL *change later*

% (Model, MarkersReference, struct) -> (number)
% Computes the heuristic value of the output of the inner optimization
function error = computeInnerOptimizationHeuristic(model, ...
    markersReference, params)
import org.opensim.modeling.*
trialModel = Model(model);
trialMarkerReference = MarkersReference(markersReference);
trialIkSolver = makeIKSolverFromMarkersReference(model, ...
    trialMarkerReference, params);
error = computeInverseKinematicsSquaredError(trialModel, trialIkSolver, ...
    params);
end

