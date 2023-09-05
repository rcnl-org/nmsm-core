% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a parsed settings tree (xml2struct) and finds the
% inverse dynamics, inverse kinematics, ground reactions (if applicable),
% muscle activation (if applicable) and muscle analysis (if applicable)
% data directories.
%
% (struct, struct) -> (struct)
% Returns input structure with experimental data

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function inputs = parseTreatmentOptimizationDataDirectory(tree, inputs)
dataDirectory = parseDataDirectory(tree);
previousResultsDirectoryElement = getFieldByName(tree, 'previous_results_directory');
if isstruct(previousResultsDirectoryElement)
    previousResultsDirectory = previousResultsDirectoryElement.Text;
else
    previousResultsDirectory = [];
end
if strcmp(previousResultsDirectory, "")
        previousResultsDirectory = [];
end
prefix = findPrefixes(tree, dataDirectory);

if ~isempty(previousResultsDirectory) && ...
        exist(fullfile(previousResultsDirectory, "optimal"), 'dir')
    directory = findFirstLevelSubDirectoriesFromPrefixes( ...
        previousResultsDirectory, "optimal");
    if ~isempty(directory)
        model = Model(inputs.model);
        [inputs.experimentalJointMoments, inputs.inverseDynamicMomentLabels] = ...
            parseTreatmentOptimizationData(directory, 'inverseDynamics', model);
        [inputs.experimentalJointAngles, inputs.coordinateNames] = ...
            parseTreatmentOptimizationData(directory, 'inverseKinematics', model);
        experimentalTime = parseTimeColumn(findFileListFromPrefixList(...
            directory, "inverseKinematics"))';
        inputs.kinematicsFile = findFileListFromPrefixList(...
            directory, "inverseKinematics");
        inputs.experimentalTime = experimentalTime - experimentalTime(1);
        if exist(fullfile(dataDirectory, "groundReactions"), 'dir')
            inputs.grfFileName = findFileListFromPrefixList(...
                directory, "groundReactions");
        end
        if strcmp(inputs.controllerType, 'synergy')
            [inputs.experimentalMuscleActivations, inputs.muscleLabels] = ...
                parseTreatmentOptimizationData(directory, 'muscleActivations', model);
        end
    end
else
    directory = findFirstLevelSubDirectoriesFromPrefixes(dataDirectory, "IDData");
    model = Model(inputs.model);
    [inputs.experimentalJointMoments, inputs.inverseDynamicMomentLabels] = ...
        parseTreatmentOptimizationData(directory, prefix, model);
    directory = findFirstLevelSubDirectoriesFromPrefixes(dataDirectory, "IKData");
    [inputs.experimentalJointAngles, inputs.coordinateNames] = ...
        parseTreatmentOptimizationData(directory, prefix, model);
    experimentalTime = parseTimeColumn(findFileListFromPrefixList(...
        fullfile(dataDirectory, "IKData"), prefix))';
    inputs.kinematicsFile = findFileListFromPrefixList( ...
        fullfile(dataDirectory, "IKData"), prefix);
    inputs.experimentalTime = experimentalTime - experimentalTime(1);
    if exist(fullfile(dataDirectory, "GRFData"), 'dir')
        inputs.grfFileName = findFileListFromPrefixList(...
            fullfile(dataDirectory, "GRFData"), prefix);
    end
    if strcmp(inputs.controllerType, 'synergy')
        directory = findFirstLevelSubDirectoriesFromPrefixes(dataDirectory, "ActData");
        [inputs.experimentalMuscleActivations, inputs.muscleLabels] = ...
            parseTreatmentOptimizationData(directory, prefix, model);
    end
end

if strcmp(inputs.controllerType, 'synergy')
    directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
        dataDirectory, "MAData"), prefix);
    inputs.momentArms = parseSelectMomentArms(directories, ...
        inputs.surrogateModelCoordinateNames, inputs.muscleNames);
    inputs.momentArms = reshape(permute(inputs.momentArms, [1 4 2 3]), [], ...
        length(inputs.surrogateModelCoordinateNames), length(inputs.muscleNames));
    inputs = getMuscleSpecificSurrogateModelData(inputs);
end
inputs.numCoordinates = size(inputs.experimentalJointAngles, 2);
end