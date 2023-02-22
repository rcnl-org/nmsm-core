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
model = Model(inputs.model);
for i = 1 : length(inputs.synergyGroups)
    muscleNames = string([]);
    for j = 1 : length(inputs.synergyGroups{i}.muscleNames)
        if ismember(inputs.synergyGroups{i}.muscleNames(j), ...
                inputs.muscleNames)
            try
                if(model.getForceSet().get(inputs.synergyGroups{i}.muscleNames(j)).get_appliesForce())
                    muscleNames(end + 1) = inputs.synergyGroups{i}.muscleNames(j);
                    newInputMuscleNames(end + 1) = ...
                        inputs.synergyGroups{i}.muscleNames(j);
                else
                    disp(inputs.synergyGroups{i}. ...
                    muscleNames(j) + " does not apply force, but is " + ...
                    "in a synergy group, it will be excluded from " + ...
                    "calculations")
                end
            catch
                throw(MException('', inputs.synergyGroups{i}. ...
                    muscleNames(j) + " muscle is not in the model"))
            end
        end
    end
    inputs.synergyGroups{i}.muscleNames = muscleNames;
end
inputs.muscleNames = newInputMuscleNames;
end

