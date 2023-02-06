function markerNames = getMarkersFromBody(model, bodyName)
markerNames = {};
for j=0:model.getMarkerSet().getSize()-1
    markerName = model.getMarkerSet().get(j).getName().toCharArray';
    markerParentName = getMarkerBodyName(model, markerName);
    if(strcmp(markerParentName, bodyName))
        if(~markerIncluded(markerNames, markerName))
            markerNames{length(markerNames)+1} = markerName;
        end
    end
end
end

