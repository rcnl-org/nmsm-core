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

function inputs = parseSurrogateModelCreationSettingsTree(settingsTree)

inputs = getInputs(settingsTree);
end
function inputs = getInputs(tree)

inputs.model = parseModel(tree);
dataDirectory = parseDataDirectory(tree);
prefixes = findPrefixes(tree, dataDirectory);
inputs.surrogateModelCoordinateNames = parseSpaceSeparatedList(tree, ...
    "coordinate_list");
inputs.muscleNames = getMusclesFromCoordinates(inputs.model, ...
    inputs.surrogateModelCoordinateNames);
inputs.numMuscles = length(inputs.muscleNames);

inverseKinematicsFileNames = ...
    findFileListFromPrefixList(fullfile(dataDirectory, "IKData"), prefixes);
[inputs.experimentalJointAngles, inputs.coordinateNames] = ...
    parseInverseKinematicsFile(inverseKinematicsFileNames, inputs.model);
inputs.experimentalJointAngles =  ...
    reshape(permute(inputs.experimentalJointAngles, [1 3 2]), [], ...
    length(inputs.coordinateNames));

directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    dataDirectory, "MAData"), prefixes);
[inputs.muscleTendonLengths, inputs.muscleTendonColumnNames] = ...
    parseFileFromDirectories(directories, "Length.sto");
inputs.muscleTendonLengths = findSpecificMusclesInData( ...
    inputs.muscleTendonLengths, inputs.muscleTendonColumnNames, ...
    inputs.muscleNames);
inputs.muscleTendonLengths = reshape(permute(inputs.muscleTendonLengths, ...
    [1 3 2]), [], length(inputs.muscleNames));
inputs.momentArms = parseSelectMomentArms(directories, ...
    inputs.surrogateModelCoordinateNames, inputs.muscleNames);
inputs.momentArms = reshape(permute(inputs.momentArms, [1 4 2 3]), [], ...
    length(inputs.surrogateModelCoordinateNames), length(inputs.muscleNames));
inputs.epsilon = getDoubleFromField(getFieldByName(tree, 'epsilon'));
inputs.polynomialDegree = getDoubleFromField(getFieldByName(tree, ...
    'polynomial_degree'));
inputs.performLatinHyperCubeSampling = getBooleanLogicFromField( ...
    getFieldByName(tree, 'perform_latin_hypercube_sampling'));
inputs.lhsRangeMultiplier = getDoubleFromField(getFieldByName(tree, ...
    'latin_hypercube_sampling_range'));
inputs.lhsNumPoints = getDoubleFromField(getFieldByName(tree, ...
    'latin_hypercube_sampling_points'));
inputs.resultsDirectory = getTextFromField(getFieldByName(tree, ...
    'results_directory'));
if(isempty(inputs.resultsDirectory))
    inputs.resultsDirectory = pwd;
end
end
function [cells, columnNames] = parseInverseKinematicsFile(files, model)
import org.opensim.modeling.*
file = Storage(files(1));
dataFromFileOne = storageToDoubleMatrix(file);
columnNames = getStorageColumnNames(file);
cells = zeros([length(files) ...
    size(dataFromFileOne)]);
cells(1, :, :) = dataFromFileOne;
for i=2:length(files)
    cells(i, :, :) = storageToDoubleMatrix(Storage(files(i)));
end
osimModel = Model(model);
for i = 1:length(columnNames)
    if strcmp(osimModel.getCoordinateSet.get(columnNames(i)).getMotionType(), 'Rotational')
        cells(:, i, :) = cells(:, i, :) * pi/180;
    end
end
end