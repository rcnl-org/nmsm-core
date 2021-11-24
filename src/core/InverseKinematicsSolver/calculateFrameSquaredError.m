% This function computes the sum of the squared error for all the markers
% in the argument InverseKinematicsSolver's current frame. The frame can be
% set by initialization an InverseKinematicsSolver, initializing the Model
% system, assembling the InverseKinematicsSolver for a given time.

% Copyright RCNL *change later*

% (InverseKinematicsSolver) -> (number)
% iterate through markers and sum the error
function error = calculateFrameSquaredError(ikSolver, desiredError)
import org.opensim.modeling.*
errorArray = SimTKArrayDouble();
ikSolver.computeCurrentMarkerErrors(errorArray);
error = 0;
for i=0:errorArray.size()-1
    error = error + (errorArray.at(i)/desiredError)^2;
end
end

