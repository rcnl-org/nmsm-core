% Compute the heuristic value of the inner optimization for kinematic
% calibration

% copyright RCNL *change later*

% (Model, MarkersReference, struct) -> (number)
% Computes the heuristic value of the output of the inner optimization
function error = computeInnerOptimizationHeuristic(model, ...
    markersReference, params)
import org.opensim.modeling.*
trialIKSolver = InverseKinematicsSolver(model, ...
    markersReference, SimTKArrayCoordinateReference());
applyParametersToIKSolver(trialIKSolver, params);
error = computeInverseKinematicsSquaredError(model, trialIKSolver, ...
    markersReference, params);
error = error / params.desiredError
sum(error.^2)
end

