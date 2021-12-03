% This function computes the sum of the squared error for all the markers
% in the argument InverseKinematicsSolver's current frame. The frame can be
% set by initialization an InverseKinematicsSolver, initializing the Model
% system, assembling the InverseKinematicsSolver for a given time.

% Copyright RCNL *change later*

% (InverseKinematicsSolver) -> (number)
% iterate through markers and sum the error
function error = calculateFrameSquaredError(ikSolver, markersReference)
import org.opensim.modeling.*
error = [];
for i=0:markersReference.get_marker_weights().getSize()-1
    marker = markersReference.get_marker_weights().get(i).getName();
    try
    error(length(error)+1) = ikSolver.computeCurrentMarkerError(marker);
    catch
    end
end
error = error / sqrt(length(error));
end

