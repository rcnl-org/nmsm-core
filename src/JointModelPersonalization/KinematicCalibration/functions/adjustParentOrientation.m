% This function adjusts the given model joint parent frame orientation
% coordinate to the given value argument.

% Copyright RCNL *change later*

% (Model, string, integer, number) -> ()
% Mutates model joint parent frame orientation coordinate to new value
function adjustParentOrientation(model, jointName, coordinateNum, value)
import org.opensim.modeling.*
frame = model.getJointSet().get(jointName).getParentFrame();
offsetFrame = PhysicalOffsetFrame.safeDownCast(frame);
newOrientation = offsetFrame.get_orientation();
newOrientation.set(coordinateNum, value);
offsetFrame.set_orientation(newOrientation);
end