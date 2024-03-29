function saveNeuralControlPersonalizationResults(synergyWeights, ...
    synergyCommands, activations, combinedMoments, ncpMoments, inputs, resultsDirectory, ...
    precalInputs)
if ~exist(resultsDirectory, "dir")
    mkdir(resultsDirectory);
end
if ~exist(fullfile(resultsDirectory, "modelMoments"))
    mkdir(fullfile(resultsDirectory, "modelMoments"))
end
writeToSto( ...
    inputs.muscleTendonColumnNames, ...
    1:size(synergyWeights, 1), ...
    synergyWeights, ...
    fullfile(resultsDirectory, "synergyWeights.sto"));
commandColumns = [];
for j = 1 : length(inputs.synergyGroups)
    for i = 1 : inputs.synergyGroups{j}.numSynergies
        commandColumns = [commandColumns ...
            convertCharsToStrings( ...
            inputs.synergyGroups{j}.muscleGroupName) + ...
            "_" + convertCharsToStrings(num2str(i))];
    end
end
for i = 1 : size(synergyCommands, 1)
    writeToSto( ...
        commandColumns, ...
        inputs.time(i, :), ...
        squeeze(synergyCommands(i, :, :)), ...
        fullfile( ...
        resultsDirectory, ...
        inputs.prefixes(i) + "_synergyCommands.sto" ...
        ) ...
        )
    tempActivations = permute(activations(i, :, :), [3 1 2]);
    writeToSto( ...
        inputs.muscleTendonColumnNames, ...
        inputs.time(i, :), ...
        tempActivations, ...
        fullfile( ...
        resultsDirectory, ...
        inputs.prefixes(i) + "_combinedActivations.sto" ...
        ) ...
        )
    momentColumns = inputs.coordinateNames;
    model = Model(inputs.modelFileName);
    for j = 1:length(momentColumns)
        if strcmpi(model.getCoordinateSet.get(momentColumns(j)).getMotionType.toString.toCharArray', 'Rotational')
            momentColumns(j) = momentColumns(j) + "_moment";
        else
            momentColumns(j) = momentColumns(j) + "_force";
        end
    end
    writeToSto( ...
        momentColumns, ...
        inputs.time(i, :), ...
        permute(combinedMoments(i, :, :), [3 1 2]), ...
        fullfile( ...
        resultsDirectory, ...
        "modelMoments", ...
        inputs.prefixes(i) + "_modeledMomentsMtpNcpCombined.sto" ...
        ) ...
        )
    writeToSto( ...
        momentColumns, ...
        inputs.time(i, :), ...
        permute(ncpMoments(i, :, :), [3 1 2]), ...
        fullfile( ...
        resultsDirectory, ...
        "modelMoments", ...
        inputs.prefixes(i) + "_modeledMomentsNcp.sto" ...
        ) ...
        )
end
writeNeuralControlPersonalizationOsimxFile(inputs, ...
    resultsDirectory, precalInputs)

end
