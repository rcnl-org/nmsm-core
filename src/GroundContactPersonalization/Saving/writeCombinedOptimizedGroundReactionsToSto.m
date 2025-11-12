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
outfileCoP = strcat(name, "_CoP", ext);
outfileBodies = strcat(name, "_controlGroundReactions", ext);

timePoints = inputs.surfaces{1}.time;
data = zeros(length(timePoints), 9 * length(inputs.surfaces));
dataCoP = zeros(length(timePoints), 9 * length(inputs.surfaces));
dataBodies = zeros(length(timePoints), 2 * 6 * length(inputs.surfaces));
columnLabels = string([]);
columnLabelsBodies = string([]);
for foot = 1:length(inputs.surfaces)
    if any(size(timePoints) ~= size(inputs.surfaces{foot}.time)) || ...
            any(timePoints ~= inputs.surfaces{foot}.time)
        return;
    end
end
if ~exist(fullfile(resultsDirectory, "GRFData"), "dir")
    mkdir(fullfile(resultsDirectory, "GRFData"))
end
inputs.calculateBodyLoads = true;
for foot = 1:length(inputs.surfaces)
    for i = 1:3
        columnLabels(end + 1) = convertCharsToStrings( ...
            inputs.surfaces{foot}.forceColumns(i, :));
        columnLabelsBodies(end + 1) = convertCharsToStrings( ...
            inputs.surfaces{foot}.forceColumns(i, :)) + "_parent";
    end
    for i = 1:3
        columnLabelsBodies(end + 1) = convertCharsToStrings( ...
            inputs.surfaces{foot}.forceColumns(i, :)) + "_child";
    end
    for i = 1:3
        columnLabels(end + 1) = convertCharsToStrings( ...
            inputs.surfaces{foot}.electricalCenterColumns(i, :));
    end
    for i = 1:3
        columnLabels(end + 1) = convertCharsToStrings( ...
            inputs.surfaces{foot}.momentColumns(i, :));
        columnLabelsBodies(end + 1) = convertCharsToStrings( ...
            inputs.surfaces{foot}.momentColumns(i, :)) + "_parent";
    end
    for i = 1:3
        columnLabelsBodies(end + 1) = convertCharsToStrings( ...
            inputs.surfaces{foot}.momentColumns(i, :)) + "_child";
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
    data(:, (foot - 1) * 9 + 1 : foot * 9) = [modeledValues.anteriorGrf' modeledValues.verticalGrf' ...
        modeledValues.lateralGrf' center' modeledValues.xGrfMoment' ...
        modeledValues.yGrfMoment' modeledValues.zGrfMoment'];
    dataCoP(:, (foot - 1) * 9 + 1 : foot * 9) = ...
        makeCoPData(data(:, (foot - 1) * 9 + 1 : foot * 9));
    dataBodies(:, (foot - 1) * 6 * 2 + 1 : foot * 6 * 2) = ...
        [modeledValues.splitGroundReactions.parentForces{1}, ...
        modeledValues.splitGroundReactions.childForces{1}, ...
        transferMoments(modeledValues.markerPositions.midfootSuperior', ...
            modeledValues.markerPositions.parentBody', ...
            modeledValues.splitGroundReactions.parentMoments{1}, ...
            modeledValues.splitGroundReactions.parentForces{1}), ...
        transferMoments(modeledValues.markerPositions.midfootSuperior', ...
            modeledValues.markerPositions.childBody', ...
            modeledValues.splitGroundReactions.childMoments{1}, ...
            modeledValues.splitGroundReactions.childForces{1})];
end
data = lowpassFilter(inputs.surfaces{1}.time, data, 2, 6, 0);
dataCoP = lowpassFilter(inputs.surfaces{1}.time, dataCoP, 2, 6, 0);
dataBodies = lowpassFilter(inputs.surfaces{1}.time, dataBodies, 2, 6, 0);
writeToSto(columnLabels, timePoints, data, ...
    fullfile(resultsDirectory, "GRFData", outfile));
writeToSto(columnLabels, timePoints, dataCoP, ...
    fullfile(resultsDirectory, "GRFData", outfileCoP));
writeToSto(columnLabelsBodies, timePoints, dataBodies, ...
    fullfile(resultsDirectory, "GRFData", outfileBodies));
end
