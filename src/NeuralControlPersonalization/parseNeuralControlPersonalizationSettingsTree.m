% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes the necessary inputs and produces the results of IK,
% ID, and MuscleAnalysis so the values can be used as inputs for
% MuscleTendonPersonalization.
%
% (struct, struct) -> (None)
% Prepares raw data for MuscleTendonPersonalization

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function [inputs, params, resultsDirectory] = ...
    parseNeuralControlPersonalizationSettingsTree(settingsTree)
inputs = getInputs(settingsTree);
params = getParams(settingsTree, inputs.model);
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
if(isempty(resultsDirectory))
    resultsDirectory = pwd;
end
end

function inputs = getInputs(tree)
inputDirectory = getFieldByName(tree, 'input_directory').Text;
modelFile = getFieldByNameOrError(tree, 'input_model_file').Text;
if(~isempty(inputDirectory))
    try
        inputs.model = fullfile(inputDirectory, modelFile);
    catch
        inputs.model = fullfile(pwd, inputDirectory, modelFile);
        inputDirectory = fullfile(pwd, inputDirectory);
    end
else
    inputs.model = fullfile(pwd, modelFile);
    inputDirectory = pwd;
end
mtpResultsDirectory = getFieldByNameOrError( ...
    tree, "mtp_results_input_directory").Text;
inputs.coordinateNames = parseSpaceSeparatedList(tree, ...
    "coordinate_list");
inputs.muscleNames = getMusclesFromCoordinates(inputs.model, ...
    inputs.coordinateNames);
% size(inputs.muscleNames)
% test = Model(inputs.model).getForceSet().getGroup("right_side").getMembers();
% size(test)
% test = Model(inputs.model).getForceSet().get("test");
inputs.synergyGroups = getSynergyGroups(tree, Model(inputs.model));
inputs.prefixes = findPrefixes(tree, inputDirectory);
inputs = matchMuscleNamesFromCoordinatesAndSynergyGroups(inputs);
inverseDynamicsFileNames = findFileListFromPrefixList(fullfile( ...
    inputDirectory, "IDData"), inputs.prefixes);
inputs.time = parseTimeColumn(inverseDynamicsFileNames);
[inputs.inverseDynamicsMoments, ...
    inputs.inverseDynamicsMomentsColumnNames] = ...
    parseMtpStandard(inverseDynamicsFileNames);
[inputs.mtpActivation, inputs.mtpActivationColumnNames] = ...
    parseMtpStandard(findFileListFromPrefixList( ...
    fullfile(mtpResultsDirectory, "muscleActivations"), inputs.prefixes));
inputs.mtpMuscleData = parseOsimxFile(fullfile(mtpResultsDirectory, ...
    "model.osimx"));
directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    inputDirectory, "MAData"), inputs.prefixes);
[inputs.muscleTendonLength, inputs.muscleTendonColumnNames] = ...
    parseFileFromDirectories(directories, "Length.sto");
inputs.muscleTendonVelocity = parseFileFromDirectories(directories, ...
    "Velocity.sto");
inputs.momentArms = parseMomentArms(directories, inputs.model);
inputs = reorderPreprocessedDataByMuscleNames(inputs, inputs.muscleNames);
[inputs.maxIsometricForce, inputs.optimalFiberLength, ...
    inputs.tendonSlackLength, inputs.pennationAngle] = ...
    getMuscleInputs(inputs, inputs.muscleNames);
[inputs.optimalFiberLengthScaleFactors, ...
    inputs.tendonSlackLengthScaleFactors] = getMtpDataInputs( ...
    inputs.mtpMuscleData, inputs.muscleNames);

end

function [maxIsometricForce, optimalFiberLength, tendonSlackLength, ...
    pennationAngle] = getMuscleInputs(inputs, muscles)
optimalFiberLength = zeros(1, length(muscles));
tendonSlackLength = zeros(1, length(muscles));
pennationAngle = zeros(1, length(muscles));
maxIsometricForce = zeros(1, length(muscles));
model = Model(inputs.model);
for i = 1:length(muscles)
    optimalFiberLength(i) = model.getForceSet(). ...
        getMuscles().get(muscles(i)).getOptimalFiberLength();
    tendonSlackLength(i) = model.getForceSet(). ...
        getMuscles().get(muscles(i)).getTendonSlackLength();
    pennationAngle(i) = model.getForceSet().getMuscles() ...
        .get(muscles(i)).getPennationAngleAtOptimalFiberLength();
    maxIsometricForce(i) = model.getForceSet(). ...
        getMuscles().get(muscles(i)).getMaxIsometricForce();
end
end

function params = getParams(tree, model)
model = Model(model);
params = struct();
muscleGroupTree = getFieldByNameOrError(tree, 'GroupedMuscles');
params.activationGroupNames = parseSpaceSeparatedList(muscleGroupTree, ...
    'activations');
params.activationGroups = groupNamesToGroups( ...
    params.activationGroupNames, model);
params.normalizedFiberLengthGroupNames = parseSpaceSeparatedList(muscleGroupTree, ...
    'normalized_muscle_fiber_lengths');
params.normalizedFiberLengthGroups = groupNamesToGroups( ...
    params.normalizedFiberLengthGroupNames, model);
end

function groups = getSynergyGroups(tree, model)
synergySetTree = getFieldByNameOrError(tree, "SynergySet");
groupsTree = getFieldByNameOrError(synergySetTree, "objects").Synergy;
groups = {};
for i=1:length(groupsTree)
    if(length(groupsTree) == 1)
        group = groupsTree;
    else
        group = groupsTree{i};
    end
    groups{i}.numSynergies = ...
        str2double(group.num_synergies.Text);
    groupMembers = model.getForceSet().getGroup( ...
        group.muscle_group_name.Text).getMembers();
    muscleNames = string([]);
    for j=0:groupMembers.getSize() - 1
        muscleNames(end + 1) = groupMembers.get(j);
    end
    groups{i}.muscleNames = muscleNames;
    groups{i}.muscleGroupName = group.muscle_group_name.Text;
end
end

function [optimalFiberLengthScaleFactors, ...
    tendonSlackLengthScaleFactors] = getMtpDataInputs(mtpData, muscleNames)
optimalFiberLengthScaleFactors = zeros(1, length(muscleNames));
tendonSlackLengthScaleFactors = zeros(1, length(muscleNames));
mtpDataMuscleNames = fieldnames(mtpData);
for i = 1 : length(muscleNames)
    if ismember(muscleNames(i), mtpDataMuscleNames)
        optimalFiberLengthScaleFactors(i) = mtpData.(muscleNames(i)).optimalFiberLengthScaleFactor;
        tendonSlackLengthScaleFactors(i) = mtpData.(muscleNames(i)).tendonSlackLengthScaleFactor;
    else
        optimalFiberLengthScaleFactors(i) = 1;
        tendonSlackLengthScaleFactors(i) = 1;
    end
end
end
