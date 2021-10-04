% Compute the heuristic value of the inner optimization for kinematic
% calibration

% copyright RCNL *change later*

% (Model, MarkersReference, struct) -> (number)
% Computes the heuristic value of the output of the inner optimization
function error = computeInnerOptimizationHeuristic(model, ...
    markersReference, params)
import org.opensim.modeling.*
trialModel = Model(model);
trialMarkersReference = MarkersReference(... 
    markersReference.getMarkerTable(), ...
    markersReference.get_marker_weights());
trialIkSolver = makeIKSolverFromMarkersReference(trialModel, ...
    trialMarkersReference, params);
error = computeInverseKinematicsSquaredError(trialModel, trialIkSolver, ...
    trialMarkersReference, params);
end

