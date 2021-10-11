% This function adjusts the given model joint parent frame translation
% coordinate to the given value argument.

% Copyright RCNL *change later*

% (Model, string, integer, number) -> ()
% Mutates model joint parent frame translation coordinate to new value
function adjustParentTranslation(model, jointName, coordinateNum, value)
import org.opensim.modeling.*
frame = model.getJointSet().get(jointName).getParentFrame();
offsetFrame = PhysicalOffsetFrame.safeDownCast(frame);
newTranslation = offsetFrame.get_translation();
newTranslation.set(coordinateNum, value);
offsetFrame.set_translation(newTranslation);
end