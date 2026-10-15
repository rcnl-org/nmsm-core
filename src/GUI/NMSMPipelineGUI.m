% This class is part of the NMSM Pipeline, see file for full license.
%
% This class is the cover window of the NMSM Pipeline GUI. It opens each
% tool's GUI, keeping at most one window per tool open at a time, and
% links to the NMSM Pipeline documentation, tutorials and support. Its
% layout is edited in NMSMPipelineGUIVisual.mlapp.

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
classdef NMSMPipelineGUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        SimTKForumButton                matlab.ui.control.Button
        EmailButton                     matlab.ui.control.Button
        NmsmWebsiteButton               matlab.ui.control.Button
        RCNL2026ModelButton             matlab.ui.control.Button
        NMSMPipelineInputsButton        matlab.ui.control.Button
        DataCollectionGuideButton       matlab.ui.control.Button
        AdvancedTutorialsButton         matlab.ui.control.Button
        IntermediateTutorialsButton     matlab.ui.control.Button
        BeginnerTutorialsButton         matlab.ui.control.Button
        TreOptDocumentationButton       matlab.ui.control.Button
        NcpDocumentationButton          matlab.ui.control.Button
        MtpDocumentationButton          matlab.ui.control.Button
        GcpDocumentationButton          matlab.ui.control.Button
        JmpDocumentationButton          matlab.ui.control.Button
        MuscleGroupsCreatorButton       matlab.ui.control.Button
        SurrogateMuscleModelButton      matlab.ui.control.Button
        DataPreprocessingButton         matlab.ui.control.Button
        TreatmentOptimizationLabel      matlab.ui.control.Label
        NeuralControlModelPersonalizationLabel  matlab.ui.control.Label
        MuscleTendonModelPersonalizationLabel  matlab.ui.control.Label
        GroundContactModelPersonalizationLabel  matlab.ui.control.Label
        JointModelPersonalizationLabel  matlab.ui.control.Label
        TreOptFigure                    matlab.ui.control.Image
        MtpFigure                       matlab.ui.control.Image
        GcpFigure                       matlab.ui.control.Image
        NcpFigure                       matlab.ui.control.Image
        JmpFigure                       matlab.ui.control.Image
        RiceLogo                        matlab.ui.control.Image
        RiceComputationalNeuromechanicsLabLabel  matlab.ui.control.Label
        RcnlLogo                        matlab.ui.control.Image
        NeuromusculoskeletalModelingPipelineLabel  matlab.ui.control.Label
        BlueMask                        matlab.ui.control.Image
        GcpButton                       matlab.ui.control.Button
        JmpButton                       matlab.ui.control.Button
        MtpButton                       matlab.ui.control.Button
        NcpButton                       matlab.ui.control.Button
        TreOptButton                    matlab.ui.control.Button
        EmailContextMenu                matlab.ui.container.ContextMenu
        CopyEmailMenu                   matlab.ui.container.Menu
    end

    properties (Access = private)
        % The tool apps this window opened, one field per app class name.
        % A tool's app is deleted when its window closes, so an invalid
        % handle means the tool has to be opened again.
        toolApps struct = struct()
    end

    properties (Constant, Access = private)
        emailAddress = "nmsm@rice.edu"
    end

    methods (Access = private)

        % Opens a tool's GUI, or brings its window forward if this window
        % already opened one, so each tool has at most one window
        function openTool(app, className)
            if isfield(app.toolApps, className)
                tool = app.toolApps.(className);
                if isvalid(tool) && isvalid(tool.UIFigure)
                    if strcmp(tool.UIFigure.WindowState, 'minimized')
                        tool.UIFigure.WindowState = 'normal';
                    end
                    figure(tool.UIFigure);
                    return
                end
            end
            try
                app.toolApps.(className) = feval(className);
            catch exception
                uialert(app.UIFigure, exception.message, ...
                    "Could not open " + className);
            end
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            enableButtonHoverPointerGui(app.UIFigure);
            % These tools are not linked yet
            for button = [app.MuscleGroupsCreatorButton, ...
                    app.DataCollectionGuideButton]
                button.Enable = 'off';
                button.Tooltip = 'Coming soon';
            end
        end

        % Button pushed function: DataPreprocessingButton
        function DataPreprocessingButtonPushed(app, event)
            app.openTool("DataPreprocessingGui");
        end

        % Button pushed function: SurrogateMuscleModelButton
        function SurrogateMuscleModelButtonPushed(app, event)
            app.openTool("SurrogateModelGui");
        end

        % Button pushed function: JmpButton, image clicked function:
        % JmpFigure
        function JmpButtonPushed(app, event)
            app.openTool("JMPBase");
        end

        % Button pushed function: GcpButton, image clicked function:
        % GcpFigure
        function GcpButtonPushed(app, event)
            app.openTool("GCPBase");
        end

        % Button pushed function: MtpButton, image clicked function:
        % MtpFigure
        function MtpButtonPushed(app, event)
            app.openTool("MTPBase");
        end

        % Button pushed function: NcpButton, image clicked function:
        % NcpFigure
        function NcpButtonPushed(app, event)
            app.openTool("NCPBase");
        end

        % Button pushed function: TreOptButton, image clicked function:
        % TreOptFigure
        function TreOptButtonPushed(app, event)
            app.openTool("TreatmentOptimizationBase");
        end

        % Button pushed function: JmpDocumentationButton
        function JmpDocumentationButtonPushed(app, event)
            web("https://nmsm.rice.edu/guides-and-publications/tool-overviews/model-personalization/joint-model-personalization/")
        end

        % Button pushed function: GcpDocumentationButton
        function GcpDocumentationButtonPushed(app, event)
            web("https://nmsm.rice.edu/guides-and-publications/tool-overviews/model-personalization/ground-contact-personalization/")
        end

        % Button pushed function: MtpDocumentationButton
        function MtpDocumentationButtonPushed(app, event)
            web("https://nmsm.rice.edu/guides-and-publications/tool-overviews/model-personalization/muscle-tendon-personalization/")
        end

        % Button pushed function: NcpDocumentationButton
        function NcpDocumentationButtonPushed(app, event)
            web("https://nmsm.rice.edu/guides-and-publications/tool-overviews/model-personalization/neural-control-personalization/")
        end

        % Button pushed function: TreOptDocumentationButton
        function TreOptDocumentationButtonPushed(app, event)
            web("https://nmsm.rice.edu/guides-and-publications/tool-overviews/treatment-optimization/")
        end

        % Button pushed function: BeginnerTutorialsButton
        function BeginnerTutorialsButtonPushed(app, event)
            web("https://nmsm.rice.edu/guides-and-publications/tutorials/beginner-tutorials/beginner-tutorials/")
        end

        % Button pushed function: IntermediateTutorialsButton
        function IntermediateTutorialsButtonPushed(app, event)
            web("https://nmsm.rice.edu/guides-and-publications/tutorials/intermediate-tutorials/kicking-tutorial/")
        end

        % Button pushed function: AdvancedTutorialsButton
        function AdvancedTutorialsButtonPushed(app, event)
            web("https://nmsm.rice.edu/guides-and-publications/tutorials/advanced-tutorials/advanced-tutorials/")
        end

        % Button pushed function: NMSMPipelineInputsButton
        function NMSMPipelineInputsButtonPushed(app, event)
            web("https://nmsm.rice.edu/models-and-data/pipeline-inputs/")
        end

        % Button pushed function: RCNL2026ModelButton
        function RCNL2026ModelButtonPushed(app, event)
            web("https://nmsm.rice.edu/models-and-data/rcnl-model/")
        end

        % Button pushed function: NmsmWebsiteButton
        function NmsmWebsiteButtonPushed(app, event)
            web("https://nmsm.rice.edu/")
        end

        % Button pushed function: SimTKForumButton
        function SimTKForumButtonPushed(app, event)
            web("https://simtk.org/plugins/phpBB/indexPhpbb.php?group_id=2397&pluginname=phpBB")
        end

        % Image clicked function: RcnlLogo
        function RcnlLogoImageClicked(app, event)
            web("https://rcnl.rice.edu/")
        end

        % Button pushed function: EmailButton
        function EmailButtonPushed(app, event)
            % A mailto link opens a message in the default email app
            web("mailto:" + app.emailAddress)
        end

        % Menu selected function: CopyEmailMenu
        function CopyEmailMenuSelected(app, event)
            clipboard('copy', char(app.emailAddress));
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
            app.UIFigure.Position = [100 100 1786 1053];
            app.UIFigure.Name = 'MATLAB App';

            % Create TreOptButton
            app.TreOptButton = uibutton(app.UIFigure, 'push');
            app.TreOptButton.ButtonPushedFcn = createCallbackFcn(app, @TreOptButtonPushed, true);
            app.TreOptButton.Icon = fullfile(pathToMLAPP, 'Images', 'treoptFigure.png');
            app.TreOptButton.BackgroundColor = [0.851 0.851 0.851];
            app.TreOptButton.FontColor = [0.0706 0.4392 0.749];
            app.TreOptButton.Position = [1426 371 277 459];
            app.TreOptButton.Text = '';

            % Create NcpButton
            app.NcpButton = uibutton(app.UIFigure, 'push');
            app.NcpButton.ButtonPushedFcn = createCallbackFcn(app, @NcpButtonPushed, true);
            app.NcpButton.Icon = fullfile(pathToMLAPP, 'Images', 'ncpFigure.png');
            app.NcpButton.BackgroundColor = [0.851 0.851 0.851];
            app.NcpButton.FontColor = [0.0706 0.4392 0.749];
            app.NcpButton.Position = [1091 370 277 460];
            app.NcpButton.Text = '';

            % Create MtpButton
            app.MtpButton = uibutton(app.UIFigure, 'push');
            app.MtpButton.ButtonPushedFcn = createCallbackFcn(app, @MtpButtonPushed, true);
            app.MtpButton.Icon = fullfile(pathToMLAPP, 'Images', 'mtpFigure.png');
            app.MtpButton.IconAlignment = 'center';
            app.MtpButton.BackgroundColor = [0.851 0.851 0.851];
            app.MtpButton.FontColor = [0.0706 0.4392 0.749];
            app.MtpButton.Position = [756 370 277 460];
            app.MtpButton.Text = '';

            % Create JmpButton
            app.JmpButton = uibutton(app.UIFigure, 'push');
            app.JmpButton.ButtonPushedFcn = createCallbackFcn(app, @JmpButtonPushed, true);
            app.JmpButton.Icon = fullfile(pathToMLAPP, 'Images', 'jmpFigure.png');
            app.JmpButton.BackgroundColor = [0.851 0.851 0.851];
            app.JmpButton.FontColor = [0.0706 0.4392 0.749];
            app.JmpButton.Position = [85 371 277 459];
            app.JmpButton.Text = '';

            % Create GcpButton
            app.GcpButton = uibutton(app.UIFigure, 'push');
            app.GcpButton.ButtonPushedFcn = createCallbackFcn(app, @GcpButtonPushed, true);
            app.GcpButton.Icon = fullfile(pathToMLAPP, 'Images', 'gcpFigure.png');
            app.GcpButton.BackgroundColor = [0.851 0.851 0.851];
            app.GcpButton.FontColor = [0.0706 0.4392 0.749];
            app.GcpButton.Position = [420 371 277 459];
            app.GcpButton.Text = '';

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
            app.RcnlLogo.ImageClickedFcn = createCallbackFcn(app, @RcnlLogoImageClicked, true);
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
            app.DataPreprocessingButton.ButtonPushedFcn = createCallbackFcn(app, @DataPreprocessingButtonPushed, true);
            app.DataPreprocessingButton.BackgroundColor = [0.851 0.851 0.851];
            app.DataPreprocessingButton.FontSize = 25;
            app.DataPreprocessingButton.FontWeight = 'bold';
            app.DataPreprocessingButton.Position = [85 226 308 64];
            app.DataPreprocessingButton.Text = 'Data Preprocessing';

            % Create SurrogateMuscleModelButton
            app.SurrogateMuscleModelButton = uibutton(app.UIFigure, 'push');
            app.SurrogateMuscleModelButton.ButtonPushedFcn = createCallbackFcn(app, @SurrogateMuscleModelButtonPushed, true);
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

            % Create JmpDocumentationButton
            app.JmpDocumentationButton = uibutton(app.UIFigure, 'push');
            app.JmpDocumentationButton.ButtonPushedFcn = createCallbackFcn(app, @JmpDocumentationButtonPushed, true);
            app.JmpDocumentationButton.BackgroundColor = [0.851 0.851 0.851];
            app.JmpDocumentationButton.FontSize = 18;
            app.JmpDocumentationButton.FontWeight = 'bold';
            app.JmpDocumentationButton.FontColor = [0.0706 0.4392 0.749];
            app.JmpDocumentationButton.Position = [85 334 277 38];
            app.JmpDocumentationButton.Text = 'Documentation';

            % Create GcpDocumentationButton
            app.GcpDocumentationButton = uibutton(app.UIFigure, 'push');
            app.GcpDocumentationButton.ButtonPushedFcn = createCallbackFcn(app, @GcpDocumentationButtonPushed, true);
            app.GcpDocumentationButton.BackgroundColor = [0.851 0.851 0.851];
            app.GcpDocumentationButton.FontSize = 18;
            app.GcpDocumentationButton.FontWeight = 'bold';
            app.GcpDocumentationButton.FontColor = [0.0706 0.4392 0.749];
            app.GcpDocumentationButton.Position = [420 334 277 38];
            app.GcpDocumentationButton.Text = 'Documentation';

            % Create MtpDocumentationButton
            app.MtpDocumentationButton = uibutton(app.UIFigure, 'push');
            app.MtpDocumentationButton.ButtonPushedFcn = createCallbackFcn(app, @MtpDocumentationButtonPushed, true);
            app.MtpDocumentationButton.BackgroundColor = [0.851 0.851 0.851];
            app.MtpDocumentationButton.FontSize = 18;
            app.MtpDocumentationButton.FontWeight = 'bold';
            app.MtpDocumentationButton.FontColor = [0.0706 0.4392 0.749];
            app.MtpDocumentationButton.Position = [755 333 277 38];
            app.MtpDocumentationButton.Text = 'Documentation';

            % Create NcpDocumentationButton
            app.NcpDocumentationButton = uibutton(app.UIFigure, 'push');
            app.NcpDocumentationButton.ButtonPushedFcn = createCallbackFcn(app, @NcpDocumentationButtonPushed, true);
            app.NcpDocumentationButton.BackgroundColor = [0.851 0.851 0.851];
            app.NcpDocumentationButton.FontSize = 18;
            app.NcpDocumentationButton.FontWeight = 'bold';
            app.NcpDocumentationButton.FontColor = [0.0706 0.4392 0.749];
            app.NcpDocumentationButton.Position = [1091 333 277 38];
            app.NcpDocumentationButton.Text = 'Documentation';

            % Create TreOptDocumentationButton
            app.TreOptDocumentationButton = uibutton(app.UIFigure, 'push');
            app.TreOptDocumentationButton.ButtonPushedFcn = createCallbackFcn(app, @TreOptDocumentationButtonPushed, true);
            app.TreOptDocumentationButton.BackgroundColor = [0.851 0.851 0.851];
            app.TreOptDocumentationButton.FontSize = 18;
            app.TreOptDocumentationButton.FontWeight = 'bold';
            app.TreOptDocumentationButton.FontColor = [0.0706 0.4392 0.749];
            app.TreOptDocumentationButton.Position = [1426 334 277 38];
            app.TreOptDocumentationButton.Text = 'Documentation';

            % Create BeginnerTutorialsButton
            app.BeginnerTutorialsButton = uibutton(app.UIFigure, 'push');
            app.BeginnerTutorialsButton.ButtonPushedFcn = createCallbackFcn(app, @BeginnerTutorialsButtonPushed, true);
            app.BeginnerTutorialsButton.BackgroundColor = [0.851 0.851 0.851];
            app.BeginnerTutorialsButton.FontSize = 25;
            app.BeginnerTutorialsButton.FontWeight = 'bold';
            app.BeginnerTutorialsButton.FontColor = [0.0667 0.4431 0.7451];
            app.BeginnerTutorialsButton.Position = [755 226 278 64];
            app.BeginnerTutorialsButton.Text = 'Beginner Tutorials';

            % Create IntermediateTutorialsButton
            app.IntermediateTutorialsButton = uibutton(app.UIFigure, 'push');
            app.IntermediateTutorialsButton.ButtonPushedFcn = createCallbackFcn(app, @IntermediateTutorialsButtonPushed, true);
            app.IntermediateTutorialsButton.BackgroundColor = [0.851 0.851 0.851];
            app.IntermediateTutorialsButton.FontSize = 25;
            app.IntermediateTutorialsButton.FontWeight = 'bold';
            app.IntermediateTutorialsButton.FontColor = [0.0667 0.4431 0.7451];
            app.IntermediateTutorialsButton.Position = [757 143 277 64];
            app.IntermediateTutorialsButton.Text = 'IntermediateTutorials';

            % Create AdvancedTutorialsButton
            app.AdvancedTutorialsButton = uibutton(app.UIFigure, 'push');
            app.AdvancedTutorialsButton.ButtonPushedFcn = createCallbackFcn(app, @AdvancedTutorialsButtonPushed, true);
            app.AdvancedTutorialsButton.BackgroundColor = [0.851 0.851 0.851];
            app.AdvancedTutorialsButton.FontSize = 25;
            app.AdvancedTutorialsButton.FontWeight = 'bold';
            app.AdvancedTutorialsButton.FontColor = [0.0667 0.4431 0.7451];
            app.AdvancedTutorialsButton.Position = [757 60 277 64];
            app.AdvancedTutorialsButton.Text = 'Advanced Tutorials';

            % Create DataCollectionGuideButton
            app.DataCollectionGuideButton = uibutton(app.UIFigure, 'push');
            app.DataCollectionGuideButton.BackgroundColor = [0.851 0.851 0.851];
            app.DataCollectionGuideButton.FontSize = 25;
            app.DataCollectionGuideButton.FontWeight = 'bold';
            app.DataCollectionGuideButton.FontColor = [0.0667 0.4431 0.7451];
            app.DataCollectionGuideButton.Position = [1087 226 285 64];
            app.DataCollectionGuideButton.Text = 'Data Collection Guide';

            % Create NMSMPipelineInputsButton
            app.NMSMPipelineInputsButton = uibutton(app.UIFigure, 'push');
            app.NMSMPipelineInputsButton.ButtonPushedFcn = createCallbackFcn(app, @NMSMPipelineInputsButtonPushed, true);
            app.NMSMPipelineInputsButton.BackgroundColor = [0.851 0.851 0.851];
            app.NMSMPipelineInputsButton.FontSize = 25;
            app.NMSMPipelineInputsButton.FontWeight = 'bold';
            app.NMSMPipelineInputsButton.FontColor = [0.0706 0.4392 0.749];
            app.NMSMPipelineInputsButton.Position = [1087 143 285 64];
            app.NMSMPipelineInputsButton.Text = 'NMSM Pipeline Inputs';

            % Create RCNL2026ModelButton
            app.RCNL2026ModelButton = uibutton(app.UIFigure, 'push');
            app.RCNL2026ModelButton.ButtonPushedFcn = createCallbackFcn(app, @RCNL2026ModelButtonPushed, true);
            app.RCNL2026ModelButton.BackgroundColor = [0.851 0.851 0.851];
            app.RCNL2026ModelButton.FontSize = 25;
            app.RCNL2026ModelButton.FontWeight = 'bold';
            app.RCNL2026ModelButton.FontColor = [0.0667 0.4431 0.7451];
            app.RCNL2026ModelButton.Position = [1087 60 288 64];
            app.RCNL2026ModelButton.Text = 'RCNL 2026 Model';

            % Create NmsmWebsiteButton
            app.NmsmWebsiteButton = uibutton(app.UIFigure, 'push');
            app.NmsmWebsiteButton.ButtonPushedFcn = createCallbackFcn(app, @NmsmWebsiteButtonPushed, true);
            app.NmsmWebsiteButton.BackgroundColor = [0.851 0.851 0.851];
            app.NmsmWebsiteButton.FontSize = 25;
            app.NmsmWebsiteButton.FontWeight = 'bold';
            app.NmsmWebsiteButton.FontColor = [0.0667 0.4431 0.7451];
            app.NmsmWebsiteButton.Position = [1422 226 285 64];
            app.NmsmWebsiteButton.Text = 'https://nmsm.rice.edu/';

            % Create EmailButton
            app.EmailButton = uibutton(app.UIFigure, 'push');
            app.EmailButton.ButtonPushedFcn = createCallbackFcn(app, @EmailButtonPushed, true);
            app.EmailButton.BackgroundColor = [0.851 0.851 0.851];
            app.EmailButton.FontSize = 25;
            app.EmailButton.FontWeight = 'bold';
            app.EmailButton.FontColor = [0.0667 0.4431 0.7451];
            app.EmailButton.Position = [1422 143 285 64];
            app.EmailButton.Text = 'Email: nmsm@rice.edu';

            % Create SimTKForumButton
            app.SimTKForumButton = uibutton(app.UIFigure, 'push');
            app.SimTKForumButton.ButtonPushedFcn = createCallbackFcn(app, @SimTKForumButtonPushed, true);
            app.SimTKForumButton.BackgroundColor = [0.851 0.851 0.851];
            app.SimTKForumButton.FontSize = 25;
            app.SimTKForumButton.FontWeight = 'bold';
            app.SimTKForumButton.FontColor = [0.0667 0.4431 0.7451];
            app.SimTKForumButton.Position = [1422 60 288 64];
            app.SimTKForumButton.Text = 'SimTK Forum';

            % Create EmailContextMenu
            app.EmailContextMenu = uicontextmenu(app.UIFigure);

            % Create CopyEmailMenu
            app.CopyEmailMenu = uimenu(app.EmailContextMenu);
            app.CopyEmailMenu.MenuSelectedFcn = createCallbackFcn(app, @CopyEmailMenuSelected, true);
            app.CopyEmailMenu.Text = 'Copy email address';

            % Assign app.EmailContextMenu
            app.EmailButton.ContextMenu = app.EmailContextMenu;

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