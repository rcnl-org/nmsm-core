% This function adjusts the given model joint child frame translation
% coordinate to the given value argument.

% Copyright RCNL *change later*

% (Model, string, integer, number) -> ()
% Mutates model joint child frame translation coordinate to new value
function adjustChildTranslation(model, jointName, coordinateNum, value)
import org.opensim.modeling.*
frame = model.getJointSet().get(jointName).getChildFrame();
offsetFrame = PhysicalOffsetFrame.safeDownCast(frame);
newTranslation = offsetFrame.get_translation();
newTranslation.set(coordinateNum, value);
offsetFrame.set_translation(newTranslation);
end