function inputs = parseMtpNcpSharedInputs(settingsTree)

inputs = getInputs(settingsTree);

end

function inputs = getInputs(tree)

inputs = parseModel(tree, struct());
inputs.osimxFileName = parseElementTextByName(tree, "input_osimx_file");
inputs.coordinateNames = parseSpaceSeparatedList(tree, "coordinate_list");
inputs.muscleNames = getMusclesFromCoordinates(inputs.model, ...
    inputs.coordinateNames);
verifyMuscleNamesForFields(inputs.muscleNames);
inputs.vMaxFactor = str2double(parseElementTextByNameOrAlternate(tree, ...
    "v_max_factor", "10"));
inputs.activationGroupNames = parseSpaceSeparatedList(tree, ...
    "activation_muscle_groups");
inputs.activationGroups = ...
    groupNamesToGroups(inputs.activationGroupNames, inputs.model);
inputs.normalizedFiberLengthGroupNames = parseSpaceSeparatedList(tree, ...
    "normalized_fiber_length_muscle_groups");
inputs.normalizedFiberLengthGroups = ...
    groupNamesToGroups( ...
        inputs.normalizedFiberLengthGroupNames, ...
        inputs.model ...
    );
inputs = parseDataDirectory(tree, inputs);
end

function inputs = parseDataDirectory(tree, inputs)

dataDirectory = getFieldByNameOrError(tree, 'data_directory').Text;
inputs.prefixes = findPrefixes(tree, dataDirectory);
inverseDynamicsFileNames = ...
    findFileListFromPrefixList( ...
        fullfile(dataDirectory, "IDData"), ...
        inputs.prefixes ...
    );
inputs.time = parseTimeColumn(inverseDynamicsFileNames);
[inputs.inverseDynamicsMoments, ...
    inputs.inverseDynamicsMomentsColumnNames] = ...
    parseMtpStandard(inverseDynamicsFileNames);
for i = 1:length(inputs.inverseDynamicsMomentsColumnNames)
    if endsWith(inputs.inverseDynamicsMomentsColumnNames(i), "_moment")
        inputs.inverseDynamicsMomentsColumnNames(i) = extractBefore( ...
            inputs.inverseDynamicsMomentsColumnNames(i), "_moment");
    elseif endsWith(inputs.inverseDynamicsMomentsColumnNames(i), "_force")
        inputs.inverseDynamicsMomentsColumnNames(i) = extractBefore( ...
            inputs.inverseDynamicsMomentsColumnNames(i), "_force");
    end
end
directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    dataDirectory, "MAData"), inputs.prefixes);
model = Model(inputs.model);
[inputs.muscleTendonLength, inputs.muscleTendonColumnNames] = ...
    parseFileFromDirectories(directories, "Length.sto", model);
inputs.muscleTendonVelocity = parseFileFromDirectories(directories, ...
    "Velocity.sto", model);
[inputs.momentArms, inputs.momentArmsCoordinateNames] = ...
    parseMomentArms(directories, inputs.model);
end
