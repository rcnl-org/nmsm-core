% The default marker weight set includes all markers from the model and
% all markers have a weight of 1. From there, the markers can be modified
% for use.

% Copyright RCNL *change later*

% (Model) -> (SetMarkerWeight)
% Makes a default SetMarkerWeight with all markers in model with weight 1.
function markerWeightSet = makeDefaultMarkerWeightSet(model)
import org.opensim.modeling.*
markerWeightSet = SetMarkerWeights();
for i=0:model.getMarkerSet().getSize()-1
    markerWeightSet.set(i, MarkerWeight( ...
        model.getMarkerSet.get(i).getName(), 1.0));
end
end