function inputs = matchMuscleNamesFromCoordinatesAndSynergyGroups(inputs)
flattenedSynergyGroupMuscleNames = string([]);
for i = 1 : length(inputs.synergyGroups)
    for j = 1 : length(inputs.synergyGroups{i}.muscleNames)
        flattenedSynergyGroupMuscleNames(end + 1) = ...
            inputs.synergyGroups{i}.muscleNames(j);
    end
end
notInSynergyGroup = string([]);
for i = 1 : length(inputs.muscleNames)
    if ~ismember(flattenedSynergyGroupMuscleNames, inputs.muscleNames(i))
        notInSynergyGroup(end + 1) = inputs.muscleNames(i);
    end
end
if ~isempty(notInSynergyGroup)
    throw(MException('', strcat("The following muscles cross the ", ...
        "coordinates in the coordinates_list but are not in a synergy", ...
        " group ", strjoin(notInSynergyGroup))));
end
newInputMuscleNames = string([]);
for i = 1 : length(inputs.synergyGroups)
    muscleNames = string([]);
    for j = 1 : length(inputs.synergyGroups{i}.muscleNames)
        if ismember(inputs.synergyGroups{i}.muscleNames(j), ...
                inputs.muscleNames)
            muscleNames(end + 1) = inputs.synergyGroups{i}.muscleNames(j);
            newInputMuscleNames(end + 1) = ...
                inputs.synergyGroups{i}.muscleNames(j);
        end
    end
    inputs.synergyGroups{i}.muscleNames = muscleNames;
end
inputs.muscleNames = newInputMuscleNames;
end

