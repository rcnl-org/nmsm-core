% This function returns the coordinate value of the joint's parent or child
% translation or orientation frame depending on input arguments. The
% arguments are set as follows:
%
% jointName -> The name of the joint (string) (i.e. 'hip_r')
% coordNum -> The number of the coordinate for the given frame, typically
%   0 = 'x', 1 = 'y', 2 = 'z'
% isParent -> True if you want the coordinate value of the parent frame,
%   otherwise it returns the coordinate value of the child frame.
% isTranslation -> True if you want the coordinate to be the translation
%   coordinate value, false if you want orientation.

% Copyright RCNL *change later*

% (Model, string, integer, boolean, boolean) -> (number)

function value = getFrameCoordinateValue(model, jointName, coordNum, ...
    isParent, isTranslation)
import org.opensim.modeling.*
newModel = Model(model);
newModel.initSystem();
if(isParent)
    frame = newModel.getJointSet().get(jointName).getParentFrame();
    offsetFrame = PhysicalOffsetFrame.safeDownCast(frame);
    if(isTranslation)
        value = offsetFrame.get_translation();
    else
        value = offsetFrame.get_orientation();
    end
else
    frame = newModel.getJointSet().get(jointName).getChildFrame();
    offsetFrame = PhysicalOffsetFrame.safeDownCast(frame);
    if(isTranslation)
        value = offsetFrame.get_translation();
    else
        value = offsetFrame.get_orientation();
    end
end
value = value.get(coordNum);
end