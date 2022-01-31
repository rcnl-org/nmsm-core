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