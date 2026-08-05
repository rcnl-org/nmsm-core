% This class is part of the NMSM Pipeline, see file for full license.
%
% This class is the main App Designer application for the Joint Model
% Personalization (JMP) GUI, providing the interface for configuring,
% saving, and running JMP settings files.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
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
classdef JMPBase < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        JMPImage                       matlab.ui.control.Image
        JointModelPersonalizationToolLabel  matlab.ui.control.Label
        RunButton                      matlab.ui.control.Button
        HelpButton                     matlab.ui.control.Button
        SaveButton                     matlab.ui.control.Button
        LoadSettingsFileButton         matlab.ui.control.Button
        ResetButton                    matlab.ui.control.Button
        RcnlLogo                       matlab.ui.control.Image
        JMPInputsButton                matlab.ui.control.Button
        AdvancedButton                 matlab.ui.control.Button
        JMPTasksButton                 matlab.ui.control.Button
        Mask1                          matlab.ui.control.Image
        TabGroup                       matlab.ui.container.TabGroup
        InputsTab                      matlab.ui.container.Tab
        InputModelFileEditField        matlab.ui.control.EditField
        InputModelFileEditFieldLabel   matlab.ui.control.Label
        InputModelFileSearchButton     matlab.ui.control.Button
        InputModelFileStatus           matlab.ui.control.Image
        OutputModelFileEditField       matlab.ui.control.EditField
        OutputModelFileEditFieldLabel  matlab.ui.control.Label
        OutputModelFileSearchButton    matlab.ui.control.Button
        TasksTab                       matlab.ui.container.Tab
        TasksStatus                    matlab.ui.control.Image
        TasksTable                     matlab.ui.control.Table
        MoveTaskDownButton             matlab.ui.control.Button
        MoveTaskUpButton               matlab.ui.control.Button
        TasksPanel                     matlab.ui.container.Panel
        BodiesStatus                   matlab.ui.control.Image
        JointsStatus                   matlab.ui.control.Image
        MarkersStatus                  matlab.ui.control.Image
        MarkersEditButton              matlab.ui.control.Button
        MarkersTextArea                matlab.ui.control.TextArea
        MarkersTextAreaLabel           matlab.ui.control.Label
        EndTimeField                   matlab.ui.control.NumericEditField
        ToLabel                        matlab.ui.control.Label
        StartTimeField                 matlab.ui.control.NumericEditField
        TimeRangesEditFieldLabel       matlab.ui.control.Label
        MarkersFileEditField           matlab.ui.control.EditField
        MarkersFileEditFieldLabel      matlab.ui.control.Label
        BodiesLabel                    matlab.ui.control.Label
        JointsLabel                    matlab.ui.control.Label
        JointsTable                    matlab.ui.control.Table
        BodiesTable                    matlab.ui.control.Table
        TimeRangeStatus                matlab.ui.control.Image
        MarkersFileStatus              matlab.ui.control.Image
        MarkerFileSearchButton         matlab.ui.control.Button
        MuscleGroupsLabel_3            matlab.ui.control.Label
        AdvancedTab                    matlab.ui.container.Tab
        AdvancedSettingsTable          matlab.ui.control.Table
        TasksContextMenu               matlab.ui.container.ContextMenu
        RenameMenu                     matlab.ui.container.Menu
        CopyTaskMenu                   matlab.ui.container.Menu
        DeleteTaskMenu                 matlab.ui.container.Menu
        JointsContextMenu              matlab.ui.container.ContextMenu
        EditJointMenu                  matlab.ui.container.Menu
        DeleteJointMenu                matlab.ui.container.Menu
        BodiesContextMenu              matlab.ui.container.ContextMenu
        EditBodyMenu                   matlab.ui.container.Menu
        DeleteBodyMenu                 matlab.ui.container.Menu
    end


    properties (Access = private, SetObservable)
        input_model_file string = "";
        output_model_file string = "";
        JMPTask cell = cell(0);
        taskIndex double = 1;

        model_markers string;
        model_bodies string;
        model_joints string;

        advancedSettingValues double = [];

        % Error checking and flow control
        currentSettingsFile string = "";
        inputModelValid logical = false
        outputModelValid logical = false
    end

    properties (Constant, Access = private)
        advancedSettingNames = ...
            ["allowable_error"
            "max_function_evaluations"
            "step_tolerance"
            "function_tolerance"
            "optimality_tolerance"
            "diff_min_change"
            "accuracy"]

        defaultAdvancedSettingValues = ...
            [0.005
            200
            1e-5
            1e-5
            1e-5
            1e-3
            1e-6]
    end

    properties (Access = private)  % private UI components not in appModel
        OutputModelFileStatus          matlab.ui.control.Image
        JointBodyStatus                matlab.ui.control.Image
        AdvancedSettingsStatus         matlab.ui.control.Image
    end

    properties (Access = private)  % listener handles
        inputModelFileListener
        outputModelFileListener
        taskIndexListener
        advancedSettingsListener
        selectedTabListener
    end

    methods (Access = private) % listener methods
        function makeAllListeners(app)
            app.inputModelFileListener = addlistener(app, ...
                'input_model_file', 'PostSet', ...
                @(src, event)updateInputModelFile(app));

            app.outputModelFileListener = addlistener(app, ...
                'output_model_file', 'PostSet', ...
                @(src, event)updateOutputModelFile(app));

            app.taskIndexListener = addlistener(app, ...
                'taskIndex', 'PostSet', ...
                @(src, event)updateTaskIndex(app));

            app.advancedSettingsListener = addlistener(app, ...
                'advancedSettingValues', 'PostSet', ...
                @(src, event)refreshAdvancedSettingsTable(app));

            app.selectedTabListener = addlistener(app.TabGroup, ...
                'SelectedTab', 'PostSet', ...
                @(src, event)formatTabButtons(app));

            app.makeTaskListeners()
        end

        function makeTaskListeners(app)
            task = app.JMPTask{app.taskIndex};
            addlistener(task, 'name', 'PostSet', ...
                @(src, event)updateJMPTasksListBox(app));
            addlistener(task, 'marker_file_name', 'PostSet', ...
                @(src, event)updateMarkersFile(app));
            addlistener(task, 'marker_names', 'PostSet', ...
                @(src, event)updateMarkerNames(app));
            addlistener(task, 'jointNames', 'PostSet', ...
                @(src, event)updateJointsTable(app));
            addlistener(task, 'bodyNames', 'PostSet', ...
                @(src, event)updateBodiesTable(app));
        end

        function updateInputModelFile(app)
            app.InputModelFileEditField.Value = getRelativePath( ...
                app.input_model_file);
            app.validateInputModelFile();
            app.updateRunButton();
        end

        function updateOutputModelFile(app)
            app.OutputModelFileEditField.Value = getRelativePath( ...
                app.output_model_file);
            app.validateOutputModelFile();
            app.updateRunButton();
        end

        function updateTaskIndex(app)
            app.TasksTable.Selection = app.taskIndex;
            app.updateTasksPanel()
            app.updateJointsTable()
            app.updateBodiesTable()
        end

        function refreshAdvancedSettingsTable(app)
            Options = app.advancedSettingNames;
            Values = arrayfun(@formatGuiNumber, app.advancedSettingValues);
            app.AdvancedSettingsTable.Data = table(Options, Values);
            app.updateRunButton();
        end

        function updateMarkersFile(app)
            app.MarkersFileEditField.Value = getRelativePath( ...
                app.JMPTask{app.taskIndex}.marker_file_name);
            app.validateMarkerFile();
            app.updateMarkersEditButton();
            app.updateRunButton();
        end

        function updateMarkersEditButton(app)
            app.MarkersEditButton.Enable = ...
                ~isempty(app.JMPTask{app.taskIndex}.markerFileMarkers);
        end

        function updateMarkerNames(app)
            app.MarkersTextArea.Value = app.JMPTask{app.taskIndex}.marker_names;
            app.validateMarkerSelection();
            app.updateRunButton();
        end

        function updateJointsTable(app)
            app.JointsTable.Data = table([app.JMPTask{app.taskIndex}.jointNames'; ...
                "+ Add new joint"]);
            app.validateTaskContent();
            app.updateRunButton();
        end

        function updateBodiesTable(app)
            app.BodiesTable.Data = table([app.JMPTask{app.taskIndex}.bodyNames'; ...
                "+ Add new body"]);
            app.validateTaskContent();
            app.updateRunButton();
        end

        function updateJMPTasksListBox(app)
            updateTaskListTableGui(app.TasksTable, app.JMPTask);
        end

        function updateTasksPanel(app)
            if isempty(app.JMPTask)
                app.createEmptyTask()
            end
            task = app.JMPTask{app.taskIndex};
            app.MarkersFileEditField.Value = getRelativePath( ...
                task.marker_file_name);
            app.StartTimeField.Value = task.time_range(1);
            app.EndTimeField.Value = task.time_range(2);
            app.MarkersTextArea.Value = task.marker_names;
            app.updateMarkersEditButton();
            app.validateMarkerFile();
            app.validateMarkerSelection();
        end

        function formatTabButtons(app)
            if ~isvalid(app) || ~isvalid(app.TabGroup)
                return
            end
            updateTabButtonStyles(app.TabGroup.SelectedTab, ...
                [app.InputsTab, app.TasksTab, app.AdvancedTab], ...
                [app.JMPInputsButton, app.JMPTasksButton, ...
                app.AdvancedButton]);
        end
    end

    methods (Access = private)

        function createEmptyTask(app)
            app.JMPTask{end + 1} = JMPTaskClass();
            app.taskIndex = length(app.JMPTask);
            app.makeTaskListeners();
            app.JMPTask{app.taskIndex}.name = "Task " + num2str(app.taskIndex);
            app.JMPTask{app.taskIndex}.index = app.taskIndex;
            app.updateTasksPanel();
            app.updateJMPTasksListBox();
        end

        function deleteTask(app, deletionIndex)
            [app.JMPTask, newTaskIndex] = removeTaskFromList( ...
                app.JMPTask, deletionIndex, app.taskIndex);
            if isempty(app.JMPTask)
                app.createEmptyTask();
            else
                app.taskIndex = newTaskIndex;
            end
            app.updateJMPTasksListBox();
            app.updateRunButton();
        end

        function moveTaskUp(app)
            [app.JMPTask, app.taskIndex] = moveTaskInList( ...
                app.JMPTask, app.taskIndex, -1);
            app.updateJMPTasksListBox();
        end

        function moveTaskDown(app)
            [app.JMPTask, app.taskIndex] = moveTaskInList( ...
                app.JMPTask, app.taskIndex, 1);
            app.updateJMPTasksListBox();
        end

        function deleteJoint(app, jointIndex)
            task = app.JMPTask{app.taskIndex};
            if isempty(jointIndex) || ~iscell(task.JMPJointSet.JMPJoint) || ...
                    jointIndex > length(task.JMPJointSet.JMPJoint)
                return
            end
            task.JMPJointSet.JMPJoint(jointIndex) = [];
            task.jointNames(jointIndex) = [];
        end

        function deleteBody(app, bodyIndex)
            task = app.JMPTask{app.taskIndex};
            if isempty(bodyIndex) || ~iscell(task.JMPBodySet.JMPBody) || ...
                    bodyIndex > length(task.JMPBodySet.JMPBody)
                return
            end
            task.JMPBodySet.JMPBody(bodyIndex) = [];
            task.bodyNames(bodyIndex) = [];
        end

        function parseMarkerFileData(app, markerFileName)
            import org.opensim.modeling.TimeSeriesTableVec3
            task = app.JMPTask{app.taskIndex};
            timeSeriesTable = TimeSeriesTableVec3(markerFileName);
            columnLabels = char(timeSeriesTable.getColumnLabels);
            task.markerFileMarkers = strsplit(columnLabels(2:end-1), ", ");

            timeVector = timeSeriesTable.getIndependentColumn;
            task.minTime = double(timeVector.get(0));
            task.maxTime = double(timeVector.get( ...
                timeSeriesTable.getNumRows - 1));
            if isequal(task.time_range, [0 0]) || ...
                    task.time_range(1) < task.minTime || ...
                    task.time_range(2) > task.maxTime
                task.time_range = [task.minTime task.maxTime];
            end
        end

        function validateAllFields(app)
            app.validateInputModelFile();
            app.validateOutputModelFile();
            app.validateMarkerFile();
            app.validateMarkerSelection();
            app.validateTimeRange();
            app.validateTaskContent();
            app.validateAllTasksSilent();
        end

        function validateInputModelFile(app)
            app.inputModelValid = validateRequiredFieldGui( ...
                app.input_model_file, "Input model file is required.", ...
                app.InputModelFileEditField, app.InputModelFileStatus, ...
                app.InputModelFileStatus, ...
                @(value, field, icon)validateOsimFileGui(app, value, field, icon));
            if app.inputModelValid && ~isempty(app.JMPTask) && ...
                    ~strcmp(app.JMPTask{app.taskIndex}.marker_file_name, "")
                app.validateMarkerFile();
            end
        end

        function validateOutputModelFile(app)
            if strcmp(app.output_model_file, "")
                setGuiFieldStatus(app.OutputModelFileEditField, ...
                    app.OutputModelFileStatus, "required", ...
                    "Output model file is required.");
                app.outputModelValid = false;
                return
            end
            [~, ~, extension] = fileparts(app.output_model_file);
            if ~strcmp(extension, '.osim')
                setGuiFieldStatus(app.OutputModelFileEditField, ...
                    app.OutputModelFileStatus, "error", ...
                    "Output model file must have a .osim extension.");
                app.outputModelValid = false;
                return
            end
            app.outputModelValid = true;
            if exist(app.output_model_file, 'file')
                setGuiFieldStatus(app.OutputModelFileEditField, ...
                    app.OutputModelFileStatus, "warning", ...
                    "Output file already exists and will be overwritten.");
            else
                setGuiFieldStatus(app.OutputModelFileEditField, ...
                    app.OutputModelFileStatus, "none");
            end
        end

        function validateMarkerFile(app)
            task = app.JMPTask{app.taskIndex};
            isValid = validateRequiredFieldGui(task.marker_file_name, ...
                "Marker file is required for this task.", ...
                app.MarkersFileEditField, app.MarkersFileStatus, ...
                app.MarkersFileStatus, @validateTrcFileGui);
            if isValid
                app.parseMarkerFileData(task.marker_file_name);
                app.StartTimeField.Value = task.time_range(1);
                app.EndTimeField.Value = task.time_range(2);
                app.checkMarkerModelConsistency();
            end
        end

        function validateMarkerSelection(app)
            if isEmptyStringList(app.JMPTask{app.taskIndex}.marker_names)
                setGuiFieldStatus([], app.MarkersStatus, "required", ...
                    "At least one marker must be selected for this task.");
            else
                setGuiFieldStatus([], app.MarkersStatus, "none");
            end
        end

        function checkMarkerModelConsistency(app)
            if isempty(app.model_markers) || ...
                    isempty(app.JMPTask{app.taskIndex}.markerFileMarkers)
                return
            end
            markerFileMarkers = app.JMPTask{app.taskIndex}.markerFileMarkers;
            invalidMarkerIndices = ~ismember(markerFileMarkers, app.model_markers);
            if any(invalidMarkerIndices)
                invalidMarkers = markerFileMarkers(invalidMarkerIndices);
                warningMessage = "The following markers are in the .trc " + ...
                    "file but not in the .osim model: " + ...
                    strjoin(invalidMarkers, ", ") + ".";
                setGuiFieldStatus(app.MarkersFileEditField, ...
                    app.MarkersFileStatus, "warning", warningMessage);
            end
        end

        function isValid = validateTimeRange(app)
            task = app.JMPTask{app.taskIndex};
            if task.time_range(1) > task.time_range(2)
                setGuiFieldStatus([], app.TimeRangeStatus, "error", ...
                    "Start time must be less than end time.");
                isValid = false;
            elseif task.maxTime > 0 && ...
                    (task.time_range(1) < task.minTime || ...
                    task.time_range(2) > task.maxTime)
                setGuiFieldStatus([], app.TimeRangeStatus, "error", sprintf( ...
                    "Time range must be within [%.3f, %.3f] seconds.", ...
                    task.minTime, task.maxTime));
                isValid = false;
            else
                setGuiFieldStatus([], app.TimeRangeStatus, "none");
                isValid = true;
            end
        end

        function validateTaskContent(app)
            task = app.JMPTask{app.taskIndex};
            joints = task.JMPJointSet.JMPJoint;
            bodies = task.JMPBodySet.JMPBody;
            if (~iscell(joints) || isempty(joints)) && ...
                    (~iscell(bodies) || isempty(bodies))
                setGuiFieldStatus([], app.JointBodyStatus, "required", ...
                    "At least one joint or body is required for this task.");
            else
                setGuiFieldStatus([], app.JointBodyStatus, "none");
            end
            app.warnEntriesWithoutParameters(app.JointsTable, joints, ...
                @app.jointHasParameters, app.JointsStatus, ...
                "One or more joints have no parameters selected and " + ...
                "will not contribute to the optimization.");
            app.warnEntriesWithoutParameters(app.BodiesTable, bodies, ...
                @app.bodyHasParameters, app.BodiesStatus, ...
                "One or more bodies have no parameters selected and " + ...
                "will not contribute to the optimization.");
        end

        function warnEntriesWithoutParameters(~, uiTable, entries, ...
                hasParametersFcn, statusIcon, warningMessage)
            setGuiFieldStatus([], statusIcon, "none");
            removeStyle(uiTable);
            if ~iscell(entries)
                return
            end
            anyMissingParameters = false;
            for i = 1:length(entries)
                if ~hasParametersFcn(entries{i})
                    anyMissingParameters = true;
                    addStyle(uiTable, uistyle('BackgroundColor', ...
                        [1.00 1.00 0.67]), 'row', i);
                end
            end
            if anyMissingParameters
                setGuiFieldStatus([], statusIcon, "warning", warningMessage);
            end
        end

        function hasParameters = jointHasParameters(~, joint)
            allParameters = [joint.parent_frame_transformation.translation, ...
                joint.parent_frame_transformation.orientation, ...
                joint.child_frame_transformation.translation, ...
                joint.child_frame_transformation.orientation];
            hasParameters = any(strcmp(allParameters, "true"));
        end

        function hasParameters = bodyHasParameters(~, body)
            hasParameters = strcmp(body.scale_body, "true") || ...
                any(strcmp(body.move_markers, "true"));
        end

        function isValid = validateAllTasksSilent(app)
            removeStyle(app.TasksTable);
            if isempty(app.JMPTask)
                setGuiFieldStatus([], app.TasksStatus, "required", ...
                    "At least one task is required.");
                isValid = false;
                return
            end
            hasEnabledTask = false;
            anyMissingRequired = false;
            anyError = false;
            for i = 1:length(app.JMPTask)
                if ~strcmp(app.JMPTask{i}.is_enabled, 'true')
                    continue
                end
                hasEnabledTask = true;
                [missingRequired, hasError, hasWarning] = ...
                    app.getTaskState(app.JMPTask{i});
                if hasError
                    anyError = true;
                    addStyle(app.TasksTable, uistyle('BackgroundColor', ...
                        [1.00 0.67 0.67]), 'row', i);
                elseif missingRequired
                    anyMissingRequired = true;
                    addStyle(app.TasksTable, uistyle('BackgroundColor', ...
                        [0.67 0.84 1.00]), 'row', i);
                elseif hasWarning
                    addStyle(app.TasksTable, uistyle('BackgroundColor', ...
                        [1.00 1.00 0.67]), 'row', i);
                end
            end
            if ~hasEnabledTask
                setGuiFieldStatus([], app.TasksStatus, "error", ...
                    "At least one task must be enabled to run.");
                isValid = false;
                return
            end
            if anyError
                setGuiFieldStatus([], app.TasksStatus, "error", ...
                    "One or more tasks have errors. Check that " + ...
                    "each enabled task's marker file exists and the time " + ...
                    "range is valid.");
            elseif anyMissingRequired
                setGuiFieldStatus([], app.TasksStatus, "required", ...
                    "One or more tasks are missing required " + ...
                    "fields. Check that each enabled task has a marker " + ...
                    "file, at least one marker selected, and at least " + ...
                    "one design variable.");
            else
                setGuiFieldStatus([], app.TasksStatus, "none");
            end
            isValid = ~anyError && ~anyMissingRequired;
        end

        function [missingRequired, hasError, hasWarning] = ...
                getTaskState(app, task)
            missingRequired = false;
            hasError = false;
            hasWarning = false;
            if strcmp(task.marker_file_name, "")
                missingRequired = true;
            elseif ~exist(task.marker_file_name, 'file')
                hasError = true;
            end
            if isEmptyStringList(task.marker_names)
                missingRequired = true;
            end
            if isequal(task.time_range, [0 0])
                missingRequired = true;
            elseif task.time_range(1) >= task.time_range(2)
                hasError = true;
            end
            hasDesignVariable = false;
            joints = task.JMPJointSet.JMPJoint;
            if iscell(joints)
                for i = 1:length(joints)
                    if app.jointHasParameters(joints{i})
                        hasDesignVariable = true;
                    else
                        hasWarning = true;
                    end
                end
            end
            bodies = task.JMPBodySet.JMPBody;
            if iscell(bodies)
                for i = 1:length(bodies)
                    if app.bodyHasParameters(bodies{i})
                        hasDesignVariable = true;
                    else
                        hasWarning = true;
                    end
                end
            end
            if ~hasDesignVariable
                missingRequired = true;
            end
            if ~isempty(app.model_markers) && ...
                    ~isempty(task.markerFileMarkers) && ...
                    any(~ismember(task.markerFileMarkers, app.model_markers))
                hasWarning = true;
            end
        end

        function updateRunButton(app)
            advancedSettingsValid = validateAdvancedSettingsGui( ...
                app.AdvancedSettingsTable, app.advancedSettingNames, ...
                app.advancedSettingValues, app.AdvancedSettingsStatus);
            tasksValid = app.validateAllTasksSilent();
            app.RunButton.Enable = app.inputModelValid && ...
                app.outputModelValid && advancedSettingsValid && tasksValid;
            app.updateTabControls();
        end

        function updateTabControls(app)
            app.JMPTasksButton.Enable = app.inputModelValid && ...
                app.outputModelValid;
        end

        function saveSettingsFile(app, settingsFileName)
            cd(fileparts(settingsFileName));
            app.currentSettingsFile = settingsFileName;
            saveGuiSettings(settingsFileName, ...
                'JointModelPersonalizationTool', ...
                app.makeJMPSettingsStruct(settingsFileName));
        end

        function settingsTree = makeJMPSettingsStruct(app, settingsFileName)
            settingsFilePath = fileparts(settingsFileName);
            settingsTree.input_model_file = getRelativePath( ...
                app.input_model_file, settingsFilePath);
            settingsTree.output_model_file = getRelativePath( ...
                app.output_model_file, settingsFilePath);
            settingsTree.JMPTaskList = struct("JMPTask", cell(1));
            for i = 1 : length(app.JMPTask)
                task = app.JMPTask{i}.toStruct();
                task.marker_file_name = getRelativePath( ...
                    task.marker_file_name, settingsFilePath);
                if isempty(task.JMPJointSet.JMPJoint)
                    task = rmfield(task, 'JMPJointSet');
                end
                if isempty(task.JMPBodySet.JMPBody)
                    task = rmfield(task, 'JMPBodySet');
                end
                settingsTree.JMPTaskList.JMPTask{i} = task;
            end
            settingsTree = app.setOptimizationParams(settingsTree);
            settingsTree = formatGuiDataForXml(settingsTree);
        end

        function settingsTree = setOptimizationParams(app, settingsTree)
            for i = 1 : length(app.advancedSettingNames)
                settingsTree.(app.advancedSettingNames(i)) = ...
                    app.advancedSettingValues(i);
            end
        end

        function loadOptimizationParams(app, settingsTree)
            values = app.advancedSettingValues;
            for i = 1 : length(app.advancedSettingNames)
                if isfield(settingsTree, app.advancedSettingNames(i))
                    values(i) = settingsTree.(app.advancedSettingNames(i));
                end
            end
            app.advancedSettingValues = values;
        end

        function loadSettingsFile(app, settingsFileName)
            app.resetAllFields();
            cd(fileparts(settingsFileName));
            app.currentSettingsFile = settingsFileName;
            settingsTree = loadGuiSettings(settingsFileName, ...
                'JointModelPersonalizationTool');
            app.applySettingsStruct(settingsTree);
            app.loadOptimizationParams(settingsTree);

            app.JMPTask = {};
            if isfield(settingsTree, 'JMPTaskList') && ...
                    isfield(settingsTree.JMPTaskList, 'JMPTask')
                tasks = settingsTree.JMPTaskList.JMPTask;
                % xml2struct yields '', "", or [] for an empty list and
                % a bare struct for a single entry
                if isstruct(tasks)
                    tasks = {tasks};
                elseif ~iscell(tasks)
                    tasks = {};
                end
                for i = 1 : length(tasks)
                    app.createEmptyTask();
                    app.JMPTask{i}.loadFromStruct(tasks{i});
                end
            end
            app.updateTasksPanel();
            app.updateJMPTasksListBox();
            app.validateTimeRange();
            app.updateRunButton();
        end

        function applySettingsStruct(app, settingsTree)
            % The shared applyStructToHandle cannot assign this class's
            % private properties, so the same loop must run as a method.
            metaProperties = metaclass(app).PropertyList;
            metaProperties = metaProperties(~[metaProperties.Constant] ...
                & ~[metaProperties.Dependent]);
            propertyNames = {metaProperties.Name};
            fields = fieldnames(settingsTree);
            for i = 1 : length(fields)
                if any(strcmp(fields{i}, propertyNames)) && ...
                        ~isstruct(settingsTree.(fields{i}))
                    app.(fields{i}) = settingsTree.(fields{i});
                end
            end
        end

        function resetAllFields(app)
            app.inputModelValid = false;
            app.outputModelValid = false;

            app.model_markers = [];
            app.model_bodies = [];
            app.model_joints = [];

            app.input_model_file = "";
            app.output_model_file = "";

            app.JMPTask = cell(0);
            app.createEmptyTask();

            app.currentSettingsFile = "";

            app.advancedSettingValues = app.defaultAdvancedSettingValues;
            app.validateAllFields();
            app.updateRunButton();
        end
    end

    methods (Access = public)

        function setSelectedObjects(app, objects)
            % Function to assign objects selected by ObjectSelectionWindow
            app.JMPTask{app.taskIndex}.marker_names = strjoin(objects, " ");
        end

        function addJoint(app, joint)
            app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint{end+1} = joint;
            app.JMPTask{app.taskIndex}.jointNames{end+1} = ...
                joint.Attributes.name;
        end

        function editJoint(app, joint)
            selectedJoint = app.JointsTable.Selection;
            app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint{selectedJoint} = joint;
            app.JMPTask{app.taskIndex}.jointNames{selectedJoint} = ...
                joint.Attributes.name;
            app.validateTaskContent();
            app.updateRunButton();
        end

        function addBody(app, body)
            app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody{end+1} = body;
            app.JMPTask{app.taskIndex}.bodyNames{end+1} = ...
                body.Attributes.name;
        end

        function editBody(app, body)
            selectedBody = app.BodiesTable.Selection;
            app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody{selectedBody} = body;
            app.JMPTask{app.taskIndex}.bodyNames{selectedBody} = ...
                body.Attributes.name;
            app.validateTaskContent();
            app.updateRunButton();
        end

        function setModelMarkers(app, markers)
            app.model_markers = markers;
        end

        function setModelJoints(app, joints)
            app.model_joints = joints;
        end

        function setModelBodies(app, bodies)
            app.model_bodies = bodies;
        end

        function joints = getModelJoints(app)
            joints = app.model_joints;
        end

        function joints = getSelectedJoints(app)
            joints = app.JMPTask{app.taskIndex}.jointNames;
        end

        function bodies = getSelectedBodies(app)
            bodies = app.JMPTask{app.taskIndex}.bodyNames;
        end

        function bodies = getModelBodies(app)
            bodies = app.model_bodies;
        end
    end



    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.advancedSettingValues = app.defaultAdvancedSettingValues;
            app.refreshAdvancedSettingsTable();
            app.createEmptyTask();
            app.TasksTable.Selection = 1;
            app.updateJointsTable();
            app.updateBodiesTable();
            app.RunButton.Enable = false;
            app.JMPTasksButton.Enable = false;
            app.MarkersEditButton.Enable = false;
            app.makeAllListeners()
            app.validateAllFields()
        end

        % Button pushed function: JMPInputsButton
        function JMPInputsButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.InputsTab;
        end

        % Button pushed function: AdvancedButton
        function AdvancedButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.AdvancedTab;
        end

        % Button pushed function: JMPTasksButton
        function JMPTasksButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.TasksTab;
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            [file, path] = uiputfile('*.xml', "Save XML Settings File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.saveSettingsFile(fullfile(path, file))
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            if strcmp(app.currentSettingsFile, "")
                [file, path] = uiputfile('*.xml', "Save XML Settings File");
                % User hit "Cancel"
                if isequal(file, 0)
                    return
                end
                app.currentSettingsFile = fullfile(path, file);
            end
            app.saveSettingsFile(app.currentSettingsFile);
            JMPRun(app, app.currentSettingsFile);
        end

        % Button pushed function: HelpButton
        function HelpButtonPushed(app, event)
            web("https://nmsm.rice.edu/guides-and-publications/tool-overviews/model-personalization/joint-model-personalization/")
        end

        % Image clicked function: RcnlLogo
        function RcnlLogoImageClicked(app, event)
            web("https://nmsm.rice.edu/")
        end

        % Button pushed function: InputModelFileSearchButton
        function InputModelFileSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.osim', "Select an OpenSim Model File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.input_model_file = fullfile(path, file);
            if strcmp(app.output_model_file, "")
                app.output_model_file = fullfile(path, ...
                    strrep(file, ".osim", "_JMP.osim"));
            end
        end

        % Value changed function: InputModelFileEditField
        function InputModelFileEditFieldValueChanged(app, event)
            app.input_model_file = ...
                getPathFieldValue(app.InputModelFileEditField);
        end

        % Button pushed function: OutputModelFileSearchButton
        function OutputModelFileSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.osim', "Select an OpenSim Model File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.output_model_file = fullfile(path, file);
        end

        % Value changed function: OutputModelFileEditField
        function OutputModelFileEditFieldValueChanged(app, event)
            app.output_model_file = ...
                getPathFieldValue(app.OutputModelFileEditField);
        end

        % Button pushed function: MarkerFileSearchButton
        function MarkerFileSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.trc', "Select a trc marker file.");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.JMPTask{app.taskIndex}.marker_file_name = fullfile(path, file);
        end

        % Value changed function: MarkersFileEditField
        function MarkersFileEditFieldValueChanged(app, event)
            app.JMPTask{app.taskIndex}.marker_file_name = ...
                getPathFieldValue(app.MarkersFileEditField);
        end

        % Selection changed function: TasksTable
        function TasksTableSelectionChanged(app, event)
            if isempty(app.TasksTable.Selection)
                return
            end
            if app.TasksTable.Selection == height(app.TasksTable.Data)
                app.createEmptyTask(); % last row adds a new task
            else
                app.taskIndex = app.TasksTable.Selection;
            end
        end

        % Cell edit callback: TasksTable
        function TasksTableCellEdit(app, event)
            rowIndex = event.Indices(1);
            if rowIndex > length(app.JMPTask)
                app.updateJMPTasksListBox(); % restore the add-task row
                return
            end
            app.taskIndex = rowIndex;
            if event.Indices(2) == 1
                app.JMPTask{rowIndex}.is_enabled = boolToString(event.NewData);
            else
                app.JMPTask{rowIndex}.name = event.NewData;
            end
            app.updateRunButton();
        end

        % Value changed function: StartTimeField
        function StartTimeFieldValueChanged(app, event)
            app.JMPTask{app.taskIndex}.time_range(1) = app.StartTimeField.Value;
            app.validateTimeRange();
            app.updateRunButton();
        end

        % Value changed function: EndTimeField
        function EndTimeFieldValueChanged(app, event)
            app.JMPTask{app.taskIndex}.time_range(2) = app.EndTimeField.Value;
            app.validateTimeRange();
            app.updateRunButton();
        end

        % Button pushed function: MarkersEditButton
        function MarkersEditButtonPushed(app, event)
            ObjectSelectionWindow(app, app.JMPTask{app.taskIndex}.markerFileMarkers, ...
                app.JMPTask{app.taskIndex}.marker_names);
        end

        % Menu selected function: RenameMenu
        function RenameMenuSelected(app, event)
            oldName = app.JMPTask{app.taskIndex}.name;
            newName = inputdlg("Rename task:", "Rename", [1 40], ...
                {char(oldName)});
            if isempty(newName)
                return
            end
            app.JMPTask{app.taskIndex}.name = newName{1};
        end

        % Menu selected function: CopyTaskMenu
        function CopyTaskMenuSelected(app, event)
            sourceTask = app.JMPTask{app.taskIndex}.toStruct();
            app.createEmptyTask();
            app.JMPTask{app.taskIndex}.loadFromStruct(sourceTask);
            app.JMPTask{app.taskIndex}.name = "Copy of " + ...
                sourceTask.Attributes.name;
            app.JMPTask{app.taskIndex}.index = app.taskIndex;
            app.updateTasksPanel();
        end

        % Menu selected function: DeleteTaskMenu
        function DeleteTaskMenuSelected(app, event)
            app.deleteTask(app.TasksTable.Selection);
        end

        % Button pushed function: MoveTaskUpButton
        function MoveTaskUpButtonPushed(app, event)
            app.moveTaskUp()
        end

        % Button pushed function: MoveTaskDownButton
        function MoveTaskDownButtonPushed(app, event)
            app.moveTaskDown()
        end

        % Selection changed function: JointsTable
        function JointsTableSelectionChanged(app, event)
            selection = app.JointsTable.Selection;
            if selection > length(app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint)
                JMPJointSelection(app, []); % last row adds a new joint
            end
        end

        % Selection changed function: BodiesTable
        function BodiesTableSelectionChanged(app, event)
            selection = app.BodiesTable.Selection;
            if selection > length(app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody)
                JMPBodySelection(app, []); % last row adds a new body
            end
        end

        % Double-clicked callback: JointsTable
        function JointsTableDoubleClicked(app, event)
            selection = event.InteractionInformation.DisplayRow;
            if selection > length(app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint)
                return
            end
            JMPJointSelection(app, ...
                app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint{selection})
        end

        % Double-clicked callback: BodiesTable
        function BodiesTableDoubleClicked(app, event)
            selection = event.InteractionInformation.DisplayRow;
            if selection > length(app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody)
                return
            end
            JMPBodySelection(app, ...
                app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody{selection})
        end

        % Menu selected function: EditJointMenu
        function EditJointMenuSelected(app, event)
            selection = app.JointsTable.Selection;
            if selection > length(app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint)
                return
            end
            JMPJointSelection(app, ...
                app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint{selection});
        end

        % Menu selected function: DeleteJointMenu
        function DeleteJointMenuSelected(app, event)
            app.deleteJoint(app.JointsTable.Selection);
        end

        % Menu selected function: EditBodyMenu
        function EditBodyMenuSelected(app, event)
            selection = app.BodiesTable.Selection;
            if selection > length(app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody)
                return
            end
            JMPBodySelection(app, ...
                app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody{selection});
        end

        % Menu selected function: DeleteBodyMenu
        function DeleteBodyMenuSelected(app, event)
            app.deleteBody(app.BodiesTable.Selection);
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
            app.resetAllFields();
        end

        % Button pushed function: LoadSettingsFileButton
        function LoadSettingsFileButtonPushed(app, event)
            [file, path] = uigetfile('*.xml', "Load XML Settings File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.loadSettingsFile(fullfile(path, file));
        end

        % Cell edit callback: AdvancedSettingsTable
        function AdvancedSettingsTableCellEdit(app, event)
            app.advancedSettingValues(event.Indices(1)) = ...
                str2double(event.NewData);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.851 0.851 0.851];
            app.UIFigure.Position = [500 500 1000 600];
            app.UIFigure.Name = 'MATLAB App';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [211 78 790 478];

            % Create InputsTab
            app.InputsTab = uitab(app.TabGroup);
            app.InputsTab.BackgroundColor = [0.851 0.851 0.851];
            app.InputsTab.ForegroundColor = [0 0 0];

            % Create OutputModelFileSearchButton
            app.OutputModelFileSearchButton = uibutton(app.InputsTab, 'push');
            app.OutputModelFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @OutputModelFileSearchButtonPushed, true);
            app.OutputModelFileSearchButton.Icon = 'folderIcon.svg';
            app.OutputModelFileSearchButton.VerticalAlignment = 'bottom';
            app.OutputModelFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.OutputModelFileSearchButton.Position = [667 323 30 30];
            app.OutputModelFileSearchButton.Text = '';

            % Create OutputModelFileEditFieldLabel
            app.OutputModelFileEditFieldLabel = uilabel(app.InputsTab);
            app.OutputModelFileEditFieldLabel.HorizontalAlignment = 'right';
            app.OutputModelFileEditFieldLabel.FontSize = 18;
            app.OutputModelFileEditFieldLabel.FontWeight = 'bold';
            app.OutputModelFileEditFieldLabel.Position = [8 323 160 30];
            app.OutputModelFileEditFieldLabel.Text = 'Output Model File';

            % Create OutputModelFileEditField
            app.OutputModelFileEditField = uieditfield(app.InputsTab, 'text');
            app.OutputModelFileEditField.ValueChangedFcn = createCallbackFcn(app, @OutputModelFileEditFieldValueChanged, true);
            app.OutputModelFileEditField.Position = [178 323 472 30];

            % Create InputModelFileStatus
            app.InputModelFileStatus = uiimage(app.InputsTab);
            app.InputModelFileStatus.Visible = 'off';
            app.InputModelFileStatus.Position = [710 383 28 30];
            app.InputModelFileStatus.ImageSource = 'error.png';

            % Create InputModelFileSearchButton
            app.InputModelFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputModelFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputModelFileSearchButtonPushed, true);
            app.InputModelFileSearchButton.Icon = 'folderIcon.svg';
            app.InputModelFileSearchButton.VerticalAlignment = 'bottom';
            app.InputModelFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputModelFileSearchButton.Position = [666 383 31 30];
            app.InputModelFileSearchButton.Text = '';

            % Create InputModelFileEditFieldLabel
            app.InputModelFileEditFieldLabel = uilabel(app.InputsTab);
            app.InputModelFileEditFieldLabel.HorizontalAlignment = 'right';
            app.InputModelFileEditFieldLabel.FontSize = 18;
            app.InputModelFileEditFieldLabel.FontWeight = 'bold';
            app.InputModelFileEditFieldLabel.Position = [28 383 140 30];
            app.InputModelFileEditFieldLabel.Text = 'Input Model File';

            % Create InputModelFileEditField
            app.InputModelFileEditField = uieditfield(app.InputsTab, 'text');
            app.InputModelFileEditField.ValueChangedFcn = createCallbackFcn(app, @InputModelFileEditFieldValueChanged, true);
            app.InputModelFileEditField.Position = [178 383 472 30];

            % Create OutputModelFileStatus
            app.OutputModelFileStatus = uiimage(app.InputsTab);
            app.OutputModelFileStatus.Visible = 'off';
            app.OutputModelFileStatus.Position = [710 322 28 30];
            app.OutputModelFileStatus.ImageSource = 'error.png';

            % Create TasksTab
            app.TasksTab = uitab(app.TabGroup);
            app.TasksTab.BackgroundColor = [0.851 0.851 0.851];

            % Create MuscleGroupsLabel_3
            app.MuscleGroupsLabel_3 = uilabel(app.TasksTab);
            app.MuscleGroupsLabel_3.HorizontalAlignment = 'right';
            app.MuscleGroupsLabel_3.FontSize = 18;
            app.MuscleGroupsLabel_3.FontWeight = 'bold';
            app.MuscleGroupsLabel_3.Position = [68 352 55 23];
            app.MuscleGroupsLabel_3.Text = 'Tasks';

            % Create TasksPanel
            app.TasksPanel = uipanel(app.TasksTab);
            app.TasksPanel.BorderWidth = 2;
            app.TasksPanel.BackgroundColor = [0.851 0.851 0.851];
            app.TasksPanel.Position = [217 1 572 442];

            % Create MarkerFileSearchButton
            app.MarkerFileSearchButton = uibutton(app.TasksPanel, 'push');
            app.MarkerFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @MarkerFileSearchButtonPushed, true);
            app.MarkerFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.MarkerFileSearchButton.VerticalAlignment = 'bottom';
            app.MarkerFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MarkerFileSearchButton.Position = [472 396 36 35];
            app.MarkerFileSearchButton.Text = '';

            % Create MarkersFileStatus
            app.MarkersFileStatus = uiimage(app.TasksPanel);
            app.MarkersFileStatus.Visible = 'off';
            app.MarkersFileStatus.Position = [519 397 35 35];
            app.MarkersFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create TimeRangeStatus
            app.TimeRangeStatus = uiimage(app.TasksPanel);
            app.TimeRangeStatus.Visible = 'off';
            app.TimeRangeStatus.Position = [336 328 35 35];
            app.TimeRangeStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create BodiesTable
            app.BodiesTable = uitable(app.TasksPanel);
            app.BodiesTable.ColumnName = '';
            app.BodiesTable.RowName = {};
            app.BodiesTable.SelectionType = 'row';
            app.BodiesTable.DoubleClickedFcn = createCallbackFcn(app, @BodiesTableDoubleClicked, true);
            app.BodiesTable.SelectionChangedFcn = createCallbackFcn(app, @BodiesTableSelectionChanged, true);
            app.BodiesTable.Multiselect = 'off';
            app.BodiesTable.FontSize = 18;
            app.BodiesTable.Position = [319 7 201 136];

            % Create JointsTable
            app.JointsTable = uitable(app.TasksPanel);
            app.JointsTable.ColumnName = '';
            app.JointsTable.RowName = {};
            app.JointsTable.SelectionType = 'row';
            app.JointsTable.DoubleClickedFcn = createCallbackFcn(app, @JointsTableDoubleClicked, true);
            app.JointsTable.SelectionChangedFcn = createCallbackFcn(app, @JointsTableSelectionChanged, true);
            app.JointsTable.Multiselect = 'off';
            app.JointsTable.FontSize = 18;
            app.JointsTable.Position = [53 7 201 136];

            % Create JointsLabel
            app.JointsLabel = uilabel(app.TasksPanel);
            app.JointsLabel.HorizontalAlignment = 'center';
            app.JointsLabel.FontSize = 18;
            app.JointsLabel.FontWeight = 'bold';
            app.JointsLabel.Position = [53 152 201 23];
            app.JointsLabel.Text = 'Joints';

            % Create BodiesLabel
            app.BodiesLabel = uilabel(app.TasksPanel);
            app.BodiesLabel.HorizontalAlignment = 'center';
            app.BodiesLabel.FontSize = 18;
            app.BodiesLabel.FontWeight = 'bold';
            app.BodiesLabel.Position = [319 152 201 23];
            app.BodiesLabel.Text = 'Bodies';

            % Create MarkersFileEditFieldLabel
            app.MarkersFileEditFieldLabel = uilabel(app.TasksPanel);
            app.MarkersFileEditFieldLabel.HorizontalAlignment = 'right';
            app.MarkersFileEditFieldLabel.FontSize = 18;
            app.MarkersFileEditFieldLabel.FontWeight = 'bold';
            app.MarkersFileEditFieldLabel.Position = [8 402 110 23];
            app.MarkersFileEditFieldLabel.Text = 'Markers File';

            % Create MarkersFileEditField
            app.MarkersFileEditField = uieditfield(app.TasksPanel, 'text');
            app.MarkersFileEditField.ValueChangedFcn = createCallbackFcn(app, @MarkersFileEditFieldValueChanged, true);
            app.MarkersFileEditField.Position = [133 397 324 35];

            % Create TimeRangesEditFieldLabel
            app.TimeRangesEditFieldLabel = uilabel(app.TasksPanel);
            app.TimeRangesEditFieldLabel.HorizontalAlignment = 'right';
            app.TimeRangesEditFieldLabel.FontSize = 18;
            app.TimeRangesEditFieldLabel.FontWeight = 'bold';
            app.TimeRangesEditFieldLabel.Position = [8 334 140 23];
            app.TimeRangesEditFieldLabel.Text = 'Time Range (s):';

            % Create StartTimeField
            app.StartTimeField = uieditfield(app.TasksPanel, 'numeric');
            app.StartTimeField.ValueChangedFcn = createCallbackFcn(app, @StartTimeFieldValueChanged, true);
            app.StartTimeField.FontSize = 18;
            app.StartTimeField.Position = [163 329 51 33];

            % Create ToLabel
            app.ToLabel = uilabel(app.TasksPanel);
            app.ToLabel.HorizontalAlignment = 'right';
            app.ToLabel.FontSize = 18;
            app.ToLabel.FontWeight = 'bold';
            app.ToLabel.Position = [227 334 32 23];
            app.ToLabel.Text = 'To:';

            % Create EndTimeField
            app.EndTimeField = uieditfield(app.TasksPanel, 'numeric');
            app.EndTimeField.ValueChangedFcn = createCallbackFcn(app, @EndTimeFieldValueChanged, true);
            app.EndTimeField.FontSize = 18;
            app.EndTimeField.Position = [274 329 51 33];

            % Create MarkersTextAreaLabel
            app.MarkersTextAreaLabel = uilabel(app.TasksPanel);
            app.MarkersTextAreaLabel.HorizontalAlignment = 'right';
            app.MarkersTextAreaLabel.FontSize = 18;
            app.MarkersTextAreaLabel.FontWeight = 'bold';
            app.MarkersTextAreaLabel.Position = [36 236 74 23];
            app.MarkersTextAreaLabel.Text = 'Markers';

            % Create MarkersTextArea
            app.MarkersTextArea = uitextarea(app.TasksPanel);
            app.MarkersTextArea.Editable = 'off';
            app.MarkersTextArea.FontSize = 18;
            app.MarkersTextArea.Position = [128 203 324 88];

            % Create MarkersEditButton
            app.MarkersEditButton = uibutton(app.TasksPanel, 'push');
            app.MarkersEditButton.ButtonPushedFcn = createCallbackFcn(app, @MarkersEditButtonPushed, true);
            app.MarkersEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MarkersEditButton.FontSize = 18;
            app.MarkersEditButton.FontColor = [1 1 1];
            app.MarkersEditButton.Position = [460 232 65 30];
            app.MarkersEditButton.Text = 'Edit';

            % Create MarkersStatus
            app.MarkersStatus = uiimage(app.TasksPanel);
            app.MarkersStatus.Visible = 'off';
            app.MarkersStatus.Tooltip = {'You must select markers for this task.'};
            app.MarkersStatus.Position = [529 229 35 35];
            app.MarkersStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create JointsStatus
            app.JointsStatus = uiimage(app.TasksPanel);
            app.JointsStatus.Visible = 'off';
            app.JointsStatus.Tooltip = {'You must select markers for this task.'};
            app.JointsStatus.Position = [193 146 35 35];
            app.JointsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create BodiesStatus
            app.BodiesStatus = uiimage(app.TasksPanel);
            app.BodiesStatus.Visible = 'off';
            app.BodiesStatus.Tooltip = {'You must select markers for this task.'};
            app.BodiesStatus.Position = [460 146 35 35];
            app.BodiesStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create MoveTaskUpButton
            app.MoveTaskUpButton = uibutton(app.TasksTab, 'push');
            app.MoveTaskUpButton.ButtonPushedFcn = createCallbackFcn(app, @MoveTaskUpButtonPushed, true);
            app.MoveTaskUpButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'ArrowUp.svg');
            app.MoveTaskUpButton.IconAlignment = 'center';
            app.MoveTaskUpButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MoveTaskUpButton.Position = [188 225 25 25];
            app.MoveTaskUpButton.Text = '';

            % Create MoveTaskDownButton
            app.MoveTaskDownButton = uibutton(app.TasksTab, 'push');
            app.MoveTaskDownButton.ButtonPushedFcn = createCallbackFcn(app, @MoveTaskDownButtonPushed, true);
            app.MoveTaskDownButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'ArrowDown.svg');
            app.MoveTaskDownButton.IconAlignment = 'center';
            app.MoveTaskDownButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MoveTaskDownButton.Position = [188 172 25 25];
            app.MoveTaskDownButton.Text = '';

            % Create TasksTable
            app.TasksTable = uitable(app.TasksTab);
            app.TasksTable.ColumnName = {''; 'Task'};
            app.TasksTable.ColumnWidth = {30, 'auto'};
            app.TasksTable.RowName = {};
            app.TasksTable.ColumnSortable = [false true];
            app.TasksTable.SelectionType = 'row';
            app.TasksTable.ColumnEditable = true;
            app.TasksTable.RowStriping = 'off';
            app.TasksTable.CellEditCallback = createCallbackFcn(app, @TasksTableCellEdit, true);
            app.TasksTable.SelectionChangedFcn = createCallbackFcn(app, @TasksTableSelectionChanged, true);
            app.TasksTable.Multiselect = 'off';
            app.TasksTable.FontSize = 18;
            app.TasksTable.Position = [5 96 181 242];

            % Create TasksStatus
            app.TasksStatus = uiimage(app.TasksTab);
            app.TasksStatus.Visible = 'off';
            app.TasksStatus.Position = [133 346 35 35];
            app.TasksStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create AdvancedTab
            app.AdvancedTab = uitab(app.TabGroup);
            app.AdvancedTab.BackgroundColor = [0.851 0.851 0.851];

            % Create AdvancedSettingsTable
            app.AdvancedSettingsTable = uitable(app.AdvancedTab);
            app.AdvancedSettingsTable.ColumnName = {'Optimization Parameter'; 'Value'};
            app.AdvancedSettingsTable.RowName = {};
            app.AdvancedSettingsTable.SelectionType = 'row';
            app.AdvancedSettingsTable.ColumnEditable = [false true];
            app.AdvancedSettingsTable.CellEditCallback = createCallbackFcn(app, @AdvancedSettingsTableCellEdit, true);
            app.AdvancedSettingsTable.FontSize = 20;
            app.AdvancedSettingsTable.Position = [122 11 528 393];

            % Create AdvancedSettingsStatus
            app.AdvancedSettingsStatus = uiimage(app.AdvancedTab);
            app.AdvancedSettingsStatus.Visible = 'off';
            app.AdvancedSettingsStatus.Position = [369 412 35 35];
            app.AdvancedSettingsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create Mask1
            app.Mask1 = uiimage(app.UIFigure);
            app.Mask1.ScaleMethod = 'fill';
            app.Mask1.Position = [211 532 790 30];
            app.Mask1.ImageSource = 'greyMask.png';

            % Create JMPTasksButton
            app.JMPTasksButton = uibutton(app.UIFigure, 'push');
            app.JMPTasksButton.ButtonPushedFcn = createCallbackFcn(app, @JMPTasksButtonPushed, true);
            app.JMPTasksButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.JMPTasksButton.FontSize = 18;
            app.JMPTasksButton.FontColor = [1 1 1];
            app.JMPTasksButton.Position = [329 532 109 30];
            app.JMPTasksButton.Text = 'JMP Tasks';

            % Create AdvancedButton
            app.AdvancedButton = uibutton(app.UIFigure, 'push');
            app.AdvancedButton.ButtonPushedFcn = createCallbackFcn(app, @AdvancedButtonPushed, true);
            app.AdvancedButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.AdvancedButton.FontSize = 18;
            app.AdvancedButton.FontColor = [1 1 1];
            app.AdvancedButton.Position = [446 532 108 30];
            app.AdvancedButton.Text = 'Advanced';

            % Create JMPInputsButton
            app.JMPInputsButton = uibutton(app.UIFigure, 'push');
            app.JMPInputsButton.ButtonPushedFcn = createCallbackFcn(app, @JMPInputsButtonPushed, true);
            app.JMPInputsButton.BackgroundColor = [1 1 1];
            app.JMPInputsButton.FontSize = 18;
            app.JMPInputsButton.FontColor = [0.1294 0.1804 0.4];
            app.JMPInputsButton.Position = [215 532 105 30];
            app.JMPInputsButton.Text = 'JMP Inputs';

            % Create RcnlLogo
            app.RcnlLogo = uiimage(app.UIFigure);
            app.RcnlLogo.ImageClickedFcn = createCallbackFcn(app, @RcnlLogoImageClicked, true);
            app.RcnlLogo.Position = [11 511 80 80];
            app.RcnlLogo.ImageSource = 'rcnlIcon.png';

            % Create LoadSettingsFileButton
            app.LoadSettingsFileButton = uibutton(app.UIFigure, 'push');
            app.LoadSettingsFileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadSettingsFileButtonPushed, true);
            app.LoadSettingsFileButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.LoadSettingsFileButton.FontSize = 18;
            app.LoadSettingsFileButton.FontColor = [1 1 1];
            app.LoadSettingsFileButton.Position = [524 19 90 30];
            app.LoadSettingsFileButton.Text = 'Load';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SaveButton.FontSize = 18;
            app.SaveButton.FontColor = [1 1 1];
            app.SaveButton.Position = [644 19 90 30];
            app.SaveButton.Text = 'Save';

            % Create HelpButton
            app.HelpButton = uibutton(app.UIFigure, 'push');
            app.HelpButton.ButtonPushedFcn = createCallbackFcn(app, @HelpButtonPushed, true);
            app.HelpButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.HelpButton.FontSize = 18;
            app.HelpButton.FontColor = [1 1 1];
            app.HelpButton.Position = [884 20 90 30];
            app.HelpButton.Text = 'Help';

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.RunButton.FontSize = 18;
            app.RunButton.FontColor = [1 1 1];
            app.RunButton.Position = [764 19 90 30];
            app.RunButton.Text = 'Run';

            % Create JointModelPersonalizationToolLabel
            app.JointModelPersonalizationToolLabel = uilabel(app.UIFigure);
            app.JointModelPersonalizationToolLabel.HorizontalAlignment = 'center';
            app.JointModelPersonalizationToolLabel.FontSize = 25;
            app.JointModelPersonalizationToolLabel.FontWeight = 'bold';
            app.JointModelPersonalizationToolLabel.Position = [1 561 1000 40];
            app.JointModelPersonalizationToolLabel.Text = 'Joint Model Personalization Tool';

            % Create JMPImage
            app.JMPImage = uiimage(app.UIFigure);
            app.JMPImage.Position = [21 33 178 420];
            app.JMPImage.ImageSource = 'jmpFigure.png';

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ResetButton.FontSize = 18;
            app.ResetButton.FontColor = [1 1 1];
            app.ResetButton.Position = [402 19 90 30];
            app.ResetButton.Text = 'Reset';

            % Create TasksContextMenu
            app.TasksContextMenu = uicontextmenu(app.UIFigure);

            % Create RenameMenu
            app.RenameMenu = uimenu(app.TasksContextMenu);
            app.RenameMenu.MenuSelectedFcn = createCallbackFcn(app, @RenameMenuSelected, true);
            app.RenameMenu.Text = 'Rename';

            % Create CopyTaskMenu
            app.CopyTaskMenu = uimenu(app.TasksContextMenu);
            app.CopyTaskMenu.MenuSelectedFcn = createCallbackFcn(app, @CopyTaskMenuSelected, true);
            app.CopyTaskMenu.Text = 'Copy';

            % Create DeleteTaskMenu
            app.DeleteTaskMenu = uimenu(app.TasksContextMenu);
            app.DeleteTaskMenu.MenuSelectedFcn = createCallbackFcn(app, @DeleteTaskMenuSelected, true);
            app.DeleteTaskMenu.Text = 'Delete';
            
            % Assign app.TasksContextMenu
            app.TasksTable.ContextMenu = app.TasksContextMenu;

            % Create JointsContextMenu
            app.JointsContextMenu = uicontextmenu(app.UIFigure);

            % Create EditJointMenu
            app.EditJointMenu = uimenu(app.JointsContextMenu);
            app.EditJointMenu.MenuSelectedFcn = createCallbackFcn(app, @EditJointMenuSelected, true);
            app.EditJointMenu.Text = 'Edit';

            % Create DeleteJointMenu
            app.DeleteJointMenu = uimenu(app.JointsContextMenu);
            app.DeleteJointMenu.MenuSelectedFcn = createCallbackFcn(app, @DeleteJointMenuSelected, true);
            app.DeleteJointMenu.Text = 'Delete';
            
            % Assign app.JointsContextMenu
            app.JointsTable.ContextMenu = app.JointsContextMenu;

            % Create BodiesContextMenu
            app.BodiesContextMenu = uicontextmenu(app.UIFigure);

            % Create EditBodyMenu
            app.EditBodyMenu = uimenu(app.BodiesContextMenu);
            app.EditBodyMenu.MenuSelectedFcn = createCallbackFcn(app, @EditBodyMenuSelected, true);
            app.EditBodyMenu.Text = 'Edit';

            % Create DeleteBodyMenu
            app.DeleteBodyMenu = uimenu(app.BodiesContextMenu);
            app.DeleteBodyMenu.MenuSelectedFcn = createCallbackFcn(app, @DeleteBodyMenuSelected, true);
            app.DeleteBodyMenu.Text = 'Delete';
            
            % Assign app.BodiesContextMenu
            app.BodiesTable.ContextMenu = app.BodiesContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';

            % The window is tall enough that a fixed corner runs off the
            % top of a 1080p display, so center it on whichever screen it
            % lands on before showing it
            movegui(app.UIFigure, 'center');
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = JMPBase

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end