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
end

function markersReference = makeOptMarkerRef(model, markerFileName, params)
import org.opensim.modeling.*
if(isfield(params, 'markerNames'))
    markersReference = MarkersReference(markerFileName);
    markersReference.setMarkerWeightSet(makeMarkerWeightSet( ...
        params.markerNames, ones(1, length(params.markerNames))));
    removeNonUsedMarkers(model, params.markerNames)
else
    markersReference = makeMarkersReference(model, markerFileName, params);
end
end

function removeNonUsedMarkers(model, keptMarkerNames)
toBeRemoved = [];
for i=0:model.getMarkerSet().getSize()-1
    markerName = model.getMarkerSet().get(i).getName();
    if(~markerIncluded(keptMarkerNames, markerName))
        toBeRemoved(length(toBeRemoved) + 1) = i;
    end
end
markerSet = model.updMarkerSet();
for i=1:length(toBeRemoved)
    markerSet.remove(toBeRemoved(length(toBeRemoved)-i+1));
end
end