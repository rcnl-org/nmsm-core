function plotJmpResultsFromSettingsFile(settingsFileName)
import org.opensim.modeling.Storage
settingsTree = xml2struct(settingsFileName);
[outputModelFileName, inputs, ~] = ...
    parseJointModelPersonalizationSettingsTree(settingsTree);

inputModelFileName = inputs.modelFileName;
% inputModel = Model(inputModelFileName);
% outputModel = Model(outputModelFileName);

for i = 1 : numel(inputs.tasks)
    task = inputs.tasks{i};
    if isempty(task.markers)
        task.markers = getMarkersInTask(inputs.model, task);
    end
    
    % markerFileStorage = Storage(task.markerFile);
    % markerNamesInStorage = getStorageColumnNames(markerFileStorage);
    % 
    % markersInFile = contains(task.markers, markerNamesInStorage);
    [markersInFile, ~, ~] = parseMotToComponents(Model(inputModelFileName), ...
        Storage(task.markerFile));
    markerIndicesToUse = boolean(zeros(size(task.markers)));
    markerCounter = 1;
    for i = 1 : numel(task.markers)
        if any(contains(markersInFile, task.markers(i)))
            markerIndicesToUse(i) = 1;
        end
    end

    % markersIndicesInFile = contains(task.markers, ...
    %     erase(markersInFile, ["_x", "_y", "_z"]));


    reportDistanceErrorByMarker(inputModelFileName, ...
        task.markerFile, task.markers(markerIndicesToUse), "start.sto");
    reportDistanceErrorByMarker(outputModelFileName, ...
        task.markerFile, task.markers(markerIndicesToUse), "finish.sto");
    figure(Name=strcat(settingsFileName, " Task ", num2str(i)));
    plotMarkerDistanceErrors(["start.sto", "finish.sto"], false)
end
% settingsTree = xml2struct(settingsFileName);
% inputModelFileName = parseElementTextByName(settingsTree, 'input_model_file');
% inputModel = Model(inputModelFileName);
% 
% outputModelFileName = parseElementTextByName(settingsTree, 'output_model_file');
% outputModel = Model(outputModelFileName);
% 
% tasks = getFieldByNameOrError(settingsTree, 'JMPTaskList');
% counter = 1;
% jmpTasks = orderByIndex(tasks.JMPTask);
% taskInputs = {};
% for i=1:length(jmpTasks)
%     if(length(jmpTasks) == 1)
%         task = jmpTasks;
%     else
%         task = jmpTasks{i};
%     end
%     if strcmpi(task.is_enabled.Text, 'true')
%         taskInputs{counter}.markerFileName = ...
%             parseElementTextByName(task, 'marker_file_name');
%         taskInputs{counter}.markerNames = getMarkerNames(task, inputModel);
%         counter = counter + 1;
%     end
end

function markerNames = getMarkersInTask(model, task)
import org.opensim.modeling.*
if isfield(task, "markerNames")
    markerNames = task.markerNames;
    return
end
parameters = task.parameters;
bodies = task.scaling;
markerNames = {};
for i = 1:length(task.markers)
    if ~any(strcmp(markerNames, task.markers{i}(1)))
        markerNames{end+1} = convertStringsToChars(task.markers{i}(1));
    end
end
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
for k=1:length(jointNames)
    newMarkerNames = getMarkersFromJoint(model, jointNames{k});
    for j=1:length(newMarkerNames)
        if(~markerIncluded(markerNames, newMarkerNames{j}))
            markerNames{length(markerNames)+1} = newMarkerNames{j};
        end
    end
end
end
% function markerNames = getMarkerNames(tree, model)
% try
%     markerNames = parseSpaceSeparatedList(tree, 'marker_names');
%     if ~isempty(markerNames)
%         output.markerNames = markerNames;
%     end
% catch; end
% end

