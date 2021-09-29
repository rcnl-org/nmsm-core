% This function changes the marker weights of the SetMarkerWeights object
% based on the struct given as input. The struct format is:
% field name=name of marker, field value = new weight (number)
% No change is applied if the weight is not a number

% Copyright RCNL *change later*

% (SetMarkerWeights, struct) -> (SetMarkerWeights)
% Changes the weight of specified markers in the SetMarkerWeights
function newMarkerWeightSet = adjustMarkerWeights(markerWeightSet, ...
    markersToAdjust)
import org.opensim.modeling.*
newMarkerWeightSet = markerWeightSet.clone();
namesMarkersToAdjust = string(fieldnames(markersToAdjust));
for i=1:length(namesMarkersToAdjust)
    for j=0:newMarkerWeightSet.getSize()-1
        if(namesMarkersToAdjust(i) == ...
            char(newMarkerWeightSet.get(j).getName()))
            newWeight = markersToAdjust.(namesMarkersToAdjust(i));
            if isnumeric(newWeight)
                newMarkerWeightSet.get(j).setWeight(newWeight);
                break
            end
        end
    end
end
end

