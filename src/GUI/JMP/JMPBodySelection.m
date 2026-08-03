% This class is part of the NMSM Pipeline, see file for full license.
%
% This class is the App Designer dialog for selecting JMP body parameters
% within the Joint Model Personalization GUI.

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
classdef JMPBodySelection < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        OKStatus              matlab.ui.control.Image
        BodyNameStatus          matlab.ui.control.Image
        CloseButton            matlab.ui.control.Button
        OKButton               matlab.ui.control.Button
        ScaleBodyLabel         matlab.ui.control.Label
        MoveMarkersZCheckBox   matlab.ui.control.CheckBox
        MoveMarkersYCheckBox   matlab.ui.control.CheckBox
        MoveMarkersXCheckBox   matlab.ui.control.CheckBox
        MoveMarkersLabel       matlab.ui.control.Label
        ScaleBodyCheckBox      matlab.ui.control.CheckBox
        BodyNameDropDown       matlab.ui.control.DropDown
        BodyNameDropDownLabel  matlab.ui.control.Label
    end


    properties (Access = private)
        JMPParent
        JMPBody struct = struct("Attributes", [], "scale_body", [], ...
            "move_markers", []);
        editingFlag logical = false;
        originalBodyName string = "";
        errorFlag logical = false;
    end

    methods (Access = private)
        function ErrorsCallback(app)
            app.errorFlag = false;
            if ~any(contains(app.BodyNameDropDown.Value, ...
                    app.JMPParent.getModelBodies))
                setGuiFieldStatus([], app.BodyNameStatus, "error", ...
                    "This body is not found in the .osim model");
                app.errorFlag = true;
            elseif any(contains(app.BodyNameDropDown.Value, ...
                    app.JMPParent.getSelectedBodies())) && ...
                    ~(app.editingFlag && strcmp(app.BodyNameDropDown.Value, ...
                    app.originalBodyName))
                setGuiFieldStatus([], app.BodyNameStatus, "error", ...
                    "This body is already in this task");
                app.errorFlag = true;
            else
                setGuiFieldStatus([], app.BodyNameStatus, "none");
            end

            if ~any([app.ScaleBodyCheckBox.Value, ...
                    app.MoveMarkersXCheckBox.Value, ...
                    app.MoveMarkersYCheckBox.Value, ...
                    app.MoveMarkersZCheckBox.Value])
                setGuiFieldStatus([], app.OKStatus, "warning", ...
                    "This task has no parameters selected.")
            else
                setGuiFieldStatus([], app.OKStatus, "none")
            end
            app.EnableActionsCallback()
        end

        function EnableActionsCallback(app)
            if app.errorFlag
                app.OKButton.Enable = 'off';
            else
                app.OKButton.Enable = 'on';
            end
        end
        
        function buildEmptyBody(app)
            app.JMPBody.Attributes.name = app.BodyNameDropDown.Value;
            app.JMPBody.scale_body = 'false';
            app.JMPBody.move_markers = ["false" "false" "false"];
        end

        function loadBody(app, body)
            app.JMPBody = body;
            app.originalBodyName = body.Attributes.name;
            app.BodyNameDropDown.Value = body.Attributes.name;
            if strcmp(body.scale_body, 'true')
                app.ScaleBodyCheckBox.Value = true;
            end
            markerAxes = strcmp(body.move_markers, "true");
            [app.MoveMarkersXCheckBox.Value, ...
                app.MoveMarkersYCheckBox.Value, ...
                app.MoveMarkersZCheckBox.Value] = ...
                deal(markerAxes(1), markerAxes(2), markerAxes(3));
            app.ErrorsCallback()
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, JMPParent, JMPBody)
            app.JMPParent = JMPParent;
            modelBodies = JMPParent.getModelBodies();
            app.BodyNameDropDown.Items = modelBodies;
            if isempty(JMPBody)
                app.buildEmptyBody()
                app.ErrorsCallback()
            else
                app.editingFlag = true;
                app.loadBody(JMPBody)
            end
        end

        % Value changed function: BodyNameDropDown
        function BodyNameDropDownValueChanged(app, event)
            value = app.BodyNameDropDown.Value;
            app.JMPBody.Attributes.name = value;
            app.ErrorsCallback()
        end

        % Value changed function: MoveMarkersXCheckBox, 
        % ...and 2 other components
        function xCheckBoxValueChanged(app, event)
            app.JMPBody.move_markers( ...
                [app.MoveMarkersXCheckBox.Value, ...
                app.MoveMarkersYCheckBox.Value, ...
                app.MoveMarkersZCheckBox.Value]) = "true";
            app.JMPBody.move_markers( ...
                ~[app.MoveMarkersXCheckBox.Value, ...
                app.MoveMarkersYCheckBox.Value, ...
                app.MoveMarkersZCheckBox.Value]) = "false";
            app.ErrorsCallback()
        end

        % Value changed function: ScaleBodyCheckBox
        function ScaleBodyCheckBoxValueChanged(app, event)
            if app.ScaleBodyCheckBox.Value
                app.JMPBody.scale_body = 'true';
            else
                app.JMPBody.scale_body = 'false';
            end
            app.ErrorsCallback()
        end

        % Button pushed function: OKButton
        function OKButtonPushed(app, event)
            if ~app.editingFlag
                app.JMPParent.addBody(app.JMPBody);
            else
                app.JMPParent.editBody(app.JMPBody);
            end
            
            delete(app.UIFigure);
        end

        % Button pushed function: CloseButton
        function CloseButtonPushed(app, event)
            % app.JMPTaskCreation.selectionExitFunction()
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
            app.UIFigure.Position = [100 100 397 228];
            app.UIFigure.Name = 'MATLAB App';

            % Create BodyNameDropDownLabel
            app.BodyNameDropDownLabel = uilabel(app.UIFigure);
            app.BodyNameDropDownLabel.HorizontalAlignment = 'right';
            app.BodyNameDropDownLabel.FontSize = 18;
            app.BodyNameDropDownLabel.FontWeight = 'bold';
            app.BodyNameDropDownLabel.Position = [35 181 104 23];
            app.BodyNameDropDownLabel.Text = 'Body Name';

            % Create BodyNameDropDown
            app.BodyNameDropDown = uidropdown(app.UIFigure);
            app.BodyNameDropDown.Editable = 'on';
            app.BodyNameDropDown.ValueChangedFcn = createCallbackFcn(app, @BodyNameDropDownValueChanged, true);
            app.BodyNameDropDown.FontSize = 18;
            app.BodyNameDropDown.Position = [157 180 193 24];

            % Create ScaleBodyCheckBox
            app.ScaleBodyCheckBox = uicheckbox(app.UIFigure);
            app.ScaleBodyCheckBox.ValueChangedFcn = createCallbackFcn(app, @ScaleBodyCheckBoxValueChanged, true);
            app.ScaleBodyCheckBox.Text = '';
            app.ScaleBodyCheckBox.Position = [156 133 25 22];

            % Create MoveMarkersLabel
            app.MoveMarkersLabel = uilabel(app.UIFigure);
            app.MoveMarkersLabel.FontSize = 18;
            app.MoveMarkersLabel.FontWeight = 'bold';
            app.MoveMarkersLabel.Position = [18 86 125 23];
            app.MoveMarkersLabel.Text = 'Move Markers';

            % Create MoveMarkersXCheckBox
            app.MoveMarkersXCheckBox = uicheckbox(app.UIFigure);
            app.MoveMarkersXCheckBox.ValueChangedFcn = createCallbackFcn(app, @xCheckBoxValueChanged, true);
            app.MoveMarkersXCheckBox.Text = 'x';
            app.MoveMarkersXCheckBox.Position = [156 86 28 22];

            % Create MoveMarkersYCheckBox
            app.MoveMarkersYCheckBox = uicheckbox(app.UIFigure);
            app.MoveMarkersYCheckBox.ValueChangedFcn = createCallbackFcn(app, @xCheckBoxValueChanged, true);
            app.MoveMarkersYCheckBox.Text = 'y';
            app.MoveMarkersYCheckBox.Position = [196 86 28 22];

            % Create MoveMarkersZCheckBox
            app.MoveMarkersZCheckBox = uicheckbox(app.UIFigure);
            app.MoveMarkersZCheckBox.ValueChangedFcn = createCallbackFcn(app, @xCheckBoxValueChanged, true);
            app.MoveMarkersZCheckBox.Text = 'z';
            app.MoveMarkersZCheckBox.Position = [232 86 28 22];

            % Create ScaleBodyLabel
            app.ScaleBodyLabel = uilabel(app.UIFigure);
            app.ScaleBodyLabel.FontSize = 18;
            app.ScaleBodyLabel.FontWeight = 'bold';
            app.ScaleBodyLabel.Position = [41 133 102 23];
            app.ScaleBodyLabel.Text = 'Scale Body';

            % Create OKButton
            app.OKButton = uibutton(app.UIFigure, 'push');
            app.OKButton.ButtonPushedFcn = createCallbackFcn(app, @OKButtonPushed, true);
            app.OKButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.OKButton.FontSize = 18;
            app.OKButton.FontColor = [1 1 1];
            app.OKButton.Position = [175 19 85 30];
            app.OKButton.Text = 'OK';

            % Create CloseButton
            app.CloseButton = uibutton(app.UIFigure, 'push');
            app.CloseButton.ButtonPushedFcn = createCallbackFcn(app, @CloseButtonPushed, true);
            app.CloseButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CloseButton.FontSize = 18;
            app.CloseButton.FontColor = [1 1 1];
            app.CloseButton.Position = [291 19 85 30];
            app.CloseButton.Text = 'Close';

            % Create BodyNameStatus
            app.BodyNameStatus = uiimage(app.UIFigure);
            app.BodyNameStatus.Visible = 'off';
            app.BodyNameStatus.Position = [352 175 37 35];

            % Create OKStatus
            app.OKStatus = uiimage(app.UIFigure);
            app.OKStatus.Visible = 'off';
            app.OKStatus.Position = [130 17 35 35];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';

            % The window is tall enough that a fixed corner runs off the
            % top of a 1080p display, so center it on whichever screen it
            % lands on before showing it
            movegui(app.UIFigure, 'center');
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = JMPBodySelection(varargin)

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