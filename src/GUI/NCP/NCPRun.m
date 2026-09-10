% This class is part of the NMSM Pipeline, see file for full license.
%
% This class is the progress window for a Neural Control Personalization
% run. NCPBase saves its settings file and hands both itself and that file
% name to this window, which drives the run and reports where it has got
% to.
%
% NeuralControlPersonalizationTool takes this app as an optional second
% argument and calls back into it three ways: updateRunStageGui toggles the
% stage labels, CancelOptimizationGui is installed as fmincon's OutputFcn so
% the Cancel button can stop the solver, and isRunCancelled is read between
% stages so a cancel during Muscle Tendon Length Initialization does not
% fall through into the NCP optimization. All three are found by name, so a
% scripted run that passes no app is unaffected.

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
classdef NCPRun < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        NCPCompletedLabel     matlab.ui.control.Label
        PlottingResultsLabel  matlab.ui.control.Label
        SavingResultsLabel    matlab.ui.control.Label
        RunningNCPLabel       matlab.ui.control.Label
        RunningMTLILabel      matlab.ui.control.Label
        CloseButton           matlab.ui.control.Button
        CancelButton          matlab.ui.control.Button
        ParsingLabel          matlab.ui.control.Label
    end

    properties (Access = private)
        NCPBase;
        SettingsFileName string;
        cancelOptimizationFlag logical = false;
    end

    methods (Access = public)

        % fmincon OutputFcn. computeNeuralControlOptimization and
        % MuscleTendonLengthInitialization both look this up by name, the
        % same way MTP, JMP and GCP do.
        function stop = CancelOptimizationGui(app, x, optimValues, state)
            drawnow; % lets GUI process button presses
            stop = app.cancelOptimizationFlag;
        end

        % Read between stages, so Cancel during MTLI stops the run rather
        % than letting it fall through into the NCP optimization.
        function cancelled = isRunCancelled(app)
            cancelled = app.cancelOptimizationFlag;
        end
    end

    methods (Access = private)

        % Reports how the run ended. The stage labels are cleared first so
        % a failed or cancelled run does not leave its stage lit.
        function finish(app, text)
            app.ParsingLabel.Enable = 'off';
            app.RunningMTLILabel.Enable = 'off';
            app.RunningNCPLabel.Enable = 'off';
            app.SavingResultsLabel.Enable = 'off';
            app.PlottingResultsLabel.Enable = 'off';
            app.NCPCompletedLabel.Text = text;
            app.NCPCompletedLabel.Enable = 'on';
            app.CloseButton.Enable = 'on';
            app.CancelButton.Enable = 'off';
            drawnow
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, base, settingsFileName)
            app.NCPBase = base;
            app.SettingsFileName = settingsFileName;
            % Paints the window before the blocking call starts.
            drawnow
            pause(0.01)
            try
                NeuralControlPersonalizationTool(settingsFileName, app);
            catch runException
                app.finish('NCP Failed');
                rethrow(runException)
            end
            if app.cancelOptimizationFlag
                % A cancel during MTLI leaves nothing on disk to plot; a
                % cancel during NCP saved the iterate fmincon stopped on.
                app.finish('NCP Cancelled');
            end
            updateRunStageGui(app, 'PlottingResultsLabel', 'on');
            try
                plotNcpResultsFromSettingsFile(settingsFileName);
            catch plotException
                % Plotting is not part of the result, so a failure here is
                % reported rather than thrown - the run's output is already
                % on disk either way.
                warning('NCPRun:plottingFailed', '%s', ...
                    "Neural control results could not be plotted: " + ...
                    plotException.message);
            end
            updateRunStageGui(app, 'PlottingResultsLabel', 'off');
            app.finish('NCP Completed');
        end

        % Button pushed function: CancelButton
        function CancelButtonPushed(app, event)
            app.cancelOptimizationFlag = true;
            app.CancelButton.Enable = 'off';
            app.CancelButton.Text = 'Cancelling';
        end

        % Button pushed function: CloseButton
        function CloseButtonPushed(app, event)
            delete(app.UIFigure);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.851 0.851 0.851];
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'Neural Control Personalization';
            app.UIFigure.WindowStyle = 'docked';

            % Create ParsingLabel
            app.ParsingLabel = uilabel(app.UIFigure);
            app.ParsingLabel.FontSize = 30;
            app.ParsingLabel.FontWeight = 'bold';
            app.ParsingLabel.Position = [39 379 432 39];
            app.ParsingLabel.Text = 'Parsing Settings File...';

            % Create CancelButton
            app.CancelButton = uibutton(app.UIFigure, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.CancelButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CancelButton.FontSize = 18;
            app.CancelButton.FontColor = [1 1 1];
            app.CancelButton.Position = [517 24 85 30];
            app.CancelButton.Text = 'Cancel';

            % Create CloseButton
            app.CloseButton = uibutton(app.UIFigure, 'push');
            app.CloseButton.ButtonPushedFcn = createCallbackFcn(app, @CloseButtonPushed, true);
            app.CloseButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CloseButton.FontSize = 18;
            app.CloseButton.FontColor = [1 1 1];
            app.CloseButton.Enable = 'off';
            app.CloseButton.Position = [399 24 85 30];
            app.CloseButton.Text = 'Close';

            % Create RunningMTLILabel
            app.RunningMTLILabel = uilabel(app.UIFigure);
            app.RunningMTLILabel.FontSize = 30;
            app.RunningMTLILabel.FontWeight = 'bold';
            app.RunningMTLILabel.Enable = 'off';
            app.RunningMTLILabel.Position = [39 336 432 39];
            app.RunningMTLILabel.Text = 'Running MTLI...';

            % Create RunningNCPLabel
            app.RunningNCPLabel = uilabel(app.UIFigure);
            app.RunningNCPLabel.FontSize = 30;
            app.RunningNCPLabel.FontWeight = 'bold';
            app.RunningNCPLabel.Enable = 'off';
            app.RunningNCPLabel.Position = [39 275 432 39];
            app.RunningNCPLabel.Text = 'Running NCP...';

            % Create SavingResultsLabel
            app.SavingResultsLabel = uilabel(app.UIFigure);
            app.SavingResultsLabel.FontSize = 30;
            app.SavingResultsLabel.FontWeight = 'bold';
            app.SavingResultsLabel.Enable = 'off';
            app.SavingResultsLabel.Position = [39 223 432 39];
            app.SavingResultsLabel.Text = 'Saving Results...';

            % Create PlottingResultsLabel
            app.PlottingResultsLabel = uilabel(app.UIFigure);
            app.PlottingResultsLabel.FontSize = 30;
            app.PlottingResultsLabel.FontWeight = 'bold';
            app.PlottingResultsLabel.Enable = 'off';
            app.PlottingResultsLabel.Position = [39 171 432 39];
            app.PlottingResultsLabel.Text = 'Plotting Results...';

            % Create NCPCompletedLabel
            app.NCPCompletedLabel = uilabel(app.UIFigure);
            app.NCPCompletedLabel.FontSize = 30;
            app.NCPCompletedLabel.FontWeight = 'bold';
            app.NCPCompletedLabel.Enable = 'off';
            app.NCPCompletedLabel.Position = [39 132 432 39];
            app.NCPCompletedLabel.Text = 'NCP Completed';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = NCPRun(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

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
