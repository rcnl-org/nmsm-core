function joints = getBodyJointNames(model, bodyName)
joints = string([]);
for i = 0 : model.getJointSet().getSize() - 1
    [parent, child] = getJointBodyNames(model, ...
        model.getJointSet().get(i).getName().toCharArray');
    if strcmp(parent, bodyName) || strcmp(child, bodyName)
        joints(end + 1) = ...
            model.getJointSet().get(i).getName().toCharArray';
    end
end
end

