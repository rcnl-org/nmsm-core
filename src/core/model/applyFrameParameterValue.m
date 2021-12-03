% This function sets the coordinate value of a child or parent frame for a
% given joint depending on the parameters included.

% Copyright RCNL *change later*

% (Model, double, string, integer, boolean, boolean) -> (None)
% Modifies the model with the given coordinate value
function applyFrameParameterValue(model, newValue, jointName, isParent, ...
    isTranslation, coordNum)
if(isParent)
    frame = model.getJointSet().get(jointName).getParentFrame();
    offsetFrame = org.opensim.modeling.PhysicalOffsetFrame ...
        .safeDownCast(frame);
    if(isTranslation)
        coord = offsetFrame.get_translation();
        coord.set(coordNum, newValue);
        offsetFrame.set_translation(coord);
    else
        coord = offsetFrame.get_orientation();
        coord.set(coordNum, newValue);
        offsetFrame.set_orientation(coord);
    end
else
    frame = model.getJointSet().get(jointName).getChildFrame();
    offsetFrame = org.opensim.modeling.PhysicalOffsetFrame ...
        .safeDownCast(frame);
    if(isTranslation)
        coord = offsetFrame.get_translation();
        coord.set(coordNum, newValue);
        offsetFrame.set_translation(coord);
    else
        coord = offsetFrame.get_orientation();
        coord.set(coordNum, newValue);
        offsetFrame.set_orientation(coord);
    end
end
end

