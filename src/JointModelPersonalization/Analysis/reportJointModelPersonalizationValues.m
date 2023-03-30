% This function is part of the NMSM Pipeline, see file for full license.
%
% Returns the values of the task. A task comes from
% parseJointModelPersonalizationSettingsTree.m in inputs.task{index}.
%
% (Model, task) -> (1D Array of string, 1D Cell Array)
% Runs the Joint Model Personalization algorithm

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

function [taskDescriptions, values] = ...
    reportJointModelPersonalizationValues(model, task)
model = Model(model);
values = {};
taskDescriptions = string([]);
for i=1:length(task.parameters)
    p = task.parameters{i};
    values{end + 1} = getFrameParameterValue( ...
        model, p{1}, p{2}, p{3}, p{4});
    taskDescriptions(end + 1) = makeJointParameterTaskDescription( ...
        p{1}, p{2}, p{3}, p{4});
end
for i=1:length(task.scaling)
    values{end + 1} = getScalingParameterValue(model, task.scaling(i));
    taskDescriptions(end + 1) = makeScalingParameterTaskDescription( ...
        task.scaling(i));
end
for i=1:length(task.markers)
     [x, y, z] = getMarkerParameterValues(model, task.markers(i));
    values{end + 1} = [x, y, z];
    taskDescriptions(end + 1) = makeMarkerParameterTaskDescription( ...
        task.markers(i));
end
end

function out = makeJointParameterTaskDescription(jointName, isParent, ...
    isTranslation, coordNum)

out = jointName;

if isParent
    out = strcat(out, " parent");
else
    out = strcat(out, " child");
end

if isTranslation
    out = strcat(out, " translation");
else
    out = strcat(out, " orientation");
end

if coordNum == 0
    out = strcat(out, " x");
    return
end
if coordNum == 1
    out = strcat(out, " y");
    return
end
if coordNum == 2
    out = strcat(out, " z");
    return
end
end

function out = makeScalingParameterTaskDescription(bodyName)
out = strcat("Scaling ", bodyName);
end

function out = makeMarkerParameterTaskDescription(markerName)
out = strcat("Marker ", markerName);
end