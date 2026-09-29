classdef DataPreprocessingGui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        ProcessedEmgFileStatus          matlab.ui.control.Image
        ProcessedEMGFileEditField       matlab.ui.control.EditField
        ProcessedEMGFileEditFieldLabel  matlab.ui.control.Label
        ProcessedEmgFileSearchButton    matlab.ui.control.Button
        OutputDirectorySearchButton     matlab.ui.control.Button
        z                               matlab.ui.control.Image
        OutputDirectoryEditField        matlab.ui.control.EditField
        OutputDirectoryLabel            matlab.ui.control.Label
        RunDataPreprocessingButton      matlab.ui.control.Button
        NumberofTimePointsEditField     matlab.ui.control.EditField
        NumberofTimePointsEditFieldLabel  matlab.ui.control.Label
        NumTimePointsStatus             matlab.ui.control.Image
        TrialTimePairsLabel             matlab.ui.control.Label
        TrialTimePairsTable             matlab.ui.control.Table
        TrialPrefixStatus               matlab.ui.control.Image
        TrialPrefixEditField            matlab.ui.control.EditField
        TrialPrefixEditFieldLabel       matlab.ui.control.Label
        RunMuscleAnalysisButton         matlab.ui.control.Button
        MuscleAnalysisDataDirectoryStatus  matlab.ui.control.Image
        MuscleAnalysisDataDirectoryEditField  matlab.ui.control.EditField
        MuscleAnalysisDataDirectoryEditFieldLabel  matlab.ui.control.Label
        MuscleAnalysisDataDirectorySearchButton  matlab.ui.control.Button
        GroundReactionsFileStatus       matlab.ui.control.Image
        GroundReactionsFileEditField    matlab.ui.control.EditField
        GroundReactionsFileEditFieldLabel  matlab.ui.control.Label
        GroundReactionsFileSearchButton  matlab.ui.control.Button
        JointLoadsFileStatus            matlab.ui.control.Image
        JointLoadsFileEditField         matlab.ui.control.EditField
        JointLoadsFileEditFieldLabel    matlab.ui.control.Label
        JointLoadsFileSearchButton      matlab.ui.control.Button
        JointAnglesStatus               matlab.ui.control.Image
        JointAnglesFileEditField        matlab.ui.control.EditField
        JointAnglesFileEditFieldLabel   matlab.ui.control.Label
        JointAnglesFileSearchButton     matlab.ui.control.Button
        Panel                           matlab.ui.container.Panel
        EMGProcessingCheckBox           matlab.ui.control.CheckBox
        LowPassCutoffFrequencyEditField  matlab.ui.control.NumericEditField
        LowPassCutoffFrequencyEditField_2Label  matlab.ui.control.Label
        HighPassCutoffFrequencyEditField  matlab.ui.control.NumericEditField
        HighPassCutoffFrequencyEditFieldLabel  matlab.ui.control.Label
        FilterOrderEditField            matlab.ui.control.NumericEditField
        LowPassCutoffFrequencyLabel     matlab.ui.control.Label
        RawEmgFileStatus                matlab.ui.control.Image
        RawEMGFileEditField             matlab.ui.control.EditField
        RawEMGFileEditFieldLabel        matlab.ui.control.Label
        RawEmgFileSearchButton          matlab.ui.control.Button
        InputModelFileStatus            matlab.ui.control.Image
        InputModelFileEditField         matlab.ui.control.EditField
        InputModelFileEditFieldLabel    matlab.ui.control.Label
        InputModelFileSearchButton      matlab.ui.control.Button
        RcnlLogo                        matlab.ui.control.Image
        DataPreprocessingLabel          matlab.ui.control.Label
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
            app.UIFigure.Position = [100 100 770 960];
            app.UIFigure.Name = 'MATLAB App';

            % Create DataPreprocessingLabel
            app.DataPreprocessingLabel = uilabel(app.UIFigure);
            app.DataPreprocessingLabel.HorizontalAlignment = 'center';
            app.DataPreprocessingLabel.FontSize = 25;
            app.DataPreprocessingLabel.FontWeight = 'bold';
            app.DataPreprocessingLabel.Position = [1 921 770 40];
            app.DataPreprocessingLabel.Text = 'Data Preprocessing';

            % Create RcnlLogo
            app.RcnlLogo = uiimage(app.UIFigure);
            app.RcnlLogo.Position = [6 876 80 80];
            app.RcnlLogo.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'rcnlIcon.png');

            % Create InputModelFileSearchButton
            app.InputModelFileSearchButton = uibutton(app.UIFigure, 'push');
            app.InputModelFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputModelFileSearchButton.VerticalAlignment = 'bottom';
            app.InputModelFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputModelFileSearchButton.Position = [695 837 31 30];
            app.InputModelFileSearchButton.Text = '';

            % Create InputModelFileEditFieldLabel
            app.InputModelFileEditFieldLabel = uilabel(app.UIFigure);
            app.InputModelFileEditFieldLabel.HorizontalAlignment = 'right';
            app.InputModelFileEditFieldLabel.FontSize = 18;
            app.InputModelFileEditFieldLabel.FontWeight = 'bold';
            app.InputModelFileEditFieldLabel.Position = [85 837 140 30];
            app.InputModelFileEditFieldLabel.Text = 'Input Model File';

            % Create InputModelFileEditField
            app.InputModelFileEditField = uieditfield(app.UIFigure, 'text');
            app.InputModelFileEditField.Position = [235 837 450 30];

            % Create InputModelFileStatus
            app.InputModelFileStatus = uiimage(app.UIFigure);
            app.InputModelFileStatus.Visible = 'off';
            app.InputModelFileStatus.Position = [728 837 28 30];
            app.InputModelFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create Panel
            app.Panel = uipanel(app.UIFigure);
            app.Panel.BackgroundColor = [0.851 0.851 0.851];
            app.Panel.Position = [-34 656 821 171];

            % Create RawEmgFileSearchButton
            app.RawEmgFileSearchButton = uibutton(app.Panel, 'push');
            app.RawEmgFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.RawEmgFileSearchButton.VerticalAlignment = 'bottom';
            app.RawEmgFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.RawEmgFileSearchButton.Position = [729 107 31 30];
            app.RawEmgFileSearchButton.Text = '';

            % Create RawEMGFileEditFieldLabel
            app.RawEMGFileEditFieldLabel = uilabel(app.Panel);
            app.RawEMGFileEditFieldLabel.HorizontalAlignment = 'right';
            app.RawEMGFileEditFieldLabel.FontSize = 18;
            app.RawEMGFileEditFieldLabel.FontWeight = 'bold';
            app.RawEMGFileEditFieldLabel.Position = [119 107 140 30];
            app.RawEMGFileEditFieldLabel.Text = 'Raw EMG File';

            % Create RawEMGFileEditField
            app.RawEMGFileEditField = uieditfield(app.Panel, 'text');
            app.RawEMGFileEditField.Position = [269 107 450 30];

            % Create RawEmgFileStatus
            app.RawEmgFileStatus = uiimage(app.Panel);
            app.RawEmgFileStatus.Visible = 'off';
            app.RawEmgFileStatus.Position = [762 107 28 30];
            app.RawEmgFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create LowPassCutoffFrequencyLabel
            app.LowPassCutoffFrequencyLabel = uilabel(app.Panel);
            app.LowPassCutoffFrequencyLabel.HorizontalAlignment = 'right';
            app.LowPassCutoffFrequencyLabel.FontSize = 18;
            app.LowPassCutoffFrequencyLabel.FontWeight = 'bold';
            app.LowPassCutoffFrequencyLabel.Position = [154 63 103 23];
            app.LowPassCutoffFrequencyLabel.Text = 'Filter Order';

            % Create FilterOrderEditField
            app.FilterOrderEditField = uieditfield(app.Panel, 'numeric');
            app.FilterOrderEditField.Limits = [0 Inf];
            app.FilterOrderEditField.FontSize = 18;
            app.FilterOrderEditField.Position = [269 62 70 24];
            app.FilterOrderEditField.Value = 4;

            % Create HighPassCutoffFrequencyEditFieldLabel
            app.HighPassCutoffFrequencyEditFieldLabel = uilabel(app.Panel);
            app.HighPassCutoffFrequencyEditFieldLabel.HorizontalAlignment = 'right';
            app.HighPassCutoffFrequencyEditFieldLabel.FontSize = 18;
            app.HighPassCutoffFrequencyEditFieldLabel.FontWeight = 'bold';
            app.HighPassCutoffFrequencyEditFieldLabel.Position = [374 19 154 44];
            app.HighPassCutoffFrequencyEditFieldLabel.Text = {'High Pass'; 'Cutoff Frequency'};

            % Create HighPassCutoffFrequencyEditField
            app.HighPassCutoffFrequencyEditField = uieditfield(app.Panel, 'numeric');
            app.HighPassCutoffFrequencyEditField.Limits = [0 Inf];
            app.HighPassCutoffFrequencyEditField.FontSize = 18;
            app.HighPassCutoffFrequencyEditField.Position = [543 28 70 24];
            app.HighPassCutoffFrequencyEditField.Value = 40;

            % Create LowPassCutoffFrequencyEditField_2Label
            app.LowPassCutoffFrequencyEditField_2Label = uilabel(app.Panel);
            app.LowPassCutoffFrequencyEditField_2Label.HorizontalAlignment = 'right';
            app.LowPassCutoffFrequencyEditField_2Label.FontSize = 18;
            app.LowPassCutoffFrequencyEditField_2Label.FontWeight = 'bold';
            app.LowPassCutoffFrequencyEditField_2Label.Position = [104 8 154 44];
            app.LowPassCutoffFrequencyEditField_2Label.Text = {'Low Pass'; 'Cutoff Frequency'};

            % Create LowPassCutoffFrequencyEditField
            app.LowPassCutoffFrequencyEditField = uieditfield(app.Panel, 'numeric');
            app.LowPassCutoffFrequencyEditField.Limits = [0 Inf];
            app.LowPassCutoffFrequencyEditField.FontSize = 18;
            app.LowPassCutoffFrequencyEditField.Position = [270 18 70 24];
            app.LowPassCutoffFrequencyEditField.Value = 3.5;

            % Create EMGProcessingCheckBox
            app.EMGProcessingCheckBox = uicheckbox(app.Panel);
            app.EMGProcessingCheckBox.Text = 'EMG Processing';
            app.EMGProcessingCheckBox.FontSize = 18;
            app.EMGProcessingCheckBox.FontWeight = 'bold';
            app.EMGProcessingCheckBox.Position = [338 142 165 22];
            app.EMGProcessingCheckBox.Value = true;

            % Create JointAnglesFileSearchButton
            app.JointAnglesFileSearchButton = uibutton(app.UIFigure, 'push');
            app.JointAnglesFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.JointAnglesFileSearchButton.VerticalAlignment = 'bottom';
            app.JointAnglesFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.JointAnglesFileSearchButton.Position = [695 564 31 30];
            app.JointAnglesFileSearchButton.Text = '';

            % Create JointAnglesFileEditFieldLabel
            app.JointAnglesFileEditFieldLabel = uilabel(app.UIFigure);
            app.JointAnglesFileEditFieldLabel.HorizontalAlignment = 'right';
            app.JointAnglesFileEditFieldLabel.FontSize = 18;
            app.JointAnglesFileEditFieldLabel.FontWeight = 'bold';
            app.JointAnglesFileEditFieldLabel.Position = [77 564 148 30];
            app.JointAnglesFileEditFieldLabel.Text = 'Joint Angles File';

            % Create JointAnglesFileEditField
            app.JointAnglesFileEditField = uieditfield(app.UIFigure, 'text');
            app.JointAnglesFileEditField.Position = [235 564 450 30];

            % Create JointAnglesStatus
            app.JointAnglesStatus = uiimage(app.UIFigure);
            app.JointAnglesStatus.Visible = 'off';
            app.JointAnglesStatus.Position = [728 564 28 30];
            app.JointAnglesStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create JointLoadsFileSearchButton
            app.JointLoadsFileSearchButton = uibutton(app.UIFigure, 'push');
            app.JointLoadsFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.JointLoadsFileSearchButton.VerticalAlignment = 'bottom';
            app.JointLoadsFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.JointLoadsFileSearchButton.Position = [695 515 31 30];
            app.JointLoadsFileSearchButton.Text = '';

            % Create JointLoadsFileEditFieldLabel
            app.JointLoadsFileEditFieldLabel = uilabel(app.UIFigure);
            app.JointLoadsFileEditFieldLabel.HorizontalAlignment = 'right';
            app.JointLoadsFileEditFieldLabel.FontSize = 18;
            app.JointLoadsFileEditFieldLabel.FontWeight = 'bold';
            app.JointLoadsFileEditFieldLabel.Position = [83 515 142 30];
            app.JointLoadsFileEditFieldLabel.Text = 'Joint Loads File';

            % Create JointLoadsFileEditField
            app.JointLoadsFileEditField = uieditfield(app.UIFigure, 'text');
            app.JointLoadsFileEditField.Position = [235 515 450 30];

            % Create JointLoadsFileStatus
            app.JointLoadsFileStatus = uiimage(app.UIFigure);
            app.JointLoadsFileStatus.Visible = 'off';
            app.JointLoadsFileStatus.Position = [728 515 28 30];
            app.JointLoadsFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create GroundReactionsFileSearchButton
            app.GroundReactionsFileSearchButton = uibutton(app.UIFigure, 'push');
            app.GroundReactionsFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.GroundReactionsFileSearchButton.VerticalAlignment = 'bottom';
            app.GroundReactionsFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.GroundReactionsFileSearchButton.Position = [695 466 31 30];
            app.GroundReactionsFileSearchButton.Text = '';

            % Create GroundReactionsFileEditFieldLabel
            app.GroundReactionsFileEditFieldLabel = uilabel(app.UIFigure);
            app.GroundReactionsFileEditFieldLabel.HorizontalAlignment = 'right';
            app.GroundReactionsFileEditFieldLabel.FontSize = 18;
            app.GroundReactionsFileEditFieldLabel.FontWeight = 'bold';
            app.GroundReactionsFileEditFieldLabel.Position = [27 466 198 30];
            app.GroundReactionsFileEditFieldLabel.Text = 'Ground Reactions File';

            % Create GroundReactionsFileEditField
            app.GroundReactionsFileEditField = uieditfield(app.UIFigure, 'text');
            app.GroundReactionsFileEditField.Position = [235 466 450 30];

            % Create GroundReactionsFileStatus
            app.GroundReactionsFileStatus = uiimage(app.UIFigure);
            app.GroundReactionsFileStatus.Visible = 'off';
            app.GroundReactionsFileStatus.Position = [728 466 28 30];
            app.GroundReactionsFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MuscleAnalysisDataDirectorySearchButton
            app.MuscleAnalysisDataDirectorySearchButton = uibutton(app.UIFigure, 'push');
            app.MuscleAnalysisDataDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.MuscleAnalysisDataDirectorySearchButton.VerticalAlignment = 'bottom';
            app.MuscleAnalysisDataDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.MuscleAnalysisDataDirectorySearchButton.Position = [695 366 31 30];
            app.MuscleAnalysisDataDirectorySearchButton.Text = '';

            % Create MuscleAnalysisDataDirectoryEditFieldLabel
            app.MuscleAnalysisDataDirectoryEditFieldLabel = uilabel(app.UIFigure);
            app.MuscleAnalysisDataDirectoryEditFieldLabel.HorizontalAlignment = 'right';
            app.MuscleAnalysisDataDirectoryEditFieldLabel.FontSize = 18;
            app.MuscleAnalysisDataDirectoryEditFieldLabel.FontWeight = 'bold';
            app.MuscleAnalysisDataDirectoryEditFieldLabel.Position = [37 359 188 44];
            app.MuscleAnalysisDataDirectoryEditFieldLabel.Text = {'Muscle Analysis'; 'Data Directory'};

            % Create MuscleAnalysisDataDirectoryEditField
            app.MuscleAnalysisDataDirectoryEditField = uieditfield(app.UIFigure, 'text');
            app.MuscleAnalysisDataDirectoryEditField.Position = [235 366 450 30];

            % Create MuscleAnalysisDataDirectoryStatus
            app.MuscleAnalysisDataDirectoryStatus = uiimage(app.UIFigure);
            app.MuscleAnalysisDataDirectoryStatus.Visible = 'off';
            app.MuscleAnalysisDataDirectoryStatus.Position = [728 366 28 30];
            app.MuscleAnalysisDataDirectoryStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create RunMuscleAnalysisButton
            app.RunMuscleAnalysisButton = uibutton(app.UIFigure, 'push');
            app.RunMuscleAnalysisButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.RunMuscleAnalysisButton.FontSize = 18;
            app.RunMuscleAnalysisButton.FontWeight = 'bold';
            app.RunMuscleAnalysisButton.FontColor = [1 1 1];
            app.RunMuscleAnalysisButton.Position = [236 416 210 30];
            app.RunMuscleAnalysisButton.Text = 'Run Muscle Analysis';

            % Create TrialPrefixEditFieldLabel
            app.TrialPrefixEditFieldLabel = uilabel(app.UIFigure);
            app.TrialPrefixEditFieldLabel.HorizontalAlignment = 'right';
            app.TrialPrefixEditFieldLabel.FontSize = 18;
            app.TrialPrefixEditFieldLabel.FontWeight = 'bold';
            app.TrialPrefixEditFieldLabel.Position = [37 319 188 30];
            app.TrialPrefixEditFieldLabel.Text = 'Trial Prefix';

            % Create TrialPrefixEditField
            app.TrialPrefixEditField = uieditfield(app.UIFigure, 'text');
            app.TrialPrefixEditField.Position = [235 319 450 30];
            app.TrialPrefixEditField.Value = 'gait';

            % Create TrialPrefixStatus
            app.TrialPrefixStatus = uiimage(app.UIFigure);
            app.TrialPrefixStatus.Visible = 'off';
            app.TrialPrefixStatus.Position = [686 319 28 30];
            app.TrialPrefixStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create TrialTimePairsTable
            app.TrialTimePairsTable = uitable(app.UIFigure);
            app.TrialTimePairsTable.ColumnName = {'Start Time'; 'End Time'};
            app.TrialTimePairsTable.RowName = {};
            app.TrialTimePairsTable.ColumnEditable = [true true];
            app.TrialTimePairsTable.Position = [236 182 302 117];

            % Create TrialTimePairsLabel
            app.TrialTimePairsLabel = uilabel(app.UIFigure);
            app.TrialTimePairsLabel.HorizontalAlignment = 'right';
            app.TrialTimePairsLabel.FontSize = 18;
            app.TrialTimePairsLabel.FontWeight = 'bold';
            app.TrialTimePairsLabel.Position = [38 225 188 30];
            app.TrialTimePairsLabel.Text = 'Trial Time Pairs';

            % Create NumTimePointsStatus
            app.NumTimePointsStatus = uiimage(app.UIFigure);
            app.NumTimePointsStatus.Visible = 'off';
            app.NumTimePointsStatus.Position = [687 130 28 30];
            app.NumTimePointsStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create NumberofTimePointsEditFieldLabel
            app.NumberofTimePointsEditFieldLabel = uilabel(app.UIFigure);
            app.NumberofTimePointsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofTimePointsEditFieldLabel.FontSize = 18;
            app.NumberofTimePointsEditFieldLabel.FontWeight = 'bold';
            app.NumberofTimePointsEditFieldLabel.Position = [25 132 203 30];
            app.NumberofTimePointsEditFieldLabel.Text = 'Number of Time Points';

            % Create NumberofTimePointsEditField
            app.NumberofTimePointsEditField = uieditfield(app.UIFigure, 'text');
            app.NumberofTimePointsEditField.CharacterLimits = [1 Inf];
            app.NumberofTimePointsEditField.InputType = 'digits';
            app.NumberofTimePointsEditField.Position = [237 130 450 30];
            app.NumberofTimePointsEditField.Value = '101';

            % Create RunDataPreprocessingButton
            app.RunDataPreprocessingButton = uibutton(app.UIFigure, 'push');
            app.RunDataPreprocessingButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.RunDataPreprocessingButton.FontSize = 18;
            app.RunDataPreprocessingButton.FontColor = [1 1 1];
            app.RunDataPreprocessingButton.Position = [305 25 212 30];
            app.RunDataPreprocessingButton.Text = 'Run Data Preprocessing';

            % Create OutputDirectoryLabel
            app.OutputDirectoryLabel = uilabel(app.UIFigure);
            app.OutputDirectoryLabel.HorizontalAlignment = 'right';
            app.OutputDirectoryLabel.FontSize = 18;
            app.OutputDirectoryLabel.FontWeight = 'bold';
            app.OutputDirectoryLabel.Position = [40 81 188 30];
            app.OutputDirectoryLabel.Text = 'Output Directory';

            % Create OutputDirectoryEditField
            app.OutputDirectoryEditField = uieditfield(app.UIFigure, 'text');
            app.OutputDirectoryEditField.Position = [238 81 450 30];
            app.OutputDirectoryEditField.Value = 'preprocessed';

            % Create z
            app.z = uiimage(app.UIFigure);
            app.z.Visible = 'off';
            app.z.Position = [730 81 28 30];
            app.z.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create OutputDirectorySearchButton
            app.OutputDirectorySearchButton = uibutton(app.UIFigure, 'push');
            app.OutputDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.OutputDirectorySearchButton.VerticalAlignment = 'bottom';
            app.OutputDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.OutputDirectorySearchButton.Position = [696 81 31 30];
            app.OutputDirectorySearchButton.Text = '';

            % Create ProcessedEmgFileSearchButton
            app.ProcessedEmgFileSearchButton = uibutton(app.UIFigure, 'push');
            app.ProcessedEmgFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.ProcessedEmgFileSearchButton.VerticalAlignment = 'bottom';
            app.ProcessedEmgFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.ProcessedEmgFileSearchButton.Position = [695 613 31 30];
            app.ProcessedEmgFileSearchButton.Text = '';

            % Create ProcessedEMGFileEditFieldLabel
            app.ProcessedEMGFileEditFieldLabel = uilabel(app.UIFigure);
            app.ProcessedEMGFileEditFieldLabel.HorizontalAlignment = 'right';
            app.ProcessedEMGFileEditFieldLabel.FontSize = 18;
            app.ProcessedEMGFileEditFieldLabel.FontWeight = 'bold';
            app.ProcessedEMGFileEditFieldLabel.Position = [47 613 178 30];
            app.ProcessedEMGFileEditFieldLabel.Text = 'Processed EMG File';

            % Create ProcessedEMGFileEditField
            app.ProcessedEMGFileEditField = uieditfield(app.UIFigure, 'text');
            app.ProcessedEMGFileEditField.Position = [235 613 450 30];

            % Create ProcessedEmgFileStatus
            app.ProcessedEmgFileStatus = uiimage(app.UIFigure);
            app.ProcessedEmgFileStatus.Visible = 'off';
            app.ProcessedEmgFileStatus.Position = [728 613 28 30];
            app.ProcessedEmgFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = DataPreprocessingGui

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

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