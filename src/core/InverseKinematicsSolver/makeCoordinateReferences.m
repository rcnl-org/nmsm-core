% A SimTK Array of CoordinateReference is needed for the
% InverseKinematicSolver for use in a few modules. This function takes a
% model for reference and params. The params are a struct where the fields
% are the name of the coordinates for the CoordinateReference and each of
% these fields is a struct containing the parameters of the specific
% CoordinateReference.
% params.mtp_angle_l = struct('weight',100.0)
% produces a param variable such that the SimTKArrayCoordinateReference
% will contain one CoordinateReference with a weight of 100 with the name
% 'mtp_angle_l'.

% Copyright RCNL *change later*

% (Model, struct) -> (SimTKArrayCoordinateReference)
% Builds the Coordinate Reference Array for InverseKinematicSolver
function coordinateReferences = makeCoordinateReferences(model, params)
import org.opensim.modeling.*
coordinateReferences = SimTKArrayCoordinateReference();
tasks = string(fieldnames(params));
for i=1:length(tasks)
   value = model.getCoordinateSet().get(tasks(i)).getDefaultValue();
   coordinateReference = CoordinateReference(tasks(i), Constant(value));
   modifyWeight(coordinateReference, params.(tasks(i)));
   coordinateReferences.push_back(coordinateReference)
end
end

% (CoordinateReference, struct) -> (CoordinateReference)
% Mutates the CoordinateReference with the weight from the params, if valid
function modifyWeight(coordRef, params)
if(isfield(params, 'weight'))
    if(isnumeric(params.weight))
       coordRef.setWeight(params.weight)
    end    
end
end