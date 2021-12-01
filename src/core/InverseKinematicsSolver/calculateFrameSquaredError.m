% This function computes the sum of the squared error for all the markers
% in the argument InverseKinematicsSolver's current frame. The frame can be
% set by initialization an InverseKinematicsSolver, initializing the Model
% system, assembling the InverseKinematicsSolver for a given time.

% Copyright RCNL *change later*

% (InverseKinematicsSolver) -> (number)
% iterate through markers and sum the error
function error = calculateFrameSquaredError(ikSolver)
import org.opensim.modeling.*
errorArray = SimTKArrayDouble();
ikSolver.computeCurrentMarkerErrors(errorArray);
errorArray.size()
error = zeros(1, errorArray.size());
for i=0:errorArray.size()-1
    error(i+1) = errorArray.at(i);
end
end

