function groups = findGroups(tree, model)
groupElements = getFieldByName(tree, 'musclegroups');
activationGroupNames = string([]);
if isstruct(groupElements)
    activationGroupNames(end+1) = groupElements.Text;
elseif iscell(groupElements)
    for i=1:length(groupElements)
        activationGroupNames(end+1) = groupElements{i}.Text;
    end
else
    groups = {};
    return
end
groups = groupNamesToGroups(activationGroupNames, model);
end