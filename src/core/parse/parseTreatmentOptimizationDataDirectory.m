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

function inputs = parseTreatmentOptimizationDataDirectory(tree, inputs)
dataDirectory = parseDataDirectory(tree);
prefix = findPrefixes(tree, dataDirectory);

directory = findFirstLevelSubDirectoriesFromPrefixes( ...
    inputs.resultsDirectory, "optimal");
if ~isempty(directory)
    [inputs.experimentalJointMoments, inputs.inverseDynamicMomentLabels] = ...
        parseTreatmentOptimizationData(directory, 'inverseDynamics');
    [inputs.experimentalJointAngles, inputs.coordinateNames] = ...
        parseTreatmentOptimizationData(directory, 'inverseKinematics');
    experimentalTime = parseTimeColumn(findFileListFromPrefixList(...
        directory, "inverseKinematics"))';
    inputs.experimentalTime = experimentalTime - experimentalTime(1);
    inputs.grfFileName = findFileListFromPrefixList(...
        directory, "groundReactions");
    if strcmp(inputs.controllerType, 'synergy_driven')
        [inputs.experimentalMuscleActivations, inputs.muscleLabels] = ...
            parseTreatmentOptimizationData(directory, 'muscleActivations');
    end
else
    directory = findFirstLevelSubDirectoriesFromPrefixes(dataDirectory, "IDData");
    [inputs.experimentalJointMoments, inputs.inverseDynamicMomentLabels] = ...
        parseTreatmentOptimizationData(directory, prefix);
    directory = findFirstLevelSubDirectoriesFromPrefixes(dataDirectory, "IKData");
    [inputs.experimentalJointAngles, inputs.coordinateNames] = ...
        parseTreatmentOptimizationData(directory, prefix);
    experimentalTime = parseTimeColumn(findFileListFromPrefixList(...
        fullfile(dataDirectory, "IKData"), prefix))';
    inputs.experimentalTime = experimentalTime - experimentalTime(1);
    inputs.grfFileName = findFileListFromPrefixList(...
        fullfile(dataDirectory, "GRFData"), prefix);
    if strcmp(inputs.controllerType, 'synergy_driven')
        directory = findFirstLevelSubDirectoriesFromPrefixes(dataDirectory, "ActData");
        [inputs.experimentalMuscleActivations, inputs.muscleLabels] = ...
            parseTreatmentOptimizationData(directory, prefix);
    end
end

if strcmp(inputs.controllerType, 'synergy_driven')
    directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
        dataDirectory, "MAData"), prefix);
    inputs.momentArms = parseSelectMomentArms(directories, ...
        inputs.surrogateModelCoordinateNames, inputs.muscleNames);
    inputs.momentArms = reshape(permute(inputs.momentArms, [1 4 2 3]), [], ...
        length(inputs.surrogateModelCoordinateNames), length(inputs.muscleNames));
    inputs = getMuscleSpecificSurrogateModelData(inputs);
end
inputs.numActuators = size(inputs.experimentalJointMoments, 2);
inputs.numCoordinates = size(inputs.experimentalJointAngles, 2);
end