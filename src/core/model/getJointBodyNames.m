% This function returns the names of the bodies for a given joint name on a
% given model.

% Copyright RCNL *change later*

% (Model, string) -> (string, string)
% returns the name of the parent and child bodies of a joint
function [parentName, childName] = getJointBodyNames(model,jointName)
parentName = model.findComponent(model.getJointSet().get(jointName) ...
    .getParentFrame().getSocket('parent').getConnecteePath()) ...
    .getName().toCharArray';
childName = model.findComponent(model.getJointSet().get(jointName) ...
    .getChildFrame().getSocket('parent').getConnecteePath()).getName() ...
    .toCharArray';
end

