classdef NMSMPipelineGUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        SimTKForumButton                matlab.ui.control.Button
        EmailnmsmriceeduButton          matlab.ui.control.Button
        httpsnmsmriceeduButton          matlab.ui.control.Button
        AdvancedTutorialsButton         matlab.ui.control.Button
        IntermediateTutorialsButton     matlab.ui.control.Button
        BeginnerTutorialsButton         matlab.ui.control.Button
        DocumentationButton_5           matlab.ui.control.Button
        DocumentationButton_4           matlab.ui.control.Button
        DocumentationButton_3           matlab.ui.control.Button
        DocumentationButton_2           matlab.ui.control.Button
        DocumentationButton             matlab.ui.control.Button
        MuscleGroupsCreatorButton       matlab.ui.control.Button
        SurrogateMuscleModelButton      matlab.ui.control.Button
        DataPreprocessingButton         matlab.ui.control.Button
        TreatmentOptimizationLabel      matlab.ui.control.Label
        NeuralControlModelPersonalizationLabel  matlab.ui.control.Label
        MuscleTendonModelPersonalizationLabel  matlab.ui.control.Label
        GroundContactModelPersonalizationLabel  matlab.ui.control.Label
        JointModelPersonalizationLabel  matlab.ui.control.Label
        Image4_5                        matlab.ui.control.Image
        Image4_4                        matlab.ui.control.Image
        Image4_3                        matlab.ui.control.Image
        Image4_2                        matlab.ui.control.Image
        Image4                          matlab.ui.control.Image
        RiceLogo                        matlab.ui.control.Image
        RiceComputationalNeuromechanicsLabLabel  matlab.ui.control.Label
        RcnlLogo                        matlab.ui.control.Image
        NeuromusculoskeletalModelingPipelineLabel  matlab.ui.control.Label
        BlueMask                        matlab.ui.control.Image
        Button_2                        matlab.ui.control.Button
        Button_3                        matlab.ui.control.Button
        Button_4                        matlab.ui.control.Button
        Button_5                        matlab.ui.control.Button
        Button_6                        matlab.ui.control.Button
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
            app.UIFigure.Position = [100 100 1786 1053];
            app.UIFigure.Name = 'MATLAB App';

            % Create Button_6
            app.Button_6 = uibutton(app.UIFigure, 'push');
            app.Button_6.BackgroundColor = [0.851 0.851 0.851];
            app.Button_6.FontColor = [0.0706 0.4392 0.749];
            app.Button_6.Position = [1426 371 277 530];

            % Create Button_5
            app.Button_5 = uibutton(app.UIFigure, 'push');
            app.Button_5.BackgroundColor = [0.851 0.851 0.851];
            app.Button_5.FontColor = [0.0706 0.4392 0.749];
            app.Button_5.Position = [1091 370 277 530];

            % Create Button_4
            app.Button_4 = uibutton(app.UIFigure, 'push');
            app.Button_4.BackgroundColor = [0.851 0.851 0.851];
            app.Button_4.FontColor = [0.0706 0.4392 0.749];
            app.Button_4.Position = [756 370 277 530];

            % Create Button_3
            app.Button_3 = uibutton(app.UIFigure, 'push');
            app.Button_3.BackgroundColor = [0.851 0.851 0.851];
            app.Button_3.FontColor = [0.0706 0.4392 0.749];
            app.Button_3.Position = [85 371 277 530];

            % Create Button_2
            app.Button_2 = uibutton(app.UIFigure, 'push');
            app.Button_2.BackgroundColor = [0.851 0.851 0.851];
            app.Button_2.FontColor = [0.0706 0.4392 0.749];
            app.Button_2.Position = [420 371 277 530];

            % Create BlueMask
            app.BlueMask = uiimage(app.UIFigure);
            app.BlueMask.ScaleMethod = 'fill';
            app.BlueMask.Position = [1 954 1786 100];
            app.BlueMask.ImageSource = fullfile(pathToMLAPP, 'Images', 'blueMask.png');

            % Create NeuromusculoskeletalModelingPipelineLabel
            app.NeuromusculoskeletalModelingPipelineLabel = uilabel(app.UIFigure);
            app.NeuromusculoskeletalModelingPipelineLabel.FontSize = 40;
            app.NeuromusculoskeletalModelingPipelineLabel.FontWeight = 'bold';
            app.NeuromusculoskeletalModelingPipelineLabel.FontColor = [1 1 1];
            app.NeuromusculoskeletalModelingPipelineLabel.Position = [493 978 801 52];
            app.NeuromusculoskeletalModelingPipelineLabel.Text = 'Neuromusculoskeletal Modeling Pipeline';

            % Create RcnlLogo
            app.RcnlLogo = uiimage(app.UIFigure);
            app.RcnlLogo.Position = [1 954 100 100];
            app.RcnlLogo.ImageSource = fullfile(pathToMLAPP, 'Images', 'rcnlIcon.png');

            % Create RiceComputationalNeuromechanicsLabLabel
            app.RiceComputationalNeuromechanicsLabLabel = uilabel(app.UIFigure);
            app.RiceComputationalNeuromechanicsLabLabel.HorizontalAlignment = 'center';
            app.RiceComputationalNeuromechanicsLabLabel.FontSize = 24;
            app.RiceComputationalNeuromechanicsLabLabel.FontColor = [1 1 1];
            app.RiceComputationalNeuromechanicsLabLabel.Position = [100 971 234 59];
            app.RiceComputationalNeuromechanicsLabLabel.Text = {'Rice Computational'; 'Neuromechanics Lab'};

            % Create RiceLogo
            app.RiceLogo = uiimage(app.UIFigure);
            app.RiceLogo.ScaleMethod = 'fill';
            app.RiceLogo.Position = [1512 954 275 100];
            app.RiceLogo.ImageSource = fullfile(pathToMLAPP, 'Images', 'riceLogo.png');

            % Create Image4
            app.Image4 = uiimage(app.UIFigure);
            app.Image4.Position = [135 381 185 440];
            app.Image4.ImageSource = fullfile(pathToMLAPP, 'Images', 'jmpFigure.png');

            % Create Image4_2
            app.Image4_2 = uiimage(app.UIFigure);
            app.Image4_2.Position = [1149 391 161 429];
            app.Image4_2.ImageSource = fullfile(pathToMLAPP, 'Images', 'ncpFigure.png');

            % Create Image4_3
            app.Image4_3 = uiimage(app.UIFigure);
            app.Image4_3.Position = [473 381 170 440];
            app.Image4_3.ImageSource = fullfile(pathToMLAPP, 'Images', 'gcpFigure.png');

            % Create Image4_4
            app.Image4_4 = uiimage(app.UIFigure);
            app.Image4_4.Position = [802 388 185 432];
            app.Image4_4.ImageSource = fullfile(pathToMLAPP, 'Images', 'mtpFigure.png');

            % Create Image4_5
            app.Image4_5 = uiimage(app.UIFigure);
            app.Image4_5.Position = [1482 392 165 429];
            app.Image4_5.ImageSource = fullfile(pathToMLAPP, 'Images', 'treoptFigure.png');

            % Create JointModelPersonalizationLabel
            app.JointModelPersonalizationLabel = uilabel(app.UIFigure);
            app.JointModelPersonalizationLabel.HorizontalAlignment = 'center';
            app.JointModelPersonalizationLabel.FontSize = 25;
            app.JointModelPersonalizationLabel.FontWeight = 'bold';
            app.JointModelPersonalizationLabel.FontColor = [0 0 0];
            app.JointModelPersonalizationLabel.Position = [132 829 191 62];
            app.JointModelPersonalizationLabel.Text = {'Joint Model'; 'Personalization'};

            % Create GroundContactModelPersonalizationLabel
            app.GroundContactModelPersonalizationLabel = uilabel(app.UIFigure);
            app.GroundContactModelPersonalizationLabel.HorizontalAlignment = 'center';
            app.GroundContactModelPersonalizationLabel.FontSize = 25;
            app.GroundContactModelPersonalizationLabel.FontWeight = 'bold';
            app.GroundContactModelPersonalizationLabel.Position = [420 829 277 62];
            app.GroundContactModelPersonalizationLabel.Text = {'Ground Contact Model'; 'Personalization'};

            % Create MuscleTendonModelPersonalizationLabel
            app.MuscleTendonModelPersonalizationLabel = uilabel(app.UIFigure);
            app.MuscleTendonModelPersonalizationLabel.HorizontalAlignment = 'center';
            app.MuscleTendonModelPersonalizationLabel.FontSize = 25;
            app.MuscleTendonModelPersonalizationLabel.FontWeight = 'bold';
            app.MuscleTendonModelPersonalizationLabel.Position = [761 828 269 62];
            app.MuscleTendonModelPersonalizationLabel.Text = {'Muscle-Tendon Model'; 'Personalization'};

            % Create NeuralControlModelPersonalizationLabel
            app.NeuralControlModelPersonalizationLabel = uilabel(app.UIFigure);
            app.NeuralControlModelPersonalizationLabel.HorizontalAlignment = 'center';
            app.NeuralControlModelPersonalizationLabel.FontSize = 25;
            app.NeuralControlModelPersonalizationLabel.FontWeight = 'bold';
            app.NeuralControlModelPersonalizationLabel.Position = [1100 828 261 62];
            app.NeuralControlModelPersonalizationLabel.Text = {'Neural Control Model'; 'Personalization'};

            % Create TreatmentOptimizationLabel
            app.TreatmentOptimizationLabel = uilabel(app.UIFigure);
            app.TreatmentOptimizationLabel.HorizontalAlignment = 'center';
            app.TreatmentOptimizationLabel.FontSize = 25;
            app.TreatmentOptimizationLabel.FontWeight = 'bold';
            app.TreatmentOptimizationLabel.Position = [1487 828 156 62];
            app.TreatmentOptimizationLabel.Text = {'Treatment'; 'Optimization'};

            % Create DataPreprocessingButton
            app.DataPreprocessingButton = uibutton(app.UIFigure, 'push');
            app.DataPreprocessingButton.BackgroundColor = [0.851 0.851 0.851];
            app.DataPreprocessingButton.FontSize = 25;
            app.DataPreprocessingButton.FontWeight = 'bold';
            app.DataPreprocessingButton.Position = [85 226 308 64];
            app.DataPreprocessingButton.Text = 'Data Preprocessing';

            % Create SurrogateMuscleModelButton
            app.SurrogateMuscleModelButton = uibutton(app.UIFigure, 'push');
            app.SurrogateMuscleModelButton.BackgroundColor = [0.851 0.851 0.851];
            app.SurrogateMuscleModelButton.FontSize = 25;
            app.SurrogateMuscleModelButton.FontWeight = 'bold';
            app.SurrogateMuscleModelButton.Position = [85 143 308 64];
            app.SurrogateMuscleModelButton.Text = 'Surrogate Muscle Model';

            % Create MuscleGroupsCreatorButton
            app.MuscleGroupsCreatorButton = uibutton(app.UIFigure, 'push');
            app.MuscleGroupsCreatorButton.BackgroundColor = [0.851 0.851 0.851];
            app.MuscleGroupsCreatorButton.FontSize = 25;
            app.MuscleGroupsCreatorButton.FontWeight = 'bold';
            app.MuscleGroupsCreatorButton.Position = [85 60 308 64];
            app.MuscleGroupsCreatorButton.Text = 'Muscle Groups Creator';

            % Create DocumentationButton
            app.DocumentationButton = uibutton(app.UIFigure, 'push');
            app.DocumentationButton.BackgroundColor = [0.851 0.851 0.851];
            app.DocumentationButton.FontSize = 18;
            app.DocumentationButton.FontWeight = 'bold';
            app.DocumentationButton.Position = [85 334 277 38];
            app.DocumentationButton.Text = 'Documentation';

            % Create DocumentationButton_2
            app.DocumentationButton_2 = uibutton(app.UIFigure, 'push');
            app.DocumentationButton_2.BackgroundColor = [0.851 0.851 0.851];
            app.DocumentationButton_2.FontSize = 18;
            app.DocumentationButton_2.FontWeight = 'bold';
            app.DocumentationButton_2.Position = [420 334 277 38];
            app.DocumentationButton_2.Text = 'Documentation';

            % Create DocumentationButton_3
            app.DocumentationButton_3 = uibutton(app.UIFigure, 'push');
            app.DocumentationButton_3.BackgroundColor = [0.851 0.851 0.851];
            app.DocumentationButton_3.FontSize = 18;
            app.DocumentationButton_3.FontWeight = 'bold';
            app.DocumentationButton_3.Position = [755 333 277 38];
            app.DocumentationButton_3.Text = 'Documentation';

            % Create DocumentationButton_4
            app.DocumentationButton_4 = uibutton(app.UIFigure, 'push');
            app.DocumentationButton_4.BackgroundColor = [0.851 0.851 0.851];
            app.DocumentationButton_4.FontSize = 18;
            app.DocumentationButton_4.FontWeight = 'bold';
            app.DocumentationButton_4.Position = [1091 333 277 38];
            app.DocumentationButton_4.Text = 'Documentation';

            % Create DocumentationButton_5
            app.DocumentationButton_5 = uibutton(app.UIFigure, 'push');
            app.DocumentationButton_5.BackgroundColor = [0.851 0.851 0.851];
            app.DocumentationButton_5.FontSize = 18;
            app.DocumentationButton_5.FontWeight = 'bold';
            app.DocumentationButton_5.Position = [1426 334 277 38];
            app.DocumentationButton_5.Text = 'Documentation';

            % Create BeginnerTutorialsButton
            app.BeginnerTutorialsButton = uibutton(app.UIFigure, 'push');
            app.BeginnerTutorialsButton.BackgroundColor = [0.851 0.851 0.851];
            app.BeginnerTutorialsButton.FontSize = 25;
            app.BeginnerTutorialsButton.FontWeight = 'bold';
            app.BeginnerTutorialsButton.FontColor = [0.0667 0.4431 0.7451];
            app.BeginnerTutorialsButton.Position = [755 226 278 64];
            app.BeginnerTutorialsButton.Text = 'Beginner Tutorials';

            % Create IntermediateTutorialsButton
            app.IntermediateTutorialsButton = uibutton(app.UIFigure, 'push');
            app.IntermediateTutorialsButton.BackgroundColor = [0.851 0.851 0.851];
            app.IntermediateTutorialsButton.FontSize = 25;
            app.IntermediateTutorialsButton.FontWeight = 'bold';
            app.IntermediateTutorialsButton.FontColor = [0.0667 0.4431 0.7451];
            app.IntermediateTutorialsButton.Position = [757 143 277 64];
            app.IntermediateTutorialsButton.Text = 'IntermediateTutorials';

            % Create AdvancedTutorialsButton
            app.AdvancedTutorialsButton = uibutton(app.UIFigure, 'push');
            app.AdvancedTutorialsButton.BackgroundColor = [0.851 0.851 0.851];
            app.AdvancedTutorialsButton.FontSize = 25;
            app.AdvancedTutorialsButton.FontWeight = 'bold';
            app.AdvancedTutorialsButton.FontColor = [0.0667 0.4431 0.7451];
            app.AdvancedTutorialsButton.Position = [757 60 277 64];
            app.AdvancedTutorialsButton.Text = 'Advanced Tutorials';

            % Create httpsnmsmriceeduButton
            app.httpsnmsmriceeduButton = uibutton(app.UIFigure, 'push');
            app.httpsnmsmriceeduButton.BackgroundColor = [0.851 0.851 0.851];
            app.httpsnmsmriceeduButton.FontSize = 25;
            app.httpsnmsmriceeduButton.FontWeight = 'bold';
            app.httpsnmsmriceeduButton.FontColor = [0.0667 0.4431 0.7451];
            app.httpsnmsmriceeduButton.Position = [1426 226 285 64];
            app.httpsnmsmriceeduButton.Text = 'https://nmsm.rice.edu/';

            % Create EmailnmsmriceeduButton
            app.EmailnmsmriceeduButton = uibutton(app.UIFigure, 'push');
            app.EmailnmsmriceeduButton.BackgroundColor = [0.851 0.851 0.851];
            app.EmailnmsmriceeduButton.FontSize = 25;
            app.EmailnmsmriceeduButton.FontWeight = 'bold';
            app.EmailnmsmriceeduButton.FontColor = [0.0667 0.4431 0.7451];
            app.EmailnmsmriceeduButton.Position = [1426 143 285 64];
            app.EmailnmsmriceeduButton.Text = 'Email: nmsm@rice.edu';

            % Create SimTKForumButton
            app.SimTKForumButton = uibutton(app.UIFigure, 'push');
            app.SimTKForumButton.BackgroundColor = [0.851 0.851 0.851];
            app.SimTKForumButton.FontSize = 25;
            app.SimTKForumButton.FontWeight = 'bold';
            app.SimTKForumButton.FontColor = [0.0667 0.4431 0.7451];
            app.SimTKForumButton.Position = [1426 60 288 64];
            app.SimTKForumButton.Text = 'SimTK Forum';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = NMSMPipelineGUI

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