% This class is part of the NMSM Pipeline, see file for full license.
%
% This class is the progress window for a Ground Contact Personalization
% run. GCPBase saves its settings file and hands both itself and that
% file name to this window, which drives the run and reports where it
% has got to.
%
% GroundContactPersonalizationTool takes this app as an optional second
% argument and calls back into it three ways: updateRunStageGui toggles
% the stage labels, updateTaskProgress names the round in progress, and
% CancelOptimizationGui is installed as lsqnonlin's OutputFcn so the
% Cancel button can stop the solver. All three are found by name, so a
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
classdef GCPRun < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        ParsingLabel            matlab.ui.control.Label
        InitializingLabel       matlab.ui.control.Label
        RunningLabel            matlab.ui.control.Label
        TaskLabel               matlab.ui.control.Label
        SavingLabel             matlab.ui.control.Label
        PlottingLabel           matlab.ui.control.Label
        CompletedLabel          matlab.ui.control.Label
        CancelButton            matlab.ui.control.Button
        CloseButton             matlab.ui.control.Button
    end

    properties (Access = private)
        GCPBase;
        SettingsFileName string;
        cancelOptimizationFlag logical = false;
    end

    methods (Access = public)

        % lsqnonlin OutputFcn. optimizeGroundContactPersonalizationTask
        % looks this up by name, the same way MTP and JMP do.
        function stop = CancelOptimizationGui(app, x, optimValues, state)
            drawnow;
            stop = app.cancelOptimizationFlag;
        end

        % Read between rounds, so Cancel stops the whole sequence rather
        % than just the round that happened to be running.
        function cancelled = isRunCancelled(app)
            cancelled = app.cancelOptimizationFlag;
        end

        % Called once per round by GroundContactPersonalization. A GCP
        % round can run for a long time with no other sign of progress,
        % so naming which one is under way is most of the value here.
        function updateTaskProgress(app, task, taskCount)
            if ~isvalid(app)
                return
            end
            app.TaskLabel.Text = "Task " + task + " of " + taskCount;
            app.TaskLabel.Enable = 'on';
            drawnow
        end
    end

    methods (Access = private)

        function finish(app, text)
            app.TaskLabel.Enable = 'off';
            app.CompletedLabel.Text = text;
            app.CompletedLabel.Enable = 'on';
            app.CloseButton.Enable = 'on';
            app.CancelButton.Enable = 'off';
            drawnow
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, base, settingsFileName)
            app.GCPBase = base;
            app.SettingsFileName = settingsFileName;
            % Paints the window before the blocking call starts.
            drawnow
            pause(0.01)
            try
                GroundContactPersonalizationTool(settingsFileName, app);
            catch runException
                app.finish('GCP Failed');
                rethrow(runException)
            end
            if app.cancelOptimizationFlag
                % Whatever rounds finished before the cancel have
                % already been saved.
                app.finish('GCP Cancelled');
                return
            end
            updateRunStageGui(app, 'PlottingLabel', 'on');
            try
                plotGcpResultsFromSettingsFile(settingsFileName);
            catch plotException
                % Plotting is not part of the result, so a failure here
                % is reported rather than thrown - the run's output is
                % already on disk either way.
                warning('GCPRun:plottingFailed', '%s', ...
                    "Ground contact results could not be plotted: " + ...
                    plotException.message);
            end
            updateRunStageGui(app, 'PlottingLabel', 'off');
            app.finish('GCP Completed');
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
            app.UIFigure.Name = 'Ground Contact Personalization';
            app.UIFigure.WindowStyle = 'docked';

            % Create ParsingLabel
            app.ParsingLabel = uilabel(app.UIFigure);
            app.ParsingLabel.FontSize = 30;
            app.ParsingLabel.FontWeight = 'bold';
            app.ParsingLabel.Position = [39 379 432 39];
            app.ParsingLabel.Text = 'Parsing Settings File...';

            % Create InitializingLabel
            app.InitializingLabel = uilabel(app.UIFigure);
            app.InitializingLabel.FontSize = 30;
            app.InitializingLabel.FontWeight = 'bold';
            app.InitializingLabel.Enable = 'off';
            app.InitializingLabel.Position = [39 327 432 39];
            app.InitializingLabel.Text = 'Initializing Spring Length...';

            % Create RunningLabel
            app.RunningLabel = uilabel(app.UIFigure);
            app.RunningLabel.FontSize = 30;
            app.RunningLabel.FontWeight = 'bold';
            app.RunningLabel.Enable = 'off';
            app.RunningLabel.Position = [39 275 432 39];
            app.RunningLabel.Text = 'Running GCP...';

            % Create TaskLabel
            app.TaskLabel = uilabel(app.UIFigure);
            app.TaskLabel.FontSize = 20;
            app.TaskLabel.Enable = 'off';
            app.TaskLabel.Position = [75 243 432 26];
            app.TaskLabel.Text = 'Task 1 of 1';

            % Create SavingLabel
            app.SavingLabel = uilabel(app.UIFigure);
            app.SavingLabel.FontSize = 30;
            app.SavingLabel.FontWeight = 'bold';
            app.SavingLabel.Enable = 'off';
            app.SavingLabel.Position = [39 191 432 39];
            app.SavingLabel.Text = 'Saving Results...';

            % Create PlottingLabel
            app.PlottingLabel = uilabel(app.UIFigure);
            app.PlottingLabel.FontSize = 30;
            app.PlottingLabel.FontWeight = 'bold';
            app.PlottingLabel.Enable = 'off';
            app.PlottingLabel.Position = [39 139 432 39];
            app.PlottingLabel.Text = 'Plotting Results...';

            % Create CompletedLabel
            app.CompletedLabel = uilabel(app.UIFigure);
            app.CompletedLabel.FontSize = 30;
            app.CompletedLabel.FontWeight = 'bold';
            app.CompletedLabel.Enable = 'off';
            app.CompletedLabel.Position = [39 87 432 39];
            app.CompletedLabel.Text = 'GCP Completed';

            % Create CloseButton
            app.CloseButton = uibutton(app.UIFigure, 'push');
            app.CloseButton.ButtonPushedFcn = createCallbackFcn(app, @CloseButtonPushed, true);
            app.CloseButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CloseButton.FontSize = 18;
            app.CloseButton.FontColor = [1 1 1];
            app.CloseButton.Enable = 'off';
            app.CloseButton.Position = [399 24 85 30];
            app.CloseButton.Text = 'Close';

            % Create CancelButton
            app.CancelButton = uibutton(app.UIFigure, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.CancelButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CancelButton.FontSize = 18;
            app.CancelButton.FontColor = [1 1 1];
            app.CancelButton.Position = [517 24 85 30];
            app.CancelButton.Text = 'Cancel';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GCPRun(varargin)

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
