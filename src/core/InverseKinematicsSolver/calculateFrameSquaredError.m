% This function computes the sum of the squared error for all the markers
% in the argument InverseKinematicsSolver's current frame. The frame can be
% set by initialization an InverseKinematicsSolver, initializing the Model
% system, assembling the InverseKinematicsSolver for a given time.

% Copyright RCNL *change later*

% (InverseKinematicsSolver) -> (number)
% iterate through markers and sum the error
function error = calculateFrameSquaredError(ikSolver)
error = 0;
for i=0:ikSolver.getNumMarkersInUse()-1
    error = error + ikSolver.computeCurrentSquaredMarkerError(i);
end
end

