function adjustBodyScaling(model, bodyName, value)
model.getBodySet().get(bodyName).get_frame_geometry() ...
    .set_scale_factors(org.opensim.modeling.Vec3(value))
end

