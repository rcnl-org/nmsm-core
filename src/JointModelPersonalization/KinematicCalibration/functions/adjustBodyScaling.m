function adjustBodyScaling(model, bodyName, value)
state = initializeState(model);

scaleSet = org.opensim.modeling.ScaleSet();
scale = org.opensim.modeling.Scale();
scale.setSegmentName(bodyName);
scale.setScaleFactors(org.opensim.modeling.Vec3(value));
scale.setApply(true);
scaleSet.cloneAndAppend(scale);
model.scale(state, scaleSet, true, -1.0);
end

