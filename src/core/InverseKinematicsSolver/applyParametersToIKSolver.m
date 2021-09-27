% This function applies the parameters (struct field/value pairs) such that
% known field values are applied to the correct function for the IKSolver.

% Copyright RCNL *change later*

% (InverseKinematicSolver, struct) -> (InverseKinematicSolver)
% Applies parameters to the Inverse Kinematic Solver
function newIKSolver = applyParametersToIKSolver(IKSolver, params)
import org.opensim.modeling.*
newIKSolver = IKSolver.clone();
modifyAccuracy(newIKSolver, params)
end

function modifyAccuracy(IKSolver, params)
if(isfield(params, 'accuracy'))
    if(isnumeric(params.accuracy))
        IKSolver.setAccuracy(params.accuracy)
    end
end
end
