function verifyNoDuplicateMusclesBetweenSynergyGroups(synergyGroups)
for i=1 : length(synergyGroups)
    for j = i + 1 : length(synergyGroups)
        for k = 1 : length(synergyGroups{i}.muscleNames)
            for h = 1 : length(synergyGroups{j}.muscleNames)
                if strcmp(synergyGroups{i}.muscleNames(k), ...
                        synergyGroups{j}.muscleNames(h))
                    throw(MException('',strcat('duplicate muscle "', ...
                        synergyGroups{i}.muscleNames(k), ...
                        '" in synergy groups')))
                end
            end
        end
    end
end
end

