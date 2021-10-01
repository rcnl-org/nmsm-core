% This function removes the markers as outlined in the input array. The
% input array is a 1D array of string names of the markers to remove from
% the SetMarkerWeights.

% Copyright RCNL *change later*

% (SetMarkerWeights, Array of strings) -> (SetMarkerWeights)
% Returns a marker weight set with the named markers removed
function newMarkerWeightSet = excludeMarkers(markerWeightSet, ...
    excludedMarkers)
import org.opensim.modeling.*
newMarkerWeightSet = SetMarkerWeights(markerWeightSet);
for i=1:length(excludedMarkers)
    for j=0:newMarkerWeightSet.getSize()-1
        if(excludedMarkers(i) == char(newMarkerWeightSet.get(j).getName()))
            newMarkerWeightSet.remove(j);
            break
        end
    end
end
end