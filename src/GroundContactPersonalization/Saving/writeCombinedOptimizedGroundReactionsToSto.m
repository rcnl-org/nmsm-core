% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (struct, string, string) -> (None)
% Write modeled ground reactions to an OpenSim Storage file.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function writeCombinedOptimizedGroundReactionsToSto(inputs, params, ...
    resultsDirectory)
for foot = 1:length(inputs.surfaces)
    models.("model_" + foot) = Model(inputs.surfaces{foot}.model);
end
[~,name,ext] = fileparts(inputs.grfFileName);
outfile = strcat(name, ext);

timePoints = inputs.surfaces{1}.time;
data = zeros(length(timePoints), 9 * length(inputs.surfaces));
dataCoP = zeros(size(data));
columnLabels = string([]);
for foot = 1:length(inputs.surfaces)
    if any(size(timePoints) ~= size(inputs.surfaces{foot}.time)) || ...
            any(timePoints ~= inputs.surfaces{foot}.time)
        return;
    end
end
if ~exist(fullfile(resultsDirectory, "GRFData"), "dir")
    mkdir(fullfile(resultsDirectory, "GRFData"))
end
for foot = 1:length(inputs.surfaces)
    for i = 1:3
        columnLabels(end + 1) = convertCharsToStrings( ...
            inputs.surfaces{foot}.forceColumns(i, :));
    end
    for i = 1:3
        columnLabels(end + 1) = convertCharsToStrings( ...
            inputs.surfaces{foot}.electricalCenterColumns(i, :));
    end
    for i = 1:3
        columnLabels(end + 1) = convertCharsToStrings( ...
            inputs.surfaces{foot}.momentColumns(i, :));
    end
    [modeledJointPositions, modeledJointVelocities] = ...
        calcGCPJointKinematics(inputs.surfaces{foot} ...
        .experimentalJointPositions, inputs.surfaces{foot} ...
        .jointKinematicsBSplines, inputs.surfaces{foot}.bSplineCoefficients);
    modeledValues = calcGCPModeledValues(inputs, inputs, ...
        modeledJointPositions, modeledJointVelocities, params, ...
        length(params.tasks), foot, models);
    center = inputs.surfaces{foot}.midfootSuperiorPosition;
    center(2, :) = inputs.restingSpringLength;
    data(:, (foot - 1) * 9 + 1 : foot * 9) = [modeledValues.anteriorGrf' ...
        modeledValues.verticalGrf' modeledValues.lateralGrf' center' ...
        modeledValues.xGrfMoment' modeledValues.yGrfMoment' ...
        modeledValues.zGrfMoment'];
    dataCoP(:, (foot - 1) * 9 + 1 : foot * 9) = ...
        convertEcToCoP(data(:, (foot - 1) * 9 + 1 : foot * 9));
end
data = lowpassFilter(inputs.surfaces{1}.time, data, 2, 6, 0);
dataCoP = lowpassFilter(inputs.surfaces{1}.time, dataCoP, 2, 6, 0);
writeToSto(columnLabels, timePoints, data, ...
    fullfile(resultsDirectory, "GRFData", outfile));
writeToSto(columnLabels, timePoints, dataCoP, ...
    fullfile(resultsDirectory, "GRFData", strcat('CoP_', outfile)));
end

function dataCoP = convertEcToCoP(data)
forces = data(:, 1:3);
forcesThreshold = forces;
points = data(:, 4:6);
moments = data(:, 7:9);

threshold = 1e-6;
forcesThreshold(abs(forcesThreshold(:, 2)) < threshold, 2) = ...
    sign(forcesThreshold(abs(forcesThreshold(:, 2)) < threshold, 2)) * threshold;

centerOfPressure = zeros(size(points));
centerOfPressure(:, 1) = points(:, 1) + (moments(:, 3) - forcesThreshold(:, 1) ...
    .* points(:, 2)) ./ forcesThreshold(:, 2);
centerOfPressure(:, 3) = points(:, 3) - (moments(:, 1) + forcesThreshold(:, 3) ...
    .* points(:, 2)) ./ forcesThreshold(:, 2);

dataCoP = zeros(size(data));
dataCoP(:, 1:3) = forces;
dataCoP(:, 4:6) = centerOfPressure;
dataCoP(:, 8) = moments(:, 2) + forcesThreshold(:, 1) .* points(:, 3) - ...
    forcesThreshold(:, 3) .* points(:, 1);
end
