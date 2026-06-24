classdef JMPJointSelection < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        OKWarning                  matlab.ui.control.Image
        ChildOrientBoundsError     matlab.ui.control.Image
        ChildTransBoundsError      matlab.ui.control.Image
        ParentOrientBoundsError    matlab.ui.control.Image
        ParentTransBoundsError     matlab.ui.control.Image
        JointNameError             matlab.ui.control.Image
        CloseButton                matlab.ui.control.Button
        OKButton                   matlab.ui.control.Button
        ParentRotBound             matlab.ui.control.NumericEditField
        BoundsradEditField_2Label  matlab.ui.control.Label
        ChildRotBound              matlab.ui.control.NumericEditField
        BoundsradEditFieldLabel    matlab.ui.control.Label
        ChildTransBound            matlab.ui.control.NumericEditField
        BoundsmEditField_2Label    matlab.ui.control.Label
        ParentTransBound           matlab.ui.control.NumericEditField
        BoundsmEditFieldLabel      matlab.ui.control.Label
        ChildTransLabel            matlab.ui.control.Label
        ChildTransX                matlab.ui.control.CheckBox
        ChildTransY                matlab.ui.control.CheckBox
        ChildTransZ                matlab.ui.control.CheckBox
        ChildOrientX               matlab.ui.control.CheckBox
        ChildOrientY               matlab.ui.control.CheckBox
        ChildOrientZ               matlab.ui.control.CheckBox
        ChildOrientLabel           matlab.ui.control.Label
        ChildFrameLabel            matlab.ui.control.Label
        ParentOrientX              matlab.ui.control.CheckBox
        ParentOrientY              matlab.ui.control.CheckBox
        ParentOrientZ              matlab.ui.control.CheckBox
        ParentOrientLabel          matlab.ui.control.Label
        ParentTransLabel           matlab.ui.control.Label
        ParentTransZ               matlab.ui.control.CheckBox
        ParentTransY               matlab.ui.control.CheckBox
        ParentTransX               matlab.ui.control.CheckBox
        ParentFrameLabel           matlab.ui.control.Label
        JointNameDropDown          matlab.ui.control.DropDown
        JointNameDropDownLabel     matlab.ui.control.Label
    end

    
    properties (Access = private)
        JMPParent;
        JointSet struct = struct("Attributes", [], "parent_frame_transformation", ...
            [], "child_frame_transformation", []);
        defaultTransBound = 0.05;
        defaultOrientBound = 0.5;
        editingFlag logical = false;
        originalJointName string = "";
        parentTransBounds;
        errorFlag logical = false;
        
    end
    
    methods (Access = private)
        
        function ErrorsCallback(app)
            app.errorFlag = false;

            if ~any(contains(app.JointNameDropDown.Value, ...
                    app.JMPParent.getModelJoints))
                throwGuiError("This joint is not found in the .osim model", ...
                    [], app.JointNameError);
                app.errorFlag = true;
            elseif any(contains(app.JointNameDropDown.Value, ...
                    app.JMPParent.getSelectedJoints())) && ...
                    ~(app.editingFlag && strcmp(app.JointNameDropDown.Value, ...
                    app.originalJointName))
                throwGuiError("This joint is already in this task", ...
                    [], app.JointNameError);
                app.errorFlag = true;
            else
                clearGuiError([], app.JointNameError);
            end

            if app.ParentRotBound.Value <= 0
                throwGuiError("Bounds must be greater than 0", ...
                    app.ParentRotBound, app.ParentOrientBoundsError);
                app.errorFlag = true;
            else
                clearGuiError(app.ParentRotBound, app.ParentOrientBoundsError);
                
            end
            if app.ParentTransBound.Value <= 0
                throwGuiError("Bounds must be greater than 0", ...
                    app.ParentTransBound, app.ParentTransBoundsError);
                app.errorFlag = true;
            else
                clearGuiError(app.ParentTransBound, app.ParentTransBoundsError);
            end
            if app.ChildRotBound.Value <= 0
                throwGuiError("Bounds must be greater than 0", ...
                    app.ChildRotBound, app.ChildOrientBoundsError);
                app.errorFlag = true;
            else
                clearGuiError(app.ChildRotBound, app.ChildOrientBoundsError);
            end
            if app.ChildTransBound.Value <= 0
                throwGuiError("Bounds must be greater than 0", ...
                    app.ChildTransBound, app.ChildTransBoundsError);
                app.errorFlag = true;
            else
                clearGuiError(app.ChildTransBound, app.ChildTransBoundsError);
            end

            if all(strcmp([app.JointSet.parent_frame_transformation.translation, ...
                    app.JointSet.parent_frame_transformation.orientation, ...
                    app.JointSet.child_frame_transformation.translation, ...
                    app.JointSet.child_frame_transformation.orientation], "false"))
                throwGuiWarning("No joint translations or orientations selected", ...
                    [], app.OKWarning)
            else
                clearGuiError([], app.OKWarning)
            end

            app.EnableActionsCallback();
        end

        function EnableActionsCallback(app)
            if app.errorFlag
               app.OKButton.Enable = 'off';
            else
                app.OKButton.Enable = 'on';
            end
        end

        function constructDefaultJointSet(app)
            app.JointSet.Attributes.name = app.JointNameDropDown.Value;
                app.JointSet.parent_frame_transformation.translation =  ...
                    ["false" "false" "false"];
                app.JointSet.parent_frame_transformation.orientation = ...
                    ["false" "false" "false"];
                app.JointSet.parent_frame_transformation.translation_bounds = ...
                    app.defaultTransBound;
                app.JointSet.parent_frame_transformation.orientation_bounds = ...
                    app.defaultOrientBound;
                app.JointSet.child_frame_transformation.translation = ...
                    ["false" "false" "false"];
                app.JointSet.child_frame_transformation.orientation = ...
                    ["false" "false" "false"];
                app.JointSet.child_frame_transformation.translation_bounds = ...
                    app.defaultTransBound;
                app.JointSet.child_frame_transformation.orientation_bounds = ...
                    app.defaultOrientBound;
        end
        
        function loadJoint(app, Joint)
            app.JointSet = Joint;
            app.originalJointName = Joint.Attributes.name;
            app.JointNameDropDown.Value = Joint.Attributes.name;
            app.ParentTransBound.Value = ...
                Joint.parent_frame_transformation.translation_bounds;
            app.ParentRotBound.Value = ...
                Joint.parent_frame_transformation.orientation_bounds;
            app.ChildTransBound.Value = ...
                Joint.child_frame_transformation.translation_bounds;
            app.ChildRotBound.Value = ...
                Joint.child_frame_transformation.orientation_bounds;
            parentTrans = strcmp(Joint.parent_frame_transformation.translation, "true");
            parentOrient = strcmp(Joint.parent_frame_transformation.orientation, "true");
            childTrans = strcmp(Joint.child_frame_transformation.translation, "true");
            childOrient = strcmp(Joint.child_frame_transformation.orientation, "true");
               
            [app.ParentTransX.Value, app.ParentTransY.Value, app.ParentTransZ.Value] = ...
                deal(parentTrans(1), parentTrans(2), parentTrans(3));
            [app.ParentOrientX.Value, app.ParentOrientY.Value, app.ParentOrientZ.Value] = ...
                deal(parentOrient(1), parentOrient(2), parentOrient(3));
            [app.ChildTransX.Value, app.ChildTransY.Value, app.ChildTransZ.Value] = ...
                deal(childTrans(1), childTrans(2), childTrans(3));
            [app.ChildOrientX.Value, app.ChildOrientY.Value, app.ChildOrientZ.Value] = ...
                deal(childOrient(1), childOrient(2), childOrient(3));
            app.ErrorsCallback()
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, JMPParent, Joint)
            app.JMPParent = JMPParent;
            % modelJoints = JMPTaskCreation.JMPBase.getModelJoints();
            modelJoints = JMPParent.getModelJoints();
            app.JointNameDropDown.Items = modelJoints;
            if isempty(Joint)
                app.constructDefaultJointSet()
                app.ErrorsCallback()
            else
                app.editingFlag = true;
                app.loadJoint(Joint);
            end
        end

        % Value changed function: JointNameDropDown
        function JointNameDropDownValueChanged(app, event)
            value = app.JointNameDropDown.Value;
            app.JointSet.Attributes.name = value;
            app.ErrorsCallback()
        end

        % Value changed function: ParentTransX, ParentTransY, ParentTransZ
        function ParentTransZValueChanged(app, event)
            app.JointSet.parent_frame_transformation.translation( ...
                [app.ParentTransX.Value, app.ParentTransY.Value, ...
                app.ParentTransZ.Value]) = "true";
            app.JointSet.parent_frame_transformation.translation( ...
                ~[app.ParentTransX.Value, app.ParentTransY.Value, ...
                app.ParentTransZ.Value]) = "false";
            ErrorsCallback(app)
        end

        % Value changed function: ParentOrientX, ParentOrientY, 
        % ...and 1 other component
        function ParentRotZValueChanged(app, event)
            app.JointSet.parent_frame_transformation.orientation( ...
                [app.ParentOrientX.Value, app.ParentOrientY.Value, ...
                app.ParentOrientZ.Value]) = "true";
            app.JointSet.parent_frame_transformation.orientation( ...
                ~[app.ParentOrientX.Value, app.ParentOrientY.Value, ...
                app.ParentOrientZ.Value]) = "false";
            ErrorsCallback(app)
        end

        % Value changed function: ChildTransX, ChildTransY, ChildTransZ
        function ChildTransZValueChanged(app, event)
            app.JointSet.child_frame_transformation.translation( ...
                [app.ChildTransX.Value, app.ChildTransY.Value, ...
                app.ChildTransZ.Value]) = "true";
            app.JointSet.child_frame_transformation.translation( ...
                ~[app.ChildTransX.Value, app.ChildTransY.Value, ...
                app.ChildTransZ.Value]) = "false";
            ErrorsCallback(app)
        end

        % Value changed function: ChildOrientX, ChildOrientY, ChildOrientZ
        function ChildRotZValueChanged(app, event)
            app.JointSet.child_frame_transformation.orientation( ...
                [app.ChildOrientX.Value, app.ChildOrientY.Value, ...
                app.ChildOrientZ.Value]) = "true";
            app.JointSet.child_frame_transformation.orientation( ...
                ~[app.ChildOrientX.Value, app.ChildOrientY.Value, ...
                app.ChildOrientZ.Value]) = "false";
            ErrorsCallback(app)
        end

        % Button pushed function: OKButton
        function OKButtonPushed(app, event)
            if ~app.editingFlag
                app.JMPParent.addJoint(app.JointSet);
            else
                app.JMPParent.editJoint(app.JointSet);
            end
            delete(app.UIFigure);
        end

        % Value changed function: ParentTransBound
        function ParentTransBoundValueChanged(app, event)
            app.JointSet.parent_frame_transformation.translation_bounds = ...
                app.ParentTransBound.Value;
            app.ErrorsCallback()
        end

        % Value changed function: ParentRotBound
        function ParentRotBoundValueChanged(app, event)
            app.JointSet.parent_frame_transformation.orientation_bounds = ...
                app.ParentRotBound.Value;
            app.ErrorsCallback()
        end

        % Value changed function: ChildTransBound
        function ChildTransBoundValueChanged(app, event)
            app.JointSet.child_frame_transformation.translation_bounds = ...
                app.ChildTransBound.Value;
            app.ErrorsCallback()
        end

        % Value changed function: ChildRotBound
        function ChildRotBoundValueChanged(app, event)
            app.JointSet.child_frame_transformation.orientation_bounds = ...
                app.ChildRotBound.Value;
            app.ErrorsCallback()
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

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.851 0.851 0.851];
            app.UIFigure.Position = [100 100 491 515];
            app.UIFigure.Name = 'MATLAB App';

            % Create JointNameDropDownLabel
            app.JointNameDropDownLabel = uilabel(app.UIFigure);
            app.JointNameDropDownLabel.HorizontalAlignment = 'right';
            app.JointNameDropDownLabel.FontSize = 18;
            app.JointNameDropDownLabel.FontWeight = 'bold';
            app.JointNameDropDownLabel.Position = [101 447 102 23];
            app.JointNameDropDownLabel.Text = 'Joint Name';

            % Create JointNameDropDown
            app.JointNameDropDown = uidropdown(app.UIFigure);
            app.JointNameDropDown.Editable = 'on';
            app.JointNameDropDown.ValueChangedFcn = createCallbackFcn(app, @JointNameDropDownValueChanged, true);
            app.JointNameDropDown.FontSize = 18;
            app.JointNameDropDown.Position = [218 446 176 24];

            % Create ParentFrameLabel
            app.ParentFrameLabel = uilabel(app.UIFigure);
            app.ParentFrameLabel.FontSize = 18;
            app.ParentFrameLabel.FontWeight = 'bold';
            app.ParentFrameLabel.Position = [48 383 120 23];
            app.ParentFrameLabel.Text = 'Parent Frame';

            % Create ParentTransX
            app.ParentTransX = uicheckbox(app.UIFigure);
            app.ParentTransX.ValueChangedFcn = createCallbackFcn(app, @ParentTransZValueChanged, true);
            app.ParentTransX.Text = 'x';
            app.ParentTransX.FontSize = 18;
            app.ParentTransX.FontWeight = 'bold';
            app.ParentTransX.Position = [79 323 32 22];

            % Create ParentTransY
            app.ParentTransY = uicheckbox(app.UIFigure);
            app.ParentTransY.ValueChangedFcn = createCallbackFcn(app, @ParentTransZValueChanged, true);
            app.ParentTransY.Text = 'y';
            app.ParentTransY.FontSize = 18;
            app.ParentTransY.FontWeight = 'bold';
            app.ParentTransY.Position = [121 323 32 22];

            % Create ParentTransZ
            app.ParentTransZ = uicheckbox(app.UIFigure);
            app.ParentTransZ.ValueChangedFcn = createCallbackFcn(app, @ParentTransZValueChanged, true);
            app.ParentTransZ.Text = 'z';
            app.ParentTransZ.FontSize = 18;
            app.ParentTransZ.FontWeight = 'bold';
            app.ParentTransZ.Position = [160 323 31 22];

            % Create ParentTransLabel
            app.ParentTransLabel = uilabel(app.UIFigure);
            app.ParentTransLabel.FontSize = 18;
            app.ParentTransLabel.FontWeight = 'bold';
            app.ParentTransLabel.Position = [79 351 101 23];
            app.ParentTransLabel.Text = 'Translation';

            % Create ParentOrientLabel
            app.ParentOrientLabel = uilabel(app.UIFigure);
            app.ParentOrientLabel.FontSize = 18;
            app.ParentOrientLabel.FontWeight = 'bold';
            app.ParentOrientLabel.Position = [79 280 78 23];
            app.ParentOrientLabel.Text = 'Rotation';

            % Create ParentOrientZ
            app.ParentOrientZ = uicheckbox(app.UIFigure);
            app.ParentOrientZ.ValueChangedFcn = createCallbackFcn(app, @ParentRotZValueChanged, true);
            app.ParentOrientZ.Text = 'z';
            app.ParentOrientZ.FontSize = 18;
            app.ParentOrientZ.FontWeight = 'bold';
            app.ParentOrientZ.Position = [160 252 31 22];

            % Create ParentOrientY
            app.ParentOrientY = uicheckbox(app.UIFigure);
            app.ParentOrientY.ValueChangedFcn = createCallbackFcn(app, @ParentRotZValueChanged, true);
            app.ParentOrientY.Text = 'y';
            app.ParentOrientY.FontSize = 18;
            app.ParentOrientY.FontWeight = 'bold';
            app.ParentOrientY.Position = [121 253 32 22];

            % Create ParentOrientX
            app.ParentOrientX = uicheckbox(app.UIFigure);
            app.ParentOrientX.ValueChangedFcn = createCallbackFcn(app, @ParentRotZValueChanged, true);
            app.ParentOrientX.Text = 'x';
            app.ParentOrientX.FontSize = 18;
            app.ParentOrientX.FontWeight = 'bold';
            app.ParentOrientX.Position = [79 252 32 22];

            % Create ChildFrameLabel
            app.ChildFrameLabel = uilabel(app.UIFigure);
            app.ChildFrameLabel.FontSize = 18;
            app.ChildFrameLabel.FontWeight = 'bold';
            app.ChildFrameLabel.Position = [48 214 109 23];
            app.ChildFrameLabel.Text = 'Child Frame';

            % Create ChildOrientLabel
            app.ChildOrientLabel = uilabel(app.UIFigure);
            app.ChildOrientLabel.FontSize = 18;
            app.ChildOrientLabel.FontWeight = 'bold';
            app.ChildOrientLabel.Position = [79 111 78 23];
            app.ChildOrientLabel.Text = 'Rotation';

            % Create ChildOrientZ
            app.ChildOrientZ = uicheckbox(app.UIFigure);
            app.ChildOrientZ.ValueChangedFcn = createCallbackFcn(app, @ChildRotZValueChanged, true);
            app.ChildOrientZ.Text = 'z';
            app.ChildOrientZ.FontSize = 18;
            app.ChildOrientZ.FontWeight = 'bold';
            app.ChildOrientZ.Position = [160 83 31 22];

            % Create ChildOrientY
            app.ChildOrientY = uicheckbox(app.UIFigure);
            app.ChildOrientY.ValueChangedFcn = createCallbackFcn(app, @ChildRotZValueChanged, true);
            app.ChildOrientY.Text = 'y';
            app.ChildOrientY.FontSize = 18;
            app.ChildOrientY.FontWeight = 'bold';
            app.ChildOrientY.Position = [121 84 32 22];

            % Create ChildOrientX
            app.ChildOrientX = uicheckbox(app.UIFigure);
            app.ChildOrientX.ValueChangedFcn = createCallbackFcn(app, @ChildRotZValueChanged, true);
            app.ChildOrientX.Text = 'x';
            app.ChildOrientX.FontSize = 18;
            app.ChildOrientX.FontWeight = 'bold';
            app.ChildOrientX.Position = [79 83 32 22];

            % Create ChildTransZ
            app.ChildTransZ = uicheckbox(app.UIFigure);
            app.ChildTransZ.ValueChangedFcn = createCallbackFcn(app, @ChildTransZValueChanged, true);
            app.ChildTransZ.Text = 'z';
            app.ChildTransZ.FontSize = 18;
            app.ChildTransZ.FontWeight = 'bold';
            app.ChildTransZ.Position = [160 154 31 22];

            % Create ChildTransY
            app.ChildTransY = uicheckbox(app.UIFigure);
            app.ChildTransY.ValueChangedFcn = createCallbackFcn(app, @ChildTransZValueChanged, true);
            app.ChildTransY.Text = 'y';
            app.ChildTransY.FontSize = 18;
            app.ChildTransY.FontWeight = 'bold';
            app.ChildTransY.Position = [121 154 32 22];

            % Create ChildTransX
            app.ChildTransX = uicheckbox(app.UIFigure);
            app.ChildTransX.ValueChangedFcn = createCallbackFcn(app, @ChildTransZValueChanged, true);
            app.ChildTransX.Text = 'x';
            app.ChildTransX.FontSize = 18;
            app.ChildTransX.FontWeight = 'bold';
            app.ChildTransX.Position = [79 154 32 22];

            % Create ChildTransLabel
            app.ChildTransLabel = uilabel(app.UIFigure);
            app.ChildTransLabel.FontSize = 18;
            app.ChildTransLabel.FontWeight = 'bold';
            app.ChildTransLabel.Position = [79 182 101 23];
            app.ChildTransLabel.Text = 'Translation';

            % Create BoundsmEditFieldLabel
            app.BoundsmEditFieldLabel = uilabel(app.UIFigure);
            app.BoundsmEditFieldLabel.HorizontalAlignment = 'right';
            app.BoundsmEditFieldLabel.FontSize = 18;
            app.BoundsmEditFieldLabel.FontWeight = 'bold';
            app.BoundsmEditFieldLabel.Position = [223 323 105 23];
            app.BoundsmEditFieldLabel.Text = 'Bounds (m)';

            % Create ParentTransBound
            app.ParentTransBound = uieditfield(app.UIFigure, 'numeric');
            app.ParentTransBound.ValueChangedFcn = createCallbackFcn(app, @ParentTransBoundValueChanged, true);
            app.ParentTransBound.Position = [343 324 100 22];
            app.ParentTransBound.Value = 0.05;

            % Create BoundsmEditField_2Label
            app.BoundsmEditField_2Label = uilabel(app.UIFigure);
            app.BoundsmEditField_2Label.HorizontalAlignment = 'right';
            app.BoundsmEditField_2Label.FontSize = 18;
            app.BoundsmEditField_2Label.FontWeight = 'bold';
            app.BoundsmEditField_2Label.Position = [223 154 105 23];
            app.BoundsmEditField_2Label.Text = 'Bounds (m)';

            % Create ChildTransBound
            app.ChildTransBound = uieditfield(app.UIFigure, 'numeric');
            app.ChildTransBound.ValueChangedFcn = createCallbackFcn(app, @ChildTransBoundValueChanged, true);
            app.ChildTransBound.Position = [343 155 100 22];
            app.ChildTransBound.Value = 0.05;

            % Create BoundsradEditFieldLabel
            app.BoundsradEditFieldLabel = uilabel(app.UIFigure);
            app.BoundsradEditFieldLabel.HorizontalAlignment = 'right';
            app.BoundsradEditFieldLabel.FontSize = 18;
            app.BoundsradEditFieldLabel.FontWeight = 'bold';
            app.BoundsradEditFieldLabel.Position = [211 83 117 23];
            app.BoundsradEditFieldLabel.Text = 'Bounds (rad)';

            % Create ChildRotBound
            app.ChildRotBound = uieditfield(app.UIFigure, 'numeric');
            app.ChildRotBound.ValueChangedFcn = createCallbackFcn(app, @ChildRotBoundValueChanged, true);
            app.ChildRotBound.Position = [343 84 100 22];
            app.ChildRotBound.Value = 0.5;

            % Create BoundsradEditField_2Label
            app.BoundsradEditField_2Label = uilabel(app.UIFigure);
            app.BoundsradEditField_2Label.HorizontalAlignment = 'right';
            app.BoundsradEditField_2Label.FontSize = 18;
            app.BoundsradEditField_2Label.FontWeight = 'bold';
            app.BoundsradEditField_2Label.Position = [211 258 117 23];
            app.BoundsradEditField_2Label.Text = 'Bounds (rad)';

            % Create ParentRotBound
            app.ParentRotBound = uieditfield(app.UIFigure, 'numeric');
            app.ParentRotBound.ValueChangedFcn = createCallbackFcn(app, @ParentRotBoundValueChanged, true);
            app.ParentRotBound.Position = [343 259 100 22];
            app.ParentRotBound.Value = 0.5;

            % Create OKButton
            app.OKButton = uibutton(app.UIFigure, 'push');
            app.OKButton.ButtonPushedFcn = createCallbackFcn(app, @OKButtonPushed, true);
            app.OKButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.OKButton.FontSize = 18;
            app.OKButton.FontColor = [1 1 1];
            app.OKButton.Position = [254 14 85 30];
            app.OKButton.Text = 'OK';

            % Create CloseButton
            app.CloseButton = uibutton(app.UIFigure, 'push');
            app.CloseButton.ButtonPushedFcn = createCallbackFcn(app, @CloseButtonPushed, true);
            app.CloseButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.CloseButton.FontSize = 18;
            app.CloseButton.FontColor = [1 1 1];
            app.CloseButton.Position = [383 14 85 30];
            app.CloseButton.Text = 'Close';

            % Create JointNameError
            app.JointNameError = uiimage(app.UIFigure);
            app.JointNameError.Visible = 'off';
            app.JointNameError.Position = [396 441 37 35];
            app.JointNameError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ParentTransBoundsError
            app.ParentTransBoundsError = uiimage(app.UIFigure);
            app.ParentTransBoundsError.Visible = 'off';
            app.ParentTransBoundsError.Position = [445 317 37 35];
            app.ParentTransBoundsError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ParentOrientBoundsError
            app.ParentOrientBoundsError = uiimage(app.UIFigure);
            app.ParentOrientBoundsError.Visible = 'off';
            app.ParentOrientBoundsError.Position = [445 252 37 35];
            app.ParentOrientBoundsError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ChildTransBoundsError
            app.ChildTransBoundsError = uiimage(app.UIFigure);
            app.ChildTransBoundsError.Visible = 'off';
            app.ChildTransBoundsError.Position = [445 149 37 35];
            app.ChildTransBoundsError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create ChildOrientBoundsError
            app.ChildOrientBoundsError = uiimage(app.UIFigure);
            app.ChildOrientBoundsError.Visible = 'off';
            app.ChildOrientBoundsError.Position = [445 78 37 35];
            app.ChildOrientBoundsError.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create OKWarning
            app.OKWarning = uiimage(app.UIFigure);
            app.OKWarning.Visible = 'off';
            app.OKWarning.Position = [211 12 35 35];
            app.OKWarning.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'warning.png');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = JMPJointSelection(varargin)

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