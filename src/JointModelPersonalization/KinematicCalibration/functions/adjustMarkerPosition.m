function adjustMarkerPosition(model, ...
    markerName, value, axis)
currentPosition = model.getMarkerSet().get(markerName).get_location();
if strcmp(axis, "x")
    newPosition = org.opensim.modeling.Vec3(value, ...
        currentPosition.get(1), currentPosition.get(2));
end
if strcmp(axis, "y")
    newPosition = org.opensim.modeling.Vec3(currentPosition.get(0), ...
        value, currentPosition.get(2));
end
if strcmp(axis, "z")
    newPosition = org.opensim.modeling.Vec3(currentPosition.get(0), ...
        currentPosition.get(1), value);
end
model.getMarkerSet().get(markerName).set_location(newPosition);
end
