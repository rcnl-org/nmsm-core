% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a JMP settings file and produces plots of marker
% matching, and prints error values to the command window.
%
% (string) -> (None)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function plotJmpResultsFromSettingsFile(settingsFileName)
import org.opensim.modeling.Storage
try 
    verifyProjectOpened()
catch
    error("NMSM Pipeline Project is not opened.")
end
settingsTree = xml2struct(settingsFileName);
[outputModelFileName, inputs, ~] = ...
    parseJointModelPersonalizationSettingsTree(settingsTree);

inputModelFileName = inputs.modelFileName;

for i = 1 : numel(inputs.tasks)
    task = inputs.tasks{i};
    if isempty(task.markers)
        [task.joints, task.markers] = getMarkersAndJointsInTask(inputs.model, task);
    else
        [task.joints, ~] = getMarkersAndJointsInTask(inputs.model, task);
    end
    [markersInFile, ~, ~] = parseMotToComponents(Model(inputModelFileName), ...
        Storage(task.markerFile));
    markerNames = convertCharsToStrings(task.markers);
    if iscell(markerNames)
        markerNames = cellfun(@(marker) marker(1), markerNames);
    end
    markerIndicesToUse = false(size(task.markers));
    for j = 1 : numel(task.markers)
        if any(contains(markersInFile, markerNames(j)))
            markerIndicesToUse(j) = true;
        end
    end

    % Plot marker errors
    reportDistanceErrorByMarker(inputModelFileName, ...
        task.markerFile, markerNames(markerIndicesToUse), "start.sto");
    reportDistanceErrorByMarker(outputModelFileName, ...
        task.markerFile, markerNames(markerIndicesToUse), "finish.sto");
    figure(Name=strcat(settingsFileName, " Task ", num2str(i)));
    plotMarkerDistanceErrors(["start.sto", "finish.sto"], false)
end
end

function [jointNames, markerNames] = getMarkersAndJointsInTask(model, task)
import org.opensim.modeling.*

parameters = task.parameters;
bodies = task.scaling;
jointNames = {};
for i=1:length(parameters)
    if ~any(strcmp(jointNames,parameters{i}{1}))
        jointNames{length(jointNames)+1} = parameters{i}{1};
    end
end
for i = 1:length(bodies)
    joints = getBodyJointNames(model, bodies{i});
    for j = 1:length(joints)
        if ~any(strcmp(jointNames, joints(j)))
            jointNames{length(jointNames)+1} = joints(j);
        end
    end
end

if isfield(task, "markerNames")
    markerNames = task.markerNames;
else
    markerNames = {};
    for i = 1:length(task.markers)
        if ~any(strcmp(markerNames, task.markers{i}(1)))
            markerNames{end+1} = convertStringsToChars(task.markers{i}(1));
        end
    end
    for k=1:length(jointNames)
        newMarkerNames = getMarkersFromJoint(model, jointNames{k});
        for j=1:length(newMarkerNames)
            if(~markerIncluded(markerNames, newMarkerNames{j}))
                markerNames{length(markerNames)+1} = newMarkerNames{j};
            end
        end
    end
end
end

