function saveNeuralControlPersonalizationResults(synergyWeights, ...
    synergyCommands, activations, moments, inputs, resultsDirectory, ...
    precalInputs)
if ~exist(resultsDirectory, "dir")
    mkdir(resultsDirectory);
end
if ~exist(fullfile(resultsDirectory, "combinedMuscleActivations"))
    mkdir(fullfile(resultsDirectory, "combinedMuscleActivations"))
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
for i = 1 : size(synergyWeights, 1)
    commandColumns = [commandColumns convertCharsToStrings(num2str(i))];
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
        "combinedMuscleActivations", ...
        inputs.prefixes(i) + "_combinedActivations.sto" ...
        ) ...
        )
    tempMoments = permute(moments(i, :, :), [3 1 2]);
    momentColumns = inputs.coordinateNames;
    model = Model(inputs.model);
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
        tempMoments, ...
        fullfile( ...
        resultsDirectory, ...
        "modelMoments", ...
        inputs.prefixes(i) + "_modeledMoments.sto" ...
        ) ...
        )
end
if isstruct(precalInputs)
    writeNeuralControlPersonalizationOsimxFile(inputs, ...
        resultsDirectory, precalInputs)
end
end
