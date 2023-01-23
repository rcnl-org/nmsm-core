function adjustMarkerPosition(model, ...
    markerName, value, changeXPosition)
currentPosition = model.getMarkerSet().get(markerName).get_location();
if changeXPosition
    newPosition = org.opensim.modeling.Vec3(value, ...
        currentPosition.get(1), currentPosition.get(2));
else
    newPosition = org.opensim.modeling.Vec3(currentPosition.get(0), ...
        currentPosition.get(1), value);
end
model.getMarkerSet().get(markerName).set_location(newPosition);
end
