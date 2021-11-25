% Compute the heuristic value of the inner optimization for kinematic
% calibration

% copyright RCNL *change later*

% (Model, MarkersReference, struct) -> (number)
% Computes the heuristic value of the output of the inner optimization
function error = computeInnerOptimizationHeuristic(model, ...
    markersReference, coordinateReference, params)
import org.opensim.modeling.*
trialIKSolver = InverseKinematicsSolver(model, ...
    markersReference, coordinateReference);
applyParametersToIKSolver(trialIKSolver, params)
error = computeInverseKinematicsSquaredError(model, trialIKSolver, ...
    markersReference, params)
end

