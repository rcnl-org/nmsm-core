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
        InputModelFileError            matlab.ui.control.Image
        OutputModelFileEditField       matlab.ui.control.EditField
        OutputModelFileEditFieldLabel  matlab.ui.control.Label
        OutputModelFileSearchButton    matlab.ui.control.Button
        TasksTab                       matlab.ui.container.Tab
        TasksError                     matlab.ui.control.Image
        TasksWarning                   matlab.ui.control.Image
        TasksTable                     matlab.ui.control.Table
        MoveTaskDownButton             matlab.ui.control.Button
        MoveTaskUpButton               matlab.ui.control.Button
        TasksPanel                     matlab.ui.container.Panel
        BodiesWarning                  matlab.ui.control.Image
        JointsWarning                  matlab.ui.control.Image
        MarkersWarning                 matlab.ui.control.Image
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
        TimeRangeError                 matlab.ui.control.Image
        MarkersFileError               matlab.ui.control.Image
        MarkersFileWarning             matlab.ui.control.Image
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
        JMPTaskList struct;
        JMPTask cell = cell(1);
        taskIndex double = 1;

        model_markers string;
        model_bodies string;
        model_joints string;

        % Optimization params
        max_function_evaluations double = 200;
        step_tolerance double = 1e-5;
        function_tolerance double = 1e-5;
        optimality_tolerance double = 1e-5;
        diff_min_change double = 0.001;
        accuracy double = 1e-6;

        advancedSettingNames = ...
            ["allowable_error"
            "max_function_evaluations"
            "step_tolerance"
            "function_tolerance"
            "optimality_tolerance"
            "diff_min_change"
            "accuracy"]

        advancedSettingValues = ...
            [0.005
            200
            1e-5
            1e-5
            1e-5
            1e-3
            1e-6]

        % Error checking and flow control
        needToSave logical = true;
        currentSettingsFile string = "";
    end % Description

    properties (Access = public)

    end

    properties(Access = private)  % listner properties
        inputModelFileListener
        outputModelFileListener
        taskIndexListener
        advancedSettingsListener
    end

    methods (Access = private) % listener methods
        function makeAllListeners(app)
            app.inputModelFileListener = addlistener(app, ...
                'input_model_file', 'PostSet', ...
                @(src,event)updateInputModelFile(app));

            app.outputModelFileListener = addlistener(app, ...
                'output_model_file', 'PostSet', ...
                @(src,event)updateOutputModelFile(app));

            app.taskIndexListener = addlistener(app, ...
                'taskIndex', 'PostSet', ...
                @(src, event)updateTaskIndex(app));

            app.advancedSettingsListener = addlistener(app, ...
                'advancedSettingValues', 'PostSet', ...
                @(src, event)updateAdvancedSettingValues(app));

            app.makeTaskListeners()
        end

        function makeTaskListeners(app)
            addlistener(app.JMPTask{app.taskIndex}, ...
                'name', 'PostSet', ...
                @(src,event)updateTaskName(app));

            addlistener(app.JMPTask{app.taskIndex}, ...
                'marker_file_name', 'PostSet', ...
                @(src,event)updateMarkersFile(app));

            addlistener(app.JMPTask{app.taskIndex}, ...
                'marker_names', 'PostSet', ...
                @(src,event)updateMarkerNames(app));

            addlistener(app.JMPTask{app.taskIndex}, ...
                'jointNames', 'PostSet', ...
                @(src,event)updateJointsTable(app));

            addlistener(app.JMPTask{app.taskIndex}, ...
                'bodyNames', 'PostSet', ...
                @(src,event)updateBodiesTable(app));
        end

        function updateInputModelFile(app) % good
            app.InputModelFileEditField.Value = getRelativePath( ...
                app.input_model_file);
            [modelErrorFlag, modelErrorMessage] = parseModelFileGui( ...
                app, app.input_model_file);
            app.needToSave = true;
        end

        function updateOutputModelFile(app) % good
            app.OutputModelFileEditField.Value = getRelativePath( ...
                app.output_model_file);
            app.needToSave = true;
        end

        function updateTaskName(app)
            % app.JMPTask{app.taskIndex}.name = app.JMPTask{app.taskIndex}.name;
        end

        function updateTaskIndex(app)
            app.TasksTable.Selection = app.taskIndex;
            app.updateTasksPanel()
            app.updateJointsTable()
            app.updateBodiesTable()
        end

        function updateAdvancedSettingValues(app)
            app.AdvancedSettingsTable.Data.Values = ...
                app.advancedSettingValues;
        end

        function updateMarkersFile(app) % change
            app.MarkersFileEditField.Value = getRelativePath( ...
                app.JMPTask{app.taskIndex}.marker_file_name);
            [error, ~] = app.parseMarkerFileErrors( ...
                app.JMPTask{app.taskIndex}.marker_file_name);
            if ~error && ~strcmp(app.JMPTask{app.taskIndex}.marker_file_name, "")
                app.parseMarkerFileData( ...
                    app.JMPTask{app.taskIndex}.marker_file_name);
                app.StartTimeField.Value = app.JMPTask{app.taskIndex}.minTime;
                app.EndTimeField.Value = app.JMPTask{app.taskIndex}.maxTime;
            end
        end

        function updateMarkerNames(app)
            app.MarkersTextArea.Value = app.JMPTask{app.taskIndex}.marker_names;
        end

        function updateJointsTable(app)
            app.JointsTable.Data = table([app.JMPTask{app.taskIndex}.jointNames'; ...
                "+ Add new joint"]);
        end

        function updateBodiesTable(app)
            app.BodiesTable.Data = table([app.JMPTask{app.taskIndex}.bodyNames'; ...
                "+ Add new body"]);
        end

        function updateJMPTasksListBox(app) % good
            taskEnabled = true(length(app.JMPTask), 1);
            taskNames = strings(length(app.JMPTask), 1);
            for i = 1 : length(app.JMPTask)
                taskEnabled(i) = strcmp(app.JMPTask{i}.is_enabled, 'true');
                taskNames(i) = app.JMPTask{i}.name;
            end
            app.TasksTable.Data = table([taskEnabled; false], [taskNames; ...
                "Add a new task"]);
        end

        function updateTasksPanel(app)
            if isempty(app.JMPTask)
                app.createEmptyTask()
            end
            app.MarkersFileEditField.Value = getRelativePath( ...
                app.JMPTask{app.taskIndex}.marker_file_name);
            app.StartTimeField.Value = app.JMPTask{app.taskIndex}.time_range(1);
            app.EndTimeField.Value = app.JMPTask{app.taskIndex}.time_range(2);
            app.MarkersTextArea.Value = app.JMPTask{app.taskIndex}.marker_names;
        end

        function formatTabButtons(app) % good
            switch app.TabGroup.SelectedTab
                case app.InputsTab
                    app.JMPInputsButton.BackgroundColor = [1 1 1];
                    app.JMPInputsButton.FontColor = [0.13,0.18,0.40];

                    app.JMPTasksButton.BackgroundColor = [0.13,0.18,0.40];
                    app.JMPTasksButton.FontColor = [1 1 1];

                    app.AdvancedButton.BackgroundColor = [0.13,0.18,0.40];
                    app.AdvancedButton.FontColor = [1 1 1];

                case app.TasksTab
                    app.JMPInputsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.JMPInputsButton.FontColor = [1 1 1];

                    app.JMPTasksButton.BackgroundColor = [1 1 1];
                    app.JMPTasksButton.FontColor = [0.13,0.18,0.40];

                    app.AdvancedButton.BackgroundColor = [0.13,0.18,0.40];
                    app.AdvancedButton.FontColor = [1 1 1];

                case app.AdvancedTab
                    app.JMPInputsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.JMPInputsButton.FontColor = [1 1 1];

                    app.JMPTasksButton.BackgroundColor = [0.13,0.18,0.40];
                    app.JMPTasksButton.FontColor = [1 1 1];

                    app.AdvancedButton.BackgroundColor = [1 1 1];
                    app.AdvancedButton.FontColor = [0.13,0.18,0.40];
            end
        end
    end

    methods (Access = private)

        function createEmptyTask(app)
            app.JMPTask{length(app.JMPTask) + 1} = JMPTaskClass();
            app.taskIndex = length(app.JMPTask);
            app.makeTaskListeners();
            app.JMPTask{app.taskIndex}.name = "Task " + num2str(app.taskIndex);
            app.JMPTask{app.taskIndex}.index = app.taskIndex;
            app.updateTasksPanel();
            app.updateJMPTasksListBox();
        end

        function deleteTask(app, taskIndex)
            app.JMPTask = app.JMPTask(~taskIndex);
            for i = 1 : length(app.JMPTask)
                app.JMPTask{i}.index = i;
            end
            if isempty(app.JMPTask)
                app.taskIndex = [];
                return
            end
            if app.taskIndex > 1
                app.taskIndex = app.taskIndex - 1;
            end
            app.needToSave = true;
            app.updateJMPTasksListBox();
        end

        function moveTaskUp(app)
            if app.taskIndex == 1 || ...
                    app.taskIndex >= height(app.TasksTable.Data)
                return
            end

            indicesList = 1:1:length(app.JMPTask);

            indicesList(app.taskIndex) = app.taskIndex-1;
            indicesList(app.taskIndex-1) = app.taskIndex;
            app.JMPTask{app.taskIndex}.index = app.taskIndex-1;
            app.JMPTask{app.taskIndex-1}.index = app.taskIndex;
            app.JMPTask = {app.JMPTask{indicesList}};
            app.taskIndex = app.taskIndex-1;
            app.updateJMPTasksListBox();
        end

        function moveTaskDown(app)
            if app.taskIndex == height(app.TasksTable.Data)-1 || ...
                    app.taskIndex >= height(app.TasksTable.Data)
                return
            end

            indicesList = 1:1:length(app.JMPTask);
            indicesList(app.taskIndex) = app.taskIndex+1;
            indicesList(app.taskIndex+1) = app.taskIndex;
            app.JMPTask{app.taskIndex}.index = app.taskIndex+1;
            app.JMPTask{app.taskIndex+1}.index = app.taskIndex;
            app.JMPTask = {app.JMPTask{indicesList}};
            app.taskIndex = app.taskIndex+1;
            app.updateJMPTasksListBox();
        end

        function deleteJoint(app, jointIndex)
            app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint = ...
                app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint(~jointIndex);
            app.needToSave = true;
        end

        function deleteBody(app, bodyIndex)
            app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody = ...
                app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody(~bodyIndex);
            app.needToSave = true;
        end

        function parseMarkerFileData(app, markerFileName)
            import org.opensim.modeling.TimeSeriesTableVec3
            timeSeriesTable = TimeSeriesTableVec3( ...
                markerFileName);
            numTimePoints = timeSeriesTable.getNumRows;
            timeVector = timeSeriesTable.getIndependentColumn;
            columnLabelsStringVector = char(timeSeriesTable.getColumnLabels);
            app.JMPTask{app.taskIndex}.markerFileMarkers = strsplit( ...
                columnLabelsStringVector(2:end-1), ", ");

            startTime = double(timeVector.get(0));
            endTime = double(timeVector.get(numTimePoints-1));
            app.JMPTask{app.taskIndex}.time_range = ...
                [startTime endTime];
            app.JMPTask{app.taskIndex}.minTime = startTime;
            app.JMPTask{app.taskIndex}.maxTime = endTime;
        end

        function [warningFlag, warningMessage] = checkValidMarkers(app)
            warningFlag = false;
            warningMessage = "";
            if strcmp(app.JMPTask{app.taskIndex}.marker_file_name, "")
                return
            end
            invalidMarkerIndices = ~contains(app.JMPTask{app.taskIndex}.markerFileMarkers, ...
                app.model_markers);
            if any(invalidMarkerIndices)
                invalidMarkers = app.markerFileMarkers(invalidMarkerIndices);
                warningFlag = true;
                warningMessage = sprintf("The following markers are " + ...
                    "in the given marker file but not the given .osim" + ...
                    " model: %s", strjoin(invalidMarkers, ", "));
            end
        end

        function modelErrorsCallback(app) % good
            % Osim model errors
            app.modelErrorFlag = false;
            [app.modelErrorFlag, modelErrorMessage] = parseModelFileGui( ...
                app, app.input_model_file);
            if app.modelErrorFlag
                throwGuiError(modelErrorMessage, ...
                    app.InputModelFileEditField, app.InputModelFileError)
                app.ErrorFlag = true;
            else
                clearGuiError(app.InputModelFileEditField, app.InputModelFileError)
            end
        end

        function [error, message] = parseMarkerFileErrors(app, markerFileName)
            import org.opensim.modeling.TimeSeriesTableVec3
            error = false;
            message = "";
            if strcmp(markerFileName, "")
                return
            end

            if ~exist(markerFileName, "file")
                error = true;
                message = ...
                    "The given marker file does not exist.";
                return
            end
            try
                TimeSeriesTableVec3(markerFileName);
            catch
                error = true;
                app.JMPTask{app.taskIndex}.MarkerFileMessage = ...
                    "Cannot load the given marker file.";
                return
            end
        end

        function saveSettingsFile(app, settingsFileName)
            settingsFilePath = fileparts(settingsFileName);
            cd (settingsFilePath);
            app.currentSettingsFile = settingsFileName;
            settingsTree = makeJMPSettingsStruct(app, settingsFileName);
            settingsFileStruct.NMSMPipelineDocument.JointModelPersonalizationTool = ...
                settingsTree;
            settingsFileStruct.NMSMPipelineDocument.Attributes.Version = ...
                convertStringsToChars(getPipelineVersion());
            struct2xml(settingsFileStruct, settingsFileName)
        end

        function settingsTree = makeJMPSettingsStruct(app, settingsFileName)
            settingsFilePath = fileparts(settingsFileName);
            settingsTree.input_model_file = getRelativePath(app.input_model_file, settingsFilePath);
            settingsTree.output_model_file = getRelativePath(app.output_model_file, settingsFilePath);
            settingsTree.JMPTaskList = struct("JMPTask", cell(1));

            for i = 1 : length(app.JMPTask)
                settingsTree.JMPTaskList.JMPTask{i} = app.JMPTask{i}.toStruct();
            end
            settingsTree = setOptimizationParams(app, settingsTree);
            settingsTree = formatGuiDataForXml(settingsTree);
        end

        function settingsTree = setOptimizationParams(app, settingsTree)
            for i = 1 : length(app.advancedSettingNames)
                settingsTree.(app.advancedSettingNames(i)) = ...
                    app.advancedSettingValues(i);
            end
        end

        function loadSettingsFile(app, settingsFileName)
            settingsFilePath = fileparts(settingsFileName);
            cd (settingsFilePath);
            app.currentSettingsFile = settingsFileName;
            settingsTree = xml2struct(settingsFileName);
            settingsTree = settingsTree.NMSMPipelineDocument. ...
                JointModelPersonalizationTool;
            settingsTree = formatXmlDataForGui(settingsTree);
            app.input_model_file = settingsTree.input_model_file;
            app.output_model_file = settingsTree.output_model_file;

            app.loadOptimizationParams(settingsTree);
            app.JMPTask = {};
            for i = 1 : length(settingsTree.JMPTaskList.JMPTask)
                task = settingsTree.JMPTaskList.JMPTask{i};
                app.createEmptyTask()
                app.JMPTask{i}.name = task.Attributes.name;
                app.JMPTask{i}.is_enabled = task.is_enabled;
                app.JMPTask{i}.index = task.index;
                app.JMPTask{i}.marker_file_name = task.marker_file_name;
                app.JMPTask{i}.marker_names = task.marker_names;
                app.JMPTask{i}.time_range = task.time_range;
                if isfield(task, "JMPJointSet") && ...
                        isfield(task.JMPJointSet, "JMPJoint")
                    if ~strcmp(task.JMPJointSet.JMPJoint, "")
                        app.JMPTask{i}.JMPJointSet.JMPJoint = ...
                            {task.JMPJointSet.JMPJoint};
                        if isscalar(task.JMPJointSet.JMPJoint)
                            task.JMPJointSet.JMPJoint = {task.JMPJointSet.JMPJoint};
                        end
                        for j = 1 : numel(task.JMPJointSet.JMPJoint)
                            app.JMPTask{i}.jointNames(end+1) = ...
                                task.JMPJointSet.JMPJoint{j}.Attributes.name;
                        end
                    end
                else
                    app.JMPTask{i}.JMPJointSet = struct("JMPJoint", []);
                end
                if isfield(task, "JMPBodySet") && ...
                        isfield(task.JMPBodySet, "JMPBody")
                    if ~strcmp(task.JMPBodySet.JMPBody, "")
                        app.JMPTask{i}.JMPBodySet.JMPBody = ...
                            {task.JMPBodySet.JMPBody};
                        if isscalar(task.JMPBodySet.JMPBody)
                            task.JMPBodySet.JMPBody = {task.JMPBodySet.JMPBody};
                        end
                        for j = 1 : numel(task.JMPBodySet.JMPBody)
                            app.JMPTask{i}.bodyNames(end+1) = ...
                                task.JMPBodySet.JMPBody{j}.Attributes.name;
                        end
                    end

                else
                    app.JMPTask{i}.JMPJointSet = struct("JMPBody", []);
                end
                app.JMPTask{i}.JMPBodySet = task.JMPBodySet;
                app.updateTasksPanel();
                app.updateJMPTasksListBox();
            end

        end

        function loadOptimizationParams(app, settingsTree)
            for i = 1 : length(app.advancedSettingNames)
                paramName = app.advancedSettingNames(i);
                if isfield(settingsTree, paramName)
                    app.advancedSettingValues(i) = settingsTree.(paramName);
                end
            end
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
        end

        function addBody(app, body)
            app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody{end+1} = body;
            app.JMPTask{app.taskIndex}.bodyNames{end+1} = ...
                body.Attributes.name;
        end

        function editBody(app, body)
            selectedBody = app.BodiesTable.Selection;
            app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody{selectedBody} = body;
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
            app.JMPTask{1} = JMPTaskClass();
            app.JMPTask{1}.name = "Task 1";
            app.JMPTask{1}.index = 1;
            taskNames = ["Task 1"; "Add a new task"];
            isEnabled = [true; false];
            app.TasksTable.Data = table(isEnabled, taskNames);
            app.TasksTable.Selection = 1;
            Options = app.advancedSettingNames;
            Values = [
                sprintf("%.3f", app.advancedSettingValues(1))
                sprintf("%.0f", app.advancedSettingValues(2))
                sprintf("%.3e", app.advancedSettingValues(3))
                sprintf("%.3e", app.advancedSettingValues(4))
                sprintf("%.3e", app.advancedSettingValues(5))
                sprintf("%.3e", app.advancedSettingValues(6))
                sprintf("%.3e", app.advancedSettingValues(7))];
            app.AdvancedSettingsTable.Data = table( ...
                Options, Values);
            app.updateJointsTable();
            app.updateBodiesTable();
            app.makeAllListeners()
        end

        % Button pushed function: JMPInputsButton
        function JMPInputsButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.InputsTab;
            app.formatTabButtons();
        end

        % Button pushed function: AdvancedButton
        function AdvancedButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.AdvancedTab;
            app.formatTabButtons();
        end

        % Button pushed function: JMPTasksButton
        function JMPTasksButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.TasksTab;
            app.formatTabButtons();
            % app.updateTaskErrorColors()
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            [file, path] = uiputfile('*.xml', "Save XML Settings File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.saveSettingsFile(fullfile(path, file))
            % app.currentSettingsFile = fullfile(path, file);
            app.needToSave = false;
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
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
            app.input_model_file = GetFullPath( ...
                app.InputModelFileEditField.Value);
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
            app.output_model_file = getAbsolutePath( ...
                app.OutputModelFileEditField.Value);
        end

        % Double-clicked callback: TasksTable
        function TasksTableDoubleClicked(app, event)

        end

        % Button pushed function: MarkerFileSearchButton
        function MarkerFileSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.trc', "Select a trc marker file.");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end

            fullpath = fullfile(path, file);
            app.JMPTask{app.taskIndex}.marker_file_name = fullpath;
        end

        % Value changed function: MarkersFileEditField
        function MarkersFileEditFieldValueChanged(app, event)
            if strcmp(app.MarkersFileEditField.Value, "")
                app.JMPTask{app.taskIndex}.marker_file_name = "";
                return
            end
            app.JMPTask{app.taskIndex}.marker_file_name = ...
                GetFullPath(app.MarkersFileEditField.Value);
        end

        % Selection changed function: TasksTable
        function TasksTableSelectionChanged(app, event)
            if isempty(app.TasksTable.Selection)
                return
            end

            if app.TasksTable.Selection == height(app.TasksTable.Data) % if last element
                app.createEmptyTask();
                return
            else
                app.taskIndex = app.TasksTable.Selection;
            end
        end

        % Cell edit callback: TasksTable
        function TasksTableCellEdit(app, event)
            indices = event.Indices;
            app.taskIndex = indices(1);
            if indices(2) == 1
                if app.TasksTable.Data.isEnabled(indices(1))
                    app.JMPTask{app.taskIndex}.is_enabled = 'true';
                else
                    app.JMPTask{app.taskIndex}.is_enabled = 'false';
                end
            end
            if indices(2) == 2
                app.JMPTask{app.taskIndex}.name = event.NewData;
            end
        end

        % Value changed function: StartTimeField
        function StartTimeFieldValueChanged(app, event)
            app.JMPTask{app.taskIndex}.time_range(1) = app.StartTimeField.Value;
        end

        % Value changed function: EndTimeField
        function EndTimeFieldValueChanged(app, event)
            app.JMPTask{app.taskIndex}.time_range(2) = app.EndTimeField.Value;
        end

        % Button pushed function: MarkersEditButton
        function MarkersEditButtonPushed(app, event)
            ObjectSelectionWindow(app, app.JMPTask{app.taskIndex}.markerFileMarkers, ...
                app.JMPTask{app.taskIndex}.marker_names);
        end

        % Menu selected function: DeleteTaskMenu
        function DeleteTaskMenuSelected(app, event)
            deletionIndex = 1 : 1 : length(app.JMPTask) == ...
                app.TasksTable.Selection;
            app.deleteTask(deletionIndex);
        end

        % Selection changed function: JointsTable
        function JointsTableSelectionChanged(app, event)
            selection = app.JointsTable.Selection;
            if selection > length(app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint) % if clicked on add new joint
                JMPJointSelection(app, []);
            end
        end

        % Selection changed function: BodiesTable
        function BodiesTableSelectionChanged(app, event)
            selection = app.BodiesTable.Selection;
            if selection > length(app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody) % if clicked on add new body
                JMPBodySelection(app, []);
            end
        end

        % Menu selected function: EditJointMenu
        function EditJointMenuSelected(app, event)
            selection = app.JointsTable.Selection;
            JMPJointSelection(app, app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint{selection});
        end

        % Menu selected function: DeleteJointMenu
        function DeleteJointMenuSelected(app, event)
            deletionIndex = 1 : 1 : length(app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint) == ...
                app.JointsTable.Selection;
            app.deleteJoint(deletionIndex);
        end

        % Menu selected function: EditBodyMenu
        function EditBodyMenuSelected(app, event)
            selection = app.BodiesTable.Selection;
            JMPBodySelection(app, app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody{selection});
        end

        % Menu selected function: DeleteBodyMenu
        function DeleteBodyMenuSelected(app, event)
            deletionIndex = 1 : 1 : length(app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody) == ...
                app.BodiesTable.Selection;
            app.deleteBody(deletionIndex);
        end

        % Button pushed function: MoveTaskUpButton
        function MoveTaskUpButtonPushed(app, event)
            app.moveTaskUp()
        end

        % Button pushed function: MoveTaskDownButton
        function MoveTaskDownButtonPushed(app, event)
            app.moveTaskDown()
        end

        % Double-clicked callback: JointsTable
        function JointsTableDoubleClicked(app, event)
            selection = event.InteractionInformation.DisplayRow;
            JMPJointSelection(app, ...
                app.JMPTask{app.taskIndex}.JMPJointSet.JMPJoint{selection})
        end

        % Double-clicked callback: BodiesTable
        function BodiesTableDoubleClicked(app, event)
            selection = event.InteractionInformation.DisplayRow;
            JMPBodySelection(app, ...
                app.JMPTask{app.taskIndex}.JMPBodySet.JMPBody{selection})
        end

        % Menu selected function: RenameMenu
        function RenameMenuSelected(app, event)
            oldName = app.JMPTask{app.taskIndex}.name;
            newName = inputdlg("Rename task:", "Rename", [1 40], {oldName});
            if isempty(newName)
                return
            end
            app.JMPTask{app.taskIndex}.name = newName;
        end

        % Display data changed function: TasksTable
        function TasksTableDisplayDataChanged(app, event)

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

        % Menu selected function: CopyTaskMenu
        function CopyTaskMenuSelected(app, event)
            app.JMPTask{end+1} = app.JMPTask{app.taskIndex};
            app.JMPTaskAux{end+1} = app.JMPTaskAux{app.taskIndex};
            app.JMPTask{end}.Attributes.name = sprintf("Copy of %s", ...
                app.JMPTask{app.taskIndex}.Attributes.name);
            app.TaskEnabled(end+1) = strcmp(app.JMPTask{app.taskIndex}.is_enabled, 'true');
            app.TaskNames(end+1) = app.JMPTask{end}.Attributes.name;
        end

        % Cell edit callback: AdvancedSettingsTable
        function AdvancedSettingsTableCellEdit(app, event)
            index = event.Indices(1);

            if isnan(double(convertCharsToStrings(app.AdvancedSettingsTable.Data.paramValues(index))))
                app.AdvancedSettingsTable.Data.paramValues(index) = "NaN";
            else
                app.advancedSettingValues(index) = app.AdvancedSettingsTable.Data.paramValues(index);
            end
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
            app.OutputModelFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
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

            % Create InputModelFileError
            app.InputModelFileError = uiimage(app.InputsTab);
            app.InputModelFileError.Visible = 'off';
            app.InputModelFileError.Position = [717 383 28 30];
            app.InputModelFileError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputModelFileSearchButton
            app.InputModelFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputModelFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputModelFileSearchButtonPushed, true);
            app.InputModelFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
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

            % Create MarkersFileWarning
            app.MarkersFileWarning = uiimage(app.TasksPanel);
            app.MarkersFileWarning.Visible = 'off';
            app.MarkersFileWarning.Position = [519 397 35 35];
            app.MarkersFileWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create MarkersFileError
            app.MarkersFileError = uiimage(app.TasksPanel);
            app.MarkersFileError.Visible = 'off';
            app.MarkersFileError.Position = [519 397 35 35];
            app.MarkersFileError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create TimeRangeError
            app.TimeRangeError = uiimage(app.TasksPanel);
            app.TimeRangeError.Visible = 'off';
            app.TimeRangeError.Position = [336 328 35 35];
            app.TimeRangeError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

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

            % Create MarkersWarning
            app.MarkersWarning = uiimage(app.TasksPanel);
            app.MarkersWarning.Visible = 'off';
            app.MarkersWarning.Tooltip = {'You must select markers for this task.'};
            app.MarkersWarning.Position = [529 229 35 35];
            app.MarkersWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create JointsWarning
            app.JointsWarning = uiimage(app.TasksPanel);
            app.JointsWarning.Visible = 'off';
            app.JointsWarning.Tooltip = {'You must select markers for this task.'};
            app.JointsWarning.Position = [193 146 35 35];
            app.JointsWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create BodiesWarning
            app.BodiesWarning = uiimage(app.TasksPanel);
            app.BodiesWarning.Visible = 'off';
            app.BodiesWarning.Tooltip = {'You must select markers for this task.'};
            app.BodiesWarning.Position = [460 146 35 35];
            app.BodiesWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

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
            app.TasksTable.DoubleClickedFcn = createCallbackFcn(app, @TasksTableDoubleClicked, true);
            app.TasksTable.DisplayDataChangedFcn = createCallbackFcn(app, @TasksTableDisplayDataChanged, true);
            app.TasksTable.SelectionChangedFcn = createCallbackFcn(app, @TasksTableSelectionChanged, true);
            app.TasksTable.Multiselect = 'off';
            app.TasksTable.FontSize = 18;
            app.TasksTable.Position = [5 96 181 242];

            % Create TasksWarning
            app.TasksWarning = uiimage(app.TasksTab);
            app.TasksWarning.Visible = 'off';
            app.TasksWarning.Position = [133 346 35 35];
            app.TasksWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create TasksError
            app.TasksError = uiimage(app.TasksTab);
            app.TasksError.Visible = 'off';
            app.TasksError.Position = [133 346 35 35];
            app.TasksError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

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
            app.AdvancedSettingsTable.Position = [122 20 528 407];

            % Create Mask1
            app.Mask1 = uiimage(app.UIFigure);
            app.Mask1.ScaleMethod = 'fill';
            app.Mask1.Position = [211 532 790 30];
            app.Mask1.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'greyMask.png');

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
            app.RcnlLogo.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'rcnlIcon.png');

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
            app.JMPImage.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'jmpFigure.png');

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