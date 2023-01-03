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
params = getParams(settingsTree);
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
mtpCoordinates = parseSpaceSeparatedList(tree, ...
    "mtp_coordinate_list");
ncpCoordinates = parseSpaceSeparatedList(tree, ...
    "ncp_coordinate_list");
inputs.coordinateNames = string([mtpCoordinates ncpCoordinates]);
mtpMuscleNames = getMusclesFromCoordinates(inputs.model, ...
    mtpCoordinates);
ncpMuscleNames = getMusclesFromCoordinates(inputs.model, ...
    ncpCoordinates);
inputs.muscleNames = [mtpMuscleNames ncpMuscleNames];
inputs.numMuscles = length(inputs.muscleNames);
inputs.numLegMuscles = length(mtpMuscleNames);
inputs.numTrunkMuscles = length(ncpMuscleNames);
inputs.numJoints = length(inputs.coordinateNames);
prefixes = findPrefixes(tree, inputDirectory);
inverseDynamicsFileNames = findFileListFromPrefixList(fullfile( ...
    inputDirectory, "IDData"), prefixes);
inputs.inverseDynamicsMoments = parseMtpStandard(inverseDynamicsFileNames);
inputs.emgActivation = parseMtpStandard(findFileListFromPrefixList( ...
    fullfile(inputDirectory, "EMGData"), prefixes));
% inputs.emgActivation = parseEmgWithExpansion(inputs.model, ...
%     findFileListFromPrefixList(fullfile(inputDirectory, "EMGData"), ...
%     prefixes));
directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    inputDirectory, "MAData"), prefixes);
inputs.muscleTendonLength = parseFileFromDirectories(directories, ...
    "Length.sto");
inputs.muscleTendonVelocity = parseFileFromDirectories(directories, ...
    "Velocity.sto");
inputs.momentArms = parseMomentArms(directories, inputs.model);
[inputs.maxIsometricForce, inputs.optimalFiberLength, ...
    inputs.tendonSlackLength, inputs.pennationAngle] = ...
    getMuscleInputs(inputs, inputs.muscleNames);
inputs
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
