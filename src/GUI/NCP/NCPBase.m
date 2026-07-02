% This class is part of the NMSM Pipeline, see file for full license.
%
% This class is the main App Designer application for the Neural Control
% Personalization (NCP) GUI, providing the interface for configuring,
% saving, and running NCP settings files.

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
classdef NCPBase < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        ResetButton                     matlab.ui.control.Button
        RunButton                       matlab.ui.control.Button
        HelpButton                      matlab.ui.control.Button
        SaveButton                      matlab.ui.control.Button
        LoadSettingsFileButton          matlab.ui.control.Button
        RcnlLogo                        matlab.ui.control.Image
        InputsButton                    matlab.ui.control.Button
        MuscleGroupsButton              matlab.ui.control.Button
        CostTermsButton                 matlab.ui.control.Button
        AuxiliaryToolsButton            matlab.ui.control.Button
        AdvancedButton                  matlab.ui.control.Button
        MTPImage                        matlab.ui.control.Image
        Mask1                           matlab.ui.control.Image
        TabGroup                        matlab.ui.container.TabGroup
        InputsTab                       matlab.ui.container.Tab
        MTPResultsDirectoryLabel        matlab.ui.control.Label
        MTPResultsDirEditField          matlab.ui.control.EditField
        MTPResultsDirSearchButton       matlab.ui.control.Button
        MTPResultsDirError              matlab.ui.control.Image
        TaskPrefixesError               matlab.ui.control.Image
        TaskPrefixesWarning             matlab.ui.control.Image
        TrialPrefixesEditField          matlab.ui.control.EditField
        TrialPrefixesEditFieldLabel     matlab.ui.control.Label
        CoordinateListEditButton        matlab.ui.control.Button
        CoordinateListWarning           matlab.ui.control.Image
        CoordinatesListTextAreaLabel    matlab.ui.control.Label
        CoordinatesListTextArea         matlab.ui.control.TextArea
        InputDataDirectoryEditFieldLabel  matlab.ui.control.Label
        ResultsDirectoryError           matlab.ui.control.Image
        NCPResultsDirectoryEditField    matlab.ui.control.EditField
        NCPResultsDirectoryEditFieldLabel  matlab.ui.control.Label
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
        EditFiberLengthGroupsButton     matlab.ui.control.Button
        EditActivationGroupsButton      matlab.ui.control.Button
        ActivationMuscleGroupsTextArea  matlab.ui.control.TextArea
        ActivationMuscleGroupsTextAreaLabel  matlab.ui.control.Label
        NormalizedFiberLengthMuscleGroupsTextArea  matlab.ui.control.TextArea
        NormalizedFiberLengthMuscleGroupsTextAreaLabel  matlab.ui.control.Label
        CostTermsTab                    matlab.ui.container.Tab
        AddSynergyGroupButton           matlab.ui.control.Button
        EditSynergySetsLabel            matlab.ui.control.Label
        EditNCPCostTermsLabel           matlab.ui.control.Label
        SynergyGroupsTable              matlab.ui.control.Table
        NCPMaxAllowableErrorEditField   matlab.ui.control.NumericEditField
        MaxAllowableErrorEditField_2Label  matlab.ui.control.Label
        NCPCostTermsTable               matlab.ui.control.Table
        AuxiliaryTab                    matlab.ui.container.Tab
        EditCostTermsLabel              matlab.ui.control.Label
        MtliAdvancedSettingsTable       matlab.ui.control.Table
        AuxCostTermPanel                matlab.ui.container.Panel
        MtliCostTermsTable              matlab.ui.control.Table
        MtliErrorCenterEditField        matlab.ui.control.NumericEditField
        ErrorCenterEditFieldLabel       matlab.ui.control.Label
        MtliMaxAllowableErrorEditField  matlab.ui.control.NumericEditField
        MaxAllowableErrorEditFieldLabel  matlab.ui.control.Label
        AdvancedSettingsLabel           matlab.ui.control.Label
        MaxNormalizedFiberLengthEditField  matlab.ui.control.NumericEditField
        MaxNormalizedFiberLengthEditFieldLabel  matlab.ui.control.Label
        MinNormalizedFiberLengthEditField  matlab.ui.control.NumericEditField
        MinNormalizedFiberLengthEditFieldLabel  matlab.ui.control.Label
        PassiveDataDirectoryEditField   matlab.ui.control.EditField
        PassiveDataDirectoryEditFieldLabel  matlab.ui.control.Label
        PassiveDataDirectorySearchButton  matlab.ui.control.Button
        PassiveDataDirectoryError       matlab.ui.control.Image
        EnableMTLICheckBox              matlab.ui.control.CheckBox
        AdvancedTab                     matlab.ui.container.Tab
        AdvancedSettingsTable           matlab.ui.control.Table
        NeuralControlModelPersonalizationToolLabel  matlab.ui.control.Label
        ContextMenu                     matlab.ui.container.ContextMenu
        RenameMenu                      matlab.ui.container.Menu
        CopyMenu                        matlab.ui.container.Menu
        DeleteMenu                      matlab.ui.container.Menu
    end

    properties (Access = private)  % private UI components not in appModel
        ResultsDirectoryWarning         matlab.ui.control.Image
        InputModelFileRequired          matlab.ui.control.Image
        InputDataRequired               matlab.ui.control.Image
        MTPResultsDirRequired           matlab.ui.control.Image
        NCPResultsDirRequired           matlab.ui.control.Image
        PassiveDataDirectoryRequired    matlab.ui.control.Image
        SynergyGroupsRequired           matlab.ui.control.Image
        SynergyGroupsError              matlab.ui.control.Image
        NCPCostTermsError               matlab.ui.control.Image
        MtliCostTermsError              matlab.ui.control.Image
        MtliAdvancedSettingsError       matlab.ui.control.Image
        AdvancedSettingsError           matlab.ui.control.Image
    end


    properties (Access = private, SetObservable)
        model_coordinates string = [];
        model_groups string = [];

        input_model_file string = "";
        input_osimx_file string = "";
        data_directory string = "";
        mtp_results_directory string = "";
        results_directory string = "";
        coordinate_list string = [];
        trial_prefixes string = [];
        v_max_factor double = 10;

        activation_muscle_groups string = [];
        normalized_fiber_length_muscle_groups string = [];
        synergyGroups string = [];

        MuscleTendonLengthInitialization handle = ...
            MuscleTendonLengthInitializationClass();

        RCNLCostTerm cell = cell(0)

        RCNLSynergy cell = cell(0)

        costTermStruct = struct( ...
                'moment_tracking',            {{'true'    0    5     false}}, ...
                'activation_tracking',        {{'true'    0    0.05  false}}, ...
                'activation_minimization',    {{'false'   0    0.1   false}}, ...
                'grouped_activations',        {{'false'   0    0.1   false}}, ...
                'grouped_fiber_lengths',      {{'false'   0    0.1   false}} ...
                );


        advancedSettingNames = ...
            ["v_max_factor"
            "max_iterations"
            "max_function_evaluations"
            "step_tolerance"
            "function_tolerance"
            "optimality_tolerance"
            "diff_min_change"]

        advancedSettingValues = ...
            [10
            1000
            100000000
            1e-6
            1e-6
            1e-6
            0.0001]

        needToSave = true;
        currentSettingsFile string = "";
        objectSelectionType;

        inputModelValid          logical = false
        dataDirectoryValid       logical = false
        mtpResultsDirectoryValid logical = false
        ncpResultsDirectoryValid logical = false
        coordinateListValid      logical = false
        synergyGroupsValid       logical = false
    end

    properties(Access = private)  % listner properties
        InputModelFileListener
        OsimXFileListener
        DataDirectoryListener
        MtpResultsDirectoryListener
        NcpResultsDirectoryListener
        CoordinateListListener
        trialPrefixesListener
        ActivationGroupsListener
        FiberLengthGroupsListener
        PassiveDataDirectoryListener
        MaxFiberLengthListener
        MinFiberLengthListener
        advancedSettingsListener
        selectedTabListener
        
        ncpCostTermListener
        RCNLSynergyListener
        synergyGroupsListener
        enableMtliListener
        mtliCostTermListener

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

            app.MtpResultsDirectoryListener = addlistener(app, ...
                'mtp_results_directory', 'PostSet', ...
                @(src,event)MtpResultsDirectoryListenerFunction(app));

            app.NcpResultsDirectoryListener = addlistener(app, ...
                'results_directory', 'PostSet', ...
                @(src,event)NcpResultsDirectoryListenerFunction(app));

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

            app.advancedSettingsListener = addlistener(app, ...
                'advancedSettingValues', 'PostSet', ...
                @(src, event)updateAdvancedSettingValues(app));

            app.selectedTabListener = addlistener(app.TabGroup, ...
                'SelectedTab', 'PostSet', ...
                @(src, event)formatTabButtons(app));

            app.enableMtliListener = addlistener(app.MuscleTendonLengthInitialization, ...
                'is_enabled', 'PostSet', ...
                @(src, event)updateEnableMtliBox(app));

            app.ncpCostTermListener = addlistener(app, ...
                'RCNLCostTerm', 'PostSet', ...
                @(src, event)updateNCPCostTermsTable(app));

            app.RCNLSynergyListener = addlistener(app, ...
                'RCNLSynergy', 'PostSet', ...
                @(src, event)updateSynergyGroupsTable(app));

            app.synergyGroupsListener = addlistener(app, ...
                'synergyGroups', 'PostSet', ...
                @(src, event)updateRCNLSynergy(app));

            app.mtliCostTermListener = addlistener(app.MuscleTendonLengthInitialization, ...
                'RCNLCostTerm', 'PostSet', ...
                @(src, event)updateMtliCostTermsFields(app));
        end

        function InputModelFileListenerFunction(app)
            app.InputModelFileEditField.Value = getRelativePath( ...
                app.input_model_file);
            app.validateInputModelFile();
            app.updateRunButton();
            app.needToSave = true;
        end

        function OsimXFileListenerFunction(app)
            app.InputOsimxFileEditField.Value = getRelativePath( ...
                app.input_osimx_file);
            app.validateInputOsimxFile();
            app.updateRunButton();
            app.needToSave = true;
        end

        function DataDirectoryListenerFunction(app)
            app.InputDataEditField.Value = getRelativePath( ...
                app.data_directory);
            app.validateDataDirectory();
            app.updateRunButton();
            app.needToSave = true;
        end

        function MtpResultsDirectoryListenerFunction(app)
            app.MTPResultsDirEditField.Value = getRelativePath( ...
                app.mtp_results_directory);
            app.validateMtpResultsDirectory();
            app.updateRunButton();
            app.needToSave = true;
        end

        function NcpResultsDirectoryListenerFunction(app)
            app.NCPResultsDirectoryEditField.Value = getRelativePath( ...
                app.results_directory);
            app.validateNcpResultsDirectory();
            app.updateRunButton();
            app.needToSave = true;
        end

        function CoordinateListListenerFunction(app)
            app.CoordinatesListTextArea.Value = strjoin(app.coordinate_list, ", ");
            app.validateCoordinateList();
            app.updateRunButton();
            app.needToSave = true;
        end

        function updateTrialPrefixes(app)
            app.TrialPrefixesEditField.Value = strjoin(app.trial_prefixes, " ");
            app.updateRunButton();
        end

        function ActivationGroupsListenerFunction(app)
            app.ActivationMuscleGroupsTextArea.Value = ...
                strjoin(app.activation_muscle_groups, ", ");
            app.needToSave;
        end

        function FiberLengthGroupsListenerFunction(app)
            app.NormalizedFiberLengthMuscleGroupsTextArea.Value = ...
                strjoin(app.normalized_fiber_length_muscle_groups, ", ");
            app.needToSave;
        end

        function updateEnableMtliBox(app)
            app.EnableMTLICheckBox.Value = strcmp( ...
                app.MuscleTendonLengthInitialization.is_enabled, 'true');
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

        function s = formatAdvancedValue(~, value)
            % Format values in the advanced params table to use scientific
            % notation if over 3 sig figs. 
            s = string(sprintf('%.3g', value));
        end

        function updateAdvancedSettingValues(app)
            app.AdvancedSettingsTable.Data.Values = ...
                arrayfun(@(v) app.formatAdvancedValue(v), ...
                app.advancedSettingValues);
        end

        function formatTabButtons(app) % good
            if ~isvalid(app) || ~isvalid(app.TabGroup)
                return
            end
            switch app.TabGroup.SelectedTab
                case app.InputsTab
                    app.InputsButton.BackgroundColor = [1 1 1];
                    app.InputsButton.FontColor = [0.13,0.18,0.40];
                    
                    app.MuscleGroupsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.MuscleGroupsButton.FontColor = [1 1 1];

                    app.CostTermsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.CostTermsButton.FontColor = [1 1 1];

                    app.AuxiliaryToolsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.AuxiliaryToolsButton.FontColor = [1 1 1];

                    app.AdvancedButton.BackgroundColor = [0.13,0.18,0.40];
                    app.AdvancedButton.FontColor = [1 1 1];

                case app.MuscleGroupsTab
                    app.InputsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.InputsButton.FontColor = [1 1 1];
                    
                    app.MuscleGroupsButton.BackgroundColor = [1 1 1];
                    app.MuscleGroupsButton.FontColor = [0.13,0.18,0.40];

                    app.CostTermsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.CostTermsButton.FontColor = [1 1 1];

                    app.AuxiliaryToolsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.AuxiliaryToolsButton.FontColor = [1 1 1];

                    app.AdvancedButton.BackgroundColor = [0.13,0.18,0.40];
                    app.AdvancedButton.FontColor = [1 1 1];

                case app.CostTermsTab
                    app.InputsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.InputsButton.FontColor = [1 1 1];
                    
                    app.MuscleGroupsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.MuscleGroupsButton.FontColor = [1 1 1];

                    app.CostTermsButton.BackgroundColor = [1 1 1];
                    app.CostTermsButton.FontColor = [0.13,0.18,0.40];

                    app.AuxiliaryToolsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.AuxiliaryToolsButton.FontColor = [1 1 1];

                    app.AdvancedButton.BackgroundColor = [0.13,0.18,0.40];
                    app.AdvancedButton.FontColor = [1 1 1];

                case app.AuxiliaryTab
                    app.InputsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.InputsButton.FontColor = [1 1 1];
                    
                    app.MuscleGroupsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.MuscleGroupsButton.FontColor = [1 1 1];

                    app.CostTermsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.CostTermsButton.FontColor = [1 1 1];

                    app.AuxiliaryToolsButton.BackgroundColor = [1 1 1];
                    app.AuxiliaryToolsButton.FontColor = [0.13,0.18,0.40];

                    app.AdvancedButton.BackgroundColor = [0.13,0.18,0.40];
                    app.AdvancedButton.FontColor = [1 1 1];

                case app.AdvancedTab
                    app.InputsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.InputsButton.FontColor = [1 1 1];
                    
                    app.MuscleGroupsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.MuscleGroupsButton.FontColor = [1 1 1];

                    app.CostTermsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.CostTermsButton.FontColor = [1 1 1];

                    app.AuxiliaryToolsButton.BackgroundColor = [0.13,0.18,0.40];
                    app.AuxiliaryToolsButton.FontColor = [1 1 1];

                    app.AdvancedButton.BackgroundColor = [1 1 1];
                    app.AdvancedButton.FontColor = [0.13,0.18,0.40];
            end
        end

        function makeDefaultCostTermSet(app)
            costTermNames = fieldnames(app.costTermStruct);
            for i = 1 : length(costTermNames)
                costTerm = RCNLCostTermClass();
                costTerm.is_enabled = app.costTermStruct.(costTermNames{i}){1};
                costTerm.type = costTermNames{i};
                costTerm.error_center = app.costTermStruct.(costTermNames{i}){2};
                costTerm.max_allowable_error = app.costTermStruct.(costTermNames{i}){3};
                costTerm.uses_error_center = app.costTermStruct.(costTermNames{i}){4};
                app.RCNLCostTerm{i} = costTerm;
            end
        end

        function initMtli(app)
            app.MuscleTendonLengthInitialization.makeDefaultCostTermSet();
            app.updateMtliAdvancedSettingsTable();
            app.MuscleTendonLengthInitialization.is_enabled = 'false';
        end

        function updateMtliAdvancedSettingsTable(app)
            options = ["optimize_maximum_muscle_stress"
                "optimize_isometric_max_force"
                "optimize_absolute_length_changes"
                "maximum_muscle_stress"];
            value = [string(app.MuscleTendonLengthInitialization.optimize_maximum_muscle_stress)
                string(app.MuscleTendonLengthInitialization.optimize_isometric_max_force)
                string(app.MuscleTendonLengthInitialization.optimize_absolute_length_changes)
                app.formatAdvancedValue(app.MuscleTendonLengthInitialization.maximum_muscle_stress)];
            app.MtliAdvancedSettingsTable.Data = table(options, value);
            app.validateMtliAdvancedSettingsSilent();
        end

        function isValid = validateMtliAdvancedSettingsSilent(app)
            isValid = true;
            removeStyle(app.MtliAdvancedSettingsTable);
            clearGuiError([], app.MtliAdvancedSettingsError);
            app.MtliAdvancedSettingsTable.Tooltip = '';
            if ~strcmp(app.MuscleTendonLengthInitialization.is_enabled, 'true')
                return
            end
            data = app.MtliAdvancedSettingsTable.Data;
            if isempty(data) || height(data) < 4
                return
            end
            validBools = ["true", "false"];
            messages = string([]);
            boolNames = ["optimize_maximum_muscle_stress", ...
                "optimize_isometric_max_force", ...
                "optimize_absolute_length_changes"];
            for row = 1:3
                if ~ismember(data.value(row), validBools)
                    addStyle(app.MtliAdvancedSettingsTable, ...
                        uistyle('BackgroundColor', [1.00 0.67 0.67]), 'row', row);
                    messages(end+1) = boolNames(row) + ": must be true or false";
                end
            end
            stressVal = str2double(data.value(4));
            if isnan(stressVal) || stressVal <= 0
                addStyle(app.MtliAdvancedSettingsTable, ...
                    uistyle('BackgroundColor', [1.00 0.67 0.67]), 'row', 4);
                messages(end+1) = "maximum_muscle_stress: must be a positive number";
            end
            if ~isempty(messages)
                errorMsg = strjoin(messages, newline);
                app.MtliAdvancedSettingsTable.Tooltip = errorMsg;
                throwGuiError(errorMsg, [], app.MtliAdvancedSettingsError);
                isValid = false;
            end
        end

        function updateNCPCostTermsTable(app)
            isEnabled = true(length(app.RCNLCostTerm), 1);
            costTermTypes = strings(length(app.RCNLCostTerm), 1);
            for i = 1 : length(app.RCNLCostTerm)
                isEnabled(i) = strcmp(app.RCNLCostTerm{i}.is_enabled, "true");
                costTermTypes(i) = app.RCNLCostTerm{i}.type;
            end
            app.NCPCostTermsTable.Data = table(isEnabled, costTermTypes);
            app.validateNCPCostTermsSilent();
            app.updateRunButton();
        end

        function isValid = validateNCPCostTermsSilent(app)
            isValid = true;
            removeStyle(app.NCPCostTermsTable);
            clearGuiError([], app.NCPCostTermsError);
            app.NCPMaxAllowableErrorEditField.BackgroundColor = [1 1 1];
            hasEnabledCostTerm = false;
            selectedCostTerm = app.NCPCostTermsTable.Selection;
            for k = 1:length(app.RCNLCostTerm)
                if strcmp(app.RCNLCostTerm{k}.is_enabled, 'true')
                    hasEnabledCostTerm = true;
                    if app.RCNLCostTerm{k}.max_allowable_error <= 0
                        addStyle(app.NCPCostTermsTable, ...
                            uistyle('BackgroundColor', [1.00 0.67 0.67]), 'row', k);
                        isValid = false;
                        if ~isempty(selectedCostTerm) && selectedCostTerm == k
                            app.NCPMaxAllowableErrorEditField.BackgroundColor = ...
                                [1.00 0.67 0.67];
                        end
                    end
                end
            end
            if ~hasEnabledCostTerm
                throwGuiError("At least one cost term must be enabled.", ...
                    [], app.NCPCostTermsError);
                isValid = false;
            elseif ~isValid
                throwGuiError("Max allowable error must be greater than " + ...
                    "zero for each enabled cost term.", ...
                    [], app.NCPCostTermsError);
            end
        end

        function updateRCNLSynergy(app)
            numSynergies = ones(1, length(app.RCNLSynergy));
            for i = 1 : length(app.RCNLSynergy)
                numSynergies(i) = app.RCNLSynergy{i}.num_synergies;
            end
            for i = 1 : length(app.synergyGroups)
                if i > length(app.RCNLSynergy)
                    app.RCNLSynergy{i} = RCNLSynergyClass();
                end
                app.RCNLSynergy{i}.muscle_group_name = app.synergyGroups(i);
                if i > length(numSynergies)
                    app.RCNLSynergy{i}.num_synergies = 1;
                else
                    app.RCNLSynergy{i}.num_synergies = numSynergies(i);
                end
            end
            if length(app.RCNLSynergy) > length(app.synergyGroups)
                app.RCNLSynergy = {app.RCNLSynergy{1:length(app.synergyGroups)}};
            end
            app.updateSynergyGroupsTable();
            app.validateSynergyGroups();
            app.updateRunButton();
        end

        function updateSynergyGroupsTable(app)
            numSynergies = zeros(length(app.RCNLSynergy), 1);
            synergyNames = strings(length(app.RCNLSynergy), 1);
            for i = 1 : length(app.RCNLSynergy)
                numSynergies(i) = app.RCNLSynergy{i}.num_synergies;
                synergyNames(i) = app.RCNLSynergy{i}.muscle_group_name;
            end
            app.SynergyGroupsTable.Data = table(synergyNames, numSynergies);
        end

        function updateMtliCostTermsFields(app)
            numCostTerms = length(app.MuscleTendonLengthInitialization. ...
                RCNLCostTerm);
            isEnabled = false(numCostTerms, 1);
            costTermNames = strings(numCostTerms, 1);
            for i = 1 : numCostTerms
                isEnabled(i) = strcmp(app.MuscleTendonLengthInitialization. ...
                    RCNLCostTerm{i}.is_enabled, "true");
                costTermNames(i) = app.MuscleTendonLengthInitialization. ...
                    RCNLCostTerm{i}.type;
                app.MtliCostTermsTable.Data = table(isEnabled, costTermNames);
            end
            app.validateMtliCostTermsSilent();
            app.updateRunButton();
        end

        function isValid = validateMtliCostTermsSilent(app)
            isValid = true;
            removeStyle(app.MtliCostTermsTable);
            clearGuiError([], app.MtliCostTermsError);
            app.MtliMaxAllowableErrorEditField.BackgroundColor = [1 1 1];
            if ~strcmp(app.MuscleTendonLengthInitialization.is_enabled, 'true')
                return
            end
            costTerms = app.MuscleTendonLengthInitialization.RCNLCostTerm;
            hasEnabledCostTerm = false;
            selectedCostTerm = app.MtliCostTermsTable.Selection;
            for k = 1:length(costTerms)
                if isempty(costTerms{k})
                    continue
                end
                if strcmp(costTerms{k}.is_enabled, 'true')
                    hasEnabledCostTerm = true;
                    if costTerms{k}.max_allowable_error <= 0
                        addStyle(app.MtliCostTermsTable, ...
                            uistyle('BackgroundColor', [1.00 0.67 0.67]), 'row', k);
                        isValid = false;
                        if ~isempty(selectedCostTerm) && selectedCostTerm == k
                            app.MtliMaxAllowableErrorEditField.BackgroundColor = ...
                                [1.00 0.67 0.67];
                        end
                    end
                end
            end
            if ~hasEnabledCostTerm
                throwGuiError("At least one MTLI cost term must be enabled.", ...
                    [], app.MtliCostTermsError);
                isValid = false;
            elseif ~isValid
                throwGuiError("Max allowable error must be greater than " + ...
                    "zero for each enabled MTLI cost term.", ...
                    [], app.MtliCostTermsError);
            end
        end

        function validateInputModelFile(app)
            if strcmp(app.input_model_file, "")
                clearGuiError(app.InputModelFileEditField, app.InputModelFileError);
                throwGuiRequired("Input model file is required.", ...
                    [], app.InputModelFileRequired);
                app.inputModelValid = false;
                return
            end
            clearGuiError([], app.InputModelFileRequired);
            app.inputModelValid = validateOsimFileGui(app, ...
                app.input_model_file, ...
                app.InputModelFileEditField, app.InputModelFileError);
        end

        function validateInputOsimxFile(app)
            validateOsimxFileGui(app, app.input_osimx_file, ...
                app.input_model_file, ...
                app.InputOsimxFileEditField, app.InputOsimxFileWarning);
        end

        function validateDataDirectory(app)
            if strcmp(app.data_directory, "")
                clearGuiError(app.InputDataEditField, app.InputDataError);
                throwGuiRequired("Input data directory is required.", ...
                    [], app.InputDataRequired);
                app.dataDirectoryValid = false;
                return
            end
            clearGuiError([], app.InputDataRequired);
            app.dataDirectoryValid = validateDataDirectoryGui( ...
                app.data_directory, ["EMGData", "IDData", "MAData"], ...
                app.InputDataEditField, app.InputDataError);
            if app.dataDirectoryValid
                app.parseTrialPrefixes();
            end
        end

        function parseTrialPrefixes(app)
            maDataPath = fullfile(app.data_directory, "MAData");
            if ~exist(maDataPath, "dir")
                return
            end
            trialNames = findPrefixesFromSubdirectories(maDataPath);
            if ~isempty(trialNames)
                app.trial_prefixes = trialNames;
            end
        end

        function validateMtpResultsDirectory(app)
            if strcmp(app.mtp_results_directory, "")
                clearGuiError(app.MTPResultsDirEditField, app.MTPResultsDirError);
                throwGuiRequired("MTP results directory is required.", ...
                    [], app.MTPResultsDirRequired);
                app.mtpResultsDirectoryValid = false;
                return
            end
            clearGuiError([], app.MTPResultsDirRequired);
            app.mtpResultsDirectoryValid = validateFileExistsGui( ...
                app.mtp_results_directory, ...
                app.MTPResultsDirEditField, app.MTPResultsDirError);
        end

        function validateNcpResultsDirectory(app)
            if strcmp(app.results_directory, "")
                clearGuiError(app.NCPResultsDirectoryEditField, app.ResultsDirectoryWarning);
                throwGuiRequired("NCP results directory is required.", ...
                    [], app.NCPResultsDirRequired);
                app.ncpResultsDirectoryValid = false;
                return
            end
            clearGuiError([], app.NCPResultsDirRequired);
            app.ncpResultsDirectoryValid = validateResultsDirectoryGui( ...
                app.results_directory, ...
                app.NCPResultsDirectoryEditField, app.ResultsDirectoryWarning);
        end

        function isValid = validateCoordinateList(app)
            if isempty(app.coordinate_list) || ...
                    (isstring(app.coordinate_list) && all(strcmp(app.coordinate_list, "")))
                throwGuiRequired("At least one coordinate must be selected.", ...
                    [], app.CoordinateListWarning);
                app.coordinateListValid = false;
                isValid = false;
            else
                clearGuiError([], app.CoordinateListWarning);
                app.coordinateListValid = true;
                isValid = true;
            end
        end

        function isValid = validateTrialPrefixes(app)
            isValid = true;
            clearGuiError(app.TrialPrefixesEditField, app.TaskPrefixesError);
            if isempty(app.trial_prefixes) || all(strcmp(app.trial_prefixes, ""))
                throwGuiWarning("No trial prefixes specified. All trials in the data directory will be used.", ...
                    app.TrialPrefixesEditField, app.TaskPrefixesWarning);
                return
            end
            clearGuiError(app.TrialPrefixesEditField, app.TaskPrefixesWarning);
            if strcmp(app.data_directory, "") || ~exist(app.data_directory, "dir")
                return
            end
            maDataPath = fullfile(app.data_directory, "MAData");
            if ~exist(maDataPath, "dir")
                return
            end
            available = findPrefixesFromSubdirectories(maDataPath);
            invalid = app.trial_prefixes(~ismember(app.trial_prefixes, available));
            if ~isempty(invalid)
                throwGuiError("Trial prefix(es) not found in data directory: " + ...
                    strjoin(invalid, ", "), ...
                    app.TrialPrefixesEditField, app.TaskPrefixesError);
                isValid = false;
            end
        end

        function isValid = validateMtliConfig(app)
            if ~strcmp(app.MuscleTendonLengthInitialization.is_enabled, 'true')
                clearGuiError(app.PassiveDataDirectoryEditField, app.PassiveDataDirectoryError);
                clearGuiError([], app.PassiveDataDirectoryRequired);
                isValid = true;
                return
            end
            passiveDir = app.MuscleTendonLengthInitialization.passive_data_input_directory;
            if strcmp(passiveDir, "")
                clearGuiError(app.PassiveDataDirectoryEditField, app.PassiveDataDirectoryError);
                throwGuiRequired("Passive data directory is required when MTLI is enabled.", ...
                    [], app.PassiveDataDirectoryRequired);
                isValid = false;
            elseif ~exist(passiveDir, "dir")
                clearGuiError([], app.PassiveDataDirectoryRequired);
                throwGuiError("The passive data directory does not exist.", ...
                    app.PassiveDataDirectoryEditField, app.PassiveDataDirectoryError);
                isValid = false;
            else
                clearGuiError(app.PassiveDataDirectoryEditField, app.PassiveDataDirectoryError);
                clearGuiError([], app.PassiveDataDirectoryRequired);
                isValid = true;
            end
        end

        function validateSynergyGroups(app)
            removeStyle(app.SynergyGroupsTable);
            clearGuiError([], app.SynergyGroupsError);
            if isempty(app.synergyGroups) || ...
                    (isstring(app.synergyGroups) && all(strcmp(app.synergyGroups, "")))
                throwGuiRequired("At least one synergy group is required.", ...
                    [], app.SynergyGroupsRequired);
                app.synergyGroupsValid = false;
                return
            end
            clearGuiError([], app.SynergyGroupsRequired);
            isValid = true;
            for i = 1:length(app.RCNLSynergy)
                if isnan(app.RCNLSynergy{i}.num_synergies) || ...
                        app.RCNLSynergy{i}.num_synergies <= 0
                    addStyle(app.SynergyGroupsTable, ...
                        uistyle('BackgroundColor', [1.00 0.67 0.67]), 'row', i);
                    isValid = false;
                end
            end
            if ~isValid
                throwGuiError("Number of synergies must be a valid number " + ...
                    "greater than zero for each synergy set.", ...
                    [], app.SynergyGroupsError);
            end
            app.synergyGroupsValid = isValid;
        end

        function updateRunButton(app)
            trialPrefixesValid = app.validateTrialPrefixes();
            costTermsValid = app.validateNCPCostTermsSilent();
            mtliCostTermsValid = app.validateMtliCostTermsSilent();
            mtliAdvancedSettingsValid = app.validateMtliAdvancedSettingsSilent();
            advancedSettingsValid = app.validateAdvancedSettingsSilent();
            allValid = app.inputModelValid && app.dataDirectoryValid && ...
                app.mtpResultsDirectoryValid && app.ncpResultsDirectoryValid && ...
                app.coordinateListValid && app.synergyGroupsValid && ...
                trialPrefixesValid && app.validateMtliConfig() && ...
                costTermsValid && mtliCostTermsValid && ...
                mtliAdvancedSettingsValid && advancedSettingsValid;
            if allValid
                app.RunButton.Enable = 'on';
            else
                app.RunButton.Enable = 'off';
            end
            app.updateTabControls();
        end

        function updateTabControls(app)
            inputsReady = app.inputModelValid && app.dataDirectoryValid;
            if inputsReady
                app.MuscleGroupsButton.Enable = 'on';
                app.CostTermsButton.Enable = 'on';
            else
                app.MuscleGroupsButton.Enable = 'off';
                app.CostTermsButton.Enable = 'off';
            end
        end
    end

    methods(Access=public)
        function setSelectedObjects(app, objects)
            % Function to assign objects selected by ObjectSelectionWindow
        switch app.objectSelectionType
            case 'coordinate'
                app.coordinate_list = objects;
            case 'activationGroup'
                app.activation_muscle_groups = objects;
            case 'fiberLengthGroup'
                app.normalized_fiber_length_muscle_groups = objects;
            case 'synergyGroup'
                app.synergyGroups = objects;
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
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.MuscleTendonLengthInitialization = MuscleTendonLengthInitializationClass();
            app.makeListeners()
            app.RunButton.Enable = 'off';
            app.MuscleGroupsButton.Enable = 'off';
            app.CostTermsButton.Enable = 'off';
            app.makeDefaultCostTermSet();
            app.initMtli()
            Options = app.advancedSettingNames;
            Values = arrayfun(@(v) app.formatAdvancedValue(v), ...
                app.advancedSettingValues);
            app.AdvancedSettingsTable.Data = table( ...
                Options, Values);
            app.updateMtliCostTermsFields()
            app.formatTabButtons()
        end

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
            % app.currentSettingsFile = fullfile(path, file);
            app.needToSave = false;
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            if strcmp(app.currentSettingsFile, "")
                [file, path] = uiputfile('*.xml', "Save XML Settings File");
                if isequal(file, 0); return; end
                app.currentSettingsFile = fullfile(path, file);
            end
            app.saveSettingsFile(app.currentSettingsFile);
            app.needToSave = false;
            NCPRun(app, app.currentSettingsFile);
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

        % Button pushed function: CostTermsButton
        function CostTermsButtonPushed(app, event)
            app.TabGroup.SelectedTab = app.CostTermsTab;
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
            value = app.InputModelFileEditField.Value;
            if strcmp(value, "")
                app.input_model_file = "";
            else
                app.input_model_file = GetFullPath(value);
            end
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
            value = app.InputOsimxFileEditField.Value;
            if strcmp(value, "")
                app.input_osimx_file = "";
            else
                app.input_osimx_file = GetFullPath(value);
            end
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

        % Value changed function: InputDataEditField
        function InputDataEditFieldValueChanged(app, event)
            value = app.InputDataEditField.Value;
            if strcmp(value, "")
                app.data_directory = "";
            else
                app.data_directory = GetFullPath(value);
            end
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

        % Value changed function: MTPResultsDirEditField
        function MTPResultsDirEditFieldValueChanged(app, event)
            value = app.MTPResultsDirEditField.Value;
            if strcmp(value, "")
                app.mtp_results_directory = "";
            else
                app.mtp_results_directory = GetFullPath(value);
            end
        end

        % Button pushed function: MTPResultsDirSearchButton
        function MTPResultsDirSearchButtonPushed(app, event)
            folder = uigetdir("Select your MTP data folder");
            % User hit "Cancel"
            if isequal(folder, 0)
                return
            end
            app.mtp_results_directory = folder;
        end

        % Value changed function: NCPResultsDirectoryEditField
        function NCPResultsDirectoryEditFieldValueChanged(app, event)
            value = app.NCPResultsDirectoryEditField.Value;
            if strcmp(value, "")
                app.results_directory = "";
            else
                app.results_directory = GetFullPath(value);
            end
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

        % Image clicked function: RcnlLogo
        function RcnlLogoImageClicked(app, event)
            web("https://nmsm.rice.edu/")
        end

        % Cell edit callback: NCPCostTermsTable
        function NCPCostTermsTableCellEdit(app, event)
            indices = event.Indices;
            isEnabled = app.NCPCostTermsTable.Data.isEnabled(indices(1));
            if isEnabled
                app.RCNLCostTerm{indices(1)}. ...
                    is_enabled = 'true';
            else
                app.RCNLCostTerm{indices(1)}. ...
                    is_enabled = 'false';
            end
            app.validateNCPCostTermsSilent();
            app.updateRunButton();
        end

        % Selection changed function: NCPCostTermsTable
        function NCPCostTermsTableSelectionChanged(app, event)
            costTermIndex = app.NCPCostTermsTable.Selection;
            app.NCPMaxAllowableErrorEditField.Value = ...
                app.RCNLCostTerm{costTermIndex}. ...
                max_allowable_error;
            app.validateNCPCostTermsSilent();
        end

        % Value changed function: EnableMTLICheckBox
        function EnableMTLICheckBoxValueChanged(app, event)
            if app.EnableMTLICheckBox.Value
                app.MuscleTendonLengthInitialization.is_enabled = "true";
            else
                app.MuscleTendonLengthInitialization.is_enabled = "false";
            end
            app.updateRunButton();
        end

        % Value changed function: PassiveDataDirectoryEditField
        function PassiveDataDirectoryEditFieldValueChanged(app, event)
            value = app.PassiveDataDirectoryEditField.Value;
            if strcmp(value, "")
                app.MuscleTendonLengthInitialization.passive_data_input_directory = "";
            else
                app.MuscleTendonLengthInitialization.passive_data_input_directory = GetFullPath(value);
            end
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

        % Value changed function: MinNormalizedFiberLengthEditField
        function MinNormalizedFiberLengthEditFieldValueChanged(app, event)
            value = app.MinNormalizedFiberLengthEditField.Value;
            app.MuscleTendonLengthInitialization.min_normalized_muscle_fiber_length = value;
        end

        % Value changed function: MaxNormalizedFiberLengthEditField
        function MaxNormalizedFiberLengthEditFieldValueChanged(app, event)
            value = app.MaxNormalizedFiberLengthEditField.Value;
            app.MuscleTendonLengthInitialization.max_normalized_muscle_fiber_length = value;
        end

        % Cell edit callback: AdvancedSettingsTable
        function AdvancedSettingsTableCellEdit(app, event)
            index = event.Indices(1);

            if isnan(double(convertCharsToStrings(app.AdvancedSettingsTable.Data.Values(index))))
                app.AdvancedSettingsTable.Data.Values(index) = "NaN";
            else
                app.advancedSettingValues(index) = app.AdvancedSettingsTable.Data.Values(index);
            end
            app.validateAdvancedSettingsSilent();
            app.updateRunButton();
        end

        function isValid = validateAdvancedSettingsSilent(app)
            removeStyle(app.AdvancedSettingsTable);
            clearGuiError([], app.AdvancedSettingsError);
            app.AdvancedSettingsTable.Tooltip = '';
            isValid = true;
            data = app.AdvancedSettingsTable.Data;
            if isempty(data)
                return
            end
            messages = string([]);
            for row = 1:height(data)
                if strcmp(data.Values(row), "NaN")
                    addStyle(app.AdvancedSettingsTable, ...
                        uistyle('BackgroundColor', [1.00 0.67 0.67]), 'row', row);
                    messages(end+1) = data.Options(row) + ": must be a valid number";
                    isValid = false;
                end
            end
            if ~isValid
                errorMsg = strjoin(messages, newline);
                app.AdvancedSettingsTable.Tooltip = errorMsg;
                throwGuiError(errorMsg, [], app.AdvancedSettingsError);
            end
        end

        % Value changed function: NCPMaxAllowableErrorEditField
        function NCPMaxAllowableErrorEditFieldValueChanged(app, event)
            costTermIndex = app.NCPCostTermsTable.Selection;
            app.RCNLCostTerm{costTermIndex}.max_allowable_error = ...
                app.NCPMaxAllowableErrorEditField.Value;
            app.validateNCPCostTermsSilent();
            app.updateRunButton();
        end

        % Button pushed function: AddSynergyGroupButton
        function AddSynergyGroupButtonPushed(app, event)
            ObjectSelectionWindow(app, app.model_groups, ...
                app.synergyGroups)
            app.objectSelectionType = 'synergyGroup';
        end

        % Cell edit callback: SynergyGroupsTable
        function SynergyGroupsTableCellEdit(app, event)
            indices = event.Indices;
            newData = event.NewData;
            app.RCNLSynergy{indices(1)}.num_synergies = newData;
            app.validateSynergyGroups();
            app.updateRunButton();
        end

        % Selection changed function: MtliCostTermsTable
        function MtliCostTermsTableSelectionChanged(app, event)
            if isempty(app.MtliCostTermsTable.Selection)
                return
            end
            costTermIndex = app.MtliCostTermsTable.Selection;
            term = app.MuscleTendonLengthInitialization.RCNLCostTerm{costTermIndex};
            app.MtliErrorCenterEditField.Value = term.error_center;
            app.MtliMaxAllowableErrorEditField.Value = term.max_allowable_error;
            if term.uses_error_center
                app.MtliErrorCenterEditField.Enable = 'on';
            else
                app.MtliErrorCenterEditField.Enable = 'off';
            end
            app.validateMtliCostTermsSilent();
        end

        % Value changed function: MtliMaxAllowableErrorEditField
        function MtliMaxAllowableErrorEditFieldValueChanged(app, event)
            app.MuscleTendonLengthInitialization.RCNLCostTerm{ ...
                app.MtliCostTermsTable.Selection}.max_allowable_error = ...
                app.MtliMaxAllowableErrorEditField.Value;
            app.validateMtliCostTermsSilent();
            app.updateRunButton();
        end

        % Value changed function: MtliErrorCenterEditField
        function MtliErrorCenterEditFieldValueChanged(app, event)
            app.MuscleTendonLengthInitialization.RCNLCostTerm{ ...
                app.MtliCostTermsTable.Selection}.error_center = ...
                app.MtliErrorCenterEditField.Value;
        end

        % Cell edit callback: MtliCostTermsTable
        function MtliCostTermsTableCellEdit(app, event)
            indices = event.Indices;
            isEnabled = app.MtliCostTermsTable.Data.isEnabled(indices(1));
            if isEnabled
                app.MuscleTendonLengthInitialization.RCNLCostTerm{indices(1)}. ...
                    is_enabled = "true";
            else
                app.MuscleTendonLengthInitialization.RCNLCostTerm{indices(1)}. ...
                    is_enabled = "false";
            end
            app.validateMtliCostTermsSilent();
            app.updateRunButton();
        end

        % Cell edit callback: MtliAdvancedSettingsTable
        function MtliAdvancedSettingsTableCellEdit(app, event)
            indices = event.Indices;
            app.MuscleTendonLengthInitialization.setParameterValueByIndex(...
                indices(1), app.MtliAdvancedSettingsTable.Data(indices(1), indices(2)).value);
            app.validateMtliAdvancedSettingsSilent();
            app.updateRunButton();
        end

        function loadSettingsFile(app, settingsFileName)
            app.resetAllFields();
            settingsFilePath = fileparts(settingsFileName);
            cd(settingsFilePath);
            app.currentSettingsFile = settingsFileName;
            settingsTree = xml2struct(settingsFileName);
            settingsTree = settingsTree.NMSMPipelineDocument. ...
                NeuralControlPersonalizationTool;
            settingsTree = formatXmlDataForGui(settingsTree);

            fields = fieldnames(settingsTree);
            for i = 1 : length(fields)
                f = fields{i};
                if isprop(app, f) && ~isstruct(settingsTree.(f))
                    app.(f) = settingsTree.(f);
                end
            end
            app.loadAdvancedParams(settingsTree);

            if isfield(settingsTree, 'MuscleTendonLengthInitialization')
                app.MuscleTendonLengthInitialization.loadFromStruct( ...
                    settingsTree.MuscleTendonLengthInitialization);
                app.updateMtliAdvancedSettingsTable();
            end

            if isfield(settingsTree, 'RCNLCostTermSet') && ...
                    isfield(settingsTree.RCNLCostTermSet, 'RCNLCostTerm')
                terms = settingsTree.RCNLCostTermSet.RCNLCostTerm;
                if ~iscell(terms); terms = {terms}; end
                app.RCNLCostTerm = {};
                for i = 1 : length(terms)
                    app.RCNLCostTerm{i} = RCNLCostTermClass(terms{i});
                end
            end

            if isfield(settingsTree, 'RCNLSynergySet') && ...
                    isfield(settingsTree.RCNLSynergySet, 'RCNLSynergy')
                synergies = settingsTree.RCNLSynergySet.RCNLSynergy;
                if ~iscell(synergies); synergies = {synergies}; end
                app.RCNLSynergy = {};
                for i = 1 : length(synergies)
                    app.RCNLSynergy{i} = RCNLSynergyClass(synergies{i});
                end
                names = strings(1, length(app.RCNLSynergy));
                for i = 1 : length(app.RCNLSynergy)
                    names(i) = app.RCNLSynergy{i}.muscle_group_name;
                end
                app.synergyGroups = names;
            end

            app.validateCoordinateList();
            app.validateTrialPrefixes();
            app.validateSynergyGroups();
            app.updateRunButton();
            app.needToSave = false;
        end

        function saveSettingsFile(app, settingsFileName)
            settingsFilePath = fileparts(settingsFileName);
            cd(settingsFilePath);
            app.currentSettingsFile = settingsFileName;
            settingsTree = makeNCPSettingsStruct(app, settingsFileName);
            settingsFileStruct.NMSMPipelineDocument.NeuralControlPersonalizationTool = ...
                settingsTree;
            settingsFileStruct.NMSMPipelineDocument.Attributes.Version = ...
                convertStringsToChars(getPipelineVersion());
            struct2xml(settingsFileStruct, settingsFileName);
        end

        function settingsTree = makeNCPSettingsStruct(app, settingsFileName)
            settingsFilePath = fileparts(settingsFileName);

            settingsTree.input_model_file = getRelativePath( ...
                app.input_model_file, settingsFilePath);
            settingsTree.input_osimx_file = getRelativePath( ...
                app.input_osimx_file, settingsFilePath);
            settingsTree.data_directory = getRelativePath( ...
                app.data_directory, settingsFilePath);
            settingsTree.mtp_results_directory = getRelativePath( ...
                app.mtp_results_directory, settingsFilePath);
            settingsTree.results_directory = getRelativePath( ...
                app.results_directory, settingsFilePath);
            settingsTree.trial_prefixes = app.trial_prefixes;

            settingsTree.coordinate_list = strjoin(app.coordinate_list, " ");
            settingsTree.activation_muscle_groups = strjoin( ...
                app.activation_muscle_groups, " ");
            settingsTree.normalized_fiber_length_muscle_groups = strjoin( ...
                app.normalized_fiber_length_muscle_groups, " ");

            settingsTree.MuscleTendonLengthInitialization = ...
                app.MuscleTendonLengthInitialization.toStruct();
            settingsTree.MuscleTendonLengthInitialization.passive_data_input_directory = ...
                getRelativePath(settingsTree.MuscleTendonLengthInitialization.passive_data_input_directory);

            settingsTree.RCNLCostTermSet = struct("RCNLCostTerm", cell(1));
            for i = 1 : length(app.RCNLCostTerm)
                settingsTree.RCNLCostTermSet.RCNLCostTerm{i} = ...
                    app.RCNLCostTerm{i}.toStruct();
            end

            settingsTree.RCNLSynergySet = struct("RCNLSynergy", cell(1));
            for i = 1 : length(app.RCNLSynergy)
                settingsTree.RCNLSynergySet.RCNLSynergy{i} = ...
                    app.RCNLSynergy{i}.toStruct();
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

        function loadAdvancedParams(app, settingsTree)
            for i = 1 : length(app.advancedSettingNames)
                paramName = app.advancedSettingNames(i);
                if isfield(settingsTree, paramName)
                    app.advancedSettingValues(i) = settingsTree.(paramName);
                end
            end
        end

        function resetAllFields(app)
            app.inputModelValid = false;
            app.dataDirectoryValid = false;
            app.mtpResultsDirectoryValid = false;
            app.ncpResultsDirectoryValid = false;
            app.input_model_file = "";
            app.input_osimx_file = "";
            app.data_directory = "";
            app.mtp_results_directory = "";
            app.results_directory = "";
            app.coordinate_list = [];
            app.trial_prefixes = [];
            app.v_max_factor = 10;

            app.activation_muscle_groups = [];
            app.normalized_fiber_length_muscle_groups = [];

            app.MuscleTendonLengthInitialization = ...
                MuscleTendonLengthInitializationClass();
            app.initMtli();
            app.updateMtliCostTermsFields();
            app.updateEnableMtliBox();
            app.updatePassiveDataDirectory();
            app.maxFiberLengthListenerFunction();
            app.minFiberLengthListenerFunction();
            app.MtliErrorCenterEditField.Value = 0;
            app.MtliMaxAllowableErrorEditField.Value = 0;
            app.makeDefaultCostTermSet();
            app.RCNLSynergy = cell(0);
            app.synergyGroups = string([]);
            app.NCPMaxAllowableErrorEditField.Value = [];

            app.objectSelectionType = "";
            app.currentSettingsFile = "";
            app.needToSave = false;

            app.advancedSettingNames = ...
                ["v_max_factor"
                "max_iterations"
                "max_function_evaluations"
                "step_tolerance"
                "function_tolerance"
                "optimality_tolerance"
                "diff_min_change"];

            app.advancedSettingValues = ...
                [10
                1000
                100000000
                1e-6
                1e-6
                1e-6
                0.0001];
            app.updateRunButton();
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

            % Create NeuralControlModelPersonalizationToolLabel
            app.NeuralControlModelPersonalizationToolLabel = uilabel(app.UIFigure);
            app.NeuralControlModelPersonalizationToolLabel.HorizontalAlignment = 'center';
            app.NeuralControlModelPersonalizationToolLabel.FontSize = 25;
            app.NeuralControlModelPersonalizationToolLabel.FontWeight = 'bold';
            app.NeuralControlModelPersonalizationToolLabel.Position = [1 673 980 40];
            app.NeuralControlModelPersonalizationToolLabel.Text = 'Neural Control Model Personalization Tool';

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
            app.ResultsDirectorySearchButton.Position = [678 308 31 30];
            app.ResultsDirectorySearchButton.Text = '';

            % Create NCPResultsDirectoryEditFieldLabel
            app.NCPResultsDirectoryEditFieldLabel = uilabel(app.InputsTab);
            app.NCPResultsDirectoryEditFieldLabel.HorizontalAlignment = 'right';
            app.NCPResultsDirectoryEditFieldLabel.FontSize = 18;
            app.NCPResultsDirectoryEditFieldLabel.FontWeight = 'bold';
            app.NCPResultsDirectoryEditFieldLabel.Position = [10 308 198 30];
            app.NCPResultsDirectoryEditFieldLabel.Text = 'NCP Results Directory';

            % Create NCPResultsDirectoryEditField
            app.NCPResultsDirectoryEditField = uieditfield(app.InputsTab, 'text');
            app.NCPResultsDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @NCPResultsDirectoryEditFieldValueChanged, true);
            app.NCPResultsDirectoryEditField.Position = [218 308 450 30];

            % Create ResultsDirectoryError
            app.ResultsDirectoryError = uiimage(app.InputsTab);
            app.ResultsDirectoryError.Visible = 'off';
            app.ResultsDirectoryError.Position = [718 308 28 30];
            app.ResultsDirectoryError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ResultsDirectoryWarning
            app.ResultsDirectoryWarning = uiimage(app.InputsTab);
            app.ResultsDirectoryWarning.Visible = 'off';
            app.ResultsDirectoryWarning.Position = [718 308 28 30];
            app.ResultsDirectoryWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create NCPResultsDirRequired
            app.NCPResultsDirRequired = uiimage(app.InputsTab);
            app.NCPResultsDirRequired.Visible = 'on';
            app.NCPResultsDirRequired.Tooltip = 'NCP results directory is required.';
            app.NCPResultsDirRequired.Position = [718 308 28 30];
            app.NCPResultsDirRequired.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'required.png');

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
            app.CoordinatesListTextArea.Position = [218 119 385 160];

            % Create CoordinatesListTextAreaLabel
            app.CoordinatesListTextAreaLabel = uilabel(app.InputsTab);
            app.CoordinatesListTextAreaLabel.HorizontalAlignment = 'right';
            app.CoordinatesListTextAreaLabel.FontSize = 18;
            app.CoordinatesListTextAreaLabel.FontWeight = 'bold';
            app.CoordinatesListTextAreaLabel.Position = [61 188 147 23];
            app.CoordinatesListTextAreaLabel.Text = 'Coordinates List';

            % Create CoordinateListWarning
            app.CoordinateListWarning = uiimage(app.InputsTab);
            app.CoordinateListWarning.Visible = 'on';
            app.CoordinateListWarning.Tooltip = 'At least one coordinate must be selected.';
            app.CoordinateListWarning.Position = [718 184 28 30];
            app.CoordinateListWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'required.png');

            % Create CoordinateListEditButton
            app.CoordinateListEditButton = uibutton(app.InputsTab, 'push');
            app.CoordinateListEditButton.ButtonPushedFcn = createCallbackFcn(app, @CoordinateListEditButtonPushed, true);
            app.CoordinateListEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CoordinateListEditButton.FontSize = 18;
            app.CoordinateListEditButton.FontColor = [1 1 1];
            app.CoordinateListEditButton.Position = [611 184 91 30];
            app.CoordinateListEditButton.Text = 'Edit';

            % Create TrialPrefixesEditFieldLabel
            app.TrialPrefixesEditFieldLabel = uilabel(app.InputsTab);
            app.TrialPrefixesEditFieldLabel.HorizontalAlignment = 'right';
            app.TrialPrefixesEditFieldLabel.FontSize = 18;
            app.TrialPrefixesEditFieldLabel.FontWeight = 'bold';
            app.TrialPrefixesEditFieldLabel.Position = [89 68 117 23];
            app.TrialPrefixesEditFieldLabel.Text = 'Trial Prefixes';

            % Create TrialPrefixesEditField
            app.TrialPrefixesEditField = uieditfield(app.InputsTab, 'text');
            app.TrialPrefixesEditField.ValueChangedFcn = createCallbackFcn(app, @TrialPrefixesEditFieldValueChanged, true);
            app.TrialPrefixesEditField.FontSize = 18;
            app.TrialPrefixesEditField.Position = [218 64 444 30];

            % Create TaskPrefixesWarning
            app.TaskPrefixesWarning = uiimage(app.InputsTab);
            app.TaskPrefixesWarning.Visible = 'off';
            app.TaskPrefixesWarning.Position = [672 65 28 30];
            app.TaskPrefixesWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Create TaskPrefixesError
            app.TaskPrefixesError = uiimage(app.InputsTab);
            app.TaskPrefixesError.Visible = 'off';
            app.TaskPrefixesError.Position = [672 64 28 30];
            app.TaskPrefixesError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MTPResultsDirError
            app.MTPResultsDirError = uiimage(app.InputsTab);
            app.MTPResultsDirError.Visible = 'off';
            app.MTPResultsDirError.Position = [718 360 28 30];
            app.MTPResultsDirError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MTPResultsDirRequired
            app.MTPResultsDirRequired = uiimage(app.InputsTab);
            app.MTPResultsDirRequired.Visible = 'on';
            app.MTPResultsDirRequired.Tooltip = 'MTP results directory is required.';
            app.MTPResultsDirRequired.Position = [718 360 28 30];
            app.MTPResultsDirRequired.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'required.png');

            % Create MTPResultsDirSearchButton
            app.MTPResultsDirSearchButton = uibutton(app.InputsTab, 'push');
            app.MTPResultsDirSearchButton.ButtonPushedFcn = createCallbackFcn(app, @MTPResultsDirSearchButtonPushed, true);
            app.MTPResultsDirSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.MTPResultsDirSearchButton.VerticalAlignment = 'bottom';
            app.MTPResultsDirSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MTPResultsDirSearchButton.Position = [678 360 31 30];
            app.MTPResultsDirSearchButton.Text = '';

            % Create MTPResultsDirEditField
            app.MTPResultsDirEditField = uieditfield(app.InputsTab, 'text');
            app.MTPResultsDirEditField.ValueChangedFcn = createCallbackFcn(app, @MTPResultsDirEditFieldValueChanged, true);
            app.MTPResultsDirEditField.Position = [218 360 450 30];

            % Create MTPResultsDirectoryLabel
            app.MTPResultsDirectoryLabel = uilabel(app.InputsTab);
            app.MTPResultsDirectoryLabel.HorizontalAlignment = 'right';
            app.MTPResultsDirectoryLabel.FontSize = 18;
            app.MTPResultsDirectoryLabel.FontWeight = 'bold';
            app.MTPResultsDirectoryLabel.Position = [10 360 198 30];
            app.MTPResultsDirectoryLabel.Text = 'MTP Results Directory';

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

            % Create CostTermsTab
            app.CostTermsTab = uitab(app.TabGroup);
            app.CostTermsTab.BackgroundColor = [0.851 0.851 0.851];

            % Create NCPCostTermsTable
            app.NCPCostTermsTable = uitable(app.CostTermsTab);
            app.NCPCostTermsTable.ColumnName = {''; 'Cost Term'};
            app.NCPCostTermsTable.ColumnWidth = {30, 'auto'};
            app.NCPCostTermsTable.RowName = {};
            app.NCPCostTermsTable.SelectionType = 'row';
            app.NCPCostTermsTable.ColumnEditable = [true false];
            app.NCPCostTermsTable.RowStriping = 'off';
            app.NCPCostTermsTable.CellEditCallback = createCallbackFcn(app, @NCPCostTermsTableCellEdit, true);
            app.NCPCostTermsTable.SelectionChangedFcn = createCallbackFcn(app, @NCPCostTermsTableSelectionChanged, true);
            app.NCPCostTermsTable.Multiselect = 'off';
            app.NCPCostTermsTable.FontSize = 18;
            app.NCPCostTermsTable.Position = [89 329 590 182];

            % Create MaxAllowableErrorEditField_2Label
            app.MaxAllowableErrorEditField_2Label = uilabel(app.CostTermsTab);
            app.MaxAllowableErrorEditField_2Label.HorizontalAlignment = 'center';
            app.MaxAllowableErrorEditField_2Label.WordWrap = 'on';
            app.MaxAllowableErrorEditField_2Label.FontSize = 18;
            app.MaxAllowableErrorEditField_2Label.FontWeight = 'bold';
            app.MaxAllowableErrorEditField_2Label.Position = [231 276 178 44];
            app.MaxAllowableErrorEditField_2Label.Text = 'Max Allowable Error';

            % Create NCPMaxAllowableErrorEditField
            app.NCPMaxAllowableErrorEditField = uieditfield(app.CostTermsTab, 'numeric');
            app.NCPMaxAllowableErrorEditField.AllowEmpty = 'on';
            app.NCPMaxAllowableErrorEditField.ValueChangedFcn = createCallbackFcn(app, @NCPMaxAllowableErrorEditFieldValueChanged, true);
            app.NCPMaxAllowableErrorEditField.FontSize = 18;
            app.NCPMaxAllowableErrorEditField.FontWeight = 'bold';
            app.NCPMaxAllowableErrorEditField.Position = [424 285 96 26];
            app.NCPMaxAllowableErrorEditField.Value = [];

            % Create SynergyGroupsTable
            app.SynergyGroupsTable = uitable(app.CostTermsTab);
            app.SynergyGroupsTable.ColumnName = {'Synergy Set'; 'Num Synergies'};
            app.SynergyGroupsTable.RowName = {};
            app.SynergyGroupsTable.SelectionType = 'row';
            app.SynergyGroupsTable.ColumnEditable = [false true];
            app.SynergyGroupsTable.RowStriping = 'off';
            app.SynergyGroupsTable.CellEditCallback = createCallbackFcn(app, @SynergyGroupsTableCellEdit, true);
            app.SynergyGroupsTable.Multiselect = 'off';
            app.SynergyGroupsTable.FontSize = 18;
            app.SynergyGroupsTable.Position = [89 28 481 168];

            % Create EditNCPCostTermsLabel
            app.EditNCPCostTermsLabel = uilabel(app.CostTermsTab);
            app.EditNCPCostTermsLabel.HorizontalAlignment = 'center';
            app.EditNCPCostTermsLabel.FontSize = 18;
            app.EditNCPCostTermsLabel.FontWeight = 'bold';
            app.EditNCPCostTermsLabel.Position = [100 524 560 23];
            app.EditNCPCostTermsLabel.Text = 'Edit Cost Terms';

            % Create NCPCostTermsError
            app.NCPCostTermsError = uiimage(app.CostTermsTab);
            app.NCPCostTermsError.Visible = 'off';
            app.NCPCostTermsError.Position = [451 522 28 30];
            app.NCPCostTermsError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create EditSynergySetsLabel
            app.EditSynergySetsLabel = uilabel(app.CostTermsTab);
            app.EditSynergySetsLabel.HorizontalAlignment = 'center';
            app.EditSynergySetsLabel.FontSize = 18;
            app.EditSynergySetsLabel.FontWeight = 'bold';
            app.EditSynergySetsLabel.Position = [89 211 583 23];
            app.EditSynergySetsLabel.Text = 'Edit Synergy Sets';

            % Create AddSynergyGroupButton
            app.AddSynergyGroupButton = uibutton(app.CostTermsTab, 'push');
            app.AddSynergyGroupButton.ButtonPushedFcn = createCallbackFcn(app, @AddSynergyGroupButtonPushed, true);
            app.AddSynergyGroupButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.AddSynergyGroupButton.FontSize = 18;
            app.AddSynergyGroupButton.FontColor = [1 1 1];
            app.AddSynergyGroupButton.Position = [580 97 173 30];
            app.AddSynergyGroupButton.Text = 'Add Synergy Group';

            % Create SynergyGroupsRequired
            app.SynergyGroupsRequired = uiimage(app.CostTermsTab);
            app.SynergyGroupsRequired.Visible = 'on';
            app.SynergyGroupsRequired.Tooltip = 'At least one synergy group is required.';
            app.SynergyGroupsRequired.Position = [460 208 28 28];
            app.SynergyGroupsRequired.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'required.png');

            % Create SynergyGroupsError
            app.SynergyGroupsError = uiimage(app.CostTermsTab);
            app.SynergyGroupsError.Visible = 'off';
            app.SynergyGroupsError.Position = [460 208 28 28];
            app.SynergyGroupsError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create AuxiliaryTab
            app.AuxiliaryTab = uitab(app.TabGroup);
            app.AuxiliaryTab.BackgroundColor = [0.851 0.851 0.851];

            % Create EnableMTLICheckBox
            app.EnableMTLICheckBox = uicheckbox(app.AuxiliaryTab);
            app.EnableMTLICheckBox.ValueChangedFcn = createCallbackFcn(app, @EnableMTLICheckBoxValueChanged, true);
            app.EnableMTLICheckBox.Text = 'Enable Muscle-tendon Length Initialization';
            app.EnableMTLICheckBox.FontSize = 18;
            app.EnableMTLICheckBox.FontWeight = 'bold';
            app.EnableMTLICheckBox.Position = [191 521 393 22];

            % Create PassiveDataDirectoryError
            app.PassiveDataDirectoryError = uiimage(app.AuxiliaryTab);
            app.PassiveDataDirectoryError.Visible = 'off';
            app.PassiveDataDirectoryError.Position = [719 468 28 30];
            app.PassiveDataDirectoryError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create PassiveDataDirectoryRequired
            app.PassiveDataDirectoryRequired = uiimage(app.AuxiliaryTab);
            app.PassiveDataDirectoryRequired.Visible = 'off';
            app.PassiveDataDirectoryRequired.Tooltip = 'Passive data directory is required when MTLI is enabled.';
            app.PassiveDataDirectoryRequired.Position = [719 468 28 30];
            app.PassiveDataDirectoryRequired.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'required.png');

            % Create PassiveDataDirectorySearchButton
            app.PassiveDataDirectorySearchButton = uibutton(app.AuxiliaryTab, 'push');
            app.PassiveDataDirectorySearchButton.ButtonPushedFcn = createCallbackFcn(app, @PassiveDataDirectorySearchButtonPushed, true);
            app.PassiveDataDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.PassiveDataDirectorySearchButton.VerticalAlignment = 'bottom';
            app.PassiveDataDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.PassiveDataDirectorySearchButton.Position = [679 468 31 30];
            app.PassiveDataDirectorySearchButton.Text = '';

            % Create PassiveDataDirectoryEditFieldLabel
            app.PassiveDataDirectoryEditFieldLabel = uilabel(app.AuxiliaryTab);
            app.PassiveDataDirectoryEditFieldLabel.HorizontalAlignment = 'right';
            app.PassiveDataDirectoryEditFieldLabel.FontSize = 18;
            app.PassiveDataDirectoryEditFieldLabel.FontWeight = 'bold';
            app.PassiveDataDirectoryEditFieldLabel.Position = [8 468 201 30];
            app.PassiveDataDirectoryEditFieldLabel.Text = 'Passive Data Directory';

            % Create PassiveDataDirectoryEditField
            app.PassiveDataDirectoryEditField = uieditfield(app.AuxiliaryTab, 'text');
            app.PassiveDataDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @PassiveDataDirectoryEditFieldValueChanged, true);
            app.PassiveDataDirectoryEditField.Position = [219 468 450 30];

            % Create MinNormalizedFiberLengthEditFieldLabel
            app.MinNormalizedFiberLengthEditFieldLabel = uilabel(app.AuxiliaryTab);
            app.MinNormalizedFiberLengthEditFieldLabel.HorizontalAlignment = 'right';
            app.MinNormalizedFiberLengthEditFieldLabel.FontSize = 18;
            app.MinNormalizedFiberLengthEditFieldLabel.FontWeight = 'bold';
            app.MinNormalizedFiberLengthEditFieldLabel.Position = [45 409 254 23];
            app.MinNormalizedFiberLengthEditFieldLabel.Text = 'Min Normalized Fiber Length';

            % Create MinNormalizedFiberLengthEditField
            app.MinNormalizedFiberLengthEditField = uieditfield(app.AuxiliaryTab, 'numeric');
            app.MinNormalizedFiberLengthEditField.Limits = [0 3];
            app.MinNormalizedFiberLengthEditField.ValueChangedFcn = createCallbackFcn(app, @MinNormalizedFiberLengthEditFieldValueChanged, true);
            app.MinNormalizedFiberLengthEditField.FontSize = 18;
            app.MinNormalizedFiberLengthEditField.Position = [313 405 41 30];
            app.MinNormalizedFiberLengthEditField.Value = 0.7;

            % Create MaxNormalizedFiberLengthEditFieldLabel
            app.MaxNormalizedFiberLengthEditFieldLabel = uilabel(app.AuxiliaryTab);
            app.MaxNormalizedFiberLengthEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxNormalizedFiberLengthEditFieldLabel.FontSize = 18;
            app.MaxNormalizedFiberLengthEditFieldLabel.FontWeight = 'bold';
            app.MaxNormalizedFiberLengthEditFieldLabel.Position = [376 409 259 23];
            app.MaxNormalizedFiberLengthEditFieldLabel.Text = 'Max Normalized Fiber Length';

            % Create MaxNormalizedFiberLengthEditField
            app.MaxNormalizedFiberLengthEditField = uieditfield(app.AuxiliaryTab, 'numeric');
            app.MaxNormalizedFiberLengthEditField.Limits = [0 3];
            app.MaxNormalizedFiberLengthEditField.ValueChangedFcn = createCallbackFcn(app, @MaxNormalizedFiberLengthEditFieldValueChanged, true);
            app.MaxNormalizedFiberLengthEditField.FontSize = 18;
            app.MaxNormalizedFiberLengthEditField.Position = [649 405 41 30];
            app.MaxNormalizedFiberLengthEditField.Value = 1;

            % Create AdvancedSettingsLabel
            app.AdvancedSettingsLabel = uilabel(app.AuxiliaryTab);
            app.AdvancedSettingsLabel.FontSize = 18;
            app.AdvancedSettingsLabel.FontWeight = 'bold';
            app.AdvancedSettingsLabel.Position = [502 342 167 23];
            app.AdvancedSettingsLabel.Text = 'Advanced Settings';

            % Create MtliAdvancedSettingsError
            app.MtliAdvancedSettingsError = uiimage(app.AuxiliaryTab);
            app.MtliAdvancedSettingsError.Visible = 'off';
            app.MtliAdvancedSettingsError.Position = [673 340 28 30];
            app.MtliAdvancedSettingsError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

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

            % Create MtliMaxAllowableErrorEditField
            app.MtliMaxAllowableErrorEditField = uieditfield(app.AuxCostTermPanel, 'numeric');
            app.MtliMaxAllowableErrorEditField.ValueChangedFcn = createCallbackFcn(app, @MtliMaxAllowableErrorEditFieldValueChanged, true);
            app.MtliMaxAllowableErrorEditField.FontSize = 18;
            app.MtliMaxAllowableErrorEditField.Position = [135 12 48 24];

            % Create ErrorCenterEditFieldLabel
            app.ErrorCenterEditFieldLabel = uilabel(app.AuxCostTermPanel);
            app.ErrorCenterEditFieldLabel.HorizontalAlignment = 'right';
            app.ErrorCenterEditFieldLabel.FontSize = 18;
            app.ErrorCenterEditFieldLabel.Position = [197 13 104 23];
            app.ErrorCenterEditFieldLabel.Text = 'Error Center';

            % Create MtliErrorCenterEditField
            app.MtliErrorCenterEditField = uieditfield(app.AuxCostTermPanel, 'numeric');
            app.MtliErrorCenterEditField.ValueChangedFcn = createCallbackFcn(app, @MtliErrorCenterEditFieldValueChanged, true);
            app.MtliErrorCenterEditField.FontSize = 18;
            app.MtliErrorCenterEditField.Position = [306 12 48 24];

            % Create MtliCostTermsTable
            app.MtliCostTermsTable = uitable(app.AuxCostTermPanel);
            app.MtliCostTermsTable.ColumnName = {''; 'Cost Term'};
            app.MtliCostTermsTable.ColumnWidth = {30, 'auto'};
            app.MtliCostTermsTable.RowName = {};
            app.MtliCostTermsTable.ColumnSortable = [false true];
            app.MtliCostTermsTable.SelectionType = 'row';
            app.MtliCostTermsTable.ColumnEditable = true;
            app.MtliCostTermsTable.RowStriping = 'off';
            app.MtliCostTermsTable.CellEditCallback = createCallbackFcn(app, @MtliCostTermsTableCellEdit, true);
            app.MtliCostTermsTable.SelectionChangedFcn = createCallbackFcn(app, @MtliCostTermsTableSelectionChanged, true);
            app.MtliCostTermsTable.Multiselect = 'off';
            app.MtliCostTermsTable.FontSize = 15;
            app.MtliCostTermsTable.Position = [0 48 388 274];

            % Create MtliAdvancedSettingsTable
            app.MtliAdvancedSettingsTable = uitable(app.AuxiliaryTab);
            app.MtliAdvancedSettingsTable.ColumnName = {'Parameter'; 'Value'};
            app.MtliAdvancedSettingsTable.RowName = {};
            app.MtliAdvancedSettingsTable.SelectionType = 'row';
            app.MtliAdvancedSettingsTable.ColumnEditable = [false true];
            app.MtliAdvancedSettingsTable.CellEditCallback = createCallbackFcn(app, @MtliAdvancedSettingsTableCellEdit, true);
            app.MtliAdvancedSettingsTable.FontSize = 15;
            app.MtliAdvancedSettingsTable.Position = [418 0 336 323];

            % Create EditCostTermsLabel
            app.EditCostTermsLabel = uilabel(app.AuxiliaryTab);
            app.EditCostTermsLabel.FontSize = 18;
            app.EditCostTermsLabel.FontWeight = 'bold';
            app.EditCostTermsLabel.Position = [131 342 142 23];
            app.EditCostTermsLabel.Text = 'Edit Cost Terms';

            % Create MtliCostTermsError
            app.MtliCostTermsError = uiimage(app.AuxiliaryTab);
            app.MtliCostTermsError.Visible = 'off';
            app.MtliCostTermsError.Position = [277 340 28 30];
            app.MtliCostTermsError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

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
            app.AdvancedSettingsTable.Position = [121 94 528 407];

            % Create AdvancedSettingsError
            app.AdvancedSettingsError = uiimage(app.AdvancedTab);
            app.AdvancedSettingsError.Visible = 'off';
            app.AdvancedSettingsError.Position = [654 499 28 30];
            app.AdvancedSettingsError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create Mask1
            app.Mask1 = uiimage(app.UIFigure);
            app.Mask1.ScaleMethod = 'fill';
            app.Mask1.Position = [211 644 770 30];
            app.Mask1.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'greyMask.png');

            % Create MTPImage
            app.MTPImage = uiimage(app.UIFigure);
            app.MTPImage.Position = [1 193 178 420];
            app.MTPImage.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'ncpFigure.png');

            % Create AdvancedButton
            app.AdvancedButton = uibutton(app.UIFigure, 'push');
            app.AdvancedButton.ButtonPushedFcn = createCallbackFcn(app, @AdvancedButtonPushed, true);
            app.AdvancedButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.AdvancedButton.FontSize = 18;
            app.AdvancedButton.FontColor = [1 1 1];
            app.AdvancedButton.Position = [722 643 100 30];
            app.AdvancedButton.Text = 'Advanced';

            % Create AuxiliaryToolsButton
            app.AuxiliaryToolsButton = uibutton(app.UIFigure, 'push');
            app.AuxiliaryToolsButton.ButtonPushedFcn = createCallbackFcn(app, @AuxiliaryToolsButtonPushed, true);
            app.AuxiliaryToolsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.AuxiliaryToolsButton.FontSize = 18;
            app.AuxiliaryToolsButton.FontColor = [1 1 1];
            app.AuxiliaryToolsButton.Position = [576 643 143 30];
            app.AuxiliaryToolsButton.Text = 'Auxiliary Tools';

            % Create CostTermsButton
            app.CostTermsButton = uibutton(app.UIFigure, 'push');
            app.CostTermsButton.ButtonPushedFcn = createCallbackFcn(app, @CostTermsButtonPushed, true);
            app.CostTermsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CostTermsButton.FontSize = 18;
            app.CostTermsButton.FontColor = [1 1 1];
            app.CostTermsButton.Position = [467 643 106 30];
            app.CostTermsButton.Text = 'Cost Terms';

            % Create MuscleGroupsButton
            app.MuscleGroupsButton = uibutton(app.UIFigure, 'push');
            app.MuscleGroupsButton.ButtonPushedFcn = createCallbackFcn(app, @MuscleGroupsButtonPushed, true);
            app.MuscleGroupsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MuscleGroupsButton.FontSize = 18;
            app.MuscleGroupsButton.FontColor = [1 1 1];
            app.MuscleGroupsButton.Position = [324 643 140 30];
            app.MuscleGroupsButton.Text = 'Muscle Groups';

            % Create InputsButton
            app.InputsButton = uibutton(app.UIFigure, 'push');
            app.InputsButton.ButtonPushedFcn = createCallbackFcn(app, @InputsButtonPushed, true);
            app.InputsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputsButton.FontSize = 18;
            app.InputsButton.FontColor = [1 1 1];
            app.InputsButton.Position = [211 643 110 30];
            app.InputsButton.Text = 'NCP Inputs';

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
            app.RunButton.Enable = 'on';
            app.RunButton.Position = [742 23 90 30];
            app.RunButton.Text = 'Run';

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ResetButton.FontSize = 18;
            app.ResetButton.FontColor = [1 1 1];
            app.ResetButton.Position = [384 23 90 30];
            app.ResetButton.Text = 'Reset';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create RenameMenu
            app.RenameMenu = uimenu(app.ContextMenu);
            app.RenameMenu.Text = 'Rename';

            % Create CopyMenu
            app.CopyMenu = uimenu(app.ContextMenu);
            app.CopyMenu.Text = 'Copy';

            % Create DeleteMenu
            app.DeleteMenu = uimenu(app.ContextMenu);
            app.DeleteMenu.Text = 'Delete';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = NCPBase

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