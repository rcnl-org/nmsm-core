% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
% 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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
    parseSurrogateModelCreationSettingsTree(settingsTree)

inputs = getInputs(settingsTree);
params = getParams(settingsTree);
resultsDirectory = getFieldByName(settingsTree, 'results_directory').Text;
if(isempty(resultsDirectory))
    resultsDirectory = pwd;
end
end
function inputs = getInputs(tree)

inputs.model = parseModel(tree);
dataDirectory = parseDataDirectory(tree);
prefixes = findPrefixes(tree, dataDirectory);
inputs.coordinateNames = parseSpaceSeparatedList(tree, "coordinate_list");
inputs.muscleNames = getMusclesFromCoordinates(inputs.model, ...
    inputs.coordinateNames);

inverseKinematicsFileNames = findFileListFromPrefixList(fullfile(dataDirectory, ...
    "IKData"), prefixes);
[inputs.inverseKinematicsJointAngles, inputs.inverseKinematicsColumnNames] = ...
    parseMtpStandard(inverseKinematicsFileNames);

directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    dataDirectory, "MAData"), prefixes);
[inputs.muscleTendonLength, inputs.muscleTendonColumnNames] = ...
    parseFileFromDirectories(directories, "Length.sto");
inputs.momentArms = parseSelectMomentArms(directories, ...
    inputs.coordinateNames, inputs.muscleNames);
end
function params = getParams(tree)

params.epsilon = getDoubleFromField(getFieldByName(tree, 'epsilon'));
params.polynomialDegree = getDoubleFromField(getFieldByName(tree, 'polynomial_degree'));
params.performLatinHyperCubeSampling = getBooleanLogicFromField(getFieldByName(tree, 'perform_latin_hypercube_sampling'));
end