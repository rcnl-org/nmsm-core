% This class is part of the NMSM Pipeline, see file for full license.
%
% This class is the App Designer run dialog for the Treatment Optimization
% tools, showing which stage of the run is active and reporting failures
% rather than leaving the dialog stalled.
%
% The tools report their own progress by turning these labels on and off
% through updateRunStageGui, the same way MTPRun is driven. Parsing, the
% surrogate model, and the solve are flipped from inside the tool; this
% dialog only drives plotting and completion. A torque only run never
% lights the surrogate model stage, which no controller there needs.
%
% The cancel button is a placeholder. See CancelButtonPushed.

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
classdef TreatmentOptimizationRun < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        ParsingLabel          matlab.ui.control.Label
        SurrogateModelLabel   matlab.ui.control.Label
        RunningLabel          matlab.ui.control.Label
        PlottingResultsLabel  matlab.ui.control.Label
        CompletedLabel        matlab.ui.control.Label
        MessageLabel          matlab.ui.control.Label
        CancelButton          matlab.ui.control.Button
        CloseButton           matlab.ui.control.Button
    end

    properties (Access = private)
        TreatmentOptimizationBase
        SettingsFileName string
        ToolElement string
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, base, settingsFileName)
            app.TreatmentOptimizationBase = base;
            app.SettingsFileName = string(settingsFileName);
            app.ToolElement = base.selectedToolElement();
            toolName = string(base.ToolSelectionDropDown.Value);
            app.UIFigure.Name = toolName;
            app.RunningLabel.Text = "Running " + toolName + "...";
            app.CompletedLabel.Text = toolName + " Completed.";
            app.ParsingLabel.Enable = 'on';
            drawnow
            pause(0.01)

            try
                app.runSelectedTool();
            catch exception
                app.clearStageLabels();
                app.showMessage("The run stopped with an error:" + ...
                    newline + exception.message);
                app.CloseButton.Enable = 'on';
                return
            end

            % A plotting failure leaves the results on disk, so it is
            % reported without marking the run itself as failed
            app.clearStageLabels();
            app.PlottingResultsLabel.Enable = 'on';
            drawnow
            try
                plotTreatmentOptimizationResultsFromSettingsFile( ...
                    app.SettingsFileName);
            catch exception
                app.showMessage("The results were saved, but plotting " + ...
                    "them failed:" + newline + exception.message);
            end
            app.PlottingResultsLabel.Enable = 'off';
            app.CompletedLabel.Enable = 'on';
            app.CloseButton.Enable = 'on';
        end

        function runSelectedTool(app)
            switch app.ToolElement
                case "VerificationOptimizationTool"
                    VerificationOptimizationTool(app.SettingsFileName, app);
                case "DesignOptimizationTool"
                    DesignOptimizationTool(app.SettingsFileName, app);
                otherwise
                    TrackingOptimizationTool(app.SettingsFileName, app);
            end
        end

        % A tool that throws leaves whichever stage it was in lit
        function clearStageLabels(app)
            app.ParsingLabel.Enable = 'off';
            app.SurrogateModelLabel.Enable = 'off';
            app.RunningLabel.Enable = 'off';
        end

        function showMessage(app, text)
            app.MessageLabel.Text = text;
            app.MessageLabel.Visible = 'on';
            drawnow
        end

        % Button pushed function: CancelButton
        %
        % Not implemented. The Treatment Optimization tools hand the
        % problem to GPOPS-II or Casadi, which drive their own solver
        % loops, so there is no MATLAB optimizer OutputFcn to raise a stop
        % flag from the way MTPRun does through CancelOptimizationGui. The
        % button is left disabled until a supported stopping point exists.
        function CancelButtonPushed(app, event)
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
            app.UIFigure.Name = 'MATLAB App';

            % Create ParsingLabel
            app.ParsingLabel = uilabel(app.UIFigure);
            app.ParsingLabel.FontSize = 30;
            app.ParsingLabel.FontWeight = 'bold';
            app.ParsingLabel.Enable = 'off';
            app.ParsingLabel.Position = [39 401 562 39];
            app.ParsingLabel.Text = 'Parsing Settings File...';

            % Create SurrogateModelLabel
            app.SurrogateModelLabel = uilabel(app.UIFigure);
            app.SurrogateModelLabel.FontSize = 30;
            app.SurrogateModelLabel.FontWeight = 'bold';
            app.SurrogateModelLabel.Enable = 'off';
            app.SurrogateModelLabel.Position = [39 349 562 39];
            app.SurrogateModelLabel.Text = 'Creating Surrogate Model...';

            % Create RunningLabel
            app.RunningLabel = uilabel(app.UIFigure);
            app.RunningLabel.FontSize = 30;
            app.RunningLabel.FontWeight = 'bold';
            app.RunningLabel.Enable = 'off';
            app.RunningLabel.Position = [39 297 562 39];
            app.RunningLabel.Text = 'Running...';

            % Create PlottingResultsLabel
            app.PlottingResultsLabel = uilabel(app.UIFigure);
            app.PlottingResultsLabel.FontSize = 30;
            app.PlottingResultsLabel.FontWeight = 'bold';
            app.PlottingResultsLabel.Enable = 'off';
            app.PlottingResultsLabel.Position = [39 245 562 39];
            app.PlottingResultsLabel.Text = 'Plotting Results...';

            % Create CompletedLabel
            app.CompletedLabel = uilabel(app.UIFigure);
            app.CompletedLabel.FontSize = 30;
            app.CompletedLabel.FontWeight = 'bold';
            app.CompletedLabel.Enable = 'off';
            app.CompletedLabel.Position = [39 193 562 39];
            app.CompletedLabel.Text = 'Completed.';

            % Create MessageLabel
            app.MessageLabel = uilabel(app.UIFigure);
            app.MessageLabel.FontSize = 14;
            app.MessageLabel.WordWrap = 'on';
            app.MessageLabel.VerticalAlignment = 'top';
            app.MessageLabel.Visible = 'off';
            app.MessageLabel.Position = [39 74 562 108];
            app.MessageLabel.Text = '';

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
            app.CancelButton.Enable = 'off';
            app.CancelButton.Tooltip = ['Cancelling a run is not ' ...
                'supported yet.'];
            app.CancelButton.Position = [517 24 85 30];
            app.CancelButton.Text = 'Cancel';

            movegui(app.UIFigure, 'center');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = TreatmentOptimizationRun(varargin)

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
