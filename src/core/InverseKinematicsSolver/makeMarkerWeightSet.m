

function markerWeightSet = makeMarkerWeightSet(markerNames, weights)
if(length(markerNames) ~= length(weights))
    throw(MException('',strcat('Marker name array and weight array ', ...
        'are not the same length')))
end
import org.opensim.modeling.*
markerWeightSet = SetMarkerWeights();
for i=1:length(markerNames)
    markerWeightSet.cloneAndAppend(MarkerWeight( ...
        markerNames(i), weights(i)));
end
end

