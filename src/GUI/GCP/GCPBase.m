classdef GCPBase < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        ResetButton                    matlab.ui.control.Button
        RunButton                      matlab.ui.control.Button
        HelpButton                     matlab.ui.control.Button
        SaveButton                     matlab.ui.control.Button
        LoadSettingsFileButton         matlab.ui.control.Button
        RcnlLogo                       matlab.ui.control.Image
        InputsButton                   matlab.ui.control.Button
        ContactSurfacesButton          matlab.ui.control.Button
        GCPTasksButton                 matlab.ui.control.Button
        AdvancedButton                 matlab.ui.control.Button
        MTPImage                       matlab.ui.control.Image
        Mask1                          matlab.ui.control.Image
        TabGroup                       matlab.ui.container.TabGroup
        InputsTab                      matlab.ui.container.Tab
        MTPResultsDirectoryLabel       matlab.ui.control.Label
        InputForceFile                 matlab.ui.control.EditField
        InputForceFileSearchButton     matlab.ui.control.Button
        InputForceFileStatus           matlab.ui.control.Image
        InputMotionFileLabel           matlab.ui.control.Label
        GCPResultsDirectoryStatus      matlab.ui.control.Image
        GCPResultsDirectoryEditField   matlab.ui.control.EditField
        GCPResultsDirectoryEditFieldLabel  matlab.ui.control.Label
        GCPResultsDirectorySearchButton  matlab.ui.control.Button
        InputMotionFileStatus          matlab.ui.control.Image
        InputMotionFileEditField       matlab.ui.control.EditField
        InputMotionFileSearchButton    matlab.ui.control.Button
        InputOsimxFileStatus           matlab.ui.control.Image
        InputOsimxFileEditField        matlab.ui.control.EditField
        InputOsimxFileEditFieldLabel   matlab.ui.control.Label
        InputOsimxFileSearchButton     matlab.ui.control.Button
        InputModelFileStatus           matlab.ui.control.Image
        InputModelFileEditField        matlab.ui.control.EditField
        InputModelFileEditFieldLabel   matlab.ui.control.Label
        InputModelFileSearchButton     matlab.ui.control.Button
        ContactSurfacesTab             matlab.ui.container.Tab
        MidfootSuperiorMarkerStatus    matlab.ui.control.Image
        LateralMarkerStatus            matlab.ui.control.Image
        HeelMarkerStatus               matlab.ui.control.Image
        MedialMarkerStatus             matlab.ui.control.Image
        ToeMarkerStatus                matlab.ui.control.Image
        HindfootBodyStatus             matlab.ui.control.Image
        ElectricalCenterColumnsStatus  matlab.ui.control.Image
        MomentColumnsStatus            matlab.ui.control.Image
        ForceColumnsStatus             matlab.ui.control.Image
        TimeRangeStatus                matlab.ui.control.Image
        GridHeightEditField            matlab.ui.control.NumericEditField
        GridHeightEditFieldLabel       matlab.ui.control.Label
        GridWidthEditField             matlab.ui.control.NumericEditField
        GridWidthEditFieldLabel        matlab.ui.control.Label
        MidfootSuperiorMarkerDropDown  matlab.ui.control.DropDown
        MidfootSuperiorMarkerLabel     matlab.ui.control.Label
        HeelMarkerDropDown             matlab.ui.control.DropDown
        HeelMarkerDropDownLabel        matlab.ui.control.Label
        LateralMarkerDropDown          matlab.ui.control.DropDown
        LateralMarkerDropDownLabel     matlab.ui.control.Label
        MedialMarkerDropDown           matlab.ui.control.DropDown
        MedialMarkerLabel              matlab.ui.control.Label
        ToeMarkerDropDown              matlab.ui.control.DropDown
        ToeMarkerDropDownLabel         matlab.ui.control.Label
        HindfootBodyDropDown           matlab.ui.control.DropDown
        HindfootBodyNameLabel          matlab.ui.control.Label
        ForceColumnsDropDown_3         matlab.ui.control.DropDown
        ForceColumnsDropDown_2         matlab.ui.control.DropDown
        MomentColumnsDropDown_3        matlab.ui.control.DropDown
        MomentColumnsDropDown_2        matlab.ui.control.DropDown
        ElectricalCenterColumnsDropDown_3  matlab.ui.control.DropDown
        ElectricalCenterColumnsDropDown_2  matlab.ui.control.DropDown
        ElectricalCenterColumnsDropDown  matlab.ui.control.DropDown
        ElectricalCenterColumnsDropDownLabel  matlab.ui.control.Label
        MomentColumnsDropDown          matlab.ui.control.DropDown
        MomentColumnsLabel             matlab.ui.control.Label
        ForceColumnsDropDown           matlab.ui.control.DropDown
        ForceColumnsLabel              matlab.ui.control.Label
        BeltSpeedEditField             matlab.ui.control.NumericEditField
        BeltSpeedEditFieldLabel        matlab.ui.control.Label
        EndTimeEditField               matlab.ui.control.NumericEditField
        EndTimeEditFieldLabel          matlab.ui.control.Label
        StartTimeEditField             matlab.ui.control.NumericEditField
        StartTimeEditFieldLabel        matlab.ui.control.Label
        IsLeftFootCheckBox             matlab.ui.control.CheckBox
        ContactSurfacesStatus          matlab.ui.control.Image
        ContactSurfacesTable           matlab.ui.control.Table
        ContactSurfacesLabel           matlab.ui.control.Label
        GCPTasksTab                    matlab.ui.container.Tab
        NeighborStandardDeviationEditField  matlab.ui.control.NumericEditField
        NeighborStandardDeviationEditFieldLabel  matlab.ui.control.Label
        DesignVariablesStatus          matlab.ui.control.Image
        CostTermsStatus                matlab.ui.control.Image
        TasksStatus                    matlab.ui.control.Image
        MoveTaskDownButton             matlab.ui.control.Button
        MoveTaskUpButton               matlab.ui.control.Button
        TasksTable                     matlab.ui.control.Table
        TasksLabel                     matlab.ui.control.Label
        DesignVariablesTable           matlab.ui.control.Table
        EditDesignVariablesLabel       matlab.ui.control.Label
        EditCostTermsLabel             matlab.ui.control.Label
        CostTermPanel                  matlab.ui.container.Panel
        CostTermsTable                 matlab.ui.control.Table
        ErrorCenterEditField           matlab.ui.control.NumericEditField
        ErrorCenterEditField_2Label    matlab.ui.control.Label
        MaxAllowableErrorEditField     matlab.ui.control.NumericEditField
        MaxAllowableErrorEditField_2Label  matlab.ui.control.Label
        AdvancedTab                    matlab.ui.container.Tab
        AdvancedSettingsStatus         matlab.ui.control.Image
        AdvancedSettingsTable          matlab.ui.control.Table
        GroundContactModelPersonalizationToolLabel  matlab.ui.control.Label
    end

    
    properties (Access = private, SetObservable)
        
    end

    properties(Access = private)  % listner properties
        
    end

    methods (Access = private) % listener methods
        
    end

    methods(Access=public)
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
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
            app.UIFigure.Position = [500 500 1123 712];
            app.UIFigure.Name = 'MATLAB App';

            % Create GroundContactModelPersonalizationToolLabel
            app.GroundContactModelPersonalizationToolLabel = uilabel(app.UIFigure);
            app.GroundContactModelPersonalizationToolLabel.HorizontalAlignment = 'center';
            app.GroundContactModelPersonalizationToolLabel.FontSize = 25;
            app.GroundContactModelPersonalizationToolLabel.FontWeight = 'bold';
            app.GroundContactModelPersonalizationToolLabel.Position = [1 673 1123 40];
            app.GroundContactModelPersonalizationToolLabel.Text = 'Ground Contact Model Personalization Tool';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [211 72 913 595];

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
            app.InputModelFileSearchButton.Position = [822 516 31 30];
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
            app.InputModelFileEditField.Position = [218 516 587 30];

            % Create InputModelFileStatus
            app.InputModelFileStatus = uiimage(app.InputsTab);
            app.InputModelFileStatus.Visible = 'off';
            app.InputModelFileStatus.Position = [862 516 28 30];
            app.InputModelFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputOsimxFileSearchButton
            app.InputOsimxFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputOsimxFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputOsimxFileSearchButtonPushed, true);
            app.InputOsimxFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputOsimxFileSearchButton.VerticalAlignment = 'bottom';
            app.InputOsimxFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputOsimxFileSearchButton.Position = [822 461 31 30];
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
            app.InputOsimxFileEditField.Position = [218 461 587 30];

            % Create InputOsimxFileStatus
            app.InputOsimxFileStatus = uiimage(app.InputsTab);
            app.InputOsimxFileStatus.Visible = 'off';
            app.InputOsimxFileStatus.Position = [862 461 28 30];
            app.InputOsimxFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputMotionFileSearchButton
            app.InputMotionFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputMotionFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputMotionFileSearchButtonPushed, true);
            app.InputMotionFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputMotionFileSearchButton.VerticalAlignment = 'bottom';
            app.InputMotionFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputMotionFileSearchButton.Position = [822 411 31 30];
            app.InputMotionFileSearchButton.Text = '';

            % Create InputMotionFileEditField
            app.InputMotionFileEditField = uieditfield(app.InputsTab, 'text');
            app.InputMotionFileEditField.ValueChangedFcn = createCallbackFcn(app, @InputMotionFileEditFieldValueChanged, true);
            app.InputMotionFileEditField.Position = [218 411 587 30];

            % Create InputMotionFileStatus
            app.InputMotionFileStatus = uiimage(app.InputsTab);
            app.InputMotionFileStatus.Visible = 'off';
            app.InputMotionFileStatus.Position = [862 411 28 30];
            app.InputMotionFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create GCPResultsDirectorySearchButton
            app.GCPResultsDirectorySearchButton = uibutton(app.InputsTab, 'push');
            app.GCPResultsDirectorySearchButton.ButtonPushedFcn = createCallbackFcn(app, @GCPResultsDirectorySearchButtonPushed, true);
            app.GCPResultsDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.GCPResultsDirectorySearchButton.VerticalAlignment = 'bottom';
            app.GCPResultsDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.GCPResultsDirectorySearchButton.Position = [822 310 31 30];
            app.GCPResultsDirectorySearchButton.Text = '';

            % Create GCPResultsDirectoryEditFieldLabel
            app.GCPResultsDirectoryEditFieldLabel = uilabel(app.InputsTab);
            app.GCPResultsDirectoryEditFieldLabel.HorizontalAlignment = 'right';
            app.GCPResultsDirectoryEditFieldLabel.FontSize = 18;
            app.GCPResultsDirectoryEditFieldLabel.FontWeight = 'bold';
            app.GCPResultsDirectoryEditFieldLabel.Position = [9 310 199 30];
            app.GCPResultsDirectoryEditFieldLabel.Text = 'GCP Results Directory';

            % Create GCPResultsDirectoryEditField
            app.GCPResultsDirectoryEditField = uieditfield(app.InputsTab, 'text');
            app.GCPResultsDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @GCPResultsDirectoryEditFieldValueChanged, true);
            app.GCPResultsDirectoryEditField.Position = [218 310 587 30];

            % Create GCPResultsDirectoryStatus
            app.GCPResultsDirectoryStatus = uiimage(app.InputsTab);
            app.GCPResultsDirectoryStatus.Visible = 'off';
            app.GCPResultsDirectoryStatus.Position = [862 310 28 30];
            app.GCPResultsDirectoryStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputMotionFileLabel
            app.InputMotionFileLabel = uilabel(app.InputsTab);
            app.InputMotionFileLabel.HorizontalAlignment = 'right';
            app.InputMotionFileLabel.FontSize = 18;
            app.InputMotionFileLabel.FontWeight = 'bold';
            app.InputMotionFileLabel.Position = [31 411 177 30];
            app.InputMotionFileLabel.Text = 'Input Motion File';

            % Create InputForceFileStatus
            app.InputForceFileStatus = uiimage(app.InputsTab);
            app.InputForceFileStatus.Visible = 'off';
            app.InputForceFileStatus.Position = [862 361 28 30];
            app.InputForceFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create InputForceFileSearchButton
            app.InputForceFileSearchButton = uibutton(app.InputsTab, 'push');
            app.InputForceFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputForceFileSearchButtonPushed, true);
            app.InputForceFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputForceFileSearchButton.VerticalAlignment = 'bottom';
            app.InputForceFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputForceFileSearchButton.Position = [822 361 31 30];
            app.InputForceFileSearchButton.Text = '';

            % Create InputForceFile
            app.InputForceFile = uieditfield(app.InputsTab, 'text');
            app.InputForceFile.ValueChangedFcn = createCallbackFcn(app, @InputForceFileValueChanged, true);
            app.InputForceFile.Position = [218 361 587 30];

            % Create MTPResultsDirectoryLabel
            app.MTPResultsDirectoryLabel = uilabel(app.InputsTab);
            app.MTPResultsDirectoryLabel.HorizontalAlignment = 'right';
            app.MTPResultsDirectoryLabel.FontSize = 18;
            app.MTPResultsDirectoryLabel.FontWeight = 'bold';
            app.MTPResultsDirectoryLabel.Position = [10 361 198 30];
            app.MTPResultsDirectoryLabel.Text = 'Input Force File';

            % Create ContactSurfacesTab
            app.ContactSurfacesTab = uitab(app.TabGroup);
            app.ContactSurfacesTab.BackgroundColor = [0.851 0.851 0.851];

            % Create ContactSurfacesLabel
            app.ContactSurfacesLabel = uilabel(app.ContactSurfacesTab);
            app.ContactSurfacesLabel.HorizontalAlignment = 'center';
            app.ContactSurfacesLabel.FontSize = 18;
            app.ContactSurfacesLabel.FontWeight = 'bold';
            app.ContactSurfacesLabel.Position = [22 331 204 44];
            app.ContactSurfacesLabel.Text = {'Contact'; 'Surfaces'};

            % Create ContactSurfacesTable
            app.ContactSurfacesTable = uitable(app.ContactSurfacesTab);
            app.ContactSurfacesTable.ColumnName = {''; 'Contact Surface'};
            app.ContactSurfacesTable.ColumnWidth = {30, 'auto'};
            app.ContactSurfacesTable.RowName = {};
            app.ContactSurfacesTable.ColumnSortable = [false true];
            app.ContactSurfacesTable.SelectionType = 'row';
            app.ContactSurfacesTable.ColumnEditable = true;
            app.ContactSurfacesTable.RowStriping = 'off';
            app.ContactSurfacesTable.Multiselect = 'off';
            app.ContactSurfacesTable.FontSize = 18;
            app.ContactSurfacesTable.Position = [22 87 204 242];

            % Create ContactSurfacesStatus
            app.ContactSurfacesStatus = uiimage(app.ContactSurfacesTab);
            app.ContactSurfacesStatus.Visible = 'off';
            app.ContactSurfacesStatus.Position = [180 338 28 30];
            app.ContactSurfacesStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create IsLeftFootCheckBox
            app.IsLeftFootCheckBox = uicheckbox(app.ContactSurfacesTab);
            app.IsLeftFootCheckBox.Text = 'Is Left Foot';
            app.IsLeftFootCheckBox.FontSize = 18;
            app.IsLeftFootCheckBox.FontWeight = 'bold';
            app.IsLeftFootCheckBox.Position = [278 536 119 22];

            % Create StartTimeEditFieldLabel
            app.StartTimeEditFieldLabel = uilabel(app.ContactSurfacesTab);
            app.StartTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.StartTimeEditFieldLabel.FontSize = 18;
            app.StartTimeEditFieldLabel.FontWeight = 'bold';
            app.StartTimeEditFieldLabel.Position = [277 500 93 23];
            app.StartTimeEditFieldLabel.Text = 'Start Time';

            % Create StartTimeEditField
            app.StartTimeEditField = uieditfield(app.ContactSurfacesTab, 'numeric');
            app.StartTimeEditField.FontSize = 18;
            app.StartTimeEditField.Position = [385 499 100 24];

            % Create EndTimeEditFieldLabel
            app.EndTimeEditFieldLabel = uilabel(app.ContactSurfacesTab);
            app.EndTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.EndTimeEditFieldLabel.FontSize = 18;
            app.EndTimeEditFieldLabel.FontWeight = 'bold';
            app.EndTimeEditFieldLabel.Position = [524 500 86 23];
            app.EndTimeEditFieldLabel.Text = 'End Time';

            % Create EndTimeEditField
            app.EndTimeEditField = uieditfield(app.ContactSurfacesTab, 'numeric');
            app.EndTimeEditField.FontSize = 18;
            app.EndTimeEditField.Position = [625 499 100 24];

            % Create BeltSpeedEditFieldLabel
            app.BeltSpeedEditFieldLabel = uilabel(app.ContactSurfacesTab);
            app.BeltSpeedEditFieldLabel.HorizontalAlignment = 'right';
            app.BeltSpeedEditFieldLabel.FontSize = 18;
            app.BeltSpeedEditFieldLabel.FontWeight = 'bold';
            app.BeltSpeedEditFieldLabel.Position = [273 459 98 23];
            app.BeltSpeedEditFieldLabel.Text = 'Belt Speed';

            % Create BeltSpeedEditField
            app.BeltSpeedEditField = uieditfield(app.ContactSurfacesTab, 'numeric');
            app.BeltSpeedEditField.FontSize = 18;
            app.BeltSpeedEditField.Position = [385 458 100 24];

            % Create ForceColumnsLabel
            app.ForceColumnsLabel = uilabel(app.ContactSurfacesTab);
            app.ForceColumnsLabel.HorizontalAlignment = 'right';
            app.ForceColumnsLabel.FontSize = 18;
            app.ForceColumnsLabel.FontWeight = 'bold';
            app.ForceColumnsLabel.Position = [268 396 82 44];
            app.ForceColumnsLabel.Text = {'Force'; 'Columns'};

            % Create ForceColumnsDropDown
            app.ForceColumnsDropDown = uidropdown(app.ContactSurfacesTab);
            app.ForceColumnsDropDown.Items = {'ground_force_1_vx'};
            app.ForceColumnsDropDown.FontSize = 15;
            app.ForceColumnsDropDown.Position = [366 408 164 22];
            app.ForceColumnsDropDown.Value = 'ground_force_1_vx';

            % Create MomentColumnsLabel
            app.MomentColumnsLabel = uilabel(app.ContactSurfacesTab);
            app.MomentColumnsLabel.HorizontalAlignment = 'right';
            app.MomentColumnsLabel.FontSize = 18;
            app.MomentColumnsLabel.FontWeight = 'bold';
            app.MomentColumnsLabel.Position = [272 337 82 44];
            app.MomentColumnsLabel.Text = {'Moment'; 'Columns'};

            % Create MomentColumnsDropDown
            app.MomentColumnsDropDown = uidropdown(app.ContactSurfacesTab);
            app.MomentColumnsDropDown.FontSize = 15;
            app.MomentColumnsDropDown.Position = [367 349 163 22];

            % Create ElectricalCenterColumnsDropDownLabel
            app.ElectricalCenterColumnsDropDownLabel = uilabel(app.ContactSurfacesTab);
            app.ElectricalCenterColumnsDropDownLabel.HorizontalAlignment = 'right';
            app.ElectricalCenterColumnsDropDownLabel.FontSize = 18;
            app.ElectricalCenterColumnsDropDownLabel.FontWeight = 'bold';
            app.ElectricalCenterColumnsDropDownLabel.Position = [271 263 85 66];
            app.ElectricalCenterColumnsDropDownLabel.Text = {'Electrical'; 'Center'; 'Columns'};

            % Create ElectricalCenterColumnsDropDown
            app.ElectricalCenterColumnsDropDown = uidropdown(app.ContactSurfacesTab);
            app.ElectricalCenterColumnsDropDown.FontSize = 15;
            app.ElectricalCenterColumnsDropDown.Position = [368 286 162 22];

            % Create ElectricalCenterColumnsDropDown_2
            app.ElectricalCenterColumnsDropDown_2 = uidropdown(app.ContactSurfacesTab);
            app.ElectricalCenterColumnsDropDown_2.FontSize = 15;
            app.ElectricalCenterColumnsDropDown_2.Position = [540 286 163 22];

            % Create ElectricalCenterColumnsDropDown_3
            app.ElectricalCenterColumnsDropDown_3 = uidropdown(app.ContactSurfacesTab);
            app.ElectricalCenterColumnsDropDown_3.FontSize = 15;
            app.ElectricalCenterColumnsDropDown_3.Position = [711 286 163 22];

            % Create MomentColumnsDropDown_2
            app.MomentColumnsDropDown_2 = uidropdown(app.ContactSurfacesTab);
            app.MomentColumnsDropDown_2.FontSize = 15;
            app.MomentColumnsDropDown_2.Position = [540 349 163 22];

            % Create MomentColumnsDropDown_3
            app.MomentColumnsDropDown_3 = uidropdown(app.ContactSurfacesTab);
            app.MomentColumnsDropDown_3.FontSize = 15;
            app.MomentColumnsDropDown_3.Position = [711 349 163 22];

            % Create ForceColumnsDropDown_2
            app.ForceColumnsDropDown_2 = uidropdown(app.ContactSurfacesTab);
            app.ForceColumnsDropDown_2.Items = {'ground_force_1_vx'};
            app.ForceColumnsDropDown_2.FontSize = 15;
            app.ForceColumnsDropDown_2.Position = [540 407 163 22];
            app.ForceColumnsDropDown_2.Value = 'ground_force_1_vx';

            % Create ForceColumnsDropDown_3
            app.ForceColumnsDropDown_3 = uidropdown(app.ContactSurfacesTab);
            app.ForceColumnsDropDown_3.Items = {'ground_force_1_vx'};
            app.ForceColumnsDropDown_3.FontSize = 15;
            app.ForceColumnsDropDown_3.Position = [711 407 163 22];
            app.ForceColumnsDropDown_3.Value = 'ground_force_1_vx';

            % Create HindfootBodyNameLabel
            app.HindfootBodyNameLabel = uilabel(app.ContactSurfacesTab);
            app.HindfootBodyNameLabel.HorizontalAlignment = 'right';
            app.HindfootBodyNameLabel.FontSize = 18;
            app.HindfootBodyNameLabel.FontWeight = 'bold';
            app.HindfootBodyNameLabel.Position = [440 185 79 44];
            app.HindfootBodyNameLabel.Text = {'Hindfoot'; 'Body'};

            % Create HindfootBodyDropDown
            app.HindfootBodyDropDown = uidropdown(app.ContactSurfacesTab);
            app.HindfootBodyDropDown.FontSize = 15;
            app.HindfootBodyDropDown.Position = [531 196 162 22];

            % Create ToeMarkerDropDownLabel
            app.ToeMarkerDropDownLabel = uilabel(app.ContactSurfacesTab);
            app.ToeMarkerDropDownLabel.HorizontalAlignment = 'right';
            app.ToeMarkerDropDownLabel.FontSize = 18;
            app.ToeMarkerDropDownLabel.FontWeight = 'bold';
            app.ToeMarkerDropDownLabel.Position = [297 121 100 23];
            app.ToeMarkerDropDownLabel.Text = 'Toe Marker';

            % Create ToeMarkerDropDown
            app.ToeMarkerDropDown = uidropdown(app.ContactSurfacesTab);
            app.ToeMarkerDropDown.FontSize = 15;
            app.ToeMarkerDropDown.Position = [403 121 152 22];

            % Create MedialMarkerLabel
            app.MedialMarkerLabel = uilabel(app.ContactSurfacesTab);
            app.MedialMarkerLabel.HorizontalAlignment = 'right';
            app.MedialMarkerLabel.FontSize = 18;
            app.MedialMarkerLabel.FontWeight = 'bold';
            app.MedialMarkerLabel.Position = [587 121 125 23];
            app.MedialMarkerLabel.Text = 'Medial Marker';

            % Create MedialMarkerDropDown
            app.MedialMarkerDropDown = uidropdown(app.ContactSurfacesTab);
            app.MedialMarkerDropDown.FontSize = 15;
            app.MedialMarkerDropDown.Position = [720 121 154 22];

            % Create LateralMarkerDropDownLabel
            app.LateralMarkerDropDownLabel = uilabel(app.ContactSurfacesTab);
            app.LateralMarkerDropDownLabel.HorizontalAlignment = 'right';
            app.LateralMarkerDropDownLabel.FontSize = 18;
            app.LateralMarkerDropDownLabel.FontWeight = 'bold';
            app.LateralMarkerDropDownLabel.Position = [269 81 128 23];
            app.LateralMarkerDropDownLabel.Text = 'Lateral Marker';

            % Create LateralMarkerDropDown
            app.LateralMarkerDropDown = uidropdown(app.ContactSurfacesTab);
            app.LateralMarkerDropDown.FontSize = 15;
            app.LateralMarkerDropDown.Position = [403 81 152 22];

            % Create HeelMarkerDropDownLabel
            app.HeelMarkerDropDownLabel = uilabel(app.ContactSurfacesTab);
            app.HeelMarkerDropDownLabel.HorizontalAlignment = 'right';
            app.HeelMarkerDropDownLabel.FontSize = 18;
            app.HeelMarkerDropDownLabel.FontWeight = 'bold';
            app.HeelMarkerDropDownLabel.Position = [605 81 107 23];
            app.HeelMarkerDropDownLabel.Text = 'Heel Marker';

            % Create HeelMarkerDropDown
            app.HeelMarkerDropDown = uidropdown(app.ContactSurfacesTab);
            app.HeelMarkerDropDown.FontSize = 15;
            app.HeelMarkerDropDown.Position = [720 81 154 22];

            % Create MidfootSuperiorMarkerLabel
            app.MidfootSuperiorMarkerLabel = uilabel(app.ContactSurfacesTab);
            app.MidfootSuperiorMarkerLabel.HorizontalAlignment = 'right';
            app.MidfootSuperiorMarkerLabel.FontSize = 18;
            app.MidfootSuperiorMarkerLabel.FontWeight = 'bold';
            app.MidfootSuperiorMarkerLabel.Position = [248 30 149 44];
            app.MidfootSuperiorMarkerLabel.Text = {'Midfoot Superior'; 'Marker'};

            % Create MidfootSuperiorMarkerDropDown
            app.MidfootSuperiorMarkerDropDown = uidropdown(app.ContactSurfacesTab);
            app.MidfootSuperiorMarkerDropDown.FontSize = 15;
            app.MidfootSuperiorMarkerDropDown.Position = [403 41 152 22];

            % Create GridWidthEditFieldLabel
            app.GridWidthEditFieldLabel = uilabel(app.ContactSurfacesTab);
            app.GridWidthEditFieldLabel.HorizontalAlignment = 'right';
            app.GridWidthEditFieldLabel.FontSize = 18;
            app.GridWidthEditFieldLabel.FontWeight = 'bold';
            app.GridWidthEditFieldLabel.Position = [14 488 97 23];
            app.GridWidthEditFieldLabel.Text = 'Grid Width';

            % Create GridWidthEditField
            app.GridWidthEditField = uieditfield(app.ContactSurfacesTab, 'numeric');
            app.GridWidthEditField.Limits = [1 Inf];
            app.GridWidthEditField.FontSize = 18;
            app.GridWidthEditField.Position = [126 487 100 24];
            app.GridWidthEditField.Value = 5;

            % Create GridHeightEditFieldLabel
            app.GridHeightEditFieldLabel = uilabel(app.ContactSurfacesTab);
            app.GridHeightEditFieldLabel.HorizontalAlignment = 'right';
            app.GridHeightEditFieldLabel.FontSize = 18;
            app.GridHeightEditFieldLabel.FontWeight = 'bold';
            app.GridHeightEditFieldLabel.Position = [8 449 103 23];
            app.GridHeightEditFieldLabel.Text = 'Grid Height';

            % Create GridHeightEditField
            app.GridHeightEditField = uieditfield(app.ContactSurfacesTab, 'numeric');
            app.GridHeightEditField.Limits = [1 Inf];
            app.GridHeightEditField.FontSize = 18;
            app.GridHeightEditField.Position = [126 448 100 24];
            app.GridHeightEditField.Value = 15;

            % Create TimeRangeStatus
            app.TimeRangeStatus = uiimage(app.ContactSurfacesTab);
            app.TimeRangeStatus.Visible = 'off';
            app.TimeRangeStatus.Position = [745 496 28 30];
            app.TimeRangeStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ForceColumnsStatus
            app.ForceColumnsStatus = uiimage(app.ContactSurfacesTab);
            app.ForceColumnsStatus.Visible = 'off';
            app.ForceColumnsStatus.Position = [879 403 28 30];
            app.ForceColumnsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MomentColumnsStatus
            app.MomentColumnsStatus = uiimage(app.ContactSurfacesTab);
            app.MomentColumnsStatus.Visible = 'off';
            app.MomentColumnsStatus.Position = [879 345 28 30];
            app.MomentColumnsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ElectricalCenterColumnsStatus
            app.ElectricalCenterColumnsStatus = uiimage(app.ContactSurfacesTab);
            app.ElectricalCenterColumnsStatus.Visible = 'off';
            app.ElectricalCenterColumnsStatus.Position = [879 282 28 30];
            app.ElectricalCenterColumnsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create HindfootBodyStatus
            app.HindfootBodyStatus = uiimage(app.ContactSurfacesTab);
            app.HindfootBodyStatus.Visible = 'off';
            app.HindfootBodyStatus.Position = [697 192 28 30];
            app.HindfootBodyStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ToeMarkerStatus
            app.ToeMarkerStatus = uiimage(app.ContactSurfacesTab);
            app.ToeMarkerStatus.Visible = 'off';
            app.ToeMarkerStatus.Position = [558 117 28 30];
            app.ToeMarkerStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MedialMarkerStatus
            app.MedialMarkerStatus = uiimage(app.ContactSurfacesTab);
            app.MedialMarkerStatus.Visible = 'off';
            app.MedialMarkerStatus.Position = [879 117 28 30];
            app.MedialMarkerStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create HeelMarkerStatus
            app.HeelMarkerStatus = uiimage(app.ContactSurfacesTab);
            app.HeelMarkerStatus.Visible = 'off';
            app.HeelMarkerStatus.Position = [879 77 28 30];
            app.HeelMarkerStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create LateralMarkerStatus
            app.LateralMarkerStatus = uiimage(app.ContactSurfacesTab);
            app.LateralMarkerStatus.Visible = 'off';
            app.LateralMarkerStatus.Position = [558 77 28 30];
            app.LateralMarkerStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MidfootSuperiorMarkerStatus
            app.MidfootSuperiorMarkerStatus = uiimage(app.ContactSurfacesTab);
            app.MidfootSuperiorMarkerStatus.Visible = 'off';
            app.MidfootSuperiorMarkerStatus.Position = [558 37 28 30];
            app.MidfootSuperiorMarkerStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create GCPTasksTab
            app.GCPTasksTab = uitab(app.TabGroup);
            app.GCPTasksTab.BackgroundColor = [0.851 0.851 0.851];

            % Create CostTermPanel
            app.CostTermPanel = uipanel(app.GCPTasksTab);
            app.CostTermPanel.BackgroundColor = [1 1 1];
            app.CostTermPanel.FontWeight = 'bold';
            app.CostTermPanel.FontSize = 18;
            app.CostTermPanel.Position = [275 1 559 277];

            % Create MaxAllowableErrorEditField_2Label
            app.MaxAllowableErrorEditField_2Label = uilabel(app.CostTermPanel);
            app.MaxAllowableErrorEditField_2Label.HorizontalAlignment = 'center';
            app.MaxAllowableErrorEditField_2Label.WordWrap = 'on';
            app.MaxAllowableErrorEditField_2Label.FontSize = 18;
            app.MaxAllowableErrorEditField_2Label.Position = [44 11 116 44];
            app.MaxAllowableErrorEditField_2Label.Text = 'Max Allowable Error';

            % Create MaxAllowableErrorEditField
            app.MaxAllowableErrorEditField = uieditfield(app.CostTermPanel, 'numeric');
            app.MaxAllowableErrorEditField.Limits = [1e-08 Inf];
            app.MaxAllowableErrorEditField.AllowEmpty = 'on';
            app.MaxAllowableErrorEditField.FontSize = 18;
            app.MaxAllowableErrorEditField.Position = [173 21 78 24];
            app.MaxAllowableErrorEditField.Value = [];

            % Create ErrorCenterEditField_2Label
            app.ErrorCenterEditField_2Label = uilabel(app.CostTermPanel);
            app.ErrorCenterEditField_2Label.HorizontalAlignment = 'right';
            app.ErrorCenterEditField_2Label.FontSize = 18;
            app.ErrorCenterEditField_2Label.Position = [316 22 104 23];
            app.ErrorCenterEditField_2Label.Text = 'Error Center';

            % Create ErrorCenterEditField
            app.ErrorCenterEditField = uieditfield(app.CostTermPanel, 'numeric');
            app.ErrorCenterEditField.AllowEmpty = 'on';
            app.ErrorCenterEditField.FontSize = 18;
            app.ErrorCenterEditField.Position = [436 21 77 24];
            app.ErrorCenterEditField.Value = [];

            % Create CostTermsTable
            app.CostTermsTable = uitable(app.CostTermPanel);
            app.CostTermsTable.ColumnName = {''; 'Cost Term'};
            app.CostTermsTable.ColumnWidth = {30, 'auto'};
            app.CostTermsTable.RowName = {};
            app.CostTermsTable.SelectionType = 'row';
            app.CostTermsTable.ColumnEditable = [true false];
            app.CostTermsTable.RowStriping = 'off';
            app.CostTermsTable.Multiselect = 'off';
            app.CostTermsTable.FontSize = 18;
            app.CostTermsTable.Position = [1 63 556 213];

            % Create EditCostTermsLabel
            app.EditCostTermsLabel = uilabel(app.GCPTasksTab);
            app.EditCostTermsLabel.FontSize = 18;
            app.EditCostTermsLabel.FontWeight = 'bold';
            app.EditCostTermsLabel.Position = [484 285 142 23];
            app.EditCostTermsLabel.Text = 'Edit Cost Terms';

            % Create EditDesignVariablesLabel
            app.EditDesignVariablesLabel = uilabel(app.GCPTasksTab);
            app.EditDesignVariablesLabel.FontSize = 18;
            app.EditDesignVariablesLabel.FontWeight = 'bold';
            app.EditDesignVariablesLabel.Position = [460 543 188 23];
            app.EditDesignVariablesLabel.Text = 'Edit Design Variables';

            % Create DesignVariablesTable
            app.DesignVariablesTable = uitable(app.GCPTasksTab);
            app.DesignVariablesTable.ColumnName = {''; 'Design Variable'};
            app.DesignVariablesTable.ColumnWidth = {30, 'auto'};
            app.DesignVariablesTable.RowName = {};
            app.DesignVariablesTable.SelectionType = 'row';
            app.DesignVariablesTable.ColumnEditable = [true false];
            app.DesignVariablesTable.RowStriping = 'off';
            app.DesignVariablesTable.Multiselect = 'off';
            app.DesignVariablesTable.FontSize = 18;
            app.DesignVariablesTable.Position = [276 360 558 174];

            % Create TasksLabel
            app.TasksLabel = uilabel(app.GCPTasksTab);
            app.TasksLabel.HorizontalAlignment = 'center';
            app.TasksLabel.FontSize = 18;
            app.TasksLabel.FontWeight = 'bold';
            app.TasksLabel.Position = [97 423 55 23];
            app.TasksLabel.Text = 'Tasks';

            % Create TasksTable
            app.TasksTable = uitable(app.GCPTasksTab);
            app.TasksTable.ColumnName = {''; 'Task'};
            app.TasksTable.ColumnWidth = {30, 'auto'};
            app.TasksTable.RowName = {};
            app.TasksTable.ColumnSortable = [false true];
            app.TasksTable.SelectionType = 'row';
            app.TasksTable.ColumnEditable = true;
            app.TasksTable.RowStriping = 'off';
            app.TasksTable.Multiselect = 'off';
            app.TasksTable.FontSize = 18;
            app.TasksTable.Position = [39 176 172 242];

            % Create MoveTaskUpButton
            app.MoveTaskUpButton = uibutton(app.GCPTasksTab, 'push');
            app.MoveTaskUpButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'ArrowUp.svg');
            app.MoveTaskUpButton.IconAlignment = 'center';
            app.MoveTaskUpButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MoveTaskUpButton.Position = [220 310 25 25];
            app.MoveTaskUpButton.Text = '';

            % Create MoveTaskDownButton
            app.MoveTaskDownButton = uibutton(app.GCPTasksTab, 'push');
            app.MoveTaskDownButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'ArrowDown.svg');
            app.MoveTaskDownButton.IconAlignment = 'center';
            app.MoveTaskDownButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MoveTaskDownButton.Position = [220 256 25 25];
            app.MoveTaskDownButton.Text = '';

            % Create TasksStatus
            app.TasksStatus = uiimage(app.GCPTasksTab);
            app.TasksStatus.Visible = 'off';
            app.TasksStatus.Position = [157 419 28 30];
            app.TasksStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create CostTermsStatus
            app.CostTermsStatus = uiimage(app.GCPTasksTab);
            app.CostTermsStatus.Visible = 'off';
            app.CostTermsStatus.Position = [629 282 28 30];
            app.CostTermsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create DesignVariablesStatus
            app.DesignVariablesStatus = uiimage(app.GCPTasksTab);
            app.DesignVariablesStatus.Visible = 'off';
            app.DesignVariablesStatus.Position = [651 539 28 30];
            app.DesignVariablesStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create NeighborStandardDeviationEditFieldLabel
            app.NeighborStandardDeviationEditFieldLabel = uilabel(app.GCPTasksTab);
            app.NeighborStandardDeviationEditFieldLabel.HorizontalAlignment = 'right';
            app.NeighborStandardDeviationEditFieldLabel.FontSize = 18;
            app.NeighborStandardDeviationEditFieldLabel.FontWeight = 'bold';
            app.NeighborStandardDeviationEditFieldLabel.Position = [276 322 255 23];
            app.NeighborStandardDeviationEditFieldLabel.Text = 'Neighbor Standard Deviation';

            % Create NeighborStandardDeviationEditField
            app.NeighborStandardDeviationEditField = uieditfield(app.GCPTasksTab, 'numeric');
            app.NeighborStandardDeviationEditField.Limits = [0 Inf];
            app.NeighborStandardDeviationEditField.FontSize = 18;
            app.NeighborStandardDeviationEditField.Position = [553 321 100 24];
            app.NeighborStandardDeviationEditField.Value = 0.2;

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
            app.AdvancedSettingsTable.Position = [121 94 674 407];

            % Create AdvancedSettingsStatus
            app.AdvancedSettingsStatus = uiimage(app.AdvancedTab);
            app.AdvancedSettingsStatus.Visible = 'off';
            app.AdvancedSettingsStatus.Position = [446 507 28 30];
            app.AdvancedSettingsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create Mask1
            app.Mask1 = uiimage(app.UIFigure);
            app.Mask1.ScaleMethod = 'fill';
            app.Mask1.Position = [211 644 912 30];
            app.Mask1.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'greyMask.png');

            % Create MTPImage
            app.MTPImage = uiimage(app.UIFigure);
            app.MTPImage.Position = [1 193 178 420];
            app.MTPImage.ImageSource = 'gcpFigure.png';

            % Create AdvancedButton
            app.AdvancedButton = uibutton(app.UIFigure, 'push');
            app.AdvancedButton.ButtonPushedFcn = createCallbackFcn(app, @AdvancedButtonPushed, true);
            app.AdvancedButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.AdvancedButton.FontSize = 18;
            app.AdvancedButton.FontColor = [1 1 1];
            app.AdvancedButton.Position = [599 643 100 30];
            app.AdvancedButton.Text = 'Advanced';

            % Create GCPTasksButton
            app.GCPTasksButton = uibutton(app.UIFigure, 'push');
            app.GCPTasksButton.ButtonPushedFcn = createCallbackFcn(app, @GCPTasksButtonPushed, true);
            app.GCPTasksButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.GCPTasksButton.FontSize = 18;
            app.GCPTasksButton.FontColor = [1 1 1];
            app.GCPTasksButton.Position = [488 643 104 30];
            app.GCPTasksButton.Text = 'GCP Tasks';

            % Create ContactSurfacesButton
            app.ContactSurfacesButton = uibutton(app.UIFigure, 'push');
            app.ContactSurfacesButton.ButtonPushedFcn = createCallbackFcn(app, @ContactSurfacesButtonPushed, true);
            app.ContactSurfacesButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ContactSurfacesButton.FontSize = 18;
            app.ContactSurfacesButton.FontColor = [1 1 1];
            app.ContactSurfacesButton.Position = [328 643 153 30];
            app.ContactSurfacesButton.Text = 'Contact Surfaces';

            % Create InputsButton
            app.InputsButton = uibutton(app.UIFigure, 'push');
            app.InputsButton.ButtonPushedFcn = createCallbackFcn(app, @InputsButtonPushed, true);
            app.InputsButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputsButton.FontSize = 18;
            app.InputsButton.FontColor = [1 1 1];
            app.InputsButton.Position = [211 643 110 30];
            app.InputsButton.Text = 'GCP Inputs';

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
            app.LoadSettingsFileButton.Position = [645 23 90 30];
            app.LoadSettingsFileButton.Text = 'Load';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.SaveButton.FontSize = 18;
            app.SaveButton.FontColor = [1 1 1];
            app.SaveButton.Position = [765 23 90 30];
            app.SaveButton.Text = 'Save';

            % Create HelpButton
            app.HelpButton = uibutton(app.UIFigure, 'push');
            app.HelpButton.ButtonPushedFcn = createCallbackFcn(app, @HelpButtonPushed, true);
            app.HelpButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.HelpButton.FontSize = 18;
            app.HelpButton.FontColor = [1 1 1];
            app.HelpButton.Position = [1005 24 90 30];
            app.HelpButton.Text = 'Help';

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.RunButton.FontSize = 18;
            app.RunButton.FontColor = [1 1 1];
            app.RunButton.Enable = 'off';
            app.RunButton.Position = [885 23 90 30];
            app.RunButton.Text = 'Run';

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ResetButton.FontSize = 18;
            app.ResetButton.FontColor = [1 1 1];
            app.ResetButton.Position = [527 23 90 30];
            app.ResetButton.Text = 'Reset';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GCPBase

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