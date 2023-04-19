function adjustBodyScaling(model, bodyName, value)

markers = getMarkersFromBody(model, bodyName);
markerLocations = {};
for i = 1:length(markers)
    markerLocations{i} = org.opensim.modeling.Vec3(model.getMarkerSet().get(markers{i}).get_location());
end

state = initializeState(model);

scaleSet = org.opensim.modeling.ScaleSet();
scale = org.opensim.modeling.Scale();
scale.setSegmentName(bodyName);
scale.setScaleFactors(org.opensim.modeling.Vec3(value));
scale.setApply(true);
scaleSet.cloneAndAppend(scale);
model.scale(state, scaleSet, true, -1.0);

for i = 1:length(markers)
    model.getMarkerSet().get(markers{i}).set_location(markerLocations{i});
end
end

