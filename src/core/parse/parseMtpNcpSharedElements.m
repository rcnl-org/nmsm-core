function [inputs, params] = parseMtpNcpSharedElements(settingsTree)

inputs = getInputs(settingsTree);
params = getParams(settingsTree);

end

function inputs = getInputs(tree)

inputs.model = parseModel(tree);
inputs.coordinateNames = parseSpaceSeparatedList(tree, "coordinate_list");
inputs.vMaxFactor = str2double(parseElementTextByNameOrAlternate(tree, ...
    "v_max_factor", "10"));
inputs.activationGroupNames = parseSpaceSeparatedList(tree, ...
    "activation_muscle_groups");
inputs.normalizedFiberLengthGroupNames = parseSpaceSeparatedList(tree, ...
    "normalized_fiber_length_muscle_groups");
inputs = parseDataDirectory(tree, inputs);
end

function inputs = parseDataDirectory(tree, inputs)

dataDirectory = getFieldByNameOrError(tree, 'data_directory').Text;
[inputs.inverseDynamicsMoments, ...
    inputs.inverseDynamicsMomentsColumnNames] = ...
    parseMtpStandard(inverseDynamicsFileNames);
directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    inputDirectory, "MAData"), inputs.prefixes);
[inputs.muscleTendonLength, inputs.muscleTendonColumnNames] = ...
    parseFileFromDirectories(directories, "Length.sto");
inputs.muscleTendonVelocity = parseFileFromDirectories(directories, ...
    "Velocity.sto");
inputs.momentArms = parseMomentArms(directories, inputs.model);
end
