% MarkersReference is needed for InverseKinematicSolver as an
% initialization value. Using the model as reference, the params included
% define the markers that exist in the marker reference.
% The params are a struct containing the parameters for the
% MarkersReference. The Set of MarkerWeight is initialized with all markers
% from the model at a weight of one. Params can be set to modify excluded
% markers and change markerWeights.
% params.markerFileName = (string)
% params.excludedMarkers = (1D array of strings (names))
% params.markerWeights = (struct of weights other than 1)

% Copyright RCNL *change later*

% (Model, struct) -> (MarkersReference)
% Makes a MarkersReference from a given model and parameters
function markersReference = makeMarkersReference(model, params)
import org.opensim.modeling.*
markerWeightSet = makeDefaultMarkerWeightSet(model);
if(isfield(params, 'excludedMarkers'))
    markerWeightSet = excludeMarkers(markerWeightSet, ...
        params.excludedMarkers);
end
if(isfield(params, 'markerWeights'))
    markerWeightSet = adjustMarkerWeights(markerWeightSet, ...
        params.markerWeights);
end
markersReference = MarkersReference( ...
    valueOrEmptyString(params, 'markerFileName'), markerWeightSet);
end

