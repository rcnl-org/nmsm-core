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

function SurrogateModelCreation(inputs)

inputs = getData(inputs);

if strcmpi(inputs.performLatinHyperCubeSampling, 'true')
    [inputs.muscleTendonLengths, inputs.momentArms, ... 
        inputs.experimentalJointAngles] = performLhsSampling(inputs);
end
inputs = getMuscleSpecificSurrogateModelData(inputs);
[inputs.polynomialExpressionMuscleTendonLengths, ...
    inputs.polynomialExpressionMuscleTendonVelocities, ...
    inputs.polynomialExpressionMomentArms, inputs.coefficients] = ...
    createSurrogateModel(inputs.muscleSpecificJointAngles, ...
    inputs.muscleTendonLengths, inputs.muscleSpecificMomentArms,  ...
    inputs.polynomialDegree);

saveSurrogateModel(inputs);
reportSurrogateModel(inputs);
end

function inputs = getData(inputs)

tree.trial_prefixes = inputs.trialPrefixes;
prefixes = findPrefixes(tree.trial_prefixes, inputs.dataDirectory);
inputs.muscleNames = getMusclesFromCoordinates(inputs.model, ...
    inputs.surrogateModelCoordinateNames);
inputs.numMuscles = length(inputs.muscleNames);

inverseKinematicsFileNames = findFileListFromPrefixList(fullfile( ...
    inputs.dataDirectory, "IKData"), prefixes);
[inputs.experimentalJointAngles, inputs.coordinateNames] = ...
    parseInverseKinematicsFile(inverseKinematicsFileNames, inputs.model);
inputs.experimentalJointAngles =  ...
    reshape(permute(inputs.experimentalJointAngles, [1 3 2]), [], ...
    length(inputs.coordinateNames));

directories = findFirstLevelSubDirectoriesFromPrefixes(fullfile( ...
    inputs.dataDirectory, "MAData"), prefixes);
[inputs.muscleTendonLengths, inputs.muscleTendonColumnNames] = ...
    parseFileFromDirectories(directories, "Length.sto", Model(inputs.model));
inputs.muscleTendonLengths = findSpecificMusclesInData( ...
    inputs.muscleTendonLengths, inputs.muscleTendonColumnNames, ...
    inputs.muscleNames);
inputs.muscleTendonLengths = reshape(permute(inputs.muscleTendonLengths, ...
    [1 3 2]), [], length(inputs.muscleNames));
[inputs.muscleTendonVelocities, muscleTendonColumnNames] = ...
    parseFileFromDirectories(directories, "Velocity.sto", Model(inputs.model));
inputs.muscleTendonVelocities = findSpecificMusclesInData( ...
    inputs.muscleTendonVelocities, muscleTendonColumnNames, ...
    inputs.muscleNames);
inputs.muscleTendonVelocities = reshape(permute(inputs.muscleTendonVelocities, ...
    [1 3 2]), [], length(inputs.muscleNames));
inputs.momentArms = parseSelectMomentArms(directories, ...
    inputs.surrogateModelCoordinateNames, inputs.muscleNames);
inputs.momentArms = reshape(permute(inputs.momentArms, [1 4 2 3]), [], ...
    length(inputs.surrogateModelCoordinateNames), length(inputs.muscleNames));

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

function [muscleTendonLengths, momentArms, ...
    experimentalJointAngles] = performLhsSampling(inputs)

offset = mean(inputs.experimentalJointAngles);
dataPoints = round(linspace(1, size(inputs.experimentalJointAngles, ...
    1), inputs.lhsNumPoints));
experimentalJointAngles = inputs.experimentalJointAngles - offset;
lhsUpperBound = experimentalJointAngles + ...
    range(experimentalJointAngles) * inputs.lhsRangeMultiplier;
lhsLowerBound = experimentalJointAngles - ...
    range(experimentalJointAngles) * inputs.lhsRangeMultiplier;
lhsData = lhsdesign(inputs.lhsNumPoints, ...
    length(inputs.coordinateNames)) .* (lhsUpperBound(dataPoints, :));
lhsData = cat(1, lhsData, lhsdesign(inputs.lhsNumPoints, ...
    length(inputs.coordinateNames)) .* (lhsLowerBound(dataPoints, :)));
lhsData = lhsData + offset;

import org.opensim.modeling.*
model = Model(inputs.model);
state = model.initSystem();
for i = 1 : inputs.numMuscles
    for j = 1 : size(lhsData, 1)
       for k = 1 : size(inputs.coordinateNames, 2)
            if ~model.getCoordinateSet.get(inputs.coordinateNames(k)).get_locked
                model.getCoordinateSet.get(inputs.coordinateNames(k)).setValue(state, lhsData(j, k));
            end
        end
        muscleTendonLengthsLhs(j, i) = model.getMuscles().get(i-1).getGeometryPath().getLength(state);
        for k = 1 : length(inputs.surrogateModelCoordinateNames)
            coordinate = model.getCoordinateSet.get(inputs.surrogateModelCoordinateNames(k));
            momentArmsLhs(j, k, i) = model.getMuscles().get(i-1).getGeometryPath().computeMomentArm(state, coordinate);
        end
    end
end
muscleTendonLengths = cat(1, inputs.muscleTendonLengths, muscleTendonLengthsLhs);
momentArms = cat(1, inputs.momentArms, momentArmsLhs);
experimentalJointAngles = cat(1, inputs.experimentalJointAngles, lhsData);
end