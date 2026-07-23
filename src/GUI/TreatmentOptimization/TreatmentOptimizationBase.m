classdef TreatmentOptimizationBase_exported < matlab.apps.AppBase

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
        SolverSettingsButton            matlab.ui.control.Button
        ControllersButton               matlab.ui.control.Button
        CostTermsButton                 matlab.ui.control.Button
        ConstraintTermsButton           matlab.ui.control.Button
        AdvancedButton                  matlab.ui.control.Button
        MTPImage                        matlab.ui.control.Image
        Mask1                           matlab.ui.control.Image
        TabGroup                        matlab.ui.container.TabGroup
        InputsTab                       matlab.ui.container.Tab
        ToolSelectionDropDown           matlab.ui.control.DropDown
        ToolSelectionDropDownLabel      matlab.ui.control.Label
        MTPResultsDirectoryLabel        matlab.ui.control.Label
        MTPResultsDirEditField          matlab.ui.control.EditField
        InitialGuessSearchButton        matlab.ui.control.Button
        MTPResultsDirStatus             matlab.ui.control.Image
        TaskPrefixesStatus              matlab.ui.control.Image
        TrialPrefixEditField            matlab.ui.control.EditField
        TrialPrefixEditFieldLabel       matlab.ui.control.Label
        CoordinateListEditButton        matlab.ui.control.Button
        CoordinateListStatus            matlab.ui.control.Image
        StatesCoordinatesListTextAreaLabel  matlab.ui.control.Label
        StatesCoordinatesListTextArea   matlab.ui.control.TextArea
        TrackedQuantitiesDirectoryLabel  matlab.ui.control.Label
        InputDataStatus                 matlab.ui.control.Image
        InputDataEditField              matlab.ui.control.EditField
        TrackedQuantitiesSearchButton   matlab.ui.control.Button
        InputOsimxFileStatus            matlab.ui.control.Image
        InputOsimxFileEditField         matlab.ui.control.EditField
        InputOsimxFileEditFieldLabel    matlab.ui.control.Label
        InputOsimxFileSearchButton      matlab.ui.control.Button
        InputModelFileStatus            matlab.ui.control.Image
        InputModelFileEditField         matlab.ui.control.EditField
        InputModelFileEditFieldLabel    matlab.ui.control.Label
        InputModelFileSearchButton      matlab.ui.control.Button
        ControllersTab                  matlab.ui.container.Tab
        TorqueControlsButton            matlab.ui.control.Button
        SynergyControlsButton           matlab.ui.control.Button
        UserDefinedControlsButton       matlab.ui.control.Button
        Mask1_2                         matlab.ui.control.Image
        ControllersTabGroup             matlab.ui.container.TabGroup
        TorqueTab                       matlab.ui.container.Tab
        TorqueControllerAdvancedSettingsStatus  matlab.ui.control.Image
        TorqueControllerAdvancedSettings  matlab.ui.control.Label
        TorqueAdvancedSettingsTable     matlab.ui.control.Table
        CoordinatesListTextAreaLabel    matlab.ui.control.Label
        TorqueControllerCoordinateList  matlab.ui.control.TextArea
        TorqueControllerCoordianteListStatus  matlab.ui.control.Image
        TorqueControllerCoordinateEditButton  matlab.ui.control.Button
        UseRCNLTorqueControllerCheckBox  matlab.ui.control.CheckBox
        SynergyTab                      matlab.ui.container.Tab
        SurrogateModelAdvancedSettingsStatus  matlab.ui.control.Image
        SurrogateModelAdvancedSettingsLabel  matlab.ui.control.Label
        SurrogateModelAdvancedSettingsTable  matlab.ui.control.Table
        MuscleActivationsFileStatus     matlab.ui.control.Image
        MuscleActivationsFileSearchButton  matlab.ui.control.Button
        MuscleActivationsFileEditField  matlab.ui.control.EditField
        MuscleActivationsFileEditFieldLabel  matlab.ui.control.Label
        SurrogateModelFileNameSearchButton  matlab.ui.control.Button
        SurrogateModelDataDirectorySearchButton  matlab.ui.control.Button
        SurrogateModelFileNameEditField  matlab.ui.control.EditField
        SurrogateModelFileNameEditFieldLabel  matlab.ui.control.Label
        SurrogateModelFileNameStatus    matlab.ui.control.Image
        SurrogateModelDataDirectoryEditField  matlab.ui.control.EditField
        SurrogateModelDataDirectoryEditFieldLabel  matlab.ui.control.Label
        SurrogateModelDataDirectoryStatus  matlab.ui.control.Image
        SynergyControllerAdvancedSettingsStatus  matlab.ui.control.Image
        MuscleControllerAdvancedSettingsStatus  matlab.ui.control.Image
        MuscleControllerAdvancedSettingsLabel  matlab.ui.control.Label
        MuscleControllerAdvancedSettingsTable  matlab.ui.control.Table
        MuscleControllerMuscleList      matlab.ui.control.TextArea
        SurrogateModelCoordinatesListLabel_2  matlab.ui.control.Label
        MuscleControllerMuscleListEditButton  matlab.ui.control.Button
        SynergyControllerAdvancedSettingsLabel  matlab.ui.control.Label
        SynergyControllerAdvancedSettingsTable  matlab.ui.control.Table
        OptimizeSynergyVectorsCheckBox  matlab.ui.control.CheckBox
        SynergyVectorNormalizationMethodDropDown  matlab.ui.control.DropDown
        SynergyVectorNormalizationMethodLabel  matlab.ui.control.Label
        UseRCNLMuscleControllerCheckBox  matlab.ui.control.CheckBox
        SurrogateModelCoordinatesList   matlab.ui.control.TextArea
        SurrogateModelCoordinatesListLabel  matlab.ui.control.Label
        SurrogateModelCoordinatesListStatus  matlab.ui.control.Image
        SurrogateModelCoordinatesListEditButton  matlab.ui.control.Button
        UseRCNLSynergyControllerCheckBox  matlab.ui.control.CheckBox
        UserDefinedTab                  matlab.ui.container.Tab
        CostTermsTab                    matlab.ui.container.Tab
        MiscellaneousCostTermParametersStatus  matlab.ui.control.Image
        MiscellaneousCostTermParametersLabel  matlab.ui.control.Label
        MiscellaneousCostTermParametersTable  matlab.ui.control.Table
        ErrorCenterEditField            matlab.ui.control.NumericEditField
        ErrorCenterEditFieldLabel       matlab.ui.control.Label
        MaxAllowableErrorEditField      matlab.ui.control.NumericEditField
        MaxAllowableErrorEditFieldLabel  matlab.ui.control.Label
        CostTermsListStatus             matlab.ui.control.Image
        CostTermsListLabel              matlab.ui.control.Label
        CostTermComponentListStatus     matlab.ui.control.Image
        CostTermTypeStatus              matlab.ui.control.Image
        CostTermComponentListEditButton  matlab.ui.control.Button
        CostTermComponentListTextArea   matlab.ui.control.TextArea
        ComponentListTextAreaLabel      matlab.ui.control.Label
        CostTermTypeDropDown            matlab.ui.control.DropDown
        CostTermTypeDropDownLabel       matlab.ui.control.Label
        CostTermsListTable              matlab.ui.control.Table
        ConstraintTermsTab              matlab.ui.container.Tab
        MinErrorEditField               matlab.ui.control.NumericEditField
        MinErrorEditFieldLabel          matlab.ui.control.Label
        MaxErrorField                   matlab.ui.control.NumericEditField
        MaxErrroLabel                   matlab.ui.control.Label
        ConstraintTermComponentListEditButton  matlab.ui.control.Button
        ConstraintTermComponentListTextArea  matlab.ui.control.TextArea
        ComponentListTextAreaLabel_2    matlab.ui.control.Label
        ConstraintTermTypeDropDown      matlab.ui.control.DropDown
        ConstraintTermTypeDropDownLabel  matlab.ui.control.Label
        MiscellaneousConstraintTermParametersStatus  matlab.ui.control.Image
        MiscellaneousConstraintTermParametersLabel  matlab.ui.control.Label
        MiscellaneousConstraintTermParametersTable  matlab.ui.control.Table
        ConstraintTermsListStatus       matlab.ui.control.Image
        ConstraintTermsListLabel        matlab.ui.control.Label
        ConstraintTermComponentListStatus  matlab.ui.control.Image
        ConstraintTermTypeStatus        matlab.ui.control.Image
        ConstraintTermsListTable        matlab.ui.control.Table
        SolverSettingsTab               matlab.ui.container.Tab
        AdvancedTab                     matlab.ui.container.Tab
        MiscellaneousCostTermParametersStatus_2  matlab.ui.control.Image
        AdvancedParamsTable             matlab.ui.control.Table
        TreatmentOptimizationLabel      matlab.ui.control.Label
        ContextMenu                     matlab.ui.container.ContextMenu
        RenameMenu                      matlab.ui.container.Menu
        CopyMenu                        matlab.ui.container.Menu
        DeleteMenu                      matlab.ui.container.Menu
    end

    
    properties (Access = private, SetObservable)
        
    end

    properties(Access = private)  % listner properties

    end

    methods (Access = private) % listener methods
        function makeListeners(app)
            
        end

        function formatTabButtons(app) % good
            
        end
    end

    methods(Access=public)
        
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)

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
            
        end

        % Button pushed function: HelpButton
        function HelpButtonPushed(app, event)
            web("https://nmsm.rice.edu/guides-and-publications/tool-overviews/model-personalization/muscle-tendon-personalization/")
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
            app.UIFigure.Position = [500 500 980 961];
            app.UIFigure.Name = 'MATLAB App';

            % Create TreatmentOptimizationLabel
            app.TreatmentOptimizationLabel = uilabel(app.UIFigure);
            app.TreatmentOptimizationLabel.HorizontalAlignment = 'center';
            app.TreatmentOptimizationLabel.FontSize = 25;
            app.TreatmentOptimizationLabel.FontWeight = 'bold';
            app.TreatmentOptimizationLabel.Position = [1 922 978 40];
            app.TreatmentOptimizationLabel.Text = 'Treatment Optimization';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [211 73 770 843];

            % Create InputsTab
            app.InputsTab = uitab(app.TabGroup);
            app.InputsTab.BackgroundColor = [0.851 0.851 0.851];
            app.InputsTab.ForegroundColor = [0 0 0];

            % Create InputModelFileSearchButton
            app.InputModelFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputModelFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputModelFileSearchButton.VerticalAlignment = 'bottom';
            app.InputModelFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputModelFileSearchButton.Position = [678 651 31 30];
            app.InputModelFileSearchButton.Text = '';

            % Create InputModelFileEditFieldLabel
            app.InputModelFileEditFieldLabel = uilabel(app.InputsTab);
            app.InputModelFileEditFieldLabel.HorizontalAlignment = 'right';
            app.InputModelFileEditFieldLabel.FontSize = 18;
            app.InputModelFileEditFieldLabel.FontWeight = 'bold';
            app.InputModelFileEditFieldLabel.Position = [68 651 140 30];
            app.InputModelFileEditFieldLabel.Text = 'Input Model File';

            % Create InputModelFileEditField
            app.InputModelFileEditField = uieditfield(app.InputsTab, 'text');
            app.InputModelFileEditField.Position = [218 651 450 30];

            % Create InputModelFileStatus
            app.InputModelFileStatus = uiimage(app.InputsTab);
            app.InputModelFileStatus.Visible = 'off';
            app.InputModelFileStatus.Position = [718 651 28 30];
            app.InputModelFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputOsimxFileSearchButton
            app.InputOsimxFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputOsimxFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputOsimxFileSearchButton.VerticalAlignment = 'bottom';
            app.InputOsimxFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputOsimxFileSearchButton.Position = [678 602 31 30];
            app.InputOsimxFileSearchButton.Text = '';

            % Create InputOsimxFileEditFieldLabel
            app.InputOsimxFileEditFieldLabel = uilabel(app.InputsTab);
            app.InputOsimxFileEditFieldLabel.HorizontalAlignment = 'right';
            app.InputOsimxFileEditFieldLabel.FontSize = 18;
            app.InputOsimxFileEditFieldLabel.FontWeight = 'bold';
            app.InputOsimxFileEditFieldLabel.Position = [63 602 145 30];
            app.InputOsimxFileEditFieldLabel.Text = 'Input Osimx File';

            % Create InputOsimxFileEditField
            app.InputOsimxFileEditField = uieditfield(app.InputsTab, 'text');
            app.InputOsimxFileEditField.Position = [218 602 450 30];

            % Create InputOsimxFileStatus
            app.InputOsimxFileStatus = uiimage(app.InputsTab);
            app.InputOsimxFileStatus.Visible = 'off';
            app.InputOsimxFileStatus.Position = [718 602 28 30];
            app.InputOsimxFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create TrackedQuantitiesSearchButton
            app.TrackedQuantitiesSearchButton = uibutton(app.InputsTab, 'push');
            app.TrackedQuantitiesSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.TrackedQuantitiesSearchButton.VerticalAlignment = 'bottom';
            app.TrackedQuantitiesSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.TrackedQuantitiesSearchButton.Position = [678 552 31 30];
            app.TrackedQuantitiesSearchButton.Text = '';

            % Create InputDataEditField
            app.InputDataEditField = uieditfield(app.InputsTab, 'text');
            app.InputDataEditField.Position = [218 552 450 30];

            % Create InputDataStatus
            app.InputDataStatus = uiimage(app.InputsTab);
            app.InputDataStatus.Visible = 'off';
            app.InputDataStatus.Position = [718 552 28 30];
            app.InputDataStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create TrackedQuantitiesDirectoryLabel
            app.TrackedQuantitiesDirectoryLabel = uilabel(app.InputsTab);
            app.TrackedQuantitiesDirectoryLabel.HorizontalAlignment = 'right';
            app.TrackedQuantitiesDirectoryLabel.FontSize = 18;
            app.TrackedQuantitiesDirectoryLabel.FontWeight = 'bold';
            app.TrackedQuantitiesDirectoryLabel.Position = [38 545 168 44];
            app.TrackedQuantitiesDirectoryLabel.Text = {'Tracked Quantities'; 'Directory'};

            % Create StatesCoordinatesListTextArea
            app.StatesCoordinatesListTextArea = uitextarea(app.InputsTab);
            app.StatesCoordinatesListTextArea.Editable = 'off';
            app.StatesCoordinatesListTextArea.FontSize = 18;
            app.StatesCoordinatesListTextArea.Position = [219 275 385 160];

            % Create StatesCoordinatesListTextAreaLabel
            app.StatesCoordinatesListTextAreaLabel = uilabel(app.InputsTab);
            app.StatesCoordinatesListTextAreaLabel.HorizontalAlignment = 'right';
            app.StatesCoordinatesListTextAreaLabel.FontSize = 18;
            app.StatesCoordinatesListTextAreaLabel.FontWeight = 'bold';
            app.StatesCoordinatesListTextAreaLabel.Position = [2 344 207 23];
            app.StatesCoordinatesListTextAreaLabel.Text = 'States Coordinates List';

            % Create CoordinateListStatus
            app.CoordinateListStatus = uiimage(app.InputsTab);
            app.CoordinateListStatus.Visible = 'off';
            app.CoordinateListStatus.Position = [719 340 28 30];
            app.CoordinateListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create CoordinateListEditButton
            app.CoordinateListEditButton = uibutton(app.InputsTab, 'push');
            app.CoordinateListEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CoordinateListEditButton.FontSize = 18;
            app.CoordinateListEditButton.FontColor = [1 1 1];
            app.CoordinateListEditButton.Position = [612 340 91 30];
            app.CoordinateListEditButton.Text = 'Edit';

            % Create TrialPrefixEditFieldLabel
            app.TrialPrefixEditFieldLabel = uilabel(app.InputsTab);
            app.TrialPrefixEditFieldLabel.HorizontalAlignment = 'right';
            app.TrialPrefixEditFieldLabel.FontSize = 18;
            app.TrialPrefixEditFieldLabel.FontWeight = 'bold';
            app.TrialPrefixEditFieldLabel.Position = [110 458 97 23];
            app.TrialPrefixEditFieldLabel.Text = 'Trial Prefix';

            % Create TrialPrefixEditField
            app.TrialPrefixEditField = uieditfield(app.InputsTab, 'text');
            app.TrialPrefixEditField.FontSize = 18;
            app.TrialPrefixEditField.Position = [219 454 450 30];

            % Create TaskPrefixesStatus
            app.TaskPrefixesStatus = uiimage(app.InputsTab);
            app.TaskPrefixesStatus.Visible = 'off';
            app.TaskPrefixesStatus.Position = [680 454 28 30];
            app.TaskPrefixesStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MTPResultsDirStatus
            app.MTPResultsDirStatus = uiimage(app.InputsTab);
            app.MTPResultsDirStatus.Visible = 'off';
            app.MTPResultsDirStatus.Position = [719 503 28 30];
            app.MTPResultsDirStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InitialGuessSearchButton
            app.InitialGuessSearchButton = uibutton(app.InputsTab, 'push');
            app.InitialGuessSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InitialGuessSearchButton.VerticalAlignment = 'bottom';
            app.InitialGuessSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InitialGuessSearchButton.Position = [679 503 31 30];
            app.InitialGuessSearchButton.Text = '';

            % Create MTPResultsDirEditField
            app.MTPResultsDirEditField = uieditfield(app.InputsTab, 'text');
            app.MTPResultsDirEditField.Position = [219 503 450 30];

            % Create MTPResultsDirectoryLabel
            app.MTPResultsDirectoryLabel = uilabel(app.InputsTab);
            app.MTPResultsDirectoryLabel.HorizontalAlignment = 'right';
            app.MTPResultsDirectoryLabel.FontSize = 18;
            app.MTPResultsDirectoryLabel.FontWeight = 'bold';
            app.MTPResultsDirectoryLabel.Position = [11 503 198 30];
            app.MTPResultsDirectoryLabel.Text = 'Initial Guess Directory';

            % Create ToolSelectionDropDownLabel
            app.ToolSelectionDropDownLabel = uilabel(app.InputsTab);
            app.ToolSelectionDropDownLabel.HorizontalAlignment = 'right';
            app.ToolSelectionDropDownLabel.FontSize = 24;
            app.ToolSelectionDropDownLabel.FontWeight = 'bold';
            app.ToolSelectionDropDownLabel.Position = [41 761 167 32];
            app.ToolSelectionDropDownLabel.Text = 'Tool Selection';

            % Create ToolSelectionDropDown
            app.ToolSelectionDropDown = uidropdown(app.InputsTab);
            app.ToolSelectionDropDown.Items = {'Tracking Optimization', 'Verification Optimization', 'Design Optimization'};
            app.ToolSelectionDropDown.FontSize = 20;
            app.ToolSelectionDropDown.FontWeight = 'bold';
            app.ToolSelectionDropDown.Position = [219 758 449 36];
            app.ToolSelectionDropDown.Value = 'Tracking Optimization';

            % Create ControllersTab
            app.ControllersTab = uitab(app.TabGroup);
            app.ControllersTab.BackgroundColor = [0.851 0.851 0.851];

            % Create ControllersTabGroup
            app.ControllersTabGroup = uitabgroup(app.ControllersTab);
            app.ControllersTabGroup.Position = [0 1 769 818];

            % Create TorqueTab
            app.TorqueTab = uitab(app.ControllersTabGroup);
            app.TorqueTab.Title = 'Tab';
            app.TorqueTab.BackgroundColor = [0.851 0.851 0.851];

            % Create UseRCNLTorqueControllerCheckBox
            app.UseRCNLTorqueControllerCheckBox = uicheckbox(app.TorqueTab);
            app.UseRCNLTorqueControllerCheckBox.Text = 'Use RCNL Torque Controller';
            app.UseRCNLTorqueControllerCheckBox.FontSize = 18;
            app.UseRCNLTorqueControllerCheckBox.FontWeight = 'bold';
            app.UseRCNLTorqueControllerCheckBox.Position = [260 739 268 22];

            % Create TorqueControllerCoordinateEditButton
            app.TorqueControllerCoordinateEditButton = uibutton(app.TorqueTab, 'push');
            app.TorqueControllerCoordinateEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.TorqueControllerCoordinateEditButton.FontSize = 18;
            app.TorqueControllerCoordinateEditButton.FontColor = [1 1 1];
            app.TorqueControllerCoordinateEditButton.Position = [552 622 91 30];
            app.TorqueControllerCoordinateEditButton.Text = 'Edit';

            % Create TorqueControllerCoordianteListStatus
            app.TorqueControllerCoordianteListStatus = uiimage(app.TorqueTab);
            app.TorqueControllerCoordianteListStatus.Visible = 'off';
            app.TorqueControllerCoordianteListStatus.Position = [659 622 28 30];
            app.TorqueControllerCoordianteListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create TorqueControllerCoordinateList
            app.TorqueControllerCoordinateList = uitextarea(app.TorqueTab);
            app.TorqueControllerCoordinateList.Editable = 'off';
            app.TorqueControllerCoordinateList.FontSize = 18;
            app.TorqueControllerCoordinateList.Position = [159 557 385 160];

            % Create CoordinatesListTextAreaLabel
            app.CoordinatesListTextAreaLabel = uilabel(app.TorqueTab);
            app.CoordinatesListTextAreaLabel.HorizontalAlignment = 'right';
            app.CoordinatesListTextAreaLabel.FontSize = 18;
            app.CoordinatesListTextAreaLabel.FontWeight = 'bold';
            app.CoordinatesListTextAreaLabel.Position = [2 626 147 23];
            app.CoordinatesListTextAreaLabel.Text = 'Coordinates List';

            % Create TorqueAdvancedSettingsTable
            app.TorqueAdvancedSettingsTable = uitable(app.TorqueTab);
            app.TorqueAdvancedSettingsTable.ColumnName = {'Parameter'; 'Value'};
            app.TorqueAdvancedSettingsTable.RowName = {};
            app.TorqueAdvancedSettingsTable.SelectionType = 'row';
            app.TorqueAdvancedSettingsTable.ColumnEditable = [false true];
            app.TorqueAdvancedSettingsTable.FontSize = 15;
            app.TorqueAdvancedSettingsTable.Position = [160 278 385 208];

            % Create TorqueControllerAdvancedSettings
            app.TorqueControllerAdvancedSettings = uilabel(app.TorqueTab);
            app.TorqueControllerAdvancedSettings.HorizontalAlignment = 'right';
            app.TorqueControllerAdvancedSettings.FontSize = 18;
            app.TorqueControllerAdvancedSettings.FontWeight = 'bold';
            app.TorqueControllerAdvancedSettings.Position = [58 360 91 44];
            app.TorqueControllerAdvancedSettings.Text = {'Advanced'; 'Settings'};

            % Create TorqueControllerAdvancedSettingsStatus
            app.TorqueControllerAdvancedSettingsStatus = uiimage(app.TorqueTab);
            app.TorqueControllerAdvancedSettingsStatus.Visible = 'off';
            app.TorqueControllerAdvancedSettingsStatus.Position = [560 367 28 30];
            app.TorqueControllerAdvancedSettingsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SynergyTab
            app.SynergyTab = uitab(app.ControllersTabGroup);
            app.SynergyTab.Title = 'Tab2';
            app.SynergyTab.BackgroundColor = [0.851 0.851 0.851];

            % Create UseRCNLSynergyControllerCheckBox
            app.UseRCNLSynergyControllerCheckBox = uicheckbox(app.SynergyTab);
            app.UseRCNLSynergyControllerCheckBox.Text = 'Use RCNL Synergy Controller';
            app.UseRCNLSynergyControllerCheckBox.FontSize = 18;
            app.UseRCNLSynergyControllerCheckBox.FontWeight = 'bold';
            app.UseRCNLSynergyControllerCheckBox.Position = [24 757 280 22];

            % Create SurrogateModelCoordinatesListEditButton
            app.SurrogateModelCoordinatesListEditButton = uibutton(app.SynergyTab, 'push');
            app.SurrogateModelCoordinatesListEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SurrogateModelCoordinatesListEditButton.FontSize = 18;
            app.SurrogateModelCoordinatesListEditButton.FontColor = [1 1 1];
            app.SurrogateModelCoordinatesListEditButton.Position = [587 385 91 30];
            app.SurrogateModelCoordinatesListEditButton.Text = 'Edit';

            % Create SurrogateModelCoordinatesListStatus
            app.SurrogateModelCoordinatesListStatus = uiimage(app.SynergyTab);
            app.SurrogateModelCoordinatesListStatus.Visible = 'off';
            app.SurrogateModelCoordinatesListStatus.Position = [693 392 28 30];
            app.SurrogateModelCoordinatesListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SurrogateModelCoordinatesListLabel
            app.SurrogateModelCoordinatesListLabel = uilabel(app.SynergyTab);
            app.SurrogateModelCoordinatesListLabel.HorizontalAlignment = 'right';
            app.SurrogateModelCoordinatesListLabel.FontSize = 18;
            app.SurrogateModelCoordinatesListLabel.FontWeight = 'bold';
            app.SurrogateModelCoordinatesListLabel.Position = [35 385 147 44];
            app.SurrogateModelCoordinatesListLabel.Text = {'Surrogate Model'; 'Coordinates List'};

            % Create SurrogateModelCoordinatesList
            app.SurrogateModelCoordinatesList = uitextarea(app.SynergyTab);
            app.SurrogateModelCoordinatesList.Editable = 'off';
            app.SurrogateModelCoordinatesList.FontSize = 18;
            app.SurrogateModelCoordinatesList.Position = [192 365 385 84];

            % Create UseRCNLMuscleControllerCheckBox
            app.UseRCNLMuscleControllerCheckBox = uicheckbox(app.SynergyTab);
            app.UseRCNLMuscleControllerCheckBox.Text = 'Use RCNL Muscle Controller';
            app.UseRCNLMuscleControllerCheckBox.FontSize = 18;
            app.UseRCNLMuscleControllerCheckBox.FontWeight = 'bold';
            app.UseRCNLMuscleControllerCheckBox.Position = [451 757 270 22];

            % Create SynergyVectorNormalizationMethodLabel
            app.SynergyVectorNormalizationMethodLabel = uilabel(app.SynergyTab);
            app.SynergyVectorNormalizationMethodLabel.HorizontalAlignment = 'right';
            app.SynergyVectorNormalizationMethodLabel.FontSize = 18;
            app.SynergyVectorNormalizationMethodLabel.FontWeight = 'bold';
            app.SynergyVectorNormalizationMethodLabel.Position = [15 660 199 44];
            app.SynergyVectorNormalizationMethodLabel.Text = {'Synergy Vector '; 'Normalization Method '};

            % Create SynergyVectorNormalizationMethodDropDown
            app.SynergyVectorNormalizationMethodDropDown = uidropdown(app.SynergyTab);
            app.SynergyVectorNormalizationMethodDropDown.Items = {'Sum', 'Magnitude'};
            app.SynergyVectorNormalizationMethodDropDown.FontSize = 18;
            app.SynergyVectorNormalizationMethodDropDown.FontWeight = 'bold';
            app.SynergyVectorNormalizationMethodDropDown.Position = [223 669 123 24];
            app.SynergyVectorNormalizationMethodDropDown.Value = 'Magnitude';

            % Create OptimizeSynergyVectorsCheckBox
            app.OptimizeSynergyVectorsCheckBox = uicheckbox(app.SynergyTab);
            app.OptimizeSynergyVectorsCheckBox.Text = 'Optimize Synergy Vectors';
            app.OptimizeSynergyVectorsCheckBox.FontSize = 18;
            app.OptimizeSynergyVectorsCheckBox.FontWeight = 'bold';
            app.OptimizeSynergyVectorsCheckBox.Position = [24 715 246 22];

            % Create SynergyControllerAdvancedSettingsTable
            app.SynergyControllerAdvancedSettingsTable = uitable(app.SynergyTab);
            app.SynergyControllerAdvancedSettingsTable.ColumnName = {'Parameter'; 'Value'};
            app.SynergyControllerAdvancedSettingsTable.RowName = {};
            app.SynergyControllerAdvancedSettingsTable.SelectionType = 'row';
            app.SynergyControllerAdvancedSettingsTable.ColumnEditable = [false true];
            app.SynergyControllerAdvancedSettingsTable.FontSize = 15;
            app.SynergyControllerAdvancedSettingsTable.Position = [11 470 346 146];

            % Create SynergyControllerAdvancedSettingsLabel
            app.SynergyControllerAdvancedSettingsLabel = uilabel(app.SynergyTab);
            app.SynergyControllerAdvancedSettingsLabel.HorizontalAlignment = 'right';
            app.SynergyControllerAdvancedSettingsLabel.FontSize = 18;
            app.SynergyControllerAdvancedSettingsLabel.FontWeight = 'bold';
            app.SynergyControllerAdvancedSettingsLabel.Position = [85 623 167 23];
            app.SynergyControllerAdvancedSettingsLabel.Text = 'Advanced Settings';

            % Create MuscleControllerMuscleListEditButton
            app.MuscleControllerMuscleListEditButton = uibutton(app.SynergyTab, 'push');
            app.MuscleControllerMuscleListEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MuscleControllerMuscleListEditButton.FontSize = 18;
            app.MuscleControllerMuscleListEditButton.FontColor = [1 1 1];
            app.MuscleControllerMuscleListEditButton.Position = [670 672 91 30];
            app.MuscleControllerMuscleListEditButton.Text = 'Edit';

            % Create SurrogateModelCoordinatesListLabel_2
            app.SurrogateModelCoordinatesListLabel_2 = uilabel(app.SynergyTab);
            app.SurrogateModelCoordinatesListLabel_2.HorizontalAlignment = 'right';
            app.SurrogateModelCoordinatesListLabel_2.FontSize = 18;
            app.SurrogateModelCoordinatesListLabel_2.FontWeight = 'bold';
            app.SurrogateModelCoordinatesListLabel_2.Position = [503 728 103 23];
            app.SurrogateModelCoordinatesListLabel_2.Text = 'Muscle List';

            % Create MuscleControllerMuscleList
            app.MuscleControllerMuscleList = uitextarea(app.SynergyTab);
            app.MuscleControllerMuscleList.Editable = 'off';
            app.MuscleControllerMuscleList.FontSize = 18;
            app.MuscleControllerMuscleList.Position = [447 648 215 78];

            % Create MuscleControllerAdvancedSettingsTable
            app.MuscleControllerAdvancedSettingsTable = uitable(app.SynergyTab);
            app.MuscleControllerAdvancedSettingsTable.ColumnName = {'Parameter'; 'Value'};
            app.MuscleControllerAdvancedSettingsTable.RowName = {};
            app.MuscleControllerAdvancedSettingsTable.SelectionType = 'row';
            app.MuscleControllerAdvancedSettingsTable.ColumnEditable = [false true];
            app.MuscleControllerAdvancedSettingsTable.FontSize = 15;
            app.MuscleControllerAdvancedSettingsTable.Position = [394 470 365 146];

            % Create MuscleControllerAdvancedSettingsLabel
            app.MuscleControllerAdvancedSettingsLabel = uilabel(app.SynergyTab);
            app.MuscleControllerAdvancedSettingsLabel.HorizontalAlignment = 'right';
            app.MuscleControllerAdvancedSettingsLabel.FontSize = 18;
            app.MuscleControllerAdvancedSettingsLabel.FontWeight = 'bold';
            app.MuscleControllerAdvancedSettingsLabel.Position = [477 623 167 23];
            app.MuscleControllerAdvancedSettingsLabel.Text = 'Advanced Settings';

            % Create MuscleControllerAdvancedSettingsStatus
            app.MuscleControllerAdvancedSettingsStatus = uiimage(app.SynergyTab);
            app.MuscleControllerAdvancedSettingsStatus.Visible = 'off';
            app.MuscleControllerAdvancedSettingsStatus.Position = [654 619 28 30];
            app.MuscleControllerAdvancedSettingsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SynergyControllerAdvancedSettingsStatus
            app.SynergyControllerAdvancedSettingsStatus = uiimage(app.SynergyTab);
            app.SynergyControllerAdvancedSettingsStatus.Visible = 'off';
            app.SynergyControllerAdvancedSettingsStatus.Position = [260 619 28 30];
            app.SynergyControllerAdvancedSettingsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SurrogateModelDataDirectoryStatus
            app.SurrogateModelDataDirectoryStatus = uiimage(app.SynergyTab);
            app.SurrogateModelDataDirectoryStatus.Visible = 'off';
            app.SurrogateModelDataDirectoryStatus.Position = [691 314 28 30];
            app.SurrogateModelDataDirectoryStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SurrogateModelDataDirectoryEditFieldLabel
            app.SurrogateModelDataDirectoryEditFieldLabel = uilabel(app.SynergyTab);
            app.SurrogateModelDataDirectoryEditFieldLabel.HorizontalAlignment = 'right';
            app.SurrogateModelDataDirectoryEditFieldLabel.FontSize = 18;
            app.SurrogateModelDataDirectoryEditFieldLabel.FontWeight = 'bold';
            app.SurrogateModelDataDirectoryEditFieldLabel.Position = [35 307 147 44];
            app.SurrogateModelDataDirectoryEditFieldLabel.Text = {'Surrogate Model'; 'Data Directory'};

            % Create SurrogateModelDataDirectoryEditField
            app.SurrogateModelDataDirectoryEditField = uieditfield(app.SynergyTab, 'text');
            app.SurrogateModelDataDirectoryEditField.HorizontalAlignment = 'center';
            app.SurrogateModelDataDirectoryEditField.Position = [192 314 450 30];

            % Create SurrogateModelFileNameStatus
            app.SurrogateModelFileNameStatus = uiimage(app.SynergyTab);
            app.SurrogateModelFileNameStatus.Visible = 'off';
            app.SurrogateModelFileNameStatus.Position = [692 261 28 30];
            app.SurrogateModelFileNameStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SurrogateModelFileNameEditFieldLabel
            app.SurrogateModelFileNameEditFieldLabel = uilabel(app.SynergyTab);
            app.SurrogateModelFileNameEditFieldLabel.HorizontalAlignment = 'right';
            app.SurrogateModelFileNameEditFieldLabel.FontSize = 18;
            app.SurrogateModelFileNameEditFieldLabel.FontWeight = 'bold';
            app.SurrogateModelFileNameEditFieldLabel.Position = [36 254 147 44];
            app.SurrogateModelFileNameEditFieldLabel.Text = {'Surrogate Model'; 'File Name'};

            % Create SurrogateModelFileNameEditField
            app.SurrogateModelFileNameEditField = uieditfield(app.SynergyTab, 'text');
            app.SurrogateModelFileNameEditField.Position = [193 261 450 30];

            % Create SurrogateModelDataDirectorySearchButton
            app.SurrogateModelDataDirectorySearchButton = uibutton(app.SynergyTab, 'push');
            app.SurrogateModelDataDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.SurrogateModelDataDirectorySearchButton.VerticalAlignment = 'bottom';
            app.SurrogateModelDataDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SurrogateModelDataDirectorySearchButton.Position = [655 314 31 30];
            app.SurrogateModelDataDirectorySearchButton.Text = '';

            % Create SurrogateModelFileNameSearchButton
            app.SurrogateModelFileNameSearchButton = uibutton(app.SynergyTab, 'push');
            app.SurrogateModelFileNameSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.SurrogateModelFileNameSearchButton.VerticalAlignment = 'bottom';
            app.SurrogateModelFileNameSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SurrogateModelFileNameSearchButton.Position = [656 261 31 30];
            app.SurrogateModelFileNameSearchButton.Text = '';

            % Create MuscleActivationsFileEditFieldLabel
            app.MuscleActivationsFileEditFieldLabel = uilabel(app.SynergyTab);
            app.MuscleActivationsFileEditFieldLabel.HorizontalAlignment = 'right';
            app.MuscleActivationsFileEditFieldLabel.FontSize = 18;
            app.MuscleActivationsFileEditFieldLabel.FontWeight = 'bold';
            app.MuscleActivationsFileEditFieldLabel.Position = [17 204 167 44];
            app.MuscleActivationsFileEditFieldLabel.Text = {'Muscle Activations'; 'File'};

            % Create MuscleActivationsFileEditField
            app.MuscleActivationsFileEditField = uieditfield(app.SynergyTab, 'text');
            app.MuscleActivationsFileEditField.Position = [194 211 450 30];

            % Create MuscleActivationsFileSearchButton
            app.MuscleActivationsFileSearchButton = uibutton(app.SynergyTab, 'push');
            app.MuscleActivationsFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.MuscleActivationsFileSearchButton.VerticalAlignment = 'bottom';
            app.MuscleActivationsFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MuscleActivationsFileSearchButton.Position = [657 211 31 30];
            app.MuscleActivationsFileSearchButton.Text = '';

            % Create MuscleActivationsFileStatus
            app.MuscleActivationsFileStatus = uiimage(app.SynergyTab);
            app.MuscleActivationsFileStatus.Visible = 'off';
            app.MuscleActivationsFileStatus.Position = [693 211 28 30];
            app.MuscleActivationsFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create SurrogateModelAdvancedSettingsTable
            app.SurrogateModelAdvancedSettingsTable = uitable(app.SynergyTab);
            app.SurrogateModelAdvancedSettingsTable.ColumnName = {'Parameter'; 'Value'};
            app.SurrogateModelAdvancedSettingsTable.RowName = {};
            app.SurrogateModelAdvancedSettingsTable.SelectionType = 'row';
            app.SurrogateModelAdvancedSettingsTable.ColumnEditable = [false true];
            app.SurrogateModelAdvancedSettingsTable.FontSize = 15;
            app.SurrogateModelAdvancedSettingsTable.Position = [215 23 365 146];

            % Create SurrogateModelAdvancedSettingsLabel
            app.SurrogateModelAdvancedSettingsLabel = uilabel(app.SynergyTab);
            app.SurrogateModelAdvancedSettingsLabel.HorizontalAlignment = 'right';
            app.SurrogateModelAdvancedSettingsLabel.FontSize = 18;
            app.SurrogateModelAdvancedSettingsLabel.FontWeight = 'bold';
            app.SurrogateModelAdvancedSettingsLabel.Position = [298 176 167 23];
            app.SurrogateModelAdvancedSettingsLabel.Text = 'Advanced Settings';

            % Create SurrogateModelAdvancedSettingsStatus
            app.SurrogateModelAdvancedSettingsStatus = uiimage(app.SynergyTab);
            app.SurrogateModelAdvancedSettingsStatus.Visible = 'off';
            app.SurrogateModelAdvancedSettingsStatus.Position = [475 172 28 30];
            app.SurrogateModelAdvancedSettingsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create UserDefinedTab
            app.UserDefinedTab = uitab(app.ControllersTabGroup);
            app.UserDefinedTab.Title = 'Tab4';
            app.UserDefinedTab.BackgroundColor = [0.851 0.851 0.851];

            % Create Mask1_2
            app.Mask1_2 = uiimage(app.ControllersTab);
            app.Mask1_2.ScaleMethod = 'fill';
            app.Mask1_2.Position = [0 788 768 30];
            app.Mask1_2.ImageSource = fullfile(pathToMLAPP, '..', 'images', 'greyMask.png');

            % Create UserDefinedControlsButton
            app.UserDefinedControlsButton = uibutton(app.ControllersTab, 'push');
            app.UserDefinedControlsButton.WordWrap = 'on';
            app.UserDefinedControlsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.UserDefinedControlsButton.FontSize = 18;
            app.UserDefinedControlsButton.FontColor = [1 1 1];
            app.UserDefinedControlsButton.Position = [270 785 125 31];
            app.UserDefinedControlsButton.Text = 'User-defined';

            % Create SynergyControlsButton
            app.SynergyControlsButton = uibutton(app.ControllersTab, 'push');
            app.SynergyControlsButton.WordWrap = 'on';
            app.SynergyControlsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SynergyControlsButton.FontSize = 18;
            app.SynergyControlsButton.FontColor = [1 1 1];
            app.SynergyControlsButton.Position = [116 785 148 31];
            app.SynergyControlsButton.Text = 'Synergy/Muscle';

            % Create TorqueControlsButton
            app.TorqueControlsButton = uibutton(app.ControllersTab, 'push');
            app.TorqueControlsButton.WordWrap = 'on';
            app.TorqueControlsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.TorqueControlsButton.FontSize = 18;
            app.TorqueControlsButton.FontColor = [1 1 1];
            app.TorqueControlsButton.Position = [1 785 110 31];
            app.TorqueControlsButton.Text = 'Torque';

            % Create CostTermsTab
            app.CostTermsTab = uitab(app.TabGroup);
            app.CostTermsTab.BackgroundColor = [0.851 0.851 0.851];

            % Create CostTermsListTable
            app.CostTermsListTable = uitable(app.CostTermsTab);
            app.CostTermsListTable.ColumnName = {''; 'Cost Term'};
            app.CostTermsListTable.ColumnWidth = {30, 'auto'};
            app.CostTermsListTable.RowName = {};
            app.CostTermsListTable.ColumnEditable = [true true];
            app.CostTermsListTable.Position = [25 24 307 725];

            % Create CostTermTypeDropDownLabel
            app.CostTermTypeDropDownLabel = uilabel(app.CostTermsTab);
            app.CostTermTypeDropDownLabel.HorizontalAlignment = 'center';
            app.CostTermTypeDropDownLabel.FontSize = 18;
            app.CostTermTypeDropDownLabel.FontWeight = 'bold';
            app.CostTermTypeDropDownLabel.Position = [364 753 377 23];
            app.CostTermTypeDropDownLabel.Text = 'Cost Term Type';

            % Create CostTermTypeDropDown
            app.CostTermTypeDropDown = uidropdown(app.CostTermsTab);
            app.CostTermTypeDropDown.Items = {};
            app.CostTermTypeDropDown.Editable = 'on';
            app.CostTermTypeDropDown.FontSize = 16;
            app.CostTermTypeDropDown.Position = [362 717 379 32];
            app.CostTermTypeDropDown.Value = {};

            % Create ComponentListTextAreaLabel
            app.ComponentListTextAreaLabel = uilabel(app.CostTermsTab);
            app.ComponentListTextAreaLabel.HorizontalAlignment = 'center';
            app.ComponentListTextAreaLabel.FontSize = 18;
            app.ComponentListTextAreaLabel.FontWeight = 'bold';
            app.ComponentListTextAreaLabel.Position = [366 680 285 23];
            app.ComponentListTextAreaLabel.Text = 'Component List';

            % Create CostTermComponentListTextArea
            app.CostTermComponentListTextArea = uitextarea(app.CostTermsTab);
            app.CostTermComponentListTextArea.FontWeight = 'bold';
            app.CostTermComponentListTextArea.Position = [364 404 288 272];

            % Create CostTermComponentListEditButton
            app.CostTermComponentListEditButton = uibutton(app.CostTermsTab, 'push');
            app.CostTermComponentListEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CostTermComponentListEditButton.FontSize = 18;
            app.CostTermComponentListEditButton.FontColor = [1 1 1];
            app.CostTermComponentListEditButton.Position = [664 538 91 30];
            app.CostTermComponentListEditButton.Text = 'Edit';

            % Create CostTermTypeStatus
            app.CostTermTypeStatus = uiimage(app.CostTermsTab);
            app.CostTermTypeStatus.Visible = 'off';
            app.CostTermTypeStatus.Position = [625 749 28 30];
            app.CostTermTypeStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create CostTermComponentListStatus
            app.CostTermComponentListStatus = uiimage(app.CostTermsTab);
            app.CostTermComponentListStatus.Visible = 'off';
            app.CostTermComponentListStatus.Position = [585 677 28 30];
            app.CostTermComponentListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create CostTermsListLabel
            app.CostTermsListLabel = uilabel(app.CostTermsTab);
            app.CostTermsListLabel.HorizontalAlignment = 'center';
            app.CostTermsListLabel.FontSize = 18;
            app.CostTermsListLabel.FontWeight = 'bold';
            app.CostTermsListLabel.Position = [25 753 307 23];
            app.CostTermsListLabel.Text = 'Cost Terms';

            % Create CostTermsListStatus
            app.CostTermsListStatus = uiimage(app.CostTermsTab);
            app.CostTermsListStatus.Visible = 'off';
            app.CostTermsListStatus.Position = [234 749 28 30];
            app.CostTermsListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MaxAllowableErrorEditFieldLabel
            app.MaxAllowableErrorEditFieldLabel = uilabel(app.CostTermsTab);
            app.MaxAllowableErrorEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxAllowableErrorEditFieldLabel.FontSize = 18;
            app.MaxAllowableErrorEditFieldLabel.FontWeight = 'bold';
            app.MaxAllowableErrorEditFieldLabel.Position = [363 340 177 30];
            app.MaxAllowableErrorEditFieldLabel.Text = 'Max Allowable Error';

            % Create MaxAllowableErrorEditField
            app.MaxAllowableErrorEditField = uieditfield(app.CostTermsTab, 'numeric');
            app.MaxAllowableErrorEditField.Limits = [1e-08 Inf];
            app.MaxAllowableErrorEditField.FontSize = 16;
            app.MaxAllowableErrorEditField.FontWeight = 'bold';
            app.MaxAllowableErrorEditField.Position = [550 340 100 30];
            app.MaxAllowableErrorEditField.Value = 1;

            % Create ErrorCenterEditFieldLabel
            app.ErrorCenterEditFieldLabel = uilabel(app.CostTermsTab);
            app.ErrorCenterEditFieldLabel.HorizontalAlignment = 'right';
            app.ErrorCenterEditFieldLabel.FontSize = 18;
            app.ErrorCenterEditFieldLabel.FontWeight = 'bold';
            app.ErrorCenterEditFieldLabel.Position = [364 294 177 30];
            app.ErrorCenterEditFieldLabel.Text = 'Error Center';

            % Create ErrorCenterEditField
            app.ErrorCenterEditField = uieditfield(app.CostTermsTab, 'numeric');
            app.ErrorCenterEditField.Limits = [1e-08 Inf];
            app.ErrorCenterEditField.FontSize = 16;
            app.ErrorCenterEditField.FontWeight = 'bold';
            app.ErrorCenterEditField.Position = [551 294 100 30];
            app.ErrorCenterEditField.Value = 1;

            % Create MiscellaneousCostTermParametersTable
            app.MiscellaneousCostTermParametersTable = uitable(app.CostTermsTab);
            app.MiscellaneousCostTermParametersTable.ColumnName = {'Parameter'; 'Value'};
            app.MiscellaneousCostTermParametersTable.RowName = {};
            app.MiscellaneousCostTermParametersTable.SelectionType = 'row';
            app.MiscellaneousCostTermParametersTable.ColumnEditable = [false true];
            app.MiscellaneousCostTermParametersTable.FontSize = 15;
            app.MiscellaneousCostTermParametersTable.Position = [365 27 377 208];

            % Create MiscellaneousCostTermParametersLabel
            app.MiscellaneousCostTermParametersLabel = uilabel(app.CostTermsTab);
            app.MiscellaneousCostTermParametersLabel.HorizontalAlignment = 'center';
            app.MiscellaneousCostTermParametersLabel.FontSize = 18;
            app.MiscellaneousCostTermParametersLabel.FontWeight = 'bold';
            app.MiscellaneousCostTermParametersLabel.Position = [366 241 375 30];
            app.MiscellaneousCostTermParametersLabel.Text = 'Miscellaneous Cost Term Parameters';

            % Create MiscellaneousCostTermParametersStatus
            app.MiscellaneousCostTermParametersStatus = uiimage(app.CostTermsTab);
            app.MiscellaneousCostTermParametersStatus.Visible = 'off';
            app.MiscellaneousCostTermParametersStatus.Position = [720 241 28 30];
            app.MiscellaneousCostTermParametersStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ConstraintTermsTab
            app.ConstraintTermsTab = uitab(app.TabGroup);
            app.ConstraintTermsTab.BackgroundColor = [0.851 0.851 0.851];

            % Create ConstraintTermsListTable
            app.ConstraintTermsListTable = uitable(app.ConstraintTermsTab);
            app.ConstraintTermsListTable.ColumnName = {''; 'Cost Term'};
            app.ConstraintTermsListTable.ColumnWidth = {30, 'auto'};
            app.ConstraintTermsListTable.RowName = {};
            app.ConstraintTermsListTable.ColumnEditable = [true true];
            app.ConstraintTermsListTable.Position = [25 24 307 725];

            % Create ConstraintTermTypeStatus
            app.ConstraintTermTypeStatus = uiimage(app.ConstraintTermsTab);
            app.ConstraintTermTypeStatus.Visible = 'off';
            app.ConstraintTermTypeStatus.Position = [652 749 28 30];
            app.ConstraintTermTypeStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ConstraintTermComponentListStatus
            app.ConstraintTermComponentListStatus = uiimage(app.ConstraintTermsTab);
            app.ConstraintTermComponentListStatus.Visible = 'off';
            app.ConstraintTermComponentListStatus.Position = [585 677 28 30];
            app.ConstraintTermComponentListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ConstraintTermsListLabel
            app.ConstraintTermsListLabel = uilabel(app.ConstraintTermsTab);
            app.ConstraintTermsListLabel.HorizontalAlignment = 'center';
            app.ConstraintTermsListLabel.FontSize = 18;
            app.ConstraintTermsListLabel.FontWeight = 'bold';
            app.ConstraintTermsListLabel.Position = [25 753 307 23];
            app.ConstraintTermsListLabel.Text = 'Constraint Terms';

            % Create ConstraintTermsListStatus
            app.ConstraintTermsListStatus = uiimage(app.ConstraintTermsTab);
            app.ConstraintTermsListStatus.Visible = 'off';
            app.ConstraintTermsListStatus.Position = [260 749 28 30];
            app.ConstraintTermsListStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MiscellaneousConstraintTermParametersTable
            app.MiscellaneousConstraintTermParametersTable = uitable(app.ConstraintTermsTab);
            app.MiscellaneousConstraintTermParametersTable.ColumnName = {'Parameter'; 'Value'};
            app.MiscellaneousConstraintTermParametersTable.RowName = {};
            app.MiscellaneousConstraintTermParametersTable.SelectionType = 'row';
            app.MiscellaneousConstraintTermParametersTable.ColumnEditable = [false true];
            app.MiscellaneousConstraintTermParametersTable.FontSize = 15;
            app.MiscellaneousConstraintTermParametersTable.Position = [365 27 377 208];

            % Create MiscellaneousConstraintTermParametersLabel
            app.MiscellaneousConstraintTermParametersLabel = uilabel(app.ConstraintTermsTab);
            app.MiscellaneousConstraintTermParametersLabel.HorizontalAlignment = 'center';
            app.MiscellaneousConstraintTermParametersLabel.FontSize = 18;
            app.MiscellaneousConstraintTermParametersLabel.FontWeight = 'bold';
            app.MiscellaneousConstraintTermParametersLabel.Position = [366 241 375 30];
            app.MiscellaneousConstraintTermParametersLabel.Text = 'Miscellaneous Cost Term Parameters';

            % Create MiscellaneousConstraintTermParametersStatus
            app.MiscellaneousConstraintTermParametersStatus = uiimage(app.ConstraintTermsTab);
            app.MiscellaneousConstraintTermParametersStatus.Visible = 'off';
            app.MiscellaneousConstraintTermParametersStatus.Position = [720 241 28 30];
            app.MiscellaneousConstraintTermParametersStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ConstraintTermTypeDropDownLabel
            app.ConstraintTermTypeDropDownLabel = uilabel(app.ConstraintTermsTab);
            app.ConstraintTermTypeDropDownLabel.HorizontalAlignment = 'center';
            app.ConstraintTermTypeDropDownLabel.FontSize = 18;
            app.ConstraintTermTypeDropDownLabel.FontWeight = 'bold';
            app.ConstraintTermTypeDropDownLabel.Position = [364 753 377 23];
            app.ConstraintTermTypeDropDownLabel.Text = 'Constraint Term Type';

            % Create ConstraintTermTypeDropDown
            app.ConstraintTermTypeDropDown = uidropdown(app.ConstraintTermsTab);
            app.ConstraintTermTypeDropDown.Items = {};
            app.ConstraintTermTypeDropDown.Editable = 'on';
            app.ConstraintTermTypeDropDown.FontSize = 16;
            app.ConstraintTermTypeDropDown.Position = [362 717 379 32];
            app.ConstraintTermTypeDropDown.Value = {};

            % Create ComponentListTextAreaLabel_2
            app.ComponentListTextAreaLabel_2 = uilabel(app.ConstraintTermsTab);
            app.ComponentListTextAreaLabel_2.HorizontalAlignment = 'center';
            app.ComponentListTextAreaLabel_2.FontSize = 18;
            app.ComponentListTextAreaLabel_2.FontWeight = 'bold';
            app.ComponentListTextAreaLabel_2.Position = [366 680 285 23];
            app.ComponentListTextAreaLabel_2.Text = 'Component List';

            % Create ConstraintTermComponentListTextArea
            app.ConstraintTermComponentListTextArea = uitextarea(app.ConstraintTermsTab);
            app.ConstraintTermComponentListTextArea.FontWeight = 'bold';
            app.ConstraintTermComponentListTextArea.Position = [364 404 288 272];

            % Create ConstraintTermComponentListEditButton
            app.ConstraintTermComponentListEditButton = uibutton(app.ConstraintTermsTab, 'push');
            app.ConstraintTermComponentListEditButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ConstraintTermComponentListEditButton.FontSize = 18;
            app.ConstraintTermComponentListEditButton.FontColor = [1 1 1];
            app.ConstraintTermComponentListEditButton.Position = [664 538 91 30];
            app.ConstraintTermComponentListEditButton.Text = 'Edit';

            % Create MaxErrroLabel
            app.MaxErrroLabel = uilabel(app.ConstraintTermsTab);
            app.MaxErrroLabel.HorizontalAlignment = 'right';
            app.MaxErrroLabel.FontSize = 18;
            app.MaxErrroLabel.FontWeight = 'bold';
            app.MaxErrroLabel.Position = [363 340 177 30];
            app.MaxErrroLabel.Text = 'Max Error';

            % Create MaxErrorField
            app.MaxErrorField = uieditfield(app.ConstraintTermsTab, 'numeric');
            app.MaxErrorField.Limits = [1e-08 Inf];
            app.MaxErrorField.FontSize = 16;
            app.MaxErrorField.FontWeight = 'bold';
            app.MaxErrorField.Position = [550 340 100 30];
            app.MaxErrorField.Value = 1;

            % Create MinErrorEditFieldLabel
            app.MinErrorEditFieldLabel = uilabel(app.ConstraintTermsTab);
            app.MinErrorEditFieldLabel.HorizontalAlignment = 'right';
            app.MinErrorEditFieldLabel.FontSize = 18;
            app.MinErrorEditFieldLabel.FontWeight = 'bold';
            app.MinErrorEditFieldLabel.Position = [364 294 177 30];
            app.MinErrorEditFieldLabel.Text = 'Min Error';

            % Create MinErrorEditField
            app.MinErrorEditField = uieditfield(app.ConstraintTermsTab, 'numeric');
            app.MinErrorEditField.Limits = [1e-08 Inf];
            app.MinErrorEditField.FontSize = 16;
            app.MinErrorEditField.FontWeight = 'bold';
            app.MinErrorEditField.Position = [551 294 100 30];
            app.MinErrorEditField.Value = 1;

            % Create SolverSettingsTab
            app.SolverSettingsTab = uitab(app.TabGroup);
            app.SolverSettingsTab.BackgroundColor = [0.851 0.851 0.851];

            % Create AdvancedTab
            app.AdvancedTab = uitab(app.TabGroup);
            app.AdvancedTab.Title = 'Tab';
            app.AdvancedTab.BackgroundColor = [0.851 0.851 0.851];

            % Create AdvancedParamsTable
            app.AdvancedParamsTable = uitable(app.AdvancedTab);
            app.AdvancedParamsTable.ColumnName = {'Parameter'; 'Value'};
            app.AdvancedParamsTable.RowName = {};
            app.AdvancedParamsTable.SelectionType = 'row';
            app.AdvancedParamsTable.ColumnEditable = [false true];
            app.AdvancedParamsTable.FontSize = 15;
            app.AdvancedParamsTable.Position = [205 177 377 476];

            % Create MiscellaneousCostTermParametersStatus_2
            app.MiscellaneousCostTermParametersStatus_2 = uiimage(app.AdvancedTab);
            app.MiscellaneousCostTermParametersStatus_2.Visible = 'off';
            app.MiscellaneousCostTermParametersStatus_2.Position = [380 661 28 30];
            app.MiscellaneousCostTermParametersStatus_2.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create Mask1
            app.Mask1 = uiimage(app.UIFigure);
            app.Mask1.ScaleMethod = 'fill';
            app.Mask1.Position = [211 891 768 30];
            app.Mask1.ImageSource = fullfile(pathToMLAPP, '..', 'images', 'greyMask.png');

            % Create MTPImage
            app.MTPImage = uiimage(app.UIFigure);
            app.MTPImage.Position = [1 442 178 420];

            % Create AdvancedButton
            app.AdvancedButton = uibutton(app.UIFigure, 'push');
            app.AdvancedButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.AdvancedButton.FontSize = 18;
            app.AdvancedButton.FontColor = [1 1 1];
            app.AdvancedButton.Position = [855 892 110 30];
            app.AdvancedButton.Text = 'Advanced';

            % Create ConstraintTermsButton
            app.ConstraintTermsButton = uibutton(app.UIFigure, 'push');
            app.ConstraintTermsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ConstraintTermsButton.FontSize = 18;
            app.ConstraintTermsButton.FontColor = [1 1 1];
            app.ConstraintTermsButton.Position = [550 892 151 30];
            app.ConstraintTermsButton.Text = 'Constraint Terms';

            % Create CostTermsButton
            app.CostTermsButton = uibutton(app.UIFigure, 'push');
            app.CostTermsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CostTermsButton.FontSize = 18;
            app.CostTermsButton.FontColor = [1 1 1];
            app.CostTermsButton.Position = [437 891 106 30];
            app.CostTermsButton.Text = 'Cost Terms';

            % Create ControllersButton
            app.ControllersButton = uibutton(app.UIFigure, 'push');
            app.ControllersButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ControllersButton.FontSize = 18;
            app.ControllersButton.FontColor = [1 1 1];
            app.ControllersButton.Position = [328 892 102 30];
            app.ControllersButton.Text = 'Controllers';

            % Create SolverSettingsButton
            app.SolverSettingsButton = uibutton(app.UIFigure, 'push');
            app.SolverSettingsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SolverSettingsButton.FontSize = 18;
            app.SolverSettingsButton.FontColor = [1 1 1];
            app.SolverSettingsButton.Position = [708 892 140 30];
            app.SolverSettingsButton.Text = 'Solver Settings';

            % Create InputsButton
            app.InputsButton = uibutton(app.UIFigure, 'push');
            app.InputsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputsButton.FontSize = 18;
            app.InputsButton.FontColor = [1 1 1];
            app.InputsButton.Position = [211 892 110 30];
            app.InputsButton.Text = 'Inputs';

            % Create RcnlLogo
            app.RcnlLogo = uiimage(app.UIFigure);
            app.RcnlLogo.Position = [11 872 80 80];

            % Create LoadSettingsFileButton
            app.LoadSettingsFileButton = uibutton(app.UIFigure, 'push');
            app.LoadSettingsFileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadSettingsFileButtonPushed, true);
            app.LoadSettingsFileButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.LoadSettingsFileButton.FontSize = 18;
            app.LoadSettingsFileButton.FontColor = [1 1 1];
            app.LoadSettingsFileButton.Position = [502 26 90 30];
            app.LoadSettingsFileButton.Text = 'Load';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SaveButton.FontSize = 18;
            app.SaveButton.FontColor = [1 1 1];
            app.SaveButton.Position = [622 26 90 30];
            app.SaveButton.Text = 'Save';

            % Create HelpButton
            app.HelpButton = uibutton(app.UIFigure, 'push');
            app.HelpButton.ButtonPushedFcn = createCallbackFcn(app, @HelpButtonPushed, true);
            app.HelpButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.HelpButton.FontSize = 18;
            app.HelpButton.FontColor = [1 1 1];
            app.HelpButton.Position = [862 27 90 30];
            app.HelpButton.Text = 'Help';

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.RunButton.FontSize = 18;
            app.RunButton.FontColor = [1 1 1];
            app.RunButton.Enable = 'off';
            app.RunButton.Position = [742 26 90 30];
            app.RunButton.Text = 'Run';

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ResetButton.FontSize = 18;
            app.ResetButton.FontColor = [1 1 1];
            app.ResetButton.Position = [384 26 90 30];
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
        function app = TreatmentOptimizationBase_exported

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