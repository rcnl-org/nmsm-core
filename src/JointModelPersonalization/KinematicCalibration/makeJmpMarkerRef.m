function markersReference = makeJmpMarkerRef(model, markerFileName, params)
if(isfield(params, 'markerNames'))
    markersReference = MarkersReference(markerFileName);
    markersReference.setMarkerWeightSet(makeMarkerWeightSet( ...
        params.markerNames, ones(1, length(params.markerNames))));
    removeNonUsedMarkers(model, params.markerNames)
else
    markersReference = makeMarkersReference(model, markerFileName, params);
end
end