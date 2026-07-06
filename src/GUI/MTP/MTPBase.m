% This class is part of the NMSM Pipeline, see file for full license.
%
% This class is the main App Designer application for the Muscle-Tendon
% Personalization (MTP) GUI, providing the interface for configuring,
% saving, and running MTP settings files.

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
classdef MTPBase < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        ResetButton                     matlab.ui.control.Button
        MTPTasksButton                  matlab.ui.control.Button
        RunButton                       matlab.ui.control.Button
        HelpButton                      matlab.ui.control.Button
        SaveButton                      matlab.ui.control.Button
        LoadSettingsFileButton          matlab.ui.control.Button
        RcnlLogo                        matlab.ui.control.Image
        InputsButton                    matlab.ui.control.Button
        AdvancedButton                  matlab.ui.control.Button
        AuxiliaryToolsButton            matlab.ui.control.Button
        MuscleGroupsButton              matlab.ui.control.Button
        MTPImage                        matlab.ui.control.Image
        Mask1                           matlab.ui.control.Image
        TabGroup                        matlab.ui.container.TabGroup
        InputsTab                       matlab.ui.container.Tab
        TrialPrefixesError              matlab.ui.control.Image
        TrialPrefixesWarning            matlab.ui.control.Image
        TrialPrefixesEditField          matlab.ui.control.EditField
        TrialPrefixesEditFieldLabel     matlab.ui.control.Label
        CoordinateListEditButton        matlab.ui.control.Button
        CoordinateListWarning           matlab.ui.control.Image
        CoordinatesListTextAreaLabel    matlab.ui.control.Label
        CoordinatesListTextArea         matlab.ui.control.TextArea
        InputDataDirectoryEditFieldLabel  matlab.ui.control.Label
        ResultsDirectoryError           matlab.ui.control.Image
        ResultsDirectoryEditField       matlab.ui.control.EditField
        ResultsDirectoryEditFieldLabel  matlab.ui.control.Label
        ResultsDirectorySearchButton    matlab.ui.control.Button
        InputDataError                  matlab.ui.control.Image
        InputDataEditField              matlab.ui.control.EditField
        InputDataSearchButton           matlab.ui.control.Button
        InputOsimxFileWarning           matlab.ui.control.Image
        InputOsimxFileEditField         matlab.ui.control.EditField
        InputOsimxFileEditFieldLabel    matlab.ui.control.Label
        InputOsimxFileSearchButton      matlab.ui.control.Button
        InputModelFileError             matlab.ui.control.Image
        InputModelFileEditField         matlab.ui.control.EditField
        InputModelFileEditFieldLabel    matlab.ui.control.Label
        InputModelFileSearchButton      matlab.ui.control.Button
        MuscleGroupsTab                 matlab.ui.container.Tab
        EditCollectedEmgGroupsButton    matlab.ui.control.Button
        EditMissingEmgGroupsButton      matlab.ui.control.Button
        EditFiberLengthGroupsButton     matlab.ui.control.Button
        EditActivationGroupsButton      matlab.ui.control.Button
        ActivationMuscleGroupsTextArea  matlab.ui.control.TextArea
        ActivationMuscleGroupsTextAreaLabel  matlab.ui.control.Label
        CollectedEMGMuscleGroupsTextArea  matlab.ui.control.TextArea
        CollectedEMGMuscleGroupsTextAreaLabel  matlab.ui.control.Label
        MissingEMGMuscleGroupsTextArea  matlab.ui.control.TextArea
        MissingEMGMuscleGroupsTextAreaLabel  matlab.ui.control.Label
        NormalizedFiberLengthMuscleGroupsTextArea  matlab.ui.control.TextArea
        NormalizedFiberLengthMuscleGroupsTextAreaLabel  matlab.ui.control.Label
        MTPTasksTab                     matlab.ui.container.Tab
        MoveTaskDownButton              matlab.ui.control.Button
        MoveTaskUpButton                matlab.ui.control.Button
        MTPTasksTable                   matlab.ui.control.Table
        MTPTasksLabel                   matlab.ui.control.Label
        MTPTasksError                   matlab.ui.control.Image
        MTPTasksWarning                 matlab.ui.control.Image
        MTPDesignVariablesTable         matlab.ui.control.Table
        EditMTPDesignVariablesLabel     matlab.ui.control.Label
        EditMTPCostTermsLabel           matlab.ui.control.Label
        MTPTasksCostTermPanel           matlab.ui.container.Panel
        MTPTasksCostTermsTable          matlab.ui.control.Table
        MTPTasksErrorCenterEditField    matlab.ui.control.NumericEditField
        ErrorCenterEditField_2Label     matlab.ui.control.Label
        MTPTasksMaxAllowableErrorEditField  matlab.ui.control.NumericEditField
        MaxAllowableErrorEditField_2Label  matlab.ui.control.Label
        AuxiliaryTab                    matlab.ui.container.Tab
        AuxAdvancedSettingsTable        matlab.ui.control.Table
        AuxCostTermPanel                matlab.ui.container.Panel
        AuxCostTermsTable               matlab.ui.control.Table
        AuxErrorCenterEditField         matlab.ui.control.NumericEditField
        ErrorCenterEditFieldLabel       matlab.ui.control.Label
        AuxMaxAllowableErrorEditField   matlab.ui.control.NumericEditField
        MaxAllowableErrorEditFieldLabel  matlab.ui.control.Label
        SynxButton                      matlab.ui.control.Button
        MTLIButton                      matlab.ui.control.Button
        AuxiliaryToolsTabGroup          matlab.ui.container.TabGroup
        MuscleTendonLengthInitializationTab  matlab.ui.container.Tab
        AdvancedSettingsLabel           matlab.ui.control.Label
        EditCostTermsLabel              matlab.ui.control.Label
        MaxNormalizedFiberLengthEditField  matlab.ui.control.NumericEditField
        MaxNormalizedFiberLengthEditFieldLabel  matlab.ui.control.Label
        MinNormalizedFiberLengthEditField  matlab.ui.control.NumericEditField
        MinNormalizedFiberLengthEditFieldLabel  matlab.ui.control.Label
        PassiveDataDirectoryEditField   matlab.ui.control.EditField
        PassiveDataDirectoryEditFieldLabel  matlab.ui.control.Label
        PassiveDataDirectorySearchButton  matlab.ui.control.Button
        PassiveDataDirectoryError       matlab.ui.control.Image
        EnableMTLICheckBox              matlab.ui.control.CheckBox
        SynergyExtrapolationTab         matlab.ui.container.Tab
        NumSynergiesSpinnerLabel        matlab.ui.control.Label
        NumSynergiesSpinner             matlab.ui.control.Spinner
        EnableSynergyExtrapolationCheckBox  matlab.ui.control.CheckBox
        PassiveDataInputDirectoryEditFieldLabel  matlab.ui.control.Label
        AdvancedTab                     matlab.ui.container.Tab
        AdvancedSettingsTable           matlab.ui.control.Table
        MuscletendonModelPersonalizationToolLabel  matlab.ui.control.Label
        ContextMenu                     matlab.ui.container.ContextMenu
        RenameMenu                      matlab.ui.container.Menu
        CopyMenu                        matlab.ui.container.Menu
        DeleteMenu                      matlab.ui.container.Menu
    end

    properties (Access = private)  % private UI components not in appModel
        InputOsimxFileError             matlab.ui.control.Image
        ResultsDirectoryWarning         matlab.ui.control.Image
        AuxAdvancedSettingsError        matlab.ui.control.Image
        AuxCostTermsError               matlab.ui.control.Image
        AdvancedSettingsError           matlab.ui.control.Image
        InputModelFileRequired          matlab.ui.control.Image
        InputDataRequired               matlab.ui.control.Image
        ResultsDirectoryRequired        matlab.ui.control.Image
        PassiveDataDirectoryRequired    matlab.ui.control.Image
    end


    properties (Access = private, SetObservable)
        model_coordinates string = [];
        model_groups string = [];

        input_model_file string = "";
        input_osimx_file string = "";
        data_directory string = "";
        results_directory string = "MTPResults";
        coordinate_list string = [];
        trial_prefixes string = [];

        activation_muscle_groups string = [];
        normalized_fiber_length_muscle_groups string = [];
        missing_emg_channel_muscle_groups string = [];
        collected_emg_channel_muscle_groups string = [];

        MTPTask cell = cell(0)
        taskIndex double = 1;

        MuscleTendonLengthInitialization handle = ...
            MuscleTendonLengthInitializationClass();
        MTPSynergyExtrapolation handle = ...
            SynergyExtrapolationClass();

        advancedSettingValues double = [];

        objectSelectionType string = "";  % Used to filter in setSelectedObjects
        currentSettingsFile string = "";

        % Error checking and flow control
        inputModelValid       logical = false
        dataDirectoryValid    logical = false
        resultsDirectoryValid logical = false

        timePoints double = [];
        idLabels string = [];
        emgLabels string = [];
    end

    properties (Constant, Access = private)
        designVariables = ...
            ["Muscle Specific Electromechanical Delays"
            "Electromechanical Delays"
            "Activation Time Constants"
            "Activation Non-linearity Constants"
            "EMG Scale Factors"
            "Optimal Fiber Lengths"
            "Tendon Slack Lengths"]

        advancedSettingNames = ...
            ["v_max_factor"
            "max_iterations"
            "max_function_evaluations"
            "step_tolerance"
            "function_tolerance"
            "optimality_tolerance"
            "diff_min_change"]

        defaultAdvancedSettingValues = ...
            [10
            1000
            100000000
            1e-6
            1e-6
            1e-6
            0.0001]
    end

    properties (Access = private)  % listener handles
        InputModelFileListener
        OsimXFileListener
        DataDirectoryListener
        ResultsDirectoryListener
        CoordinateListListener
        trialPrefixesListener
        ActivationGroupsListener
        FiberLengthGroupsListener
        MissingEmgGroupsListener
        CollectedEmgGroupsListener
        PassiveDataDirectoryListener
        MaxFiberLengthListener
        MinFiberLengthListener
        taskIndexListener
        advancedSettingsListener
        selectedTabListener
        auxTabListener
    end

    methods (Access = private) % listener methods
        function makeListeners(app)
            app.InputModelFileListener = addlistener(app, ...
                'input_model_file', 'PostSet', ...
                @(src,event)InputModelFileListenerFunction(app));

            app.OsimXFileListener = addlistener(app, ...
                'input_osimx_file', 'PostSet', ...
                @(src,event)OsimXFileListenerFunction(app));

            app.DataDirectoryListener = addlistener(app, ...
                'data_directory', 'PostSet', ...
                @(src,event)DataDirectoryListenerFunction(app));

            app.ResultsDirectoryListener = addlistener(app, ...
                'results_directory', 'PostSet', ...
                @(src,event)ResultsDirectoryListenerFunction(app));

            app.CoordinateListListener = addlistener(app, ...
                'coordinate_list', 'PostSet', ...
                @(src,event)CoordinateListListenerFunction(app));

            app.trialPrefixesListener = addlistener(app, ...
                'trial_prefixes', 'PostSet', ...
                @(src, event)updateTrialPrefixes(app));

            app.ActivationGroupsListener = addlistener(app, ...
                'activation_muscle_groups', 'PostSet', ...
                @(src,event)ActivationGroupsListenerFunction(app));

            app.FiberLengthGroupsListener = addlistener(app, ...
                'normalized_fiber_length_muscle_groups', 'PostSet', ...
                @(src,event)FiberLengthGroupsListenerFunction(app));

            app.MissingEmgGroupsListener = addlistener(app, ...
                'missing_emg_channel_muscle_groups', 'PostSet', ...
                @(src,event)MissingEmgGroupsListenerFunction(app));

            app.CollectedEmgGroupsListener = addlistener(app, ...
                'collected_emg_channel_muscle_groups', 'PostSet', ...
                @(src,event)CollectedEmgGroupsListenerFunction(app));

            app.PassiveDataDirectoryListener = addlistener(...
                app.MuscleTendonLengthInitialization, ...
                'passive_data_input_directory', 'PostSet', ...
                @(src,event)updatePassiveDataDirectory(app));

            app.MaxFiberLengthListener = addlistener(...
                app.MuscleTendonLengthInitialization, ...
                'max_normalized_muscle_fiber_length', 'PostSet', ...
                @(src,event)maxFiberLengthListenerFunction(app));

            app.MinFiberLengthListener = addlistener(...
                app.MuscleTendonLengthInitialization, ...
                'min_normalized_muscle_fiber_length', 'PostSet', ...
                @(src,event)minFiberLengthListenerFunction(app));

            app.taskIndexListener = addlistener(app, ...
                'taskIndex', 'PostSet', ...
                @(src, event)updateTaskIndex(app));

            app.advancedSettingsListener = addlistener(app, ...
                'advancedSettingValues', 'PostSet', ...
                @(src, event)refreshAdvancedSettingsTable(app));

            app.selectedTabListener = addlistener(app.TabGroup, ...
                'SelectedTab', 'PostSet', ...
                @(src, event)formatTabButtons(app));

            app.auxTabListener = addlistener(app.AuxiliaryToolsTabGroup, ...
                'SelectedTab', 'PostSet', ...
                @(src, event)formatTabButtons(app));
        end

        function InputModelFileListenerFunction(app)
            app.InputModelFileEditField.Value = getRelativePath( ...
                app.input_model_file);
            app.validateInputModelFile();
            app.updateRunButton();
        end

        function OsimXFileListenerFunction(app)
            app.InputOsimxFileEditField.Value = getRelativePath( ...
                app.input_osimx_file);
            app.validateInputOsimxFile();
            app.updateRunButton();
        end

        function DataDirectoryListenerFunction(app)
            app.InputDataEditField.Value = getRelativePath( ...
                app.data_directory);
            app.validateDataDirectory();
            app.updateRunButton();
        end

        function ResultsDirectoryListenerFunction(app)
            app.ResultsDirectoryEditField.Value = getRelativePath( ...
                app.results_directory);
            app.validateResultsDirectory();
            app.updateRunButton();
        end

        function CoordinateListListenerFunction(app)
            app.CoordinatesListTextArea.Value = ...
                strjoin(app.coordinate_list, ", ");
            app.updateRunButton();
        end

        function updateTrialPrefixes(app)
            app.TrialPrefixesEditField.Value = strjoin(app.trial_prefixes, " ");
            app.updateRunButton();
        end

        function ActivationGroupsListenerFunction(app)
            app.ActivationMuscleGroupsTextArea.Value = ...
                strjoin(app.activation_muscle_groups, ", ");
        end

        function FiberLengthGroupsListenerFunction(app)
            app.NormalizedFiberLengthMuscleGroupsTextArea.Value = ...
                strjoin(app.normalized_fiber_length_muscle_groups, ", ");
        end

        function MissingEmgGroupsListenerFunction(app)
            app.MissingEMGMuscleGroupsTextArea.Value = ...
                strjoin(app.missing_emg_channel_muscle_groups, ", ");
        end

        function CollectedEmgGroupsListenerFunction(app)
            app.CollectedEMGMuscleGroupsTextArea.Value = ...
                strjoin(app.collected_emg_channel_muscle_groups, ", ");
        end

        function updatePassiveDataDirectory(app)
            app.PassiveDataDirectoryEditField.Value = ...
                getRelativePath(app.MuscleTendonLengthInitialization. ...
                passive_data_input_directory);
            app.validateMtliConfig();
            app.updateRunButton();
        end

        function maxFiberLengthListenerFunction(app)
            app.MaxNormalizedFiberLengthEditField.Value = ...
                app.MuscleTendonLengthInitialization.max_normalized_muscle_fiber_length;
        end

        function minFiberLengthListenerFunction(app)
            app.MinNormalizedFiberLengthEditField.Value = ...
                app.MuscleTendonLengthInitialization.min_normalized_muscle_fiber_length;
        end

        function refreshAdvancedSettingsTable(app)
            Options = app.advancedSettingNames;
            Values = arrayfun(@formatGuiNumber, app.advancedSettingValues);
            app.AdvancedSettingsTable.Data = table(Options, Values);
            app.updateRunButton();
        end


        function updateMtliPanel(app)
            app.EnableMTLICheckBox.Value = strcmp( ...
                app.MuscleTendonLengthInitialization.is_enabled, 'true');
            app.PassiveDataDirectoryEditField.Value = ...
                getRelativePath(app.MuscleTendonLengthInitialization. ...
                passive_data_input_directory);
            app.MaxNormalizedFiberLengthEditField.Value = ...
                app.MuscleTendonLengthInitialization.max_normalized_muscle_fiber_length;
            app.MinNormalizedFiberLengthEditField.Value = ...
                app.MuscleTendonLengthInitialization.min_normalized_muscle_fiber_length;
        end

        function updateSynxPanel(app)
            app.EnableSynergyExtrapolationCheckBox.Value = strcmp( ...
                app.MTPSynergyExtrapolation.is_enabled, 'true');
            app.NumSynergiesSpinner.Value = ...
                app.MTPSynergyExtrapolation.number_of_synergies;
        end

        function auxTool = getSelectedAuxTool(app)
            % Both auxiliary tools share the parameter and cost term
            % interface, so aux tab callbacks can be written once.
            if app.AuxiliaryToolsTabGroup.SelectedTab == ...
                    app.SynergyExtrapolationTab
                auxTool = app.MTPSynergyExtrapolation;
            else
                auxTool = app.MuscleTendonLengthInitialization;
            end
        end

        function updateAuxPanel(app)
            if app.AuxiliaryToolsTabGroup.SelectedTab == ...
                    app.SynergyExtrapolationTab
                app.updateSynxPanel()
            else
                app.updateMtliPanel()
            end
            app.updateAuxCostTermsTable()
            app.updateAuxAdvancedOptionsTable()
        end

        function updateAuxCostTermsTable(app)
            updateCostTermsTableGui(app.AuxCostTermsTable, ...
                app.getSelectedAuxTool().RCNLCostTerm);
            app.validateAuxCostTermsSilent();
        end

        function isValid = validateAuxCostTermsSilent(app)
            isValid = validateCostTermsGui( ...
                app.getSelectedAuxTool().RCNLCostTerm, ...
                app.AuxCostTermsTable, app.AuxMaxAllowableErrorEditField, ...
                app.AuxCostTermsError, "cost term");
        end

        function updateAuxAdvancedOptionsTable(app)
            auxTool = app.getSelectedAuxTool();
            options = auxTool.parameterNames;
            value = strings(length(options), 1);
            for i = 1 : length(options)
                value(i) = string(auxTool.getParameterValueByIndex(i));
            end
            app.AuxAdvancedSettingsTable.Data = table(options, value);
            app.validateAuxAdvancedSettingsSilent();
        end

        function validateAuxAdvancedSettingsSilent(app)
            if app.AuxiliaryToolsTabGroup.SelectedTab == ...
                    app.SynergyExtrapolationTab
                app.validateNumSynergiesSpinner();
            end
            validateParameterTableGui(app.getSelectedAuxTool(), ...
                app.AuxAdvancedSettingsTable, app.AuxAdvancedSettingsError);
        end

        function validateNumSynergiesSpinner(app)
            if app.MTPSynergyExtrapolation.number_of_synergies <= 0
                app.NumSynergiesSpinner.BackgroundColor = [1.00 0.67 0.67];
                app.NumSynergiesSpinner.Tooltip = ...
                    'Number of synergies must be greater than zero.';
            else
                app.NumSynergiesSpinner.BackgroundColor = [1 1 1];
                app.NumSynergiesSpinner.Tooltip = '';
            end
        end

        function createDefaultTask(app)
            app.MTPTask{end + 1} = MTPTaskClass();
            app.MTPTask{end}.name = "Task " + num2str(length(app.MTPTask));
            app.MTPTask{end}.index = length(app.MTPTask);
            app.taskIndex = length(app.MTPTask);
            app.MTPTasksCostTermsTable.Selection = [];
            app.MTPDesignVariablesTable.Selection = [];
            app.MTPTasksMaxAllowableErrorEditField.Value = [];
            app.MTPTasksErrorCenterEditField.Value = [];
            app.updateMTPTasksListBox()
            app.updateDesignVariablesTable()
            app.updateMTPCostTermsTable()
        end

        function deleteTask(app, deletionIndex)
            [app.MTPTask, newTaskIndex] = removeTaskFromList( ...
                app.MTPTask, deletionIndex, app.taskIndex);
            if isempty(app.MTPTask)
                app.createDefaultTask();
            else
                app.taskIndex = newTaskIndex;
            end
            app.updateMTPTasksListBox();
            app.updateRunButton();
        end

        function moveTaskUp(app)
            [app.MTPTask, app.taskIndex] = moveTaskInList( ...
                app.MTPTask, app.taskIndex, -1);
            app.updateMTPTasksListBox();
        end

        function moveTaskDown(app)
            [app.MTPTask, app.taskIndex] = moveTaskInList( ...
                app.MTPTask, app.taskIndex, 1);
            app.updateMTPTasksListBox();
        end

        function updateTaskIndex(app)
            app.MTPTasksTable.Selection = app.taskIndex;
            app.updateMTPTasksListBox()
            app.updateDesignVariablesTable()
            app.updateMTPCostTermsTable()
            app.updateRunButton()
        end

        function updateMTPTasksListBox(app)
            updateTaskListTableGui(app.MTPTasksTable, app.MTPTask);
        end

        function updateDesignVariablesTable(app)
            designVariableNames = app.designVariables;
            isEnabled = false(length(designVariableNames), 1);
            for i = 1 : length(isEnabled)
                isEnabled(i) = strcmp(app.MTPTask{app.taskIndex}. ...
                    getParameterValueByIndex(i), 'true');
            end
            app.MTPDesignVariablesTable.Data = ...
                table(isEnabled, designVariableNames);
        end

        function updateMTPCostTermsTable(app)
            updateCostTermsTableGui(app.MTPTasksCostTermsTable, ...
                app.MTPTask{app.taskIndex}.RCNLCostTerm);
        end

        function formatTabButtons(app)
            if ~isvalid(app) || ~isvalid(app.TabGroup)
                return
            end
            updateTabButtonStyles(app.TabGroup.SelectedTab, ...
                [app.InputsTab, app.MuscleGroupsTab, app.MTPTasksTab, ...
                app.AuxiliaryTab, app.AdvancedTab], ...
                [app.InputsButton, app.MuscleGroupsButton, ...
                app.MTPTasksButton, app.AuxiliaryToolsButton, ...
                app.AdvancedButton]);
            if app.TabGroup.SelectedTab == app.AuxiliaryTab
                updateTabButtonStyles(app.AuxiliaryToolsTabGroup.SelectedTab, ...
                    [app.MuscleTendonLengthInitializationTab, ...
                    app.SynergyExtrapolationTab], ...
                    [app.MTLIButton, app.SynxButton]);
            end
        end

        function saveSettingsFile(app, settingsFileName)
            cd(fileparts(settingsFileName));
            app.currentSettingsFile = settingsFileName;
            saveGuiSettings(settingsFileName, ...
                'MuscleTendonPersonalizationTool', ...
                app.makeMTPSettingsStruct(settingsFileName));
        end

        function settingsTree = makeMTPSettingsStruct(app, settingsFileName)
            settingsFilePath = fileparts(settingsFileName);

            % Top-level file inputs
            settingsTree.input_model_file = getRelativePath( ...
                app.input_model_file, settingsFilePath);
            settingsTree.input_osimx_file = getRelativePath( ...
                app.input_osimx_file, settingsFilePath);
            settingsTree.data_directory = getRelativePath( ...
                app.data_directory, settingsFilePath);
            settingsTree.results_directory = getRelativePath( ...
                app.results_directory, settingsFilePath);
            settingsTree.trial_prefixes = app.trial_prefixes;

            % Coordinate and muscle group lists
            settingsTree.coordinate_list = strjoin(app.coordinate_list, " ");
            settingsTree.activation_muscle_groups = strjoin( ...
                app.activation_muscle_groups, " ");
            settingsTree.normalized_fiber_length_muscle_groups = strjoin( ...
                app.normalized_fiber_length_muscle_groups, " ");
            settingsTree.missing_emg_channel_muscle_groups = strjoin( ...
                app.missing_emg_channel_muscle_groups, " ");
            settingsTree.collected_emg_channel_muscle_groups = strjoin( ...
                app.collected_emg_channel_muscle_groups, " ");

            % MuscleTendonLengthInitialization
            settingsTree.MuscleTendonLengthInitialization = ...
                app.MuscleTendonLengthInitialization.toStruct();
            settingsTree.MuscleTendonLengthInitialization.passive_data_input_directory = ...
                getRelativePath(settingsTree.MuscleTendonLengthInitialization.passive_data_input_directory);

            % MTPSynergyExtrapolation
            settingsTree.MTPSynergyExtrapolation = ...
                app.MTPSynergyExtrapolation.toStruct();

            % MTP task list
            settingsTree.MTPTaskList = struct("MTPTask", cell(1));
            for i = 1 : length(app.MTPTask)
                settingsTree.MTPTaskList.MTPTask{i} = app.MTPTask{i}.toStruct();
            end

            % Optimization parameters
            settingsTree = app.setOptimizationParams(settingsTree);
            settingsTree = formatGuiDataForXml(settingsTree);
        end

        function settingsTree = setOptimizationParams(app, settingsTree)
            for i = 1 : length(app.advancedSettingNames)
                settingsTree.(app.advancedSettingNames(i)) = ...
                    app.advancedSettingValues(i);
            end
        end

        function loadSettingsFile(app, settingsFileName)
            app.resetAllFields();
            cd(fileparts(settingsFileName));
            app.currentSettingsFile = settingsFileName;
            settingsTree = loadGuiSettings(settingsFileName, ...
                'MuscleTendonPersonalizationTool');
            applyStructToHandle(app, settingsTree);
            app.loadOptimizationParams(settingsTree);

            if isfield(settingsTree, 'MuscleTendonLengthInitialization')
                app.MuscleTendonLengthInitialization.loadFromStruct( ...
                    settingsTree.MuscleTendonLengthInitialization);
            end
            if isfield(settingsTree, 'MTPSynergyExtrapolation')
                app.MTPSynergyExtrapolation.loadFromStruct( ...
                    settingsTree.MTPSynergyExtrapolation);
            end
            app.updateAuxPanel();

            if isfield(settingsTree, 'MTPTaskList') && ...
                    isfield(settingsTree.MTPTaskList, 'MTPTask')
                tasks = settingsTree.MTPTaskList.MTPTask;
                if ~iscell(tasks)
                    tasks = {tasks};
                end
                app.MTPTask = cell(0);
                for i = 1 : length(tasks)
                    app.createDefaultTask();
                    app.MTPTask{i}.loadFromStruct(tasks{i});
                end
                app.updateMTPCostTermsTable();
            end
            app.updateMTPTasksListBox();
            app.updateRunButton();
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

        function resetAllFields(app)
            app.inputModelValid = false;
            app.dataDirectoryValid = false;
            app.resultsDirectoryValid = false;

            app.model_coordinates = [];
            app.model_groups = [];

            app.input_model_file = "";
            app.input_osimx_file = "";
            app.data_directory = "";
            app.results_directory = "";
            app.coordinate_list = [];
            app.trial_prefixes = [];

            app.activation_muscle_groups = [];
            app.normalized_fiber_length_muscle_groups = [];
            app.missing_emg_channel_muscle_groups = [];
            app.collected_emg_channel_muscle_groups = [];

            app.MTPTask = cell(0);
            app.createDefaultTask();
            app.taskIndex = 1;

            % Reset in place so listeners on these objects stay valid
            app.MuscleTendonLengthInitialization.reset();
            app.MTPSynergyExtrapolation.reset();
            app.updateAuxPanel();

            app.objectSelectionType = "";
            app.currentSettingsFile = "";

            app.timePoints = [];
            app.idLabels = [];
            app.emgLabels = [];

            app.advancedSettingValues = app.defaultAdvancedSettingValues;
            app.updateRunButton();
        end
    end

    methods (Access = private)

        function validateInputModelFile(app)
            app.inputModelValid = validateRequiredFieldGui( ...
                app.input_model_file, "Input model file is required.", ...
                app.InputModelFileEditField, app.InputModelFileError, ...
                app.InputModelFileRequired, ...
                @(value, field, icon)validateOsimFileGui(app, value, field, icon));
        end

        function validateInputOsimxFile(app)
            clearGuiError(app.InputOsimxFileEditField, app.InputOsimxFileError);
            if strcmp(app.input_osimx_file, "")
                return
            end
            [errorFlag, message] = parseOsimxFileGui(app, app.input_osimx_file, ...
                app.input_model_file);
            if errorFlag
                throwGuiError(message, app.InputOsimxFileEditField, app.InputOsimxFileError);
            end
        end

        function validateDataDirectory(app)
            app.dataDirectoryValid = validateRequiredFieldGui( ...
                app.data_directory, "Input data directory is required.", ...
                app.InputDataEditField, app.InputDataError, ...
                app.InputDataRequired, ...
                @(value, field, icon)validateDataDirectoryGui(value, ...
                ["EMGData", "IDData", "MAData"], field, icon));
            if app.dataDirectoryValid
                app.parseTrialPrefixes();
                parseMtpDataDirectoryGui(app, app.data_directory);
            end
        end

        function parseTrialPrefixes(app)
            prefixes = findPrefixesFromSubdirectories( ...
                fullfile(app.data_directory, "MAData"));
            if ~isempty(prefixes)
                app.trial_prefixes = prefixes;
            end
        end

        function isValid = validateTrialPrefixes(app)
            isValid = validateTrialPrefixesGui(app.trial_prefixes, ...
                app.data_directory, app.TrialPrefixesEditField, ...
                app.TrialPrefixesError);
        end

        function validateResultsDirectory(app)
            app.resultsDirectoryValid = validateRequiredFieldGui( ...
                app.results_directory, "Results directory is required.", ...
                app.ResultsDirectoryEditField, app.ResultsDirectoryWarning, ...
                app.ResultsDirectoryRequired, @validateResultsDirectoryGui);
        end

        function isValid = validateCoordinateList(app)
            isValid = ~isEmptyStringList(app.coordinate_list);
            if isValid
                clearGuiError([], app.CoordinateListWarning);
            else
                throwGuiRequired("At least one coordinate must be selected.", ...
                    [], app.CoordinateListWarning);
            end
        end

        function isValid = validateMtliConfig(app)
            isValid = validateMtliConfigGui( ...
                app.MuscleTendonLengthInitialization, ...
                app.PassiveDataDirectoryEditField, ...
                app.PassiveDataDirectoryError, ...
                app.PassiveDataDirectoryRequired);
        end

        function isValid = validateAllTasksSilent(app)
            isValid = true;
            clearGuiError([], app.MTPTasksError);
            removeStyle(app.MTPTasksTable);
            if isempty(app.MTPTask)
                throwGuiError("At least one task must be enabled to run.", ...
                    [], app.MTPTasksError);
                isValid = false;
                return
            end
            currentTaskValid = validateCostTermsGui( ...
                app.MTPTask{app.taskIndex}.RCNLCostTerm, ...
                app.MTPTasksCostTermsTable, ...
                app.MTPTasksMaxAllowableErrorEditField, [], "cost term");
            hasEnabledTask = false;
            for i = 1:length(app.MTPTask)
                if ~strcmp(app.MTPTask{i}.is_enabled, 'true')
                    continue
                end
                hasEnabledTask = true;
                if i == app.taskIndex
                    taskValid = currentTaskValid;
                else
                    [hasEnabledCostTerm, invalidCostTerms] = ...
                        checkCostTermsValid(app.MTPTask{i}.RCNLCostTerm);
                    taskValid = hasEnabledCostTerm && isempty(invalidCostTerms);
                end
                taskValid = taskValid && app.MTPTask{i}.anyParameterEnabled();
                if ~taskValid
                    isValid = false;
                    addStyle(app.MTPTasksTable, ...
                        uistyle('BackgroundColor', [1.00 0.67 0.67]), 'row', i);
                end
            end
            if ~hasEnabledTask
                throwGuiError("At least one task must be enabled to run.", ...
                    [], app.MTPTasksError);
                isValid = false;
                return
            end
            if ~isValid
                throwGuiError("One or more tasks have errors. Check that " + ...
                    "each enabled task has at least one design variable, " + ...
                    "one enabled cost term, and a max allowable error " + ...
                    "greater than zero for each enabled cost term.", ...
                    [], app.MTPTasksError);
            end
        end

        function updateRunButton(app)
            tasksValid = app.validateAllTasksSilent();
            mtliValid = app.validateMtliConfig();
            auxValid = app.validateAuxToolsSilent();
            trialPrefixesValid = app.validateTrialPrefixes();
            advancedValid = validateAdvancedSettingsGui( ...
                app.AdvancedSettingsTable, app.advancedSettingNames, ...
                app.advancedSettingValues, app.AdvancedSettingsError);
            coordinatesValid = app.validateCoordinateList();
            app.RunButton.Enable = app.inputModelValid && ...
                app.dataDirectoryValid && app.resultsDirectoryValid && ...
                tasksValid && mtliValid && auxValid && ...
                trialPrefixesValid && advancedValid && coordinatesValid;
            app.updateTabControls();
        end

        function isValid = validateAuxToolsSilent(app)
            isValid = true;
            synx = app.MTPSynergyExtrapolation;
            if strcmp(synx.is_enabled, 'true')
                [hasEnabledTerm, invalidTerms] = ...
                    checkCostTermsValid(synx.RCNLCostTerm);
                isValid = isempty(synx.validateParameters()) && ...
                    synx.number_of_synergies > 0 && ...
                    hasEnabledTerm && isempty(invalidTerms);
            end
            mtli = app.MuscleTendonLengthInitialization;
            if isValid && strcmp(mtli.is_enabled, 'true')
                [hasEnabledTerm, invalidTerms] = ...
                    checkCostTermsValid(mtli.RCNLCostTerm);
                isValid = isempty(mtli.validateParameters()) && ...
                    hasEnabledTerm && isempty(invalidTerms);
            end
        end

        function updateTabControls(app)
            inputsReady = app.inputModelValid && app.dataDirectoryValid;
            app.MuscleGroupsButton.Enable = inputsReady;
            app.MTPTasksButton.Enable = inputsReady;
        end
    end

    methods (Access = public)
        function setSelectedObjects(app, objects)
            % Function to assign objects selected by ObjectSelectionWindow
        switch app.objectSelectionType
            case 'coordinate'
                app.coordinate_list = objects;
            case 'activationGroup'
                app.activation_muscle_groups = objects;
            case 'fiberLengthGroup'
                app.normalized_fiber_length_muscle_groups = objects;
            case 'missingEmgGroup'
                app.missing_emg_channel_muscle_groups = objects;
            case 'collectedEmgGroup'
                app.collected_emg_channel_muscle_groups = objects;
        end
        end

        function modelFile = getInputModelFile(app)
            modelFile = app.input_model_file;
        end

        function model_coordinates = getModelCoordinate(app)
            model_coordinates = app.model_coordinates;
        end

        function setModelCoordinates(app, coordinates)
            app.model_coordinates = coordinates;
        end

        function setModelGroups(app, groups)
            app.model_groups = groups;
        end

        function setTimePoints(app, timePoints)
            app.timePoints = timePoints;
        end

        function setIDLabels(app, idLabels)
            app.idLabels = idLabels;
        end

        function setEmgLabels(app, emgLabels)
            app.emgLabels = emgLabels;
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.MuscleTendonLengthInitialization = ...
                MuscleTendonLengthInitializationClass();
            app.MTPSynergyExtrapolation = SynergyExtrapolationClass();
            app.createDefaultTask();
            app.makeListeners()
            app.advancedSettingValues = app.defaultAdvancedSettingValues;
            app.AuxiliaryToolsTabGroup.SelectedTab = ...
                app.MuscleTendonLengthInitializationTab;
            app.updateAuxPanel();
            app.RunButton.Enable = false;
            app.MuscleGroupsButton.Enable = false;
            app.MTPTasksButton.Enable = false;
            app.formatTabButtons()
        end

        % Image clicked function: RcnlLogo
        function RcnlLogoImageClicked(app, event)
            web("https://nmsm.rice.edu/")
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
            close all
            MTPRun(app, app.currentSettingsFile);
        end

        % Button pushed function: HelpButton
        function HelpButtonPushed(app, event)
            web("https://nmsm.rice.edu/guides-and-publications/tool-overviews/model-personalization/muscle-tendon-personalization/")
        end

        % Button pushed function: InputsButton
        function InputsButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.InputsTab;
        end

        % Button pushed function: MuscleGroupsButton
        function MuscleGroupsButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.MuscleGroupsTab;
        end

        % Button pushed function: MTPTasksButton
        function MTPTasksButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.MTPTasksTab;
        end

        % Button pushed function: AuxiliaryToolsButton
        function AuxiliaryToolsButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.AuxiliaryTab;
        end

        % Button pushed function: AdvancedButton
        function AdvancedButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.AdvancedTab;
        end

        % Value changed function: InputModelFileEditField
        function InputModelFileEditFieldValueChanged(app, event)
            app.input_model_file = ...
                getPathFieldValue(app.InputModelFileEditField);
        end

        % Button pushed function: InputModelFileSearchButton
        function InputModelFileSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.osim', "Select an OpenSim Model File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.input_model_file = fullfile(path, file);
        end

        % Value changed function: InputOsimxFileEditField
        function InputOsimxFileEditFieldValueChanged(app, event)
            app.input_osimx_file = ...
                getPathFieldValue(app.InputOsimxFileEditField);
        end

        % Button pushed function: InputOsimxFileSearchButton
        function InputOsimxFileSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.osimx', "Select an Osimx model File");
            % User hit "Cancel"
            if isequal(file, 0)
                return
            end
            app.input_osimx_file = fullfile(path, file);
        end

        % Value changed function: ResultsDirectoryEditField
        function ResultsDirectoryEditFieldValueChanged(app, event)
            app.results_directory = ...
                getPathFieldValue(app.ResultsDirectoryEditField);
        end

        % Button pushed function: ResultsDirectorySearchButton
        function ResultsDirectorySearchButtonPushed(app, event)
            folder = uigetdir("Select a folder to store your results");
            % User hit "Cancel"
            if isequal(folder, 0)
                return
            end
            app.results_directory = folder;
        end

        % Value changed function: InputDataEditField
        function InputDataEditFieldValueChanged(app, event)
            app.data_directory = getPathFieldValue(app.InputDataEditField);
        end

        % Button pushed function: InputDataSearchButton
        function InputDataSearchButtonPushed(app, event)
            folder = uigetdir("Select your input data folder");
            % User hit "Cancel"
            if isequal(folder, 0)
                return
            end
            app.data_directory = folder;
        end

        % Button pushed function: CoordinateListEditButton
        function CoordinateListEditButtonPushed(app, event)
            ObjectSelectionWindow(app, app.model_coordinates, ...
                app.coordinate_list)
            app.objectSelectionType = 'coordinate';
        end

        % Value changed function: TrialPrefixesEditField
        function TrialPrefixesEditFieldValueChanged(app, event)
            value = app.TrialPrefixesEditField.Value;
            if strcmp(value, "")
                app.trial_prefixes = string([]);
            else
                app.trial_prefixes = strsplit(value, " ");
            end
        end

        % Button pushed function: EditActivationGroupsButton
        function EditActivationGroupsButtonPushed(app, event)
            ObjectSelectionWindow(app, app.model_groups, ...
                app.activation_muscle_groups)
            app.objectSelectionType = 'activationGroup';
        end

        % Button pushed function: EditFiberLengthGroupsButton
        function EditFiberLengthGroupsButtonPushed(app, event)
            ObjectSelectionWindow(app, app.model_groups, ...
                app.normalized_fiber_length_muscle_groups)
            app.objectSelectionType = 'fiberLengthGroup';
        end

        % Button pushed function: EditMissingEmgGroupsButton
        function EditMissingEmgGroupsButtonPushed(app, event)
            ObjectSelectionWindow(app, app.model_groups, ...
                app.missing_emg_channel_muscle_groups)
            app.objectSelectionType = 'missingEmgGroup';
        end

        % Button pushed function: EditCollectedEmgGroupsButton
        function EditCollectedEmgGroupsButtonPushed(app, event)
            %% should read directly from EMG file

            ObjectSelectionWindow(app, app.emgLabels, ...
                app.collected_emg_channel_muscle_groups)
            app.objectSelectionType = 'collectedEmgGroup';
        end

        % Selection changed function: MTPTasksTable
        function MTPTasksTableSelectionChanged(app, event)
            if isempty(app.MTPTasksTable.Selection)
                return
            end
            if app.MTPTasksTable.Selection == height(app.MTPTasksTable.Data)
                app.createDefaultTask(); % last row adds a new task
            else
                app.taskIndex = app.MTPTasksTable.Selection;
            end
        end

        % Cell edit callback: MTPTasksTable
        function MTPTasksTableCellEdit(app, event)
            rowIndex = event.Indices(1);
            if rowIndex > length(app.MTPTask)
                app.updateMTPTasksListBox(); % restore the add-task row
                return
            end
            app.taskIndex = rowIndex;
            if event.Indices(2) == 1
                app.MTPTask{rowIndex}.is_enabled = boolToString(event.NewData);
            else
                app.MTPTask{rowIndex}.name = event.NewData;
            end
            app.updateMTPTasksListBox();
            app.updateRunButton();
        end

        % Button pushed function: MoveTaskUpButton
        function MoveTaskUpButtonPushed(app, event)
            app.moveTaskUp()
        end

        % Button pushed function: MoveTaskDownButton
        function MoveTaskDownButtonPushed(app, event)
            app.moveTaskDown()
        end

        % Menu selected function: RenameMenu
        function RenameMenuSelected(app, event)
            oldName = app.MTPTask{app.taskIndex}.name;
            newName = inputdlg("Rename task:", "Rename", [1 40], ...
                {char(oldName)});
            if isempty(newName)
                return
            end
            app.MTPTask{app.taskIndex}.name = newName{1};
            app.updateMTPTasksListBox()
        end

        % Menu selected function: CopyMenu
        function CopyMenuSelected(app, event)
            sourceTask = app.MTPTask{app.taskIndex}.toStruct();
            app.createDefaultTask();
            app.MTPTask{app.taskIndex}.loadFromStruct(sourceTask);
            app.MTPTask{app.taskIndex}.name = "Copy of " + ...
                sourceTask.Attributes.name;
            app.updateMTPTasksListBox();
            app.updateDesignVariablesTable();
            app.updateMTPCostTermsTable();
            app.updateRunButton();
        end

        % Menu selected function: DeleteMenu
        function DeleteMenuSelected(app, event)
            app.deleteTask(app.MTPTasksTable.Selection);
        end

        % Cell edit callback: MTPTasksCostTermsTable
        function MTPTasksCostTermsTableCellEdit(app, event)
            app.MTPTask{app.taskIndex}.RCNLCostTerm{event.Indices(1)}. ...
                is_enabled = boolToString(event.NewData);
            app.updateRunButton();
        end

        % Selection changed function: MTPTasksCostTermsTable
        function MTPTasksCostTermsTableSelectionChanged(app, event)
            if isempty(app.MTPTasksCostTermsTable.Selection)
                return
            end
            showCostTermGui(app.MTPTask{app.taskIndex}.RCNLCostTerm{ ...
                app.MTPTasksCostTermsTable.Selection}, ...
                app.MTPTasksMaxAllowableErrorEditField, ...
                app.MTPTasksErrorCenterEditField);
            app.updateRunButton();
        end

        % Value changed function: MTPTasksMaxAllowableErrorEditField
        function MTPTasksMaxAllowableErrorEditFieldValueChanged(app, event)
            costTermIndex = app.MTPTasksCostTermsTable.Selection;
            value = app.MTPTasksMaxAllowableErrorEditField.Value;
            app.MTPTask{app.taskIndex}.RCNLCostTerm{costTermIndex}. ...
                max_allowable_error = value;
            app.updateRunButton();
        end

        % Value changed function: MTPTasksErrorCenterEditField
        function MTPTasksErrorCenterEditFieldValueChanged(app, event)
            costTermIndex = app.MTPTasksCostTermsTable.Selection;
            value = app.MTPTasksErrorCenterEditField.Value;
            app.MTPTask{app.taskIndex}.RCNLCostTerm{costTermIndex}. ...
                error_center = value;
        end

        % Cell edit callback: MTPDesignVariablesTable
        function MTPDesignVariablesTableCellEdit(app, event)
            app.MTPTask{app.taskIndex}.setParameterValueByIndex( ...
                event.Indices(1), boolToString(event.NewData));
            app.updateRunButton();
        end

        % Button pushed function: MTLIButton
        function MTLIButtonPushed(app, event)
            app.AuxiliaryToolsTabGroup.SelectedTab = ...
                app.MuscleTendonLengthInitializationTab;
            app.updateAuxPanel()
        end

        % Button pushed function: SynxButton
        function SynxButtonPushed(app, event)
            app.AuxiliaryToolsTabGroup.SelectedTab = ...
                app.SynergyExtrapolationTab;
            app.updateAuxPanel()
        end

        % Value changed function: EnableMTLICheckBox
        function EnableMTLICheckBoxValueChanged(app, event)
            app.MuscleTendonLengthInitialization.is_enabled = ...
                boolToString(app.EnableMTLICheckBox.Value);
            app.validateMtliConfig();
            app.updateRunButton();
        end

        % Value changed function: PassiveDataDirectoryEditField
        function PassiveDataDirectoryEditFieldValueChanged(app, event)
            app.MuscleTendonLengthInitialization. ...
                passive_data_input_directory = ...
                getPathFieldValue(app.PassiveDataDirectoryEditField);
        end

        % Button pushed function: PassiveDataDirectorySearchButton
        function PassiveDataDirectorySearchButtonPushed(app, event)
            folder = uigetdir("Select your passive data folder");
            % User hit "Cancel"
            if isequal(folder, 0)
                return
            end
            app.MuscleTendonLengthInitialization.passive_data_input_directory = folder;
        end

        % Value changed function: MaxNormalizedFiberLengthEditField
        function MaxNormalizedFiberLengthEditFieldValueChanged(app, event)
            value = app.MaxNormalizedFiberLengthEditField.Value;
            app.MuscleTendonLengthInitialization.max_normalized_muscle_fiber_length = value;
        end

        % Value changed function: MinNormalizedFiberLengthEditField
        function MinNormalizedFiberLengthEditFieldValueChanged(app, event)
            value = app.MinNormalizedFiberLengthEditField.Value;
            app.MuscleTendonLengthInitialization.min_normalized_muscle_fiber_length = value;
        end

        % Value changed function: EnableSynergyExtrapolationCheckBox
        function EnableSynergyExtrapolationCheckBoxValueChanged(app, event)
            app.MTPSynergyExtrapolation.is_enabled = ...
                boolToString(app.EnableSynergyExtrapolationCheckBox.Value);
            app.updateRunButton();
        end

        % Value changed function: NumSynergiesSpinner
        function NumSynergiesSpinnerValueChanged(app, event)
            app.MTPSynergyExtrapolation.number_of_synergies = ...
                app.NumSynergiesSpinner.Value;
            app.validateAuxAdvancedSettingsSilent();
            app.updateRunButton();
        end

        % Cell edit callback: AuxAdvancedSettingsTable
        function AuxAdvancedSettingsTableCellEdit(app, event)
            app.getSelectedAuxTool().setParameterValueByIndex( ...
                event.Indices(1), event.NewData);
            app.validateAuxAdvancedSettingsSilent();
            app.updateRunButton();
        end

        % Cell edit callback: AuxCostTermsTable
        function AuxCostTermsTableCellEdit(app, event)
            app.getSelectedAuxTool().RCNLCostTerm{event.Indices(1)}. ...
                is_enabled = boolToString(event.NewData);
            app.validateAuxCostTermsSilent();
            app.updateRunButton();
        end

        % Selection changed function: AuxCostTermsTable
        function AuxCostTermsTableSelectionChanged(app, event)
            if isempty(app.AuxCostTermsTable.Selection)
                return
            end
            showCostTermGui(app.getSelectedAuxTool().RCNLCostTerm{ ...
                app.AuxCostTermsTable.Selection}, ...
                app.AuxMaxAllowableErrorEditField, ...
                app.AuxErrorCenterEditField);
            app.validateAuxCostTermsSilent();
        end

        % Value changed function: AuxMaxAllowableErrorEditField
        function AuxMaxAllowableErrorEditFieldValueChanged(app, event)
            app.getSelectedAuxTool().RCNLCostTerm{ ...
                app.AuxCostTermsTable.Selection}.max_allowable_error = ...
                app.AuxMaxAllowableErrorEditField.Value;
            app.validateAuxCostTermsSilent();
            app.updateRunButton();
        end

        % Value changed function: AuxErrorCenterEditField
        function AuxErrorCenterEditFieldValueChanged(app, event)
            app.getSelectedAuxTool().RCNLCostTerm{ ...
                app.AuxCostTermsTable.Selection}.error_center = ...
                app.AuxErrorCenterEditField.Value;
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
            app.UIFigure.Position = [500 500 980 712];
            app.UIFigure.Name = 'MATLAB App';

            % Create MuscletendonModelPersonalizationToolLabel
            app.MuscletendonModelPersonalizationToolLabel = uilabel(app.UIFigure);
            app.MuscletendonModelPersonalizationToolLabel.HorizontalAlignment = 'center';
            app.MuscletendonModelPersonalizationToolLabel.FontSize = 25;
            app.MuscletendonModelPersonalizationToolLabel.FontWeight = 'bold';
            app.MuscletendonModelPersonalizationToolLabel.Position = [1 673 980 40];
            app.MuscletendonModelPersonalizationToolLabel.Text = 'Muscle-tendon Model Personalization Tool';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [211 72 770 595];

            % Create InputsTab
            app.InputsTab = uitab(app.TabGroup);
            app.InputsTab.BackgroundColor = [0.851 0.851 0.851];
            app.InputsTab.ForegroundColor = [0 0 0];

            % Create InputModelFileSearchButton
            app.InputModelFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputModelFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputModelFileSearchButtonPushed, true);
            app.InputModelFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputModelFileSearchButton.VerticalAlignment = 'bottom';
            app.InputModelFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputModelFileSearchButton.Position = [678 516 31 30];
            app.InputModelFileSearchButton.Text = '';

            % Create InputModelFileEditFieldLabel
            app.InputModelFileEditFieldLabel = uilabel(app.InputsTab);
            app.InputModelFileEditFieldLabel.HorizontalAlignment = 'right';
            app.InputModelFileEditFieldLabel.FontSize = 18;
            app.InputModelFileEditFieldLabel.FontWeight = 'bold';
            app.InputModelFileEditFieldLabel.Position = [68 516 140 30];
            app.InputModelFileEditFieldLabel.Text = 'Input Model File';

            % Create InputModelFileEditField
            app.InputModelFileEditField = uieditfield(app.InputsTab, 'text');
            app.InputModelFileEditField.ValueChangedFcn = createCallbackFcn(app, @InputModelFileEditFieldValueChanged, true);
            app.InputModelFileEditField.Position = [218 516 450 30];

            % Create InputModelFileError
            app.InputModelFileError = uiimage(app.InputsTab);
            app.InputModelFileError.Visible = 'off';
            app.InputModelFileError.Position = [718 516 28 30];
            app.InputModelFileError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputModelFileRequired
            app.InputModelFileRequired = uiimage(app.InputsTab);
            app.InputModelFileRequired.Visible = 'on';
            app.InputModelFileRequired.Tooltip = 'Input model file is required.';
            app.InputModelFileRequired.Position = [718 516 28 30];
            app.InputModelFileRequired.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'required.png');

            % Create InputOsimxFileSearchButton
            app.InputOsimxFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputOsimxFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputOsimxFileSearchButtonPushed, true);
            app.InputOsimxFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputOsimxFileSearchButton.VerticalAlignment = 'bottom';
            app.InputOsimxFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputOsimxFileSearchButton.Position = [678 461 31 30];
            app.InputOsimxFileSearchButton.Text = '';

            % Create InputOsimxFileEditFieldLabel
            app.InputOsimxFileEditFieldLabel = uilabel(app.InputsTab);
            app.InputOsimxFileEditFieldLabel.HorizontalAlignment = 'right';
            app.InputOsimxFileEditFieldLabel.FontSize = 18;
            app.InputOsimxFileEditFieldLabel.FontWeight = 'bold';
            app.InputOsimxFileEditFieldLabel.Position = [63 461 145 30];
            app.InputOsimxFileEditFieldLabel.Text = 'Input Osimx File';

            % Create InputOsimxFileEditField
            app.InputOsimxFileEditField = uieditfield(app.InputsTab, 'text');
            app.InputOsimxFileEditField.ValueChangedFcn = createCallbackFcn(app, @InputOsimxFileEditFieldValueChanged, true);
            app.InputOsimxFileEditField.Position = [218 461 450 30];

            % Create InputOsimxFileWarning
            app.InputOsimxFileWarning = uiimage(app.InputsTab);
            app.InputOsimxFileWarning.Visible = 'off';
            app.InputOsimxFileWarning.Position = [718 461 28 30];
            app.InputOsimxFileWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create InputOsimxFileError
            app.InputOsimxFileError = uiimage(app.InputsTab);
            app.InputOsimxFileError.Visible = 'off';
            app.InputOsimxFileError.Position = [718 461 28 30];
            app.InputOsimxFileError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputDataSearchButton
            app.InputDataSearchButton = uibutton(app.InputsTab, 'push');
            app.InputDataSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputDataSearchButtonPushed, true);
            app.InputDataSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputDataSearchButton.VerticalAlignment = 'bottom';
            app.InputDataSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputDataSearchButton.Position = [678 409 31 30];
            app.InputDataSearchButton.Text = '';

            % Create InputDataEditField
            app.InputDataEditField = uieditfield(app.InputsTab, 'text');
            app.InputDataEditField.ValueChangedFcn = createCallbackFcn(app, @InputDataEditFieldValueChanged, true);
            app.InputDataEditField.Position = [218 409 450 30];

            % Create InputDataError
            app.InputDataError = uiimage(app.InputsTab);
            app.InputDataError.Visible = 'off';
            app.InputDataError.Position = [718 409 28 30];
            app.InputDataError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputDataRequired
            app.InputDataRequired = uiimage(app.InputsTab);
            app.InputDataRequired.Visible = 'on';
            app.InputDataRequired.Tooltip = 'Input data directory is required.';
            app.InputDataRequired.Position = [718 409 28 30];
            app.InputDataRequired.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'required.png');

            % Create ResultsDirectorySearchButton
            app.ResultsDirectorySearchButton = uibutton(app.InputsTab, 'push');
            app.ResultsDirectorySearchButton.ButtonPushedFcn = createCallbackFcn(app, @ResultsDirectorySearchButtonPushed, true);
            app.ResultsDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.ResultsDirectorySearchButton.VerticalAlignment = 'bottom';
            app.ResultsDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ResultsDirectorySearchButton.Position = [678 354 31 30];
            app.ResultsDirectorySearchButton.Text = '';

            % Create ResultsDirectoryEditFieldLabel
            app.ResultsDirectoryEditFieldLabel = uilabel(app.InputsTab);
            app.ResultsDirectoryEditFieldLabel.HorizontalAlignment = 'right';
            app.ResultsDirectoryEditFieldLabel.FontSize = 18;
            app.ResultsDirectoryEditFieldLabel.FontWeight = 'bold';
            app.ResultsDirectoryEditFieldLabel.Position = [31 354 177 30];
            app.ResultsDirectoryEditFieldLabel.Text = 'Results Directory';

            % Create ResultsDirectoryEditField
            app.ResultsDirectoryEditField = uieditfield(app.InputsTab, 'text');
            app.ResultsDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @ResultsDirectoryEditFieldValueChanged, true);
            app.ResultsDirectoryEditField.Position = [218 354 450 30];

            % Create ResultsDirectoryError
            app.ResultsDirectoryError = uiimage(app.InputsTab);
            app.ResultsDirectoryError.Visible = 'off';
            app.ResultsDirectoryError.Position = [718 354 28 30];
            app.ResultsDirectoryError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ResultsDirectoryWarning
            app.ResultsDirectoryWarning = uiimage(app.InputsTab);
            app.ResultsDirectoryWarning.Visible = 'off';
            app.ResultsDirectoryWarning.Position = [718 354 28 30];
            app.ResultsDirectoryWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create ResultsDirectoryRequired
            app.ResultsDirectoryRequired = uiimage(app.InputsTab);
            app.ResultsDirectoryRequired.Visible = 'on';
            app.ResultsDirectoryRequired.Tooltip = 'Results directory is required.';
            app.ResultsDirectoryRequired.Position = [718 354 28 30];
            app.ResultsDirectoryRequired.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'required.png');

            % Create InputDataDirectoryEditFieldLabel
            app.InputDataDirectoryEditFieldLabel = uilabel(app.InputsTab);
            app.InputDataDirectoryEditFieldLabel.HorizontalAlignment = 'right';
            app.InputDataDirectoryEditFieldLabel.FontSize = 18;
            app.InputDataDirectoryEditFieldLabel.FontWeight = 'bold';
            app.InputDataDirectoryEditFieldLabel.Position = [31 409 177 30];
            app.InputDataDirectoryEditFieldLabel.Text = 'Input Data Directory';

            % Create CoordinatesListTextArea
            app.CoordinatesListTextArea = uitextarea(app.InputsTab);
            app.CoordinatesListTextArea.Editable = 'off';
            app.CoordinatesListTextArea.FontSize = 18;
            app.CoordinatesListTextArea.Position = [218 165 385 160];

            % Create CoordinatesListTextAreaLabel
            app.CoordinatesListTextAreaLabel = uilabel(app.InputsTab);
            app.CoordinatesListTextAreaLabel.HorizontalAlignment = 'right';
            app.CoordinatesListTextAreaLabel.FontSize = 18;
            app.CoordinatesListTextAreaLabel.FontWeight = 'bold';
            app.CoordinatesListTextAreaLabel.Position = [61 234 147 23];
            app.CoordinatesListTextAreaLabel.Text = 'Coordinates List';

            % Create CoordinateListWarning
            app.CoordinateListWarning = uiimage(app.InputsTab);
            app.CoordinateListWarning.Visible = 'on';
            app.CoordinateListWarning.Tooltip = 'At least one coordinate must be selected.';
            app.CoordinateListWarning.Position = [718 230 28 30];
            app.CoordinateListWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'required.png');

            % Create CoordinateListEditButton
            app.CoordinateListEditButton = uibutton(app.InputsTab, 'push');
            app.CoordinateListEditButton.ButtonPushedFcn = createCallbackFcn(app, @CoordinateListEditButtonPushed, true);
            app.CoordinateListEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CoordinateListEditButton.FontSize = 18;
            app.CoordinateListEditButton.FontColor = [1 1 1];
            app.CoordinateListEditButton.Position = [611 230 91 30];
            app.CoordinateListEditButton.Text = 'Edit';

            % Create TrialPrefixesEditFieldLabel
            app.TrialPrefixesEditFieldLabel = uilabel(app.InputsTab);
            app.TrialPrefixesEditFieldLabel.HorizontalAlignment = 'right';
            app.TrialPrefixesEditFieldLabel.FontSize = 18;
            app.TrialPrefixesEditFieldLabel.FontWeight = 'bold';
            app.TrialPrefixesEditFieldLabel.Position = [89 114 117 23];
            app.TrialPrefixesEditFieldLabel.Text = 'Trial Prefixes';

            % Create TrialPrefixesEditField
            app.TrialPrefixesEditField = uieditfield(app.InputsTab, 'text');
            app.TrialPrefixesEditField.ValueChangedFcn = createCallbackFcn(app, @TrialPrefixesEditFieldValueChanged, true);
            app.TrialPrefixesEditField.FontSize = 18;
            app.TrialPrefixesEditField.Position = [218 110 444 30];

            % Create TrialPrefixesWarning
            app.TrialPrefixesWarning = uiimage(app.InputsTab);
            app.TrialPrefixesWarning.Visible = 'off';
            app.TrialPrefixesWarning.Position = [672 111 28 30];
            app.TrialPrefixesWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create TrialPrefixesError
            app.TrialPrefixesError = uiimage(app.InputsTab);
            app.TrialPrefixesError.Visible = 'off';
            app.TrialPrefixesError.Position = [672 110 28 30];
            app.TrialPrefixesError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MuscleGroupsTab
            app.MuscleGroupsTab = uitab(app.TabGroup);
            app.MuscleGroupsTab.BackgroundColor = [0.851 0.851 0.851];

            % Create NormalizedFiberLengthMuscleGroupsTextAreaLabel
            app.NormalizedFiberLengthMuscleGroupsTextAreaLabel = uilabel(app.MuscleGroupsTab);
            app.NormalizedFiberLengthMuscleGroupsTextAreaLabel.HorizontalAlignment = 'center';
            app.NormalizedFiberLengthMuscleGroupsTextAreaLabel.WordWrap = 'on';
            app.NormalizedFiberLengthMuscleGroupsTextAreaLabel.FontSize = 18;
            app.NormalizedFiberLengthMuscleGroupsTextAreaLabel.FontWeight = 'bold';
            app.NormalizedFiberLengthMuscleGroupsTextAreaLabel.Position = [23 363 159 70];
            app.NormalizedFiberLengthMuscleGroupsTextAreaLabel.Text = 'Normalized Fiber Length Muscle Groups';

            % Create NormalizedFiberLengthMuscleGroupsTextArea
            app.NormalizedFiberLengthMuscleGroupsTextArea = uitextarea(app.MuscleGroupsTab);
            app.NormalizedFiberLengthMuscleGroupsTextArea.Editable = 'off';
            app.NormalizedFiberLengthMuscleGroupsTextArea.FontSize = 18;
            app.NormalizedFiberLengthMuscleGroupsTextArea.Position = [192 364 462 70];

            % Create MissingEMGMuscleGroupsTextAreaLabel
            app.MissingEMGMuscleGroupsTextAreaLabel = uilabel(app.MuscleGroupsTab);
            app.MissingEMGMuscleGroupsTextAreaLabel.HorizontalAlignment = 'center';
            app.MissingEMGMuscleGroupsTextAreaLabel.WordWrap = 'on';
            app.MissingEMGMuscleGroupsTextAreaLabel.FontSize = 18;
            app.MissingEMGMuscleGroupsTextAreaLabel.FontWeight = 'bold';
            app.MissingEMGMuscleGroupsTextAreaLabel.Position = [43 257 141 70];
            app.MissingEMGMuscleGroupsTextAreaLabel.Text = 'Missing EMG Muscle Groups';

            % Create MissingEMGMuscleGroupsTextArea
            app.MissingEMGMuscleGroupsTextArea = uitextarea(app.MuscleGroupsTab);
            app.MissingEMGMuscleGroupsTextArea.Editable = 'off';
            app.MissingEMGMuscleGroupsTextArea.FontSize = 18;
            app.MissingEMGMuscleGroupsTextArea.Position = [193 257 463 70];

            % Create CollectedEMGMuscleGroupsTextAreaLabel
            app.CollectedEMGMuscleGroupsTextAreaLabel = uilabel(app.MuscleGroupsTab);
            app.CollectedEMGMuscleGroupsTextAreaLabel.HorizontalAlignment = 'center';
            app.CollectedEMGMuscleGroupsTextAreaLabel.WordWrap = 'on';
            app.CollectedEMGMuscleGroupsTextAreaLabel.FontSize = 18;
            app.CollectedEMGMuscleGroupsTextAreaLabel.FontWeight = 'bold';
            app.CollectedEMGMuscleGroupsTextAreaLabel.Position = [45 152 139 70];
            app.CollectedEMGMuscleGroupsTextAreaLabel.Text = 'Collected EMG Muscle Groups';

            % Create CollectedEMGMuscleGroupsTextArea
            app.CollectedEMGMuscleGroupsTextArea = uitextarea(app.MuscleGroupsTab);
            app.CollectedEMGMuscleGroupsTextArea.Editable = 'off';
            app.CollectedEMGMuscleGroupsTextArea.FontSize = 18;
            app.CollectedEMGMuscleGroupsTextArea.Position = [194 152 462 70];

            % Create ActivationMuscleGroupsTextAreaLabel
            app.ActivationMuscleGroupsTextAreaLabel = uilabel(app.MuscleGroupsTab);
            app.ActivationMuscleGroupsTextAreaLabel.HorizontalAlignment = 'center';
            app.ActivationMuscleGroupsTextAreaLabel.WordWrap = 'on';
            app.ActivationMuscleGroupsTextAreaLabel.FontSize = 18;
            app.ActivationMuscleGroupsTextAreaLabel.FontWeight = 'bold';
            app.ActivationMuscleGroupsTextAreaLabel.Position = [39 476 141 70];
            app.ActivationMuscleGroupsTextAreaLabel.Text = 'Activation Muscle Groups';

            % Create ActivationMuscleGroupsTextArea
            app.ActivationMuscleGroupsTextArea = uitextarea(app.MuscleGroupsTab);
            app.ActivationMuscleGroupsTextArea.Editable = 'off';
            app.ActivationMuscleGroupsTextArea.FontSize = 18;
            app.ActivationMuscleGroupsTextArea.Position = [190 476 462 70];

            % Create EditActivationGroupsButton
            app.EditActivationGroupsButton = uibutton(app.MuscleGroupsTab, 'push');
            app.EditActivationGroupsButton.ButtonPushedFcn = createCallbackFcn(app, @EditActivationGroupsButtonPushed, true);
            app.EditActivationGroupsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.EditActivationGroupsButton.FontSize = 18;
            app.EditActivationGroupsButton.FontColor = [1 1 1];
            app.EditActivationGroupsButton.Position = [661 496 91 30];
            app.EditActivationGroupsButton.Text = 'Edit';

            % Create EditFiberLengthGroupsButton
            app.EditFiberLengthGroupsButton = uibutton(app.MuscleGroupsTab, 'push');
            app.EditFiberLengthGroupsButton.ButtonPushedFcn = createCallbackFcn(app, @EditFiberLengthGroupsButtonPushed, true);
            app.EditFiberLengthGroupsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.EditFiberLengthGroupsButton.FontSize = 18;
            app.EditFiberLengthGroupsButton.FontColor = [1 1 1];
            app.EditFiberLengthGroupsButton.Position = [663 383 91 30];
            app.EditFiberLengthGroupsButton.Text = 'Edit';

            % Create EditMissingEmgGroupsButton
            app.EditMissingEmgGroupsButton = uibutton(app.MuscleGroupsTab, 'push');
            app.EditMissingEmgGroupsButton.ButtonPushedFcn = createCallbackFcn(app, @EditMissingEmgGroupsButtonPushed, true);
            app.EditMissingEmgGroupsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.EditMissingEmgGroupsButton.FontSize = 18;
            app.EditMissingEmgGroupsButton.FontColor = [1 1 1];
            app.EditMissingEmgGroupsButton.Position = [665 277 91 30];
            app.EditMissingEmgGroupsButton.Text = 'Edit';

            % Create EditCollectedEmgGroupsButton
            app.EditCollectedEmgGroupsButton = uibutton(app.MuscleGroupsTab, 'push');
            app.EditCollectedEmgGroupsButton.ButtonPushedFcn = createCallbackFcn(app, @EditCollectedEmgGroupsButtonPushed, true);
            app.EditCollectedEmgGroupsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.EditCollectedEmgGroupsButton.FontSize = 18;
            app.EditCollectedEmgGroupsButton.FontColor = [1 1 1];
            app.EditCollectedEmgGroupsButton.Position = [665 172 91 30];
            app.EditCollectedEmgGroupsButton.Text = 'Edit';

            % Create MTPTasksTab
            app.MTPTasksTab = uitab(app.TabGroup);
            app.MTPTasksTab.BackgroundColor = [0.851 0.851 0.851];

            % Create MTPTasksCostTermPanel
            app.MTPTasksCostTermPanel = uipanel(app.MTPTasksTab);
            app.MTPTasksCostTermPanel.BackgroundColor = [1 1 1];
            app.MTPTasksCostTermPanel.FontWeight = 'bold';
            app.MTPTasksCostTermPanel.FontSize = 18;
            app.MTPTasksCostTermPanel.Position = [211 4 559 270];

            % Create MaxAllowableErrorEditField_2Label
            app.MaxAllowableErrorEditField_2Label = uilabel(app.MTPTasksCostTermPanel);
            app.MaxAllowableErrorEditField_2Label.HorizontalAlignment = 'center';
            app.MaxAllowableErrorEditField_2Label.WordWrap = 'on';
            app.MaxAllowableErrorEditField_2Label.FontSize = 18;
            app.MaxAllowableErrorEditField_2Label.Position = [44 4 116 44];
            app.MaxAllowableErrorEditField_2Label.Text = 'Max Allowable Error';

            % Create MTPTasksMaxAllowableErrorEditField
            app.MTPTasksMaxAllowableErrorEditField = uieditfield(app.MTPTasksCostTermPanel, 'numeric');
            app.MTPTasksMaxAllowableErrorEditField.AllowEmpty = 'on';
            app.MTPTasksMaxAllowableErrorEditField.ValueChangedFcn = createCallbackFcn(app, @MTPTasksMaxAllowableErrorEditFieldValueChanged, true);
            app.MTPTasksMaxAllowableErrorEditField.FontSize = 18;
            app.MTPTasksMaxAllowableErrorEditField.Position = [173 14 78 24];
            app.MTPTasksMaxAllowableErrorEditField.Value = [];

            % Create ErrorCenterEditField_2Label
            app.ErrorCenterEditField_2Label = uilabel(app.MTPTasksCostTermPanel);
            app.ErrorCenterEditField_2Label.HorizontalAlignment = 'right';
            app.ErrorCenterEditField_2Label.FontSize = 18;
            app.ErrorCenterEditField_2Label.Position = [316 15 104 23];
            app.ErrorCenterEditField_2Label.Text = 'Error Center';

            % Create MTPTasksErrorCenterEditField
            app.MTPTasksErrorCenterEditField = uieditfield(app.MTPTasksCostTermPanel, 'numeric');
            app.MTPTasksErrorCenterEditField.AllowEmpty = 'on';
            app.MTPTasksErrorCenterEditField.ValueChangedFcn = createCallbackFcn(app, @MTPTasksErrorCenterEditFieldValueChanged, true);
            app.MTPTasksErrorCenterEditField.FontSize = 18;
            app.MTPTasksErrorCenterEditField.Position = [436 14 77 24];
            app.MTPTasksErrorCenterEditField.Value = [];

            % Create MTPTasksCostTermsTable
            app.MTPTasksCostTermsTable = uitable(app.MTPTasksCostTermPanel);
            app.MTPTasksCostTermsTable.ColumnName = {''; 'Cost Term'};
            app.MTPTasksCostTermsTable.ColumnWidth = {30, 'auto'};
            app.MTPTasksCostTermsTable.RowName = {};
            app.MTPTasksCostTermsTable.SelectionType = 'row';
            app.MTPTasksCostTermsTable.ColumnEditable = [true false];
            app.MTPTasksCostTermsTable.RowStriping = 'off';
            app.MTPTasksCostTermsTable.CellEditCallback = createCallbackFcn(app, @MTPTasksCostTermsTableCellEdit, true);
            app.MTPTasksCostTermsTable.SelectionChangedFcn = createCallbackFcn(app, @MTPTasksCostTermsTableSelectionChanged, true);
            app.MTPTasksCostTermsTable.Multiselect = 'off';
            app.MTPTasksCostTermsTable.FontSize = 18;
            app.MTPTasksCostTermsTable.Position = [1 56 556 213];

            % Create EditMTPCostTermsLabel
            app.EditMTPCostTermsLabel = uilabel(app.MTPTasksTab);
            app.EditMTPCostTermsLabel.FontSize = 18;
            app.EditMTPCostTermsLabel.FontWeight = 'bold';
            app.EditMTPCostTermsLabel.Position = [420 274 142 23];
            app.EditMTPCostTermsLabel.Text = 'Edit Cost Terms';

            % Create EditMTPDesignVariablesLabel
            app.EditMTPDesignVariablesLabel = uilabel(app.MTPTasksTab);
            app.EditMTPDesignVariablesLabel.FontSize = 18;
            app.EditMTPDesignVariablesLabel.FontWeight = 'bold';
            app.EditMTPDesignVariablesLabel.Position = [396 539 188 23];
            app.EditMTPDesignVariablesLabel.Text = 'Edit Design Variables';

            % Create MTPDesignVariablesTable
            app.MTPDesignVariablesTable = uitable(app.MTPTasksTab);
            app.MTPDesignVariablesTable.ColumnName = {''; 'Design Variable'};
            app.MTPDesignVariablesTable.ColumnWidth = {30, 'auto'};
            app.MTPDesignVariablesTable.RowName = {};
            app.MTPDesignVariablesTable.SelectionType = 'row';
            app.MTPDesignVariablesTable.ColumnEditable = [true false];
            app.MTPDesignVariablesTable.RowStriping = 'off';
            app.MTPDesignVariablesTable.CellEditCallback = createCallbackFcn(app, @MTPDesignVariablesTableCellEdit, true);
            app.MTPDesignVariablesTable.Multiselect = 'off';
            app.MTPDesignVariablesTable.FontSize = 18;
            app.MTPDesignVariablesTable.Position = [212 312 558 218];

            % Create MTPTasksLabel
            app.MTPTasksLabel = uilabel(app.MTPTasksTab);
            app.MTPTasksLabel.HorizontalAlignment = 'center';
            app.MTPTasksLabel.FontSize = 18;
            app.MTPTasksLabel.FontWeight = 'bold';
            app.MTPTasksLabel.Position = [61 419 55 23];
            app.MTPTasksLabel.Text = 'Tasks';

            % Create MTPTasksError
            app.MTPTasksError = uiimage(app.MTPTasksTab);
            app.MTPTasksError.Visible = 'off';
            app.MTPTasksError.Position = [133 414 35 35];
            app.MTPTasksError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MTPTasksWarning
            app.MTPTasksWarning = uiimage(app.MTPTasksTab);
            app.MTPTasksWarning.Visible = 'off';
            app.MTPTasksWarning.Position = [133 414 35 35];
            app.MTPTasksWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create MTPTasksTable
            app.MTPTasksTable = uitable(app.MTPTasksTab);
            app.MTPTasksTable.ColumnName = {''; 'Task'};
            app.MTPTasksTable.ColumnWidth = {30, 'auto'};
            app.MTPTasksTable.RowName = {};
            app.MTPTasksTable.ColumnSortable = [false true];
            app.MTPTasksTable.SelectionType = 'row';
            app.MTPTasksTable.ColumnEditable = true;
            app.MTPTasksTable.RowStriping = 'off';
            app.MTPTasksTable.CellEditCallback = createCallbackFcn(app, @MTPTasksTableCellEdit, true);
            app.MTPTasksTable.SelectionChangedFcn = createCallbackFcn(app, @MTPTasksTableSelectionChanged, true);
            app.MTPTasksTable.Multiselect = 'off';
            app.MTPTasksTable.FontSize = 18;
            app.MTPTasksTable.Position = [3 172 172 242];

            % Create MoveTaskUpButton
            app.MoveTaskUpButton = uibutton(app.MTPTasksTab, 'push');
            app.MoveTaskUpButton.ButtonPushedFcn = createCallbackFcn(app, @MoveTaskUpButtonPushed, true);
            app.MoveTaskUpButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'ArrowUp.svg');
            app.MoveTaskUpButton.IconAlignment = 'center';
            app.MoveTaskUpButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MoveTaskUpButton.Position = [178 306 25 25];
            app.MoveTaskUpButton.Text = '';

            % Create MoveTaskDownButton
            app.MoveTaskDownButton = uibutton(app.MTPTasksTab, 'push');
            app.MoveTaskDownButton.ButtonPushedFcn = createCallbackFcn(app, @MoveTaskDownButtonPushed, true);
            app.MoveTaskDownButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'ArrowDown.svg');
            app.MoveTaskDownButton.IconAlignment = 'center';
            app.MoveTaskDownButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MoveTaskDownButton.Position = [178 252 25 25];
            app.MoveTaskDownButton.Text = '';

            % Create AuxiliaryTab
            app.AuxiliaryTab = uitab(app.TabGroup);
            app.AuxiliaryTab.BackgroundColor = [0.851 0.851 0.851];

            % Create PassiveDataInputDirectoryEditFieldLabel
            app.PassiveDataInputDirectoryEditFieldLabel = uilabel(app.AuxiliaryTab);
            app.PassiveDataInputDirectoryEditFieldLabel.HorizontalAlignment = 'center';
            app.PassiveDataInputDirectoryEditFieldLabel.WordWrap = 'on';
            app.PassiveDataInputDirectoryEditFieldLabel.FontSize = 18;
            app.PassiveDataInputDirectoryEditFieldLabel.FontWeight = 'bold';
            app.PassiveDataInputDirectoryEditFieldLabel.Position = [35 455 161 58];
            app.PassiveDataInputDirectoryEditFieldLabel.Text = 'Passive Data Input Directory';

            % Create AuxiliaryToolsTabGroup
            app.AuxiliaryToolsTabGroup = uitabgroup(app.AuxiliaryTab);
            app.AuxiliaryToolsTabGroup.Position = [0 0 769 595];

            % Create MuscleTendonLengthInitializationTab
            app.MuscleTendonLengthInitializationTab = uitab(app.AuxiliaryToolsTabGroup);
            app.MuscleTendonLengthInitializationTab.Title = 'Tab';
            app.MuscleTendonLengthInitializationTab.BackgroundColor = [0.851 0.851 0.851];

            % Create EnableMTLICheckBox
            app.EnableMTLICheckBox = uicheckbox(app.MuscleTendonLengthInitializationTab);
            app.EnableMTLICheckBox.ValueChangedFcn = createCallbackFcn(app, @EnableMTLICheckBoxValueChanged, true);
            app.EnableMTLICheckBox.Value = false;
            app.EnableMTLICheckBox.Text = 'Enable Muscle-tendon Length Initialization';
            app.EnableMTLICheckBox.FontSize = 18;
            app.EnableMTLICheckBox.FontWeight = 'bold';
            app.EnableMTLICheckBox.Position = [195 508 393 22];

            % Create PassiveDataDirectoryError
            app.PassiveDataDirectoryError = uiimage(app.MuscleTendonLengthInitializationTab);
            app.PassiveDataDirectoryError.Visible = 'off';
            app.PassiveDataDirectoryError.Position = [723 455 28 30];
            app.PassiveDataDirectoryError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create PassiveDataDirectoryRequired
            app.PassiveDataDirectoryRequired = uiimage(app.MuscleTendonLengthInitializationTab);
            app.PassiveDataDirectoryRequired.Visible = 'on';
            app.PassiveDataDirectoryRequired.Tooltip = 'Passive data directory is required when MTLI is enabled.';
            app.PassiveDataDirectoryRequired.Position = [723 455 28 30];
            app.PassiveDataDirectoryRequired.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'required.png');

            % Create PassiveDataDirectorySearchButton
            app.PassiveDataDirectorySearchButton = uibutton(app.MuscleTendonLengthInitializationTab, 'push');
            app.PassiveDataDirectorySearchButton.ButtonPushedFcn = createCallbackFcn(app, @PassiveDataDirectorySearchButtonPushed, true);
            app.PassiveDataDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.PassiveDataDirectorySearchButton.VerticalAlignment = 'bottom';
            app.PassiveDataDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.PassiveDataDirectorySearchButton.Position = [683 455 31 30];
            app.PassiveDataDirectorySearchButton.Text = '';

            % Create PassiveDataDirectoryEditFieldLabel
            app.PassiveDataDirectoryEditFieldLabel = uilabel(app.MuscleTendonLengthInitializationTab);
            app.PassiveDataDirectoryEditFieldLabel.HorizontalAlignment = 'right';
            app.PassiveDataDirectoryEditFieldLabel.FontSize = 18;
            app.PassiveDataDirectoryEditFieldLabel.FontWeight = 'bold';
            app.PassiveDataDirectoryEditFieldLabel.Position = [12 455 201 30];
            app.PassiveDataDirectoryEditFieldLabel.Text = 'Passive Data Directory';

            % Create PassiveDataDirectoryEditField
            app.PassiveDataDirectoryEditField = uieditfield(app.MuscleTendonLengthInitializationTab, 'text');
            app.PassiveDataDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @PassiveDataDirectoryEditFieldValueChanged, true);
            app.PassiveDataDirectoryEditField.Position = [223 455 450 30];

            % Create MinNormalizedFiberLengthEditFieldLabel
            app.MinNormalizedFiberLengthEditFieldLabel = uilabel(app.MuscleTendonLengthInitializationTab);
            app.MinNormalizedFiberLengthEditFieldLabel.HorizontalAlignment = 'right';
            app.MinNormalizedFiberLengthEditFieldLabel.FontSize = 18;
            app.MinNormalizedFiberLengthEditFieldLabel.FontWeight = 'bold';
            app.MinNormalizedFiberLengthEditFieldLabel.Position = [49 396 254 23];
            app.MinNormalizedFiberLengthEditFieldLabel.Text = 'Min Normalized Fiber Length';

            % Create MinNormalizedFiberLengthEditField
            app.MinNormalizedFiberLengthEditField = uieditfield(app.MuscleTendonLengthInitializationTab, 'numeric');
            app.MinNormalizedFiberLengthEditField.Limits = [0 3];
            app.MinNormalizedFiberLengthEditField.ValueChangedFcn = createCallbackFcn(app, @MinNormalizedFiberLengthEditFieldValueChanged, true);
            app.MinNormalizedFiberLengthEditField.FontSize = 18;
            app.MinNormalizedFiberLengthEditField.Position = [317 392 41 30];
            app.MinNormalizedFiberLengthEditField.Value = 0.7;

            % Create MaxNormalizedFiberLengthEditFieldLabel
            app.MaxNormalizedFiberLengthEditFieldLabel = uilabel(app.MuscleTendonLengthInitializationTab);
            app.MaxNormalizedFiberLengthEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxNormalizedFiberLengthEditFieldLabel.FontSize = 18;
            app.MaxNormalizedFiberLengthEditFieldLabel.FontWeight = 'bold';
            app.MaxNormalizedFiberLengthEditFieldLabel.Position = [380 396 259 23];
            app.MaxNormalizedFiberLengthEditFieldLabel.Text = 'Max Normalized Fiber Length';

            % Create MaxNormalizedFiberLengthEditField
            app.MaxNormalizedFiberLengthEditField = uieditfield(app.MuscleTendonLengthInitializationTab, 'numeric');
            app.MaxNormalizedFiberLengthEditField.Limits = [0 3];
            app.MaxNormalizedFiberLengthEditField.ValueChangedFcn = createCallbackFcn(app, @MaxNormalizedFiberLengthEditFieldValueChanged, true);
            app.MaxNormalizedFiberLengthEditField.FontSize = 18;
            app.MaxNormalizedFiberLengthEditField.Position = [653 392 41 30];
            app.MaxNormalizedFiberLengthEditField.Value = 1;

            % Create EditCostTermsLabel
            app.EditCostTermsLabel = uilabel(app.AuxiliaryTab);
            app.EditCostTermsLabel.FontSize = 18;
            app.EditCostTermsLabel.FontWeight = 'bold';
            app.EditCostTermsLabel.Position = [117 339 142 23];
            app.EditCostTermsLabel.Text = 'Edit Cost Terms';

            % Create AuxCostTermsError
            app.AuxCostTermsError = uiimage(app.AuxiliaryTab);
            app.AuxCostTermsError.Visible = 'off';
            app.AuxCostTermsError.Position = [263 337 28 30];
            app.AuxCostTermsError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create AdvancedSettingsLabel
            app.AdvancedSettingsLabel = uilabel(app.AuxiliaryTab);
            app.AdvancedSettingsLabel.FontSize = 18;
            app.AdvancedSettingsLabel.FontWeight = 'bold';
            app.AdvancedSettingsLabel.Position = [504 339 167 23];
            app.AdvancedSettingsLabel.Text = 'Advanced Settings';

            % Create SynergyExtrapolationTab
            app.SynergyExtrapolationTab = uitab(app.AuxiliaryToolsTabGroup);
            app.SynergyExtrapolationTab.Title = 'Tab2';
            app.SynergyExtrapolationTab.BackgroundColor = [0.851 0.851 0.851];

            % Create EnableSynergyExtrapolationCheckBox
            app.EnableSynergyExtrapolationCheckBox = uicheckbox(app.SynergyExtrapolationTab);
            app.EnableSynergyExtrapolationCheckBox.ValueChangedFcn = createCallbackFcn(app, @EnableSynergyExtrapolationCheckBoxValueChanged, true);
            app.EnableSynergyExtrapolationCheckBox.Text = 'Enable Synergy Extrapolation';
            app.EnableSynergyExtrapolationCheckBox.FontSize = 18;
            app.EnableSynergyExtrapolationCheckBox.FontWeight = 'bold';
            app.EnableSynergyExtrapolationCheckBox.Position = [27 474 280 22];

            % Create NumSynergiesSpinner
            app.NumSynergiesSpinner = uispinner(app.SynergyExtrapolationTab);
            app.NumSynergiesSpinner.ValueChangedFcn = createCallbackFcn(app, @NumSynergiesSpinnerValueChanged, true);
            app.NumSynergiesSpinner.FontSize = 18;
            app.NumSynergiesSpinner.FontWeight = 'bold';
            app.NumSynergiesSpinner.Position = [178 418 100 24];

            % Create NumSynergiesSpinnerLabel
            app.NumSynergiesSpinnerLabel = uilabel(app.SynergyExtrapolationTab);
            app.NumSynergiesSpinnerLabel.HorizontalAlignment = 'right';
            app.NumSynergiesSpinnerLabel.FontSize = 18;
            app.NumSynergiesSpinnerLabel.FontWeight = 'bold';
            app.NumSynergiesSpinnerLabel.Position = [27 419 136 23];
            app.NumSynergiesSpinnerLabel.Text = 'Num Synergies';

            % Create MTLIButton
            app.MTLIButton = uibutton(app.AuxiliaryTab, 'push');
            app.MTLIButton.ButtonPushedFcn = createCallbackFcn(app, @MTLIButtonPushed, true);
            app.MTLIButton.WordWrap = 'on';
            app.MTLIButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MTLIButton.FontSize = 18;
            app.MTLIButton.FontColor = [1 1 1];
            app.MTLIButton.Position = [1 539 297 31];
            app.MTLIButton.Text = 'Muscle Tendon Length Initialization';

            % Create SynxButton
            app.SynxButton = uibutton(app.AuxiliaryTab, 'push');
            app.SynxButton.ButtonPushedFcn = createCallbackFcn(app, @SynxButtonPushed, true);
            app.SynxButton.WordWrap = 'on';
            app.SynxButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SynxButton.FontSize = 18;
            app.SynxButton.FontColor = [1 1 1];
            app.SynxButton.Position = [301 539 195 31];
            app.SynxButton.Text = 'Synergy Extrapolation';

            % Create AuxCostTermPanel
            app.AuxCostTermPanel = uipanel(app.AuxiliaryTab);
            app.AuxCostTermPanel.BackgroundColor = [1 1 1];
            app.AuxCostTermPanel.FontWeight = 'bold';
            app.AuxCostTermPanel.FontSize = 18;
            app.AuxCostTermPanel.Position = [8 1 389 323];

            % Create MaxAllowableErrorEditFieldLabel
            app.MaxAllowableErrorEditFieldLabel = uilabel(app.AuxCostTermPanel);
            app.MaxAllowableErrorEditFieldLabel.HorizontalAlignment = 'center';
            app.MaxAllowableErrorEditFieldLabel.WordWrap = 'on';
            app.MaxAllowableErrorEditFieldLabel.FontSize = 18;
            app.MaxAllowableErrorEditFieldLabel.Position = [15 3 116 44];
            app.MaxAllowableErrorEditFieldLabel.Text = 'Max Allowable Error';

            % Create AuxMaxAllowableErrorEditField
            app.AuxMaxAllowableErrorEditField = uieditfield(app.AuxCostTermPanel, 'numeric');
            app.AuxMaxAllowableErrorEditField.ValueChangedFcn = createCallbackFcn(app, @AuxMaxAllowableErrorEditFieldValueChanged, true);
            app.AuxMaxAllowableErrorEditField.FontSize = 18;
            app.AuxMaxAllowableErrorEditField.Position = [135 12 48 24];

            % Create ErrorCenterEditFieldLabel
            app.ErrorCenterEditFieldLabel = uilabel(app.AuxCostTermPanel);
            app.ErrorCenterEditFieldLabel.HorizontalAlignment = 'right';
            app.ErrorCenterEditFieldLabel.FontSize = 18;
            app.ErrorCenterEditFieldLabel.Position = [197 13 104 23];
            app.ErrorCenterEditFieldLabel.Text = 'Error Center';

            % Create AuxErrorCenterEditField
            app.AuxErrorCenterEditField = uieditfield(app.AuxCostTermPanel, 'numeric');
            app.AuxErrorCenterEditField.ValueChangedFcn = createCallbackFcn(app, @AuxErrorCenterEditFieldValueChanged, true);
            app.AuxErrorCenterEditField.FontSize = 18;
            app.AuxErrorCenterEditField.Position = [306 12 48 24];

            % Create AuxCostTermsTable
            app.AuxCostTermsTable = uitable(app.AuxCostTermPanel);
            app.AuxCostTermsTable.ColumnName = {''; 'Cost Term'};
            app.AuxCostTermsTable.ColumnWidth = {30, 'auto'};
            app.AuxCostTermsTable.RowName = {};
            app.AuxCostTermsTable.ColumnSortable = [false true];
            app.AuxCostTermsTable.SelectionType = 'row';
            app.AuxCostTermsTable.ColumnEditable = true;
            app.AuxCostTermsTable.RowStriping = 'off';
            app.AuxCostTermsTable.CellEditCallback = createCallbackFcn(app, @AuxCostTermsTableCellEdit, true);
            app.AuxCostTermsTable.SelectionChangedFcn = createCallbackFcn(app, @AuxCostTermsTableSelectionChanged, true);
            app.AuxCostTermsTable.Multiselect = 'off';
            app.AuxCostTermsTable.FontSize = 15;
            app.AuxCostTermsTable.Position = [0 49 388 274];

            % Create AuxAdvancedSettingsTable
            app.AuxAdvancedSettingsTable = uitable(app.AuxiliaryTab);
            app.AuxAdvancedSettingsTable.ColumnName = {'Parameter'; 'Value'};
            app.AuxAdvancedSettingsTable.RowName = {};
            app.AuxAdvancedSettingsTable.SelectionType = 'row';
            app.AuxAdvancedSettingsTable.ColumnEditable = [false true];
            app.AuxAdvancedSettingsTable.CellEditCallback = createCallbackFcn(app, @AuxAdvancedSettingsTableCellEdit, true);
            app.AuxAdvancedSettingsTable.FontSize = 15;
            app.AuxAdvancedSettingsTable.Position = [420 1 336 323];

            % Create AuxAdvancedSettingsError
            app.AuxAdvancedSettingsError = uiimage(app.AuxiliaryTab);
            app.AuxAdvancedSettingsError.Visible = 'off';
            app.AuxAdvancedSettingsError.Position = [675 337 28 30];
            app.AuxAdvancedSettingsError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create AdvancedTab
            app.AdvancedTab = uitab(app.TabGroup);
            app.AdvancedTab.BackgroundColor = [0.851 0.851 0.851];

            % Create AdvancedSettingsTable
            app.AdvancedSettingsTable = uitable(app.AdvancedTab);
            app.AdvancedSettingsTable.ColumnName = {'Option'; 'Value'};
            app.AdvancedSettingsTable.RowName = {};
            app.AdvancedSettingsTable.SelectionType = 'row';
            app.AdvancedSettingsTable.ColumnEditable = [false true];
            app.AdvancedSettingsTable.CellEditCallback = createCallbackFcn(app, @AdvancedSettingsTableCellEdit, true);
            app.AdvancedSettingsTable.FontSize = 20;
            app.AdvancedSettingsTable.Position = [110 83 528 407];

            % Create AdvancedSettingsError
            app.AdvancedSettingsError = uiimage(app.AdvancedTab);
            app.AdvancedSettingsError.Visible = 'off';
            app.AdvancedSettingsError.Position = [643 488 28 30];
            app.AdvancedSettingsError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create Mask1
            app.Mask1 = uiimage(app.UIFigure);
            app.Mask1.ScaleMethod = 'fill';
            app.Mask1.Position = [211 644 770 30];
            app.Mask1.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'greyMask.png');

            % Create MTPImage
            app.MTPImage = uiimage(app.UIFigure);
            app.MTPImage.Position = [1 193 178 420];
            app.MTPImage.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'mtpFigure.png');

            % Create MuscleGroupsButton
            app.MuscleGroupsButton = uibutton(app.UIFigure, 'push');
            app.MuscleGroupsButton.ButtonPushedFcn = createCallbackFcn(app, @MuscleGroupsButtonPushed, true);
            app.MuscleGroupsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MuscleGroupsButton.FontSize = 18;
            app.MuscleGroupsButton.FontColor = [1 1 1];
            app.MuscleGroupsButton.Position = [324 643 140 30];
            app.MuscleGroupsButton.Text = 'Muscle Groups';

            % Create AuxiliaryToolsButton
            app.AuxiliaryToolsButton = uibutton(app.UIFigure, 'push');
            app.AuxiliaryToolsButton.ButtonPushedFcn = createCallbackFcn(app, @AuxiliaryToolsButtonPushed, true);
            app.AuxiliaryToolsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.AuxiliaryToolsButton.FontSize = 18;
            app.AuxiliaryToolsButton.FontColor = [1 1 1];
            app.AuxiliaryToolsButton.Position = [573 643 143 30];
            app.AuxiliaryToolsButton.Text = 'Auxiliary Tools';

            % Create AdvancedButton
            app.AdvancedButton = uibutton(app.UIFigure, 'push');
            app.AdvancedButton.ButtonPushedFcn = createCallbackFcn(app, @AdvancedButtonPushed, true);
            app.AdvancedButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.AdvancedButton.FontSize = 18;
            app.AdvancedButton.FontColor = [1 1 1];
            app.AdvancedButton.Position = [719 643 100 30];
            app.AdvancedButton.Text = 'Advanced';

            % Create InputsButton
            app.InputsButton = uibutton(app.UIFigure, 'push');
            app.InputsButton.ButtonPushedFcn = createCallbackFcn(app, @InputsButtonPushed, true);
            app.InputsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputsButton.FontSize = 18;
            app.InputsButton.FontColor = [1 1 1];
            app.InputsButton.Position = [211 643 110 30];
            app.InputsButton.Text = 'MTP Inputs';

            % Create RcnlLogo
            app.RcnlLogo = uiimage(app.UIFigure);
            app.RcnlLogo.ImageClickedFcn = createCallbackFcn(app, @RcnlLogoImageClicked, true);
            app.RcnlLogo.Position = [11 623 80 80];
            app.RcnlLogo.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'rcnlIcon.png');

            % Create LoadSettingsFileButton
            app.LoadSettingsFileButton = uibutton(app.UIFigure, 'push');
            app.LoadSettingsFileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadSettingsFileButtonPushed, true);
            app.LoadSettingsFileButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.LoadSettingsFileButton.FontSize = 18;
            app.LoadSettingsFileButton.FontColor = [1 1 1];
            app.LoadSettingsFileButton.Position = [502 23 90 30];
            app.LoadSettingsFileButton.Text = 'Load';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SaveButton.FontSize = 18;
            app.SaveButton.FontColor = [1 1 1];
            app.SaveButton.Position = [622 23 90 30];
            app.SaveButton.Text = 'Save';

            % Create HelpButton
            app.HelpButton = uibutton(app.UIFigure, 'push');
            app.HelpButton.ButtonPushedFcn = createCallbackFcn(app, @HelpButtonPushed, true);
            app.HelpButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.HelpButton.FontSize = 18;
            app.HelpButton.FontColor = [1 1 1];
            app.HelpButton.Position = [862 24 90 30];
            app.HelpButton.Text = 'Help';

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.RunButton.FontSize = 18;
            app.RunButton.FontColor = [1 1 1];
            app.RunButton.Position = [742 23 90 30];
            app.RunButton.Text = 'Run';

            % Create MTPTasksButton
            app.MTPTasksButton = uibutton(app.UIFigure, 'push');
            app.MTPTasksButton.ButtonPushedFcn = createCallbackFcn(app, @MTPTasksButtonPushed, true);
            app.MTPTasksButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MTPTasksButton.FontSize = 18;
            app.MTPTasksButton.FontColor = [1 1 1];
            app.MTPTasksButton.Position = [467 643 103 30];
            app.MTPTasksButton.Text = 'MTP Tasks';

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ResetButton.FontSize = 18;
            app.ResetButton.FontColor = [1 1 1];
            app.ResetButton.Position = [382 23 90 30];
            app.ResetButton.Text = 'Reset';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create RenameMenu
            app.RenameMenu = uimenu(app.ContextMenu);
            app.RenameMenu.MenuSelectedFcn = createCallbackFcn(app, @RenameMenuSelected, true);
            app.RenameMenu.Text = 'Rename';

            % Create CopyMenu
            app.CopyMenu = uimenu(app.ContextMenu);
            app.CopyMenu.MenuSelectedFcn = createCallbackFcn(app, @CopyMenuSelected, true);
            app.CopyMenu.Text = 'Copy';

            % Create DeleteMenu
            app.DeleteMenu = uimenu(app.ContextMenu);
            app.DeleteMenu.MenuSelectedFcn = createCallbackFcn(app, @DeleteMenuSelected, true);
            app.DeleteMenu.Text = 'Delete';

            % Assign app.ContextMenu
            app.MTPTasksTable.ContextMenu = app.ContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MTPBase

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