% This function computes the inner optimization as defined in the Joint
% Model Personalization module by preparing and running the IK algorithm
% and returning a model with the new values

% Copyright RCNL *change later*

% (Model, struct) -> (Model)
% Returns new model with inverse kinematic optimized marker positions
function error = computeInnerOptimization(values, functions, model, ...
    markerFileName, params)
model = Model(model);
for i = 1:length(values)
    functions{i}(values(i), model);
end
markersReference = makeOptMarkerRef(model, markerFileName, params);
error = computeInnerOptimizationHeuristic(model, ...
    markersReference, params);
sum(error.^2)
end

function markersReference = makeOptMarkerRef(model, markerFileName, params)
import org.opensim.modeling.*
if(isfield(params, 'markerNames'))
    markersReference = MarkersReference(markerFileName);
    markersReference.setMarkerWeightSet(makeMarkerWeightSet( ...
        params.markerNames, ones(1, length(params.markerNames))));
else
    markersReference = makeMarkersReference(model, markerFileName, params);
end

end