% This class is part of the NMSM Pipeline, see file for full license.
%
% This class is the Surrogate Muscle Model GUI, the GUI version of
% surrogateKinematicsScript.m. It samples kinematics around a reference
% joint angles file with Latin hypercube sampling, writes them to
% <output>/IKData/<trial>.sto, and runs MuscleAnalysis on them into
% <output>/MAData/<trial>. The output directory is then ready to use as
% Treatment Optimization's surrogate model data directory. Its layout is
% edited in SurrogateModelGuiVisual.mlapp.

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
classdef SurrogateModelGui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        LinearPaddingmEditField        matlab.ui.control.EditField
        LinearPaddingmLabel            matlab.ui.control.Label
        AngularPaddingdegEditField     matlab.ui.control.EditField
        AngularPaddingdegLabel         matlab.ui.control.Label
        OutputDirectorySearchButton    matlab.ui.control.Button
        OutputDirectoryStatus          matlab.ui.control.Image
        OutputDirectoryEditField       matlab.ui.control.EditField
        OutputDirectoryLabel           matlab.ui.control.Label
        RunSurrogateModelToolButton    matlab.ui.control.Button
        NumberofSamplePointsEditField  matlab.ui.control.EditField
        NumberofSamplePointsEditFieldLabel  matlab.ui.control.Label
        PaddingbyCoordinateLabel       matlab.ui.control.Label
        PaddingTable                   matlab.ui.control.Table
        JointAnglesStatus              matlab.ui.control.Image
        JointAnglesFileEditField       matlab.ui.control.EditField
        JointAnglesFileEditFieldLabel  matlab.ui.control.Label
        JointAnglesFileSearchButton    matlab.ui.control.Button
        InputModelFileStatus           matlab.ui.control.Image
        InputModelFileEditField        matlab.ui.control.EditField
        InputModelFileEditFieldLabel   matlab.ui.control.Label
        InputModelFileSearchButton     matlab.ui.control.Button
        RcnlLogo                       matlab.ui.control.Image
        SurrogateMuscleModelLabel      matlab.ui.control.Label
    end

    properties (SetObservable, Access = private)
        input_model_file string = "";
        joint_angles_file string = "";
        output_directory string = "";
        % Kept as typed so an invalid entry can be shown as an error
        sample_points string = "25";
        angular_padding string = "20";
        linear_padding string = "0.1";
        % Per-coordinate [lower upper] padding in degrees or meters, NaN
        % meaning the default. Kept by name so another joint angles file
        % keeps the overrides for the coordinates it shares.
        padding_overrides struct = struct('names', strings(0, 1), ...
            'values', zeros(0, 2));
    end

    properties (Access = private)
        % What each file holds, by path and modification time, so a file
        % is only read again when it changes
        fileInfoCache
        % Field checks from the last validation, one struct per field
        checks struct = struct()
        % The table's rows from the last validation: name, isRotational,
        % values (the [lower upper] shown) and isDefault (per cell)
        rows struct = struct('name', {}, 'isRotational', {}, ...
            'values', {}, 'isDefault', {})
        propertyListener
    end

    methods (Access = private)

        % Redraws every field from the model properties and validates
        function refreshAll(app)
            if ~isvalid(app) || ~isvalid(app.UIFigure)
                return
            end
            app.InputModelFileEditField.Value = getRelativePath(app.input_model_file);
            app.JointAnglesFileEditField.Value = getRelativePath(app.joint_angles_file);
            app.OutputDirectoryEditField.Value = getRelativePath(app.output_directory);
            app.NumberofSamplePointsEditField.Value = app.sample_points;
            app.AngularPaddingdegEditField.Value = app.angular_padding;
            app.LinearPaddingmEditField.Value = app.linear_padding;
            app.validateAll();
            app.drawChecks();
            app.drawPaddingTable();
            c = app.checks;
            statuses = [c.model.status, c.jointAngles.status, c.output.status, ...
                c.samplePoints.status, c.angular.status, c.linear.status, ...
                c.table.status];
            app.RunSurrogateModelToolButton.Enable = ...
                ~any(statuses == "error" | statuses == "required");
        end

        % What a file holds. kind is "model", giving its coordinates and
        % whether each is rotational, or "data", giving its column names.
        function info = fileInfo(app, path, kind)
            listing = dir(path);
            key = kind + "|" + path + "|" + string(listing(1).datenum);
            if isKey(app.fileInfoCache, key)
                info = app.fileInfoCache(key);
                return
            end
            info = struct('valid', false, 'message', "", 'names', ...
                strings(0, 1), 'isRotational', false(0, 1));
            try
                if kind == "model"
                    model = Model(char(path));
                    coordinates = model.getCoordinateSet();
                    count = coordinates.getSize();
                    info.names = strings(count, 1);
                    info.isRotational = false(count, 1);
                    for i = 1 : count
                        coordinate = coordinates.get(i - 1);
                        info.names(i) = string(coordinate.getName());
                        info.isRotational(i) = string(coordinate. ...
                            getMotionType().toString()) == "Rotational";
                    end
                else
                    storage = org.opensim.modeling.Storage(char(path));
                    info.names = string(getStorageColumnNames(storage));
                    info.names = info.names(:);
                    if storage.getSize() < 1
                        error("The file has no rows of data.");
                    end
                end
                info.valid = true;
            catch exception
                info.message = "The file could not be loaded. Verify " + ...
                    "that it is a valid " + ternaryText(kind == "model", ...
                    ".osim model", ".sto or .mot file") + ". (" + ...
                    string(exception.message) + ")";
            end
            app.fileInfoCache(key) = info;
        end

        function result = check(~, status, message)
            if nargin < 3
                message = "";
            end
            result = struct('status', string(status), 'message', string(message));
        end

        % Checks a required input file, returning what it holds when valid
        function [result, info] = checkInputFile(app, path, kind, name)
            info = [];
            result = app.check("none");
            if path == ""
                result = app.check("required", "A " + name + " is required.");
            elseif ~isfile(path)
                result = app.check("error", "The given file does not exist.");
            else
                info = app.fileInfo(path, kind);
                if ~info.valid
                    result = app.check("error", info.message);
                    info = [];
                end
            end
        end

        % A non-negative padding typed into a field, or NaN
        function value = paddingValue(~, text)
            value = str2double(text);
            if ~isfinite(value) || value < 0
                value = NaN;
            end
        end

        function validateAll(app)
            c = struct();
            [c.model, modelInfo] = app.checkInputFile(app.input_model_file, ...
                "model", "model file");
            [c.jointAngles, anglesInfo] = app.checkInputFile( ...
                app.joint_angles_file, "data", "joint angles file");
            if ~isempty(modelInfo) && ~isempty(anglesInfo)
                missing = setdiff(anglesInfo.names, modelInfo.names, 'stable');
                if ~isempty(missing)
                    c.jointAngles = app.check("error", "Every column must " + ...
                        "be a coordinate in the model. These are not: " + ...
                        strjoin(missing, ", ") + ".");
                    anglesInfo = [];
                end
            end

            c.output = app.check("none");
            if app.output_directory == ""
                c.output = app.check("required", "An output directory is required.");
            elseif isfolder(app.output_directory)
                message = "The output directory already exists.";
                [~, trial] = fileparts(app.joint_angles_file);
                if app.joint_angles_file ~= "" && (isfile(fullfile( ...
                        app.output_directory, "IKData", trial + ".sto")) || ...
                        isfolder(fullfile(app.output_directory, "MAData", trial)))
                    message = message + " IKData/" + trial + ".sto and " + ...
                        "MAData/" + trial + " will be overwritten.";
                end
                c.output = app.check("warning", message);
            end

            points = str2double(app.sample_points);
            c.samplePoints = app.check("none");
            if ~isfinite(points) || points < 1 || mod(points, 1) ~= 0
                c.samplePoints = app.check("error", ...
                    "The number of sample points must be a whole number of at least 1.");
            end
            angular = app.paddingValue(app.angular_padding);
            linear = app.paddingValue(app.linear_padding);
            c.angular = app.check("none");
            c.linear = app.check("none");
            if isnan(angular)
                c.angular = app.check("error", ...
                    "The angular padding must be a number of at least 0 degrees.");
            end
            if isnan(linear)
                c.linear = app.check("error", ...
                    "The linear padding must be a number of at least 0 meters.");
            end

            % One row per joint angles column, once both files are valid
            app.rows = struct('name', {}, 'isRotational', {}, ...
                'values', {}, 'isDefault', {});
            c.badRows = [];
            c.table = app.check("none");
            if isempty(modelInfo) || isempty(anglesInfo)
                c.table.message = "The coordinates are listed once a " + ...
                    "valid model and joint angles file are given.";
            else
                problems = strings(0, 1);
                overrides = app.padding_overrides;
                for i = 1 : numel(anglesInfo.names)
                    name = anglesInfo.names(i);
                    isRotational = modelInfo.isRotational(modelInfo.names == name);
                    default = ternaryText(isRotational, angular, linear);
                    values = [-default default];
                    index = find(overrides.names == name, 1);
                    isDefault = [true true];
                    if ~isempty(index)
                        given = ~isnan(overrides.values(index, :));
                        values(given) = overrides.values(index, given);
                        isDefault = ~given;
                    end
                    app.rows(end + 1) = struct('name', name, 'isRotational', ...
                        isRotational, 'values', values, 'isDefault', isDefault);
                    if ~any(isnan(values)) && values(1) > values(2)
                        problems(end + 1) = name + ": the lower padding " + ...
                            "must not be above the upper padding."; %#ok<AGROW>
                        c.badRows(end + 1) = i;
                    end
                end
                if ~isempty(problems)
                    c.table = app.check("error", strjoin(problems, newline));
                end
            end
            app.checks = c;
        end

        function drawChecks(app)
            c = app.checks;
            setGuiFieldStatus(app.InputModelFileEditField, app.InputModelFileStatus, ...
                c.model.status, c.model.message);
            setGuiFieldStatus(app.JointAnglesFileEditField, app.JointAnglesStatus, ...
                c.jointAngles.status, c.jointAngles.message);
            setGuiFieldStatus(app.OutputDirectoryEditField, app.OutputDirectoryStatus, ...
                c.output.status, c.output.message);
            % These fields have no status icon, so the message goes on each
            % field's tooltip
            fields = [app.NumberofSamplePointsEditField, ...
                app.AngularPaddingdegEditField, app.LinearPaddingmEditField];
            fieldChecks = [c.samplePoints, c.angular, c.linear];
            for i = 1 : numel(fields)
                setGuiFieldStatus(fields(i), [], fieldChecks(i).status);
                fields(i).Tooltip = char(fieldChecks(i).message);
            end
        end

        % Default cells are grey, so an override stands out; clearing a
        % cell goes back to the default
        function drawPaddingTable(app)
            data = cell(numel(app.rows), 3);
            for i = 1 : numel(app.rows)
                row = app.rows(i);
                data{i, 1} = char(row.name + ternaryText(row.isRotational, ...
                    " (deg)", " (m)"));
                data{i, 2} = row.values(1);
                data{i, 3} = row.values(2);
            end
            paddingTable = app.PaddingTable;
            paddingTable.Data = data;
            removeStyle(paddingTable);
            if ~isempty(app.rows)
                defaults = vertcat(app.rows.isDefault);
                [defaultRows, defaultColumns] = find(defaults);
                if ~isempty(defaultRows)
                    addStyle(paddingTable, uistyle('FontColor', [0.55 0.55 0.55]), ...
                        'cell', [defaultRows, defaultColumns + 1]);
                end
            end
            if ~isempty(app.checks.badRows)
                addStyle(paddingTable, uistyle('BackgroundColor', [1.00 0.67 0.67]), ...
                    'row', app.checks.badRows);
            end
            tip = app.checks.table.message;
            if isempty(app.rows)
                % Only the reason the table is empty
            elseif tip == ""
                tip = "Grey values are the default padding. Type a value " + ...
                    "to override it, or clear it to go back to the default.";
            end
            paddingTable.Tooltip = char(tip);
            app.PaddingbyCoordinateLabel.FontColor = [0 0 0];
            if app.checks.table.status == "error"
                app.PaddingbyCoordinateLabel.FontColor = [0.8 0 0];
            end
        end

        % The sampling settings, in radians and meters, from the fields
        % and table, as surrogateKinematicsScript.m builds them
        function settings = samplingSettings(app)
            settings.samplePoints = str2double(app.sample_points);
            settings.angularPadding = deg2rad(str2double(app.angular_padding));
            settings.linearPadding = str2double(app.linear_padding);
            settings.padding = struct();
            for row = app.rows
                if all(row.isDefault)
                    continue
                end
                values = row.values;
                if row.isRotational
                    values = deg2rad(values);
                end
                settings.padding.(row.name) = values;
            end
        end

        function runSurrogateModelTool(app)
            progress = uiprogressdlg(app.UIFigure, 'Title', ...
                'Surrogate Muscle Model', 'Message', 'Sampling kinematics...', ...
                'Indeterminate', 'on');
            try
                if ~license('test', 'Statistics_Toolbox')
                    error("Sampling uses lhsdesign, which needs the " + ...
                        "Statistics and Machine Learning Toolbox.");
                end
                model = Model(char(app.input_model_file));
                [coordinateNames, ~, referenceKinematics] = ...
                    parseMotToComponents(model, org.opensim.modeling.Storage( ...
                    char(app.joint_angles_file)));
                lhsKinematics = sampleSurrogateKinematicsFromSettings(model, ...
                    referenceKinematics', coordinateNames, app.samplingSettings());

                [~, trial] = fileparts(app.joint_angles_file);
                ikDirectory = fullfile(app.output_directory, "IKData");
                maDirectory = fullfile(app.output_directory, "MAData", trial);
                for folder = [ikDirectory, maDirectory]
                    if ~isfolder(folder)
                        mkdir(folder);
                    end
                end
                ikFile = fullfile(ikDirectory, trial + ".sto");
                if isfile(ikFile)
                    delete(ikFile);
                end
                frames = size(lhsKinematics, 1);
                writeToSto(coordinateNames, (1 : frames) * 1e-3, ...
                    lhsKinematics, ikFile);

                progress.Message = sprintf( ...
                    'Running muscle analysis on %d frames...', frames);
                runMuscleAnalysis(app.input_model_file, ikFile, maDirectory);
            catch exception
                delete(progress);
                uialert(app.UIFigure, exception.message, ...
                    'Surrogate Muscle Model Failed');
                app.refreshAll();
                return
            end
            delete(progress);
            uialert(app.UIFigure, "Surrogate model data written to " + ...
                app.output_directory + ":" + newline + "IKData/" + trial + ...
                ".sto (" + frames + " frames)" + newline + "MAData/" + ...
                trial + newline + newline + "Use this folder as the " + ...
                "surrogate model data directory in Treatment Optimization.", ...
                'Surrogate Muscle Model Complete', 'Icon', 'success');
            app.refreshAll();
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.UIFigure.Name = 'Surrogate Muscle Model';
            app.fileInfoCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
            app.output_directory = string(fullfile(pwd, 'SurrogateData'));
            app.propertyListener = addlistener(app, {'input_model_file', ...
                'joint_angles_file', 'output_directory', 'sample_points', ...
                'angular_padding', 'linear_padding', 'padding_overrides'}, ...
                'PostSet', @(~, ~) app.refreshAll());
            app.refreshAll();
        end

        % Image clicked function: RcnlLogo
        function RcnlLogoImageClicked(app, event)
            web("https://nmsm.rice.edu/")
        end

        % Value changed function: InputModelFileEditField
        function InputModelFileEditFieldValueChanged(app, event)
            app.input_model_file = getPathFieldValue(app.InputModelFileEditField);
        end

        % Button pushed function: InputModelFileSearchButton
        function InputModelFileSearchButtonPushed(app, event)
            [file, path] = uigetfile('*.osim', 'Select an OpenSim Model File');
            if isequal(file, 0)
                return
            end
            app.input_model_file = string(fullfile(path, file));
        end

        % Value changed function: JointAnglesFileEditField
        function JointAnglesFileEditFieldValueChanged(app, event)
            app.joint_angles_file = getPathFieldValue(app.JointAnglesFileEditField);
        end

        % Button pushed function: JointAnglesFileSearchButton
        function JointAnglesFileSearchButtonPushed(app, event)
            [file, path] = uigetfile({'*.sto;*.mot', ...
                'Data files (*.sto, *.mot)'}, 'Select a Joint Angles File');
            if isequal(file, 0)
                return
            end
            app.joint_angles_file = string(fullfile(path, file));
        end

        % Value changed function: OutputDirectoryEditField
        function OutputDirectoryEditFieldValueChanged(app, event)
            app.output_directory = getPathFieldValue(app.OutputDirectoryEditField);
        end

        % Button pushed function: OutputDirectorySearchButton
        function OutputDirectorySearchButtonPushed(app, event)
            folder = uigetdir(pwd, 'Select an Output Directory');
            if isequal(folder, 0)
                return
            end
            app.output_directory = string(folder);
        end

        % Value changed function: NumberofSamplePointsEditField
        function NumberofSamplePointsEditFieldValueChanged(app, event)
            app.sample_points = strtrim(string(app.NumberofSamplePointsEditField.Value));
        end

        % Value changed function: AngularPaddingdegEditField
        function AngularPaddingdegEditFieldValueChanged(app, event)
            app.angular_padding = strtrim(string(app.AngularPaddingdegEditField.Value));
        end

        % Value changed function: LinearPaddingmEditField
        function LinearPaddingmEditFieldValueChanged(app, event)
            app.linear_padding = strtrim(string(app.LinearPaddingmEditField.Value));
        end

        % Cell edit callback: PaddingTable
        function PaddingTableCellEdit(app, event)
            row = event.Indices(1);
            column = event.Indices(2);
            if row > numel(app.rows) || column < 2
                return
            end
            value = event.NewData;
            if ischar(value) || isstring(value)
                value = str2double(value);
            end
            if isempty(value) || ~isfinite(value)
                value = NaN;
            end
            name = app.rows(row).name;
            overrides = app.padding_overrides;
            index = find(overrides.names == name, 1);
            if isempty(index)
                overrides.names(end + 1, 1) = name;
                overrides.values(end + 1, :) = [NaN NaN];
                index = numel(overrides.names);
            end
            overrides.values(index, column - 1) = value;
            if all(isnan(overrides.values(index, :)))
                overrides.names(index) = [];
                overrides.values(index, :) = [];
            end
            app.padding_overrides = overrides;
        end

        % Button pushed function: RunSurrogateModelToolButton
        function RunSurrogateModelToolButtonPushed(app, event)
            app.runSurrogateModelTool();
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
            app.UIFigure.Position = [100 100 779 603];
            app.UIFigure.Name = 'MATLAB App';

            % Create SurrogateMuscleModelLabel
            app.SurrogateMuscleModelLabel = uilabel(app.UIFigure);
            app.SurrogateMuscleModelLabel.HorizontalAlignment = 'center';
            app.SurrogateMuscleModelLabel.FontSize = 25;
            app.SurrogateMuscleModelLabel.FontWeight = 'bold';
            app.SurrogateMuscleModelLabel.Position = [1 564 771 40];
            app.SurrogateMuscleModelLabel.Text = 'Surrogate Muscle Model';

            % Create RcnlLogo
            app.RcnlLogo = uiimage(app.UIFigure);
            app.RcnlLogo.ImageClickedFcn = createCallbackFcn(app, @RcnlLogoImageClicked, true);
            app.RcnlLogo.Position = [6 519 80 80];
            app.RcnlLogo.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'rcnlIcon.png');

            % Create InputModelFileSearchButton
            app.InputModelFileSearchButton = uibutton(app.UIFigure, 'push');
            app.InputModelFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputModelFileSearchButtonPushed, true);
            app.InputModelFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.InputModelFileSearchButton.VerticalAlignment = 'bottom';
            app.InputModelFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.InputModelFileSearchButton.Position = [695 480 31 30];
            app.InputModelFileSearchButton.Text = '';

            % Create InputModelFileEditFieldLabel
            app.InputModelFileEditFieldLabel = uilabel(app.UIFigure);
            app.InputModelFileEditFieldLabel.HorizontalAlignment = 'right';
            app.InputModelFileEditFieldLabel.FontSize = 18;
            app.InputModelFileEditFieldLabel.FontWeight = 'bold';
            app.InputModelFileEditFieldLabel.Position = [85 480 140 30];
            app.InputModelFileEditFieldLabel.Text = 'Input Model File';

            % Create InputModelFileEditField
            app.InputModelFileEditField = uieditfield(app.UIFigure, 'text');
            app.InputModelFileEditField.ValueChangedFcn = createCallbackFcn(app, @InputModelFileEditFieldValueChanged, true);
            app.InputModelFileEditField.Position = [235 480 450 30];

            % Create InputModelFileStatus
            app.InputModelFileStatus = uiimage(app.UIFigure);
            app.InputModelFileStatus.Visible = 'off';
            app.InputModelFileStatus.Position = [728 480 28 30];
            app.InputModelFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create JointAnglesFileSearchButton
            app.JointAnglesFileSearchButton = uibutton(app.UIFigure, 'push');
            app.JointAnglesFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @JointAnglesFileSearchButtonPushed, true);
            app.JointAnglesFileSearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.JointAnglesFileSearchButton.VerticalAlignment = 'bottom';
            app.JointAnglesFileSearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.JointAnglesFileSearchButton.Position = [695 431 31 30];
            app.JointAnglesFileSearchButton.Text = '';

            % Create JointAnglesFileEditFieldLabel
            app.JointAnglesFileEditFieldLabel = uilabel(app.UIFigure);
            app.JointAnglesFileEditFieldLabel.HorizontalAlignment = 'right';
            app.JointAnglesFileEditFieldLabel.FontSize = 18;
            app.JointAnglesFileEditFieldLabel.FontWeight = 'bold';
            app.JointAnglesFileEditFieldLabel.Position = [77 431 148 30];
            app.JointAnglesFileEditFieldLabel.Text = 'Joint Angles File';

            % Create JointAnglesFileEditField
            app.JointAnglesFileEditField = uieditfield(app.UIFigure, 'text');
            app.JointAnglesFileEditField.ValueChangedFcn = createCallbackFcn(app, @JointAnglesFileEditFieldValueChanged, true);
            app.JointAnglesFileEditField.Position = [235 431 450 30];

            % Create JointAnglesStatus
            app.JointAnglesStatus = uiimage(app.UIFigure);
            app.JointAnglesStatus.Visible = 'off';
            app.JointAnglesStatus.Position = [728 431 28 30];
            app.JointAnglesStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create PaddingTable
            app.PaddingTable = uitable(app.UIFigure);
            app.PaddingTable.ColumnName = {'Coordinate'; 'Lower'; 'Upper'};
            app.PaddingTable.ColumnWidth = {'2x', '1x', '1x'};
            app.PaddingTable.RowName = {};
            app.PaddingTable.ColumnEditable = [false true true];
            app.PaddingTable.ColumnFormat = {'char', 'numeric', 'numeric'};
            app.PaddingTable.CellEditCallback = createCallbackFcn(app, @PaddingTableCellEdit, true);
            app.PaddingTable.Position = [236 61 302 205];

            % Create PaddingbyCoordinateLabel
            app.PaddingbyCoordinateLabel = uilabel(app.UIFigure);
            app.PaddingbyCoordinateLabel.HorizontalAlignment = 'right';
            app.PaddingbyCoordinateLabel.FontSize = 18;
            app.PaddingbyCoordinateLabel.FontWeight = 'bold';
            app.PaddingbyCoordinateLabel.Position = [23 192 203 30];
            app.PaddingbyCoordinateLabel.Text = 'Padding by Coordinate';

            % Create NumberofSamplePointsEditFieldLabel
            app.NumberofSamplePointsEditFieldLabel = uilabel(app.UIFigure);
            app.NumberofSamplePointsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofSamplePointsEditFieldLabel.FontSize = 18;
            app.NumberofSamplePointsEditFieldLabel.FontWeight = 'bold';
            app.NumberofSamplePointsEditFieldLabel.Position = [97 326 130 44];
            app.NumberofSamplePointsEditFieldLabel.Text = {'Number of '; 'Sample Points'};

            % Create NumberofSamplePointsEditField
            app.NumberofSamplePointsEditField = uieditfield(app.UIFigure, 'text');
            app.NumberofSamplePointsEditField.CharacterLimits = [1 Inf];
            app.NumberofSamplePointsEditField.InputType = 'digits';
            app.NumberofSamplePointsEditField.ValueChangedFcn = createCallbackFcn(app, @NumberofSamplePointsEditFieldValueChanged, true);
            app.NumberofSamplePointsEditField.FontSize = 18;
            app.NumberofSamplePointsEditField.Position = [235 333 59 30];
            app.NumberofSamplePointsEditField.Value = '25';

            % Create RunSurrogateModelToolButton
            app.RunSurrogateModelToolButton = uibutton(app.UIFigure, 'push');
            app.RunSurrogateModelToolButton.ButtonPushedFcn = createCallbackFcn(app, @RunSurrogateModelToolButtonPushed, true);
            app.RunSurrogateModelToolButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.RunSurrogateModelToolButton.FontSize = 18;
            app.RunSurrogateModelToolButton.FontColor = [1 1 1];
            app.RunSurrogateModelToolButton.Position = [289 17 226 30];
            app.RunSurrogateModelToolButton.Text = 'Run Surrogate Model Tool';

            % Create OutputDirectoryLabel
            app.OutputDirectoryLabel = uilabel(app.UIFigure);
            app.OutputDirectoryLabel.HorizontalAlignment = 'right';
            app.OutputDirectoryLabel.FontSize = 18;
            app.OutputDirectoryLabel.FontWeight = 'bold';
            app.OutputDirectoryLabel.Position = [38 382 188 30];
            app.OutputDirectoryLabel.Text = 'Output Directory';

            % Create OutputDirectoryEditField
            app.OutputDirectoryEditField = uieditfield(app.UIFigure, 'text');
            app.OutputDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @OutputDirectoryEditFieldValueChanged, true);
            app.OutputDirectoryEditField.Position = [236 382 450 30];
            app.OutputDirectoryEditField.Value = 'SurrogateData';

            % Create OutputDirectoryStatus
            app.OutputDirectoryStatus = uiimage(app.UIFigure);
            app.OutputDirectoryStatus.Visible = 'off';
            app.OutputDirectoryStatus.Position = [728 382 28 30];
            app.OutputDirectoryStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create OutputDirectorySearchButton
            app.OutputDirectorySearchButton = uibutton(app.UIFigure, 'push');
            app.OutputDirectorySearchButton.ButtonPushedFcn = createCallbackFcn(app, @OutputDirectorySearchButtonPushed, true);
            app.OutputDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.OutputDirectorySearchButton.VerticalAlignment = 'bottom';
            app.OutputDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.OutputDirectorySearchButton.Position = [694 382 31 30];
            app.OutputDirectorySearchButton.Text = '';

            % Create AngularPaddingdegLabel
            app.AngularPaddingdegLabel = uilabel(app.UIFigure);
            app.AngularPaddingdegLabel.HorizontalAlignment = 'right';
            app.AngularPaddingdegLabel.FontSize = 18;
            app.AngularPaddingdegLabel.FontWeight = 'bold';
            app.AngularPaddingdegLabel.Position = [29 288 199 23];
            app.AngularPaddingdegLabel.Text = 'Angular Padding (deg)';

            % Create AngularPaddingdegEditField
            app.AngularPaddingdegEditField = uieditfield(app.UIFigure, 'text');
            app.AngularPaddingdegEditField.CharacterLimits = [1 Inf];
            app.AngularPaddingdegEditField.ValueChangedFcn = createCallbackFcn(app, @AngularPaddingdegEditFieldValueChanged, true);
            app.AngularPaddingdegEditField.FontSize = 18;
            app.AngularPaddingdegEditField.Position = [235 284 59 30];
            app.AngularPaddingdegEditField.Value = '20';

            % Create LinearPaddingmLabel
            app.LinearPaddingmLabel = uilabel(app.UIFigure);
            app.LinearPaddingmLabel.HorizontalAlignment = 'right';
            app.LinearPaddingmLabel.FontSize = 18;
            app.LinearPaddingmLabel.FontWeight = 'bold';
            app.LinearPaddingmLabel.Position = [348 288 168 23];
            app.LinearPaddingmLabel.Text = 'Linear Padding (m)';

            % Create LinearPaddingmEditField
            app.LinearPaddingmEditField = uieditfield(app.UIFigure, 'text');
            app.LinearPaddingmEditField.CharacterLimits = [1 Inf];
            app.LinearPaddingmEditField.ValueChangedFcn = createCallbackFcn(app, @LinearPaddingmEditFieldValueChanged, true);
            app.LinearPaddingmEditField.FontSize = 18;
            app.LinearPaddingmEditField.Position = [523 284 59 30];
            app.LinearPaddingmEditField.Value = '0.1';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';

            % Center the window on whichever screen it lands on, as the
            % other tools do
            movegui(app.UIFigure, 'center');
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SurrogateModelGui

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

function value = ternaryText(condition, whenTrue, whenFalse)
if condition
    value = whenTrue;
else
    value = whenFalse;
end
end
