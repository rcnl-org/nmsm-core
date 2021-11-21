% This function computes the inner optimization as defined in the Joint
% Model Personalization module by preparing and running the IK algorithm
% and returning a model with the new values

% Copyright RCNL *change later*

% (Model, struct) -> (Model)
% Returns new model with inverse kinematic optimized marker positions
function error = computeInnerOptimization(values, functions, model, ...
    markerFileName, params)
import org.opensim.modeling.*
inputs = makeInnerOptimizationInputs(functions, model, markerFileName, ...
    params);
model = Model(model);
model.initSystem();
for i = 1:length(values)
    inputs.functions{i}(values(i), model);
end
heuristic = computeInnerOptimizationHeuristic(model, ...
    inputs.markersReference, inputs.coordinateReference, params);
error = zeros(1, length(values)) + heuristic;
end

% (cellArray, Model, struct) -> (struct)
% Adds functions, model and params to input struct
function inputs = makeInnerOptimizationInputs(functions, model, ...
    markerFileName, params)
import org.opensim.modeling.*
inputs.functions = functions;
inputs.model = Model(model);
if(params.ikSettingsFile)
    ikTool = InverseKinematicsTool(params.ikSettingsFile);
    markersRef = MarkersReference();
    coordRef = SimTKArrayCoordinateReference();
    ikTool.populateReferences(markersRef, coordRef)
    inputs.markersReference = markersRef;
    inputs.coordinateReference = coordRef;
else
    inputs.markersReference = valueOrAlternate(params, 'markersReference', ...
        makeMarkersReference(inputs.model, markerFileName, params));
    inputs.coordinateReference = valueOrAlternate(params, ...
        'coordinateReference', ...
        org.opensim.modeling.SimTKArrayCoordinateReference());
end
end