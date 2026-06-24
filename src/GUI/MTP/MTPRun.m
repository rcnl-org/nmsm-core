% This class is part of the NMSM Pipeline, see file for full license.
%
% This class is the App Designer run dialog for the Muscle-Tendon
% Personalization (MTP) tool, displaying progress labels and providing
% cancel functionality during an active MTP optimization run.

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
classdef MTPRun < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        MTPCompletedLabel     matlab.ui.control.Label
        PlottingResultsLabel  matlab.ui.control.Label
        SavingResultsLabel    matlab.ui.control.Label
        RunningMTPLabel       matlab.ui.control.Label
        RunningMTLILabel      matlab.ui.control.Label
        CloseButton           matlab.ui.control.Button
        CancelButton          matlab.ui.control.Button
        ParsingLabel          matlab.ui.control.Label
    end

    
    properties (Access = public)

        CancelOptimization = true; % Description
    end
    
    properties (Access = private)
        MTPBase; % Description
        SettingsFileName string;
        cancelOptimizationFlag logical = false;
        
    end
    
    properties (SetObservable)
        parsing logical = true;
    end

    methods (Access = public)
        
        function stop = CancelOptimizationGui(app, x, optimValues, state)

            drawnow; % lets GUI process button presses
        
            stop = false;
        
            if app.cancelOptimizationFlag
                stop = true;
            end
            drawnow; % lets GUI process button presses
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, MTPBase, SettingsFileName)
            app.MTPBase = MTPBase;
            app.SettingsFileName = SettingsFileName;
            drawnow
            pause(0.01)
            MuscleTendonPersonalizationTool(SettingsFileName, app)
            app.PlottingResultsLabel.Enable = 'on';
            drawnow
            plotMtpResultsFromSettingsFile(SettingsFileName);
            drawnow
            app.PlottingResultsLabel.Enable = 'off';
            app.MTPCompletedLabel.Enable = 'on';
            app.CloseButton.Enable = 'on';
            app.CancelButton.Enable = 'off';
        end

        % Button pushed function: CancelButton
        function CancelButtonPushed(app, event)
            app.cancelOptimizationFlag = true;
            app.CancelButton.Enable = 'off';
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

            % Create RunningMTPLabel
            app.RunningMTPLabel = uilabel(app.UIFigure);
            app.RunningMTPLabel.FontSize = 30;
            app.RunningMTPLabel.FontWeight = 'bold';
            app.RunningMTPLabel.Enable = 'off';
            app.RunningMTPLabel.Position = [39 275 432 39];
            app.RunningMTPLabel.Text = 'Running MTP...';

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

            % Create MTPCompletedLabel
            app.MTPCompletedLabel = uilabel(app.UIFigure);
            app.MTPCompletedLabel.FontSize = 30;
            app.MTPCompletedLabel.FontWeight = 'bold';
            app.MTPCompletedLabel.Enable = 'off';
            app.MTPCompletedLabel.Position = [39 132 432 39];
            app.MTPCompletedLabel.Text = 'MTP Completed.';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MTPRun(varargin)

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