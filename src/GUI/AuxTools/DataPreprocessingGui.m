% This class is part of the NMSM Pipeline, see file for full license.
%
% This class is the Data Preprocessing GUI, the GUI version of the
% preprocessing script. It processes raw EMG, differentiates
% MuscleAnalysis muscle-tendon lengths into velocities, runs
% MuscleAnalysis on a joint angles file, and splits the data files into
% trials by time pairs with splitIntoTrials. Every input is optional: the
% run does whatever the given files allow. Its layout is edited in
% DataPreprocessingGuiVisual.mlapp.

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
classdef DataPreprocessingGui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        ProcessedEmgFileStatus          matlab.ui.control.Image
        ProcessedEMGFileEditField       matlab.ui.control.EditField
        ProcessedEMGFileEditFieldLabel  matlab.ui.control.Label
        ProcessedEmgFileSearchButton    matlab.ui.control.Button
        OutputDirectorySearchButton     matlab.ui.control.Button
        OutputDirectoryStatus           matlab.ui.control.Image
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
        TimePairsContextMenu            matlab.ui.container.ContextMenu
        DeletePairMenu                  matlab.ui.container.Menu
    end

    properties (Access = private, SetObservable)
        % File and directory paths are held as full paths and shown
        % relative to the current folder
        input_model_file string = "";
        raw_emg_file string = "";
        processed_emg_file string = "";
        joint_angles_file string = "";
        joint_loads_file string = "";
        ground_reactions_file string = "";
        muscle_analysis_directory string = "";
        output_directory string = "";

        process_emg logical = true;
        filter_order double = 4;
        high_pass_cutoff double = 40;
        low_pass_cutoff double = 3.5;

        trial_prefix string = "gait";
        number_of_time_points string = "101";
        % One row per trial, [start end]
        trial_time_pairs double = zeros(0, 2);
    end

    properties (Access = private)
        % What each file holds, by path and modification time, so a file
        % is only read again when it changes
        fileInfoCache
        % The table's trailing blank row, holding a pair being typed in
        draftPair double = [NaN NaN];
        % Whether the time pairs are still the default, the time every
        % given file covers, and so follow the files as they change
        autoPairs logical = true;
        % The default pair from the last validation, to notice changes
        lastDefaultPair double = zeros(0, 2);
        % Field checks from the last validation, one struct per field
        checks struct = struct()
        propertyListener
    end

    properties (Constant, Access = private)
        % Used by splitIntoTrials for sectioning and by
        % createMuscleTendonVelocity, as in the tutorial script
        cutoffFrequency = 6.25
    end

    methods (Access = private)

        % Redraws every field from the model properties and validates
        function refreshAll(app)
            if ~isvalid(app) || ~isvalid(app.UIFigure)
                return
            end
            app.InputModelFileEditField.Value = getRelativePath(app.input_model_file);
            app.RawEMGFileEditField.Value = getRelativePath(app.raw_emg_file);
            app.ProcessedEMGFileEditField.Value = getRelativePath(app.processed_emg_file);
            app.JointAnglesFileEditField.Value = getRelativePath(app.joint_angles_file);
            app.JointLoadsFileEditField.Value = getRelativePath(app.joint_loads_file);
            app.GroundReactionsFileEditField.Value = getRelativePath(app.ground_reactions_file);
            app.MuscleAnalysisDataDirectoryEditField.Value = ...
                getRelativePath(app.muscle_analysis_directory);
            app.OutputDirectoryEditField.Value = getRelativePath(app.output_directory);
            app.EMGProcessingCheckBox.Value = app.process_emg;
            app.FilterOrderEditField.Value = app.filter_order;
            app.HighPassCutoffFrequencyEditField.Value = app.high_pass_cutoff;
            app.LowPassCutoffFrequencyEditField.Value = app.low_pass_cutoff;
            app.TrialPrefixEditField.Value = app.trial_prefix;
            app.NumberofTimePointsEditField.Value = app.number_of_time_points;
            % Raw EMG and its filter only matter when EMG is processed
            emgControls = [app.RawEMGFileEditField, app.RawEmgFileSearchButton, ...
                app.FilterOrderEditField, app.HighPassCutoffFrequencyEditField, ...
                app.LowPassCutoffFrequencyEditField];
            set(emgControls, 'Enable', app.process_emg);
            app.validateAll();
            % Fill in the default pair when the files' shared time changes,
            % unless the pairs have been edited. The listener does not fire
            % again while it is running, so the pairs are revalidated here.
            default = app.checks.defaultPair;
            if ~isequal(default, app.lastDefaultPair)
                app.lastDefaultPair = default;
                if app.autoPairs || isempty(app.trial_time_pairs)
                    app.autoPairs = true;
                    if ~isequal(app.trial_time_pairs, default)
                        app.trial_time_pairs = default;
                        app.validateAll();
                    end
                end
            end
            app.drawChecks();
            app.drawTimePairs();
            app.updateRunButtons();
        end

        % What a file holds: whether it loads, its time range and its
        % sample rate. kind is "data" (.sto or .mot), "csv" (raw EMG) or
        % "model".
        function info = fileInfo(app, path, kind)
            listing = dir(path);
            key = kind + "|" + path + "|" + string(listing(1).datenum);
            if isKey(app.fileInfoCache, key)
                info = app.fileInfoCache(key);
                return
            end
            info = struct('valid', false, 'message', "", 'range', [], ...
                'sampleRate', NaN);
            try
                switch kind
                    case "model"
                        [failed, message] = parseModelFileGui(app, path);
                        info.valid = ~failed;
                        info.message = string(message);
                    case "csv"
                        [~, time] = readEmgCsvFile(path);
                        info.valid = true;
                        info.range = [time(1) time(end)];
                        info.sampleRate = (numel(time) - 1) / (time(end) - time(1));
                    otherwise
                        storage = org.opensim.modeling.Storage(char(path));
                        info.valid = true;
                        info.range = [storage.getFirstTime() storage.getLastTime()];
                        info.sampleRate = (storage.getSize() - 1) / ...
                            (info.range(2) - info.range(1));
                end
            catch exception
                info.valid = false;
                info.message = string(exception.message);
            end
            if ~info.valid && kind ~= "model"
                info.message = "The file could not be loaded. Verify " + ...
                    "that it is a valid " + ternaryText(kind == "csv", ...
                    ".csv EMG export", ".sto or .mot file") + ". (" + ...
                    info.message + ")";
            end
            app.fileInfoCache(key) = info;
        end

        % Checks an optional data file, returning its time range when it
        % loads
        function [check, range] = checkDataFile(app, path)
            range = [];
            check = app.check("none");
            if path == ""
                return
            end
            if ~isfile(path)
                check = app.check("error", "The given file does not exist.");
                return
            end
            info = app.fileInfo(path, "data");
            if ~info.valid
                check = app.check("error", info.message);
                return
            end
            range = info.range;
        end

        function result = check(~, status, message)
            if nargin < 3
                message = "";
            end
            result = struct('status', string(status), 'message', string(message));
        end

        % The single *MuscleAnalysis_Length.sto in the muscle analysis
        % directory, or "" if there is not exactly one
        function file = muscleAnalysisLengthFile(app)
            file = "";
            if app.muscle_analysis_directory == "" || ...
                    ~isfolder(app.muscle_analysis_directory)
                return
            end
            files = dir(fullfile(app.muscle_analysis_directory, ...
                '*MuscleAnalysis_Length.sto'));
            if isscalar(files)
                file = string(fullfile(files.folder, files.name));
            end
        end

        % Whether EMG will be processed on this run, rather than the
        % processed EMG file being read as an input
        function processes = processesEmg(app)
            processes = app.process_emg && app.raw_emg_file ~= "";
        end

        % Whether any file will be split into trials
        function splits = splitsData(app)
            splits = app.splitsFiles() || ...
                (app.processesEmg() && ~isempty(app.trial_time_pairs));
        end

        % Whether a file other than EMG being processed is given to split.
        % Processed EMG only counts once a pair is added, so processing EMG
        % alone gets no default pair.
        function splits = splitsFiles(app)
            splits = any([app.joint_angles_file, app.joint_loads_file, ...
                app.ground_reactions_file, app.muscle_analysis_directory] ~= "") || ...
                (~app.processesEmg() && app.processed_emg_file ~= "");
        end

        function validateAll(app)
            c = struct();
            ranges = struct('name', {}, 'range', {}, 'isEmg', {}, 'field', {});

            % Raw EMG and its filter
            c.rawEmg = app.check("none");
            c.filter = app.check("none");
            emgRange = [];
            if app.processesEmg()
                [~, ~, extension] = fileparts(app.raw_emg_file);
                if ~isfile(app.raw_emg_file)
                    c.rawEmg = app.check("error", "The given file does not exist.");
                elseif ~any(strcmpi(extension, [".sto", ".mot", ".csv"]))
                    c.rawEmg = app.check("error", ...
                        "The raw EMG file must be a .sto, .mot or .csv file.");
                else
                    info = app.fileInfo(app.raw_emg_file, ...
                        ternaryText(strcmpi(extension, ".csv"), "csv", "data"));
                    if ~info.valid
                        c.rawEmg = app.check("error", info.message);
                    else
                        emgRange = info.range;
                        c.filter = app.filterCheck(info.sampleRate);
                    end
                end
            end

            % Processed EMG: written when EMG is processed, read otherwise
            c.processedEmg = app.check("none");
            if app.processesEmg()
                [folder, ~, extension] = fileparts(app.processed_emg_file);
                if app.processed_emg_file == ""
                    c.processedEmg = app.check("required", ...
                        "A processed EMG file name is required to process EMG.");
                elseif ~strcmpi(extension, ".sto")
                    c.processedEmg = app.check("error", ...
                        "The processed EMG file must be a .sto file.");
                elseif ~isfolder(folder)
                    c.processedEmg = app.check("error", ...
                        "The folder for the processed EMG file does not exist.");
                elseif isfile(app.processed_emg_file)
                    c.processedEmg = app.check("warning", ...
                        "The processed EMG file already exists and will be overwritten.");
                end
            else
                [c.processedEmg, emgRange] = app.checkDataFile(app.processed_emg_file);
            end
            if ~isempty(emgRange)
                ranges(end + 1) = struct('name', "EMG", 'range', emgRange, ...
                    'isEmg', true, 'field', ternaryText(app.processesEmg(), ...
                    "rawEmg", "processedEmg"));
            end

            % Joint angles, joint loads and ground reactions
            [c.jointAngles, range] = app.checkDataFile(app.joint_angles_file);
            if ~isempty(range)
                ranges(end + 1) = struct('name', "joint angles", 'range', range, ...
                    'isEmg', false, 'field', "jointAngles");
            end
            [c.jointLoads, range] = app.checkDataFile(app.joint_loads_file);
            if ~isempty(range)
                ranges(end + 1) = struct('name', "joint loads", 'range', range, ...
                    'isEmg', false, 'field', "jointLoads");
            end
            [c.groundReactions, range] = app.checkDataFile(app.ground_reactions_file);
            if ~isempty(range)
                ranges(end + 1) = struct('name', "ground reactions", 'range', range, ...
                    'isEmg', false, 'field', "groundReactions");
            end

            % Muscle analysis directory
            c.muscleAnalysis = app.check("none");
            directory = app.muscle_analysis_directory;
            if directory ~= ""
                lengthFiles = dir(fullfile(directory, '*MuscleAnalysis_Length.sto'));
                momentArms = dir(fullfile(directory, '*_MomentArm_*.sto'));
                if ~isfolder(directory)
                    c.muscleAnalysis = app.check("error", "The given directory does not exist.");
                elseif numel(lengthFiles) ~= 1
                    c.muscleAnalysis = app.check("error", "The directory must " + ...
                        "hold exactly one *MuscleAnalysis_Length.sto file; it has " + ...
                        numel(lengthFiles) + ".");
                elseif isempty(momentArms)
                    c.muscleAnalysis = app.check("error", ...
                        "The directory has no *_MomentArm_*.sto files.");
                else
                    lengthFile = string(fullfile(lengthFiles.folder, lengthFiles.name));
                    [c.muscleAnalysis, range] = app.checkDataFile(lengthFile);
                    velocityFile = strrep(lengthFile, "_Length.sto", "_Velocity.sto");
                    if c.muscleAnalysis.status == "none" && isfile(velocityFile)
                        [~, name, extension] = fileparts(velocityFile);
                        c.muscleAnalysis = app.check("warning", name + extension + ...
                            " already exists in this directory and will be overwritten.");
                    end
                    if ~isempty(range)
                        ranges(end + 1) = struct('name', "muscle analysis", ...
                            'range', range, 'isEmg', false, 'field', "muscleAnalysis");
                    end
                end
            end

            % A model is always required. splitIntoTrials loads it for
            % every split, and by preprocessing a model should exist.
            c.model = app.check("none");
            if app.input_model_file == ""
                c.model = app.check("required", "A model file is required.");
            elseif ~isfile(app.input_model_file)
                c.model = app.check("error", "The given model file does not exist.");
            else
                info = app.fileInfo(app.input_model_file, "model");
                if ~info.valid
                    c.model = app.check("error", info.message);
                end
            end

            % Settings for splitting into trials
            splits = app.splitsData();
            c.trialPrefix = app.check("none");
            c.timePoints = app.check("none");
            c.output = app.check("none");
            if splits
                if app.trial_prefix == ""
                    c.trialPrefix = app.check("required", "A trial prefix is required.");
                elseif isempty(regexp(app.trial_prefix, '^[A-Za-z0-9_]+$', 'once'))
                    c.trialPrefix = app.check("error", "The trial prefix names " + ...
                        "the output files, so it may only use letters, digits and _.");
                end
                points = str2double(app.number_of_time_points);
                if isnan(points) || points < 2 || mod(points, 1) ~= 0
                    c.timePoints = app.check("error", ...
                        "The number of time points must be a whole number of at least 2.");
                end
                if app.output_directory == ""
                    c.output = app.check("required", "An output directory is required.");
                elseif isfolder(app.output_directory)
                    c.output = app.check("warning", "The output directory " + ...
                        "already exists and its data will be overwritten.");
                end
            end
            c = app.rangeWarnings(c, ranges);
            c.defaultPair = app.defaultTimePair(ranges);
            [c.timePairs, c.badPairRows] = app.timePairsCheck(ranges, splits);
            app.checks = c;
        end

        % Warns on each file that covers more time than the given files
        % all share, since only the shared time can be split into trials
        function c = rangeWarnings(app, c, ranges)
            if numel(ranges) < 2
                return
            end
            allRanges = vertcat(ranges.range);
            shared = [max(allRanges(:, 1)) min(allRanges(:, 2))];
            differs = any(abs(allRanges - shared) > 1e-6, 2);
            if ~any(differs)
                return
            end
            % The files that set the shared start or end
            limiting = find(abs(allRanges(:, 1) - shared(1)) <= 1e-6 | ...
                abs(allRanges(:, 2) - shared(2)) <= 1e-6)';
            for i = find(differs)'
                shown = unique([i, limiting], 'stable');
                message = "The files have different time ranges:";
                for j = shown
                    message = message + newline + ranges(j).name + ": " + ...
                        formatRange(ranges(j).range);
                end
                field = ranges(i).field;
                if c.(field).status == "none"
                    c.(field) = app.check("warning", message);
                elseif c.(field).status == "warning"
                    c.(field).message = c.(field).message + newline + message;
                end
            end
        end

        % The default trial time pair: the time the given files all cover,
        % trimmed so the EMG also covers the padding splitIntoTrials adds.
        % There is none when only EMG is being processed.
        function pair = defaultTimePair(app, ranges)
            pair = zeros(0, 2);
            if isempty(ranges) || ~app.splitsFiles()
                return
            end
            allRanges = vertcat(ranges.range);
            shared = [max(allRanges(:, 1)) min(allRanges(:, 2))];
            emg = ranges([ranges.isEmg]);
            points = str2double(app.number_of_time_points);
            if ~isempty(emg) && points >= 2 && mod(points, 1) == 0
                % The padding depends on the pair's length, so trim until
                % it fits. Pairs only shrink, so this settles quickly.
                for iteration = 1 : 20
                    trialLength = shared(2) - shared(1);
                    if trialLength <= 0
                        break
                    end
                    padding = ceil(0.2 / (trialLength / (points - 1))) / ...
                        (points - 1) * trialLength;
                    trimmed = [max(shared(1), emg.range(1) + padding), ...
                        min(shared(2), emg.range(2) - padding)];
                    if isequal(trimmed, shared)
                        break
                    end
                    shared = trimmed;
                end
            end
            if shared(1) < shared(2)
                pair = shared;
            end
        end

        function result = filterCheck(app, sampleRate)
            problems = strings(0, 1);
            if app.filter_order <= 0 || mod(app.filter_order, 1) ~= 0
                problems(end + 1) = "The filter order must be a whole number above 0.";
            end
            nyquist = sampleRate / 2;
            for cutoff = ["High pass", "Low pass"]
                if cutoff == "High pass"
                    value = app.high_pass_cutoff;
                else
                    value = app.low_pass_cutoff;
                end
                if value <= 0
                    problems(end + 1) = cutoff + " cutoff frequency must be above 0."; %#ok<AGROW>
                elseif value >= nyquist
                    problems(end + 1) = cutoff + " cutoff frequency must be " + ...
                        "below half the EMG sample rate (" + ...
                        sprintf('%.4g', nyquist) + " Hz)."; %#ok<AGROW>
                end
            end
            result = app.check("none");
            if ~isempty(problems)
                result = app.check("error", strjoin(problems, newline));
            end
        end

        % Checks each time pair against the time range every given file
        % covers. EMG is padded by splitIntoTrials, so it must also cover
        % each pair's padded range.
        function [result, badRows] = timePairsCheck(app, ranges, splits)
            pairs = app.trial_time_pairs;
            badRows = [];
            problems = strings(0, 1);
            allowed = [-Inf Inf];
            if ~isempty(ranges)
                allRanges = vertcat(ranges.range);
                allowed = [max(allRanges(:, 1)) min(allRanges(:, 2))];
            end
            emg = ranges([ranges.isEmg]);
            padding = zeros(size(pairs, 1), 1);
            points = str2double(app.number_of_time_points);
            lengths = pairs(:, 2) - pairs(:, 1);
            if ~isempty(pairs) && all(lengths > 0) && points >= 2
                % Same formula as splitIntoTrials' calcNumPaddingFrames and
                % addBufferToTimePairs
                bufferRows = ceil(0.2 / (min(lengths) / (points - 1)));
                padding = bufferRows / (points - 1) * lengths;
            end
            tolerance = 1e-9;
            for row = 1 : size(pairs, 1)
                pair = pairs(row, :);
                name = "Pair " + row + ": ";
                if any(isnan(pair))
                    problems(end + 1) = name + "needs both a start and an end time."; %#ok<AGROW>
                elseif pair(1) >= pair(2)
                    problems(end + 1) = name + "the start time must be before the end time."; %#ok<AGROW>
                elseif pair(1) < allowed(1) - tolerance || pair(2) > allowed(2) + tolerance
                    problems(end + 1) = name + "must be within " + ...
                        formatRange(allowed) + ", the time every given file covers."; %#ok<AGROW>
                elseif ~isempty(emg) && (pair(1) - padding(row) < emg.range(1) - tolerance || ...
                        pair(2) + padding(row) > emg.range(2) + tolerance)
                    problems(end + 1) = name + "The time range must start " + ...
                        "or end " + sprintf('%.3g', padding(row)) + " seconds " + ...
                        "from the edge of the EMG time range to allow for " + ...
                        "padding frames."; %#ok<AGROW>
                else
                    continue
                end
                badRows(end + 1) = row; %#ok<AGROW>
            end
            % Processing EMG alone needs no pairs; splitsData counts it as
            % splitting only once a pair has been added
            if isempty(pairs) && splits
                result = app.check("required", "Add at least one trial time pair.");
            elseif ~isempty(problems)
                result = app.check("error", strjoin(problems, newline));
            else
                result = app.check("none");
            end
            if isfinite(allowed(1))
                result.message = strjoin([result.message, "Times must be within " + ...
                    formatRange(allowed) + "."], newline);
                result.message = strip(result.message, newline);
            end
        end

        function drawChecks(app)
            c = app.checks;
            setGuiFieldStatus(app.InputModelFileEditField, app.InputModelFileStatus, ...
                c.model.status, c.model.message);
            setGuiFieldStatus(app.RawEMGFileEditField, app.RawEmgFileStatus, ...
                c.rawEmg.status, c.rawEmg.message);
            setGuiFieldStatus(app.ProcessedEMGFileEditField, app.ProcessedEmgFileStatus, ...
                c.processedEmg.status, c.processedEmg.message);
            setGuiFieldStatus(app.JointAnglesFileEditField, app.JointAnglesStatus, ...
                c.jointAngles.status, c.jointAngles.message);
            setGuiFieldStatus(app.JointLoadsFileEditField, app.JointLoadsFileStatus, ...
                c.jointLoads.status, c.jointLoads.message);
            setGuiFieldStatus(app.GroundReactionsFileEditField, app.GroundReactionsFileStatus, ...
                c.groundReactions.status, c.groundReactions.message);
            setGuiFieldStatus(app.MuscleAnalysisDataDirectoryEditField, ...
                app.MuscleAnalysisDataDirectoryStatus, c.muscleAnalysis.status, ...
                c.muscleAnalysis.message);
            setGuiFieldStatus(app.TrialPrefixEditField, app.TrialPrefixStatus, ...
                c.trialPrefix.status, c.trialPrefix.message);
            setGuiFieldStatus(app.NumberofTimePointsEditField, app.NumTimePointsStatus, ...
                c.timePoints.status, c.timePoints.message);
            setGuiFieldStatus(app.OutputDirectoryEditField, app.OutputDirectoryStatus, ...
                c.output.status, c.output.message);
            % The filter fields have no status icon, so the message goes on
            % each field's tooltip
            filterFields = [app.FilterOrderEditField, ...
                app.HighPassCutoffFrequencyEditField, app.LowPassCutoffFrequencyEditField];
            for field = filterFields
                setGuiFieldStatus(field, [], c.filter.status);
                field.Tooltip = char(c.filter.message);
            end
        end

        function drawTimePairs(app)
            rows = num2cell([app.trial_time_pairs; app.draftPair]);
            rows(cellfun(@(value) isnan(value), rows)) = {[]};
            pairsTable = app.TrialTimePairsTable;
            pairsTable.Data = rows;
            removeStyle(pairsTable);
            if ~isempty(app.checks.badPairRows)
                addStyle(pairsTable, uistyle('BackgroundColor', [1.00 0.67 0.67]), ...
                    'row', app.checks.badPairRows);
            end
            tip = app.checks.timePairs.message;
            if tip == ""
                tip = "Type a start and end time in the blank row to add a " + ...
                    "pair; right-click a pair to delete it. Until the pairs " + ...
                    "are edited, they default to the time every given file covers.";
            end
            pairsTable.Tooltip = char(tip);
            app.TrialTimePairsLabel.FontColor = [0 0 0];
            if app.checks.timePairs.status == "error"
                app.TrialTimePairsLabel.FontColor = [0.8 0 0];
            end
        end

        function updateRunButtons(app)
            c = app.checks;
            names = ["model", "rawEmg", "filter", "processedEmg", "jointAngles", ...
                "jointLoads", "groundReactions", "muscleAnalysis", "trialPrefix", ...
                "timePoints", "output", "timePairs"];
            statuses = arrayfun(@(name) c.(name).status, names);
            anyFile = app.processesEmg() || app.splitsData();
            app.RunDataPreprocessingButton.Enable = anyFile && ...
                ~any(statuses == "error" | statuses == "required");
            app.RunMuscleAnalysisButton.Enable = app.input_model_file ~= "" && ...
                c.model.status == "none" && app.joint_angles_file ~= "" && ...
                c.jointAngles.status == "none";
        end

        function runDataPreprocessing(app)
            progress = uiprogressdlg(app.UIFigure, 'Title', 'Data Preprocessing', ...
                'Indeterminate', 'on');
            done = strings(0, 1);
            try
                if app.processesEmg()
                    progress.Message = 'Processing EMG...';
                    app.processEmg();
                    done(end + 1) = "Processed EMG written to " + app.processed_emg_file;
                end
                lengthFile = app.muscleAnalysisLengthFile();
                if lengthFile ~= ""
                    progress.Message = 'Calculating muscle-tendon velocities...';
                    createMuscleTendonVelocity(lengthFile, app.cutoffFrequency);
                    done(end + 1) = "Muscle-tendon velocities written to " + ...
                        strrep(lengthFile, "_Length.sto", "_Velocity.sto");
                end
                if app.splitsData() && ~isempty(app.trial_time_pairs)
                    progress.Message = 'Splitting data into trials...';
                    app.splitData();
                    done(end + 1) = size(app.trial_time_pairs, 1) + ...
                        " trial(s) written to " + app.output_directory;
                end
            catch exception
                delete(progress);
                uialert(app.UIFigure, exception.message, 'Data Preprocessing Failed');
                app.refreshAll();
                return
            end
            delete(progress);
            uialert(app.UIFigure, strjoin(done, newline), ...
                'Data Preprocessing Complete', 'Icon', 'success');
            app.refreshAll();
        end

        function processEmg(app)
            rawFile = app.raw_emg_file;
            [~, ~, extension] = fileparts(rawFile);
            if strcmpi(extension, ".csv")
                % processRawEmgFile reads through Storage, so a .csv is
                % converted to a temporary .sto first
                converted = string(tempname) + ".sto";
                deleteConverted = onCleanup(@() deleteIfFile(converted));
                convertEmgCsvToSto(rawFile, converted);
                rawFile = converted;
            end
            processRawEmgFile(char(rawFile), app.filter_order, ...
                app.high_pass_cutoff, app.low_pass_cutoff, ...
                char(app.processed_emg_file));
        end

        function splitData(app)
            inputSettings = struct('cutoffFrequency', app.cutoffFrequency, ...
                'rowsPerTrial', str2double(app.number_of_time_points), ...
                'model', app.input_model_file);
            if app.joint_angles_file ~= ""
                inputSettings.ikFileName = app.joint_angles_file;
            end
            if app.joint_loads_file ~= ""
                inputSettings.idFileName = app.joint_loads_file;
            end
            if app.ground_reactions_file ~= ""
                inputSettings.grfFileName = app.ground_reactions_file;
            end
            if app.processed_emg_file ~= ""
                inputSettings.emgFileName = app.processed_emg_file;
            end
            if app.muscle_analysis_directory ~= ""
                inputSettings.maDirectory = app.muscle_analysis_directory;
            end
            outputSettings = struct('resultsDirectory', app.output_directory, ...
                'trialPrefix', app.trial_prefix);
            splitIntoTrials(app.trial_time_pairs, inputSettings, outputSettings);
        end

        function runMuscleAnalysisInto(app, directory)
            progress = uiprogressdlg(app.UIFigure, 'Title', 'Muscle Analysis', ...
                'Message', 'Running OpenSim MuscleAnalysis...', ...
                'Indeterminate', 'on');
            try
                runMuscleAnalysis(app.input_model_file, app.joint_angles_file, directory);
            catch exception
                delete(progress);
                uialert(app.UIFigure, exception.message, 'Muscle Analysis Failed');
                return
            end
            delete(progress);
            app.muscle_analysis_directory = string(directory);
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.UIFigure.Name = 'Data Preprocessing';
            app.fileInfoCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
            app.output_directory = string(fullfile(pwd, 'preprocessed'));
            app.TrialTimePairsTable.ColumnFormat = {'numeric', 'numeric'};
            app.propertyListener = addlistener(app, {'input_model_file', ...
                'raw_emg_file', 'processed_emg_file', 'joint_angles_file', ...
                'joint_loads_file', 'ground_reactions_file', ...
                'muscle_analysis_directory', 'output_directory', 'process_emg', ...
                'filter_order', 'high_pass_cutoff', 'low_pass_cutoff', ...
                'trial_prefix', 'number_of_time_points', 'trial_time_pairs'}, ...
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

        % Value changed function: EMGProcessingCheckBox
        function EMGProcessingCheckBoxValueChanged(app, event)
            app.process_emg = app.EMGProcessingCheckBox.Value;
        end

        % Value changed function: RawEMGFileEditField
        function RawEMGFileEditFieldValueChanged(app, event)
            app.setRawEmgFile(getPathFieldValue(app.RawEMGFileEditField));
        end

        % Button pushed function: RawEmgFileSearchButton
        function RawEmgFileSearchButtonPushed(app, event)
            [file, path] = uigetfile({'*.sto;*.mot;*.csv', ...
                'EMG files (*.sto, *.mot, *.csv)'}, 'Select a Raw EMG File');
            if isequal(file, 0)
                return
            end
            app.setRawEmgFile(string(fullfile(path, file)));
        end

        % Value changed function: FilterOrderEditField
        function FilterOrderEditFieldValueChanged(app, event)
            app.filter_order = app.FilterOrderEditField.Value;
        end

        % Value changed function: HighPassCutoffFrequencyEditField
        function HighPassCutoffFrequencyEditFieldValueChanged(app, event)
            app.high_pass_cutoff = app.HighPassCutoffFrequencyEditField.Value;
        end

        % Value changed function: LowPassCutoffFrequencyEditField
        function LowPassCutoffFrequencyEditFieldValueChanged(app, event)
            app.low_pass_cutoff = app.LowPassCutoffFrequencyEditField.Value;
        end

        % Value changed function: ProcessedEMGFileEditField
        function ProcessedEMGFileEditFieldValueChanged(app, event)
            app.processed_emg_file = getPathFieldValue(app.ProcessedEMGFileEditField);
        end

        % Button pushed function: ProcessedEmgFileSearchButton
        function ProcessedEmgFileSearchButtonPushed(app, event)
            if app.processesEmg()
                % Written by this run, so a new name may be chosen
                [file, path] = uiputfile('*.sto', 'Save the Processed EMG File As');
            else
                [file, path] = uigetfile({'*.sto;*.mot', 'Data files (*.sto, *.mot)'}, ...
                    'Select a Processed EMG File');
            end
            if isequal(file, 0)
                return
            end
            app.processed_emg_file = string(fullfile(path, file));
        end

        % Value changed function: JointAnglesFileEditField
        function JointAnglesFileEditFieldValueChanged(app, event)
            app.joint_angles_file = getPathFieldValue(app.JointAnglesFileEditField);
        end

        % Button pushed function: JointAnglesFileSearchButton
        function JointAnglesFileSearchButtonPushed(app, event)
            app.joint_angles_file = app.chooseDataFile(app.joint_angles_file, ...
                'Select a Joint Angles File');
        end

        % Value changed function: JointLoadsFileEditField
        function JointLoadsFileEditFieldValueChanged(app, event)
            app.joint_loads_file = getPathFieldValue(app.JointLoadsFileEditField);
        end

        % Button pushed function: JointLoadsFileSearchButton
        function JointLoadsFileSearchButtonPushed(app, event)
            app.joint_loads_file = app.chooseDataFile(app.joint_loads_file, ...
                'Select a Joint Loads File');
        end

        % Value changed function: GroundReactionsFileEditField
        function GroundReactionsFileEditFieldValueChanged(app, event)
            app.ground_reactions_file = getPathFieldValue(app.GroundReactionsFileEditField);
        end

        % Button pushed function: GroundReactionsFileSearchButton
        function GroundReactionsFileSearchButtonPushed(app, event)
            app.ground_reactions_file = app.chooseDataFile(app.ground_reactions_file, ...
                'Select a Ground Reactions File');
        end

        % Value changed function: MuscleAnalysisDataDirectoryEditField
        function MuscleAnalysisDataDirectoryEditFieldValueChanged(app, event)
            app.muscle_analysis_directory = ...
                getPathFieldValue(app.MuscleAnalysisDataDirectoryEditField);
        end

        % Button pushed function: MuscleAnalysisDataDirectorySearchButton
        function MuscleAnalysisDataDirectorySearchButtonPushed(app, event)
            folder = uigetdir(pwd, 'Select the Muscle Analysis Data Directory');
            if isequal(folder, 0)
                return
            end
            app.muscle_analysis_directory = string(folder);
        end

        % Button pushed function: RunMuscleAnalysisButton
        function RunMuscleAnalysisButtonPushed(app, event)
            folder = uigetdir(fileparts(app.joint_angles_file), ...
                'Select a Directory for the Muscle Analysis Data');
            if isequal(folder, 0)
                return
            end
            app.runMuscleAnalysisInto(folder);
        end

        % Value changed function: TrialPrefixEditField
        function TrialPrefixEditFieldValueChanged(app, event)
            app.trial_prefix = strtrim(string(app.TrialPrefixEditField.Value));
        end

        % Cell edit callback: TrialTimePairsTable
        function TrialTimePairsTableCellEdit(app, event)
            row = event.Indices(1);
            column = event.Indices(2);
            value = event.NewData;
            if ischar(value) || isstring(value)
                value = str2double(value);
            end
            if isempty(value)
                value = NaN;
            end
            % Edited pairs no longer follow the files' default
            app.autoPairs = false;
            pairs = app.trial_time_pairs;
            if row <= size(pairs, 1)
                pairs(row, column) = value;
                if all(isnan(pairs(row, :)))
                    pairs(row, :) = [];
                end
                app.trial_time_pairs = pairs;
                return
            end
            % The blank row: a pair is added once both times are in
            app.draftPair(column) = value;
            if all(~isnan(app.draftPair))
                pairs(end + 1, :) = app.draftPair;
                app.draftPair = [NaN NaN];
                app.trial_time_pairs = pairs;
            else
                app.refreshAll();
            end
        end

        % Menu selected function: DeletePairMenu
        function DeletePairMenuSelected(app, event)
            % The row that was right-clicked, falling back to the selection
            row = [];
            if ~isempty(event) && isprop(event, 'InteractionInformation') && ...
                    ~isempty(event.InteractionInformation) && ...
                    isprop(event.InteractionInformation, 'Row')
                row = event.InteractionInformation.Row;
            end
            if isempty(row) && ~isempty(app.TrialTimePairsTable.Selection)
                row = app.TrialTimePairsTable.Selection(1, 1);
            end
            if isempty(row)
                return
            end
            if row <= size(app.trial_time_pairs, 1)
                app.autoPairs = false;
                app.trial_time_pairs(row, :) = [];
            else
                app.draftPair = [NaN NaN];
                app.refreshAll();
            end
        end

        % Value changed function: NumberofTimePointsEditField
        function NumberofTimePointsEditFieldValueChanged(app, event)
            app.number_of_time_points = string(app.NumberofTimePointsEditField.Value);
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

        % Button pushed function: RunDataPreprocessingButton
        function RunDataPreprocessingButtonPushed(app, event)
            app.runDataPreprocessing();
        end
    end

    methods (Access = private)

        % Sets the raw EMG file and names the processed file after it
        function setRawEmgFile(app, path)
            if path ~= ""
                [folder, name] = fileparts(path);
                app.processed_emg_file = string(fullfile(folder, name + "_processed.sto"));
            end
            app.raw_emg_file = path;
        end

        function path = chooseDataFile(~, current, title)
            path = current;
            [file, folder] = uigetfile({'*.sto;*.mot', 'Data files (*.sto, *.mot)'}, title);
            if ~isequal(file, 0)
                path = string(fullfile(folder, file));
            end
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
            app.RcnlLogo.ImageClickedFcn = createCallbackFcn(app, @RcnlLogoImageClicked, true);
            app.RcnlLogo.Position = [6 876 80 80];
            app.RcnlLogo.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'rcnlIcon.png');

            % Create InputModelFileSearchButton
            app.InputModelFileSearchButton = uibutton(app.UIFigure, 'push');
            app.InputModelFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @InputModelFileSearchButtonPushed, true);
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
            app.InputModelFileEditField.ValueChangedFcn = createCallbackFcn(app, @InputModelFileEditFieldValueChanged, true);
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
            app.RawEmgFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @RawEmgFileSearchButtonPushed, true);
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
            app.RawEMGFileEditField.ValueChangedFcn = createCallbackFcn(app, @RawEMGFileEditFieldValueChanged, true);
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
            app.FilterOrderEditField.ValueChangedFcn = createCallbackFcn(app, @FilterOrderEditFieldValueChanged, true);
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
            app.HighPassCutoffFrequencyEditField.ValueChangedFcn = createCallbackFcn(app, @HighPassCutoffFrequencyEditFieldValueChanged, true);
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
            app.LowPassCutoffFrequencyEditField.ValueChangedFcn = createCallbackFcn(app, @LowPassCutoffFrequencyEditFieldValueChanged, true);
            app.LowPassCutoffFrequencyEditField.Limits = [0 Inf];
            app.LowPassCutoffFrequencyEditField.FontSize = 18;
            app.LowPassCutoffFrequencyEditField.Position = [270 18 70 24];
            app.LowPassCutoffFrequencyEditField.Value = 3.5;

            % Create EMGProcessingCheckBox
            app.EMGProcessingCheckBox = uicheckbox(app.Panel);
            app.EMGProcessingCheckBox.ValueChangedFcn = createCallbackFcn(app, @EMGProcessingCheckBoxValueChanged, true);
            app.EMGProcessingCheckBox.Text = 'EMG Processing';
            app.EMGProcessingCheckBox.FontSize = 18;
            app.EMGProcessingCheckBox.FontWeight = 'bold';
            app.EMGProcessingCheckBox.Position = [338 142 165 22];
            app.EMGProcessingCheckBox.Value = true;

            % Create JointAnglesFileSearchButton
            app.JointAnglesFileSearchButton = uibutton(app.UIFigure, 'push');
            app.JointAnglesFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @JointAnglesFileSearchButtonPushed, true);
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
            app.JointAnglesFileEditField.ValueChangedFcn = createCallbackFcn(app, @JointAnglesFileEditFieldValueChanged, true);
            app.JointAnglesFileEditField.Position = [235 564 450 30];

            % Create JointAnglesStatus
            app.JointAnglesStatus = uiimage(app.UIFigure);
            app.JointAnglesStatus.Visible = 'off';
            app.JointAnglesStatus.Position = [728 564 28 30];
            app.JointAnglesStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create JointLoadsFileSearchButton
            app.JointLoadsFileSearchButton = uibutton(app.UIFigure, 'push');
            app.JointLoadsFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @JointLoadsFileSearchButtonPushed, true);
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
            app.JointLoadsFileEditField.ValueChangedFcn = createCallbackFcn(app, @JointLoadsFileEditFieldValueChanged, true);
            app.JointLoadsFileEditField.Position = [235 515 450 30];

            % Create JointLoadsFileStatus
            app.JointLoadsFileStatus = uiimage(app.UIFigure);
            app.JointLoadsFileStatus.Visible = 'off';
            app.JointLoadsFileStatus.Position = [728 515 28 30];
            app.JointLoadsFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create GroundReactionsFileSearchButton
            app.GroundReactionsFileSearchButton = uibutton(app.UIFigure, 'push');
            app.GroundReactionsFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @GroundReactionsFileSearchButtonPushed, true);
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
            app.GroundReactionsFileEditField.ValueChangedFcn = createCallbackFcn(app, @GroundReactionsFileEditFieldValueChanged, true);
            app.GroundReactionsFileEditField.Position = [235 466 450 30];

            % Create GroundReactionsFileStatus
            app.GroundReactionsFileStatus = uiimage(app.UIFigure);
            app.GroundReactionsFileStatus.Visible = 'off';
            app.GroundReactionsFileStatus.Position = [728 466 28 30];
            app.GroundReactionsFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create MuscleAnalysisDataDirectorySearchButton
            app.MuscleAnalysisDataDirectorySearchButton = uibutton(app.UIFigure, 'push');
            app.MuscleAnalysisDataDirectorySearchButton.ButtonPushedFcn = createCallbackFcn(app, @MuscleAnalysisDataDirectorySearchButtonPushed, true);
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
            app.MuscleAnalysisDataDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @MuscleAnalysisDataDirectoryEditFieldValueChanged, true);
            app.MuscleAnalysisDataDirectoryEditField.Position = [235 366 450 30];

            % Create MuscleAnalysisDataDirectoryStatus
            app.MuscleAnalysisDataDirectoryStatus = uiimage(app.UIFigure);
            app.MuscleAnalysisDataDirectoryStatus.Visible = 'off';
            app.MuscleAnalysisDataDirectoryStatus.Position = [728 366 28 30];
            app.MuscleAnalysisDataDirectoryStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create RunMuscleAnalysisButton
            app.RunMuscleAnalysisButton = uibutton(app.UIFigure, 'push');
            app.RunMuscleAnalysisButton.ButtonPushedFcn = createCallbackFcn(app, @RunMuscleAnalysisButtonPushed, true);
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
            app.TrialPrefixEditField.ValueChangedFcn = createCallbackFcn(app, @TrialPrefixEditFieldValueChanged, true);
            app.TrialPrefixEditField.Position = [235 319 450 30];
            app.TrialPrefixEditField.Value = 'gait';

            % Create TrialPrefixStatus
            app.TrialPrefixStatus = uiimage(app.UIFigure);
            app.TrialPrefixStatus.Visible = 'off';
            app.TrialPrefixStatus.Position = [686 319 28 30];
            app.TrialPrefixStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create TrialTimePairsTable
            app.TrialTimePairsTable = uitable(app.UIFigure);
            app.TrialTimePairsTable.CellEditCallback = createCallbackFcn(app, @TrialTimePairsTableCellEdit, true);
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
            app.NumberofTimePointsEditField.ValueChangedFcn = createCallbackFcn(app, @NumberofTimePointsEditFieldValueChanged, true);
            app.NumberofTimePointsEditField.CharacterLimits = [1 Inf];
            app.NumberofTimePointsEditField.InputType = 'digits';
            app.NumberofTimePointsEditField.Position = [237 130 450 30];
            app.NumberofTimePointsEditField.Value = '101';

            % Create RunDataPreprocessingButton
            app.RunDataPreprocessingButton = uibutton(app.UIFigure, 'push');
            app.RunDataPreprocessingButton.ButtonPushedFcn = createCallbackFcn(app, @RunDataPreprocessingButtonPushed, true);
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
            app.OutputDirectoryEditField.ValueChangedFcn = createCallbackFcn(app, @OutputDirectoryEditFieldValueChanged, true);
            app.OutputDirectoryEditField.Position = [238 81 450 30];
            app.OutputDirectoryEditField.Value = 'preprocessed';

            % Create OutputDirectoryStatus
            app.OutputDirectoryStatus = uiimage(app.UIFigure);
            app.OutputDirectoryStatus.Visible = 'off';
            app.OutputDirectoryStatus.Position = [730 81 28 30];
            app.OutputDirectoryStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create OutputDirectorySearchButton
            app.OutputDirectorySearchButton = uibutton(app.UIFigure, 'push');
            app.OutputDirectorySearchButton.ButtonPushedFcn = createCallbackFcn(app, @OutputDirectorySearchButtonPushed, true);
            app.OutputDirectorySearchButton.Icon = fullfile(pathToMLAPP, '..', 'Images', 'folderIcon.svg');
            app.OutputDirectorySearchButton.VerticalAlignment = 'bottom';
            app.OutputDirectorySearchButton.BackgroundColor = [0.1294 0.1804 0.4];
            app.OutputDirectorySearchButton.Position = [696 81 31 30];
            app.OutputDirectorySearchButton.Text = '';

            % Create ProcessedEmgFileSearchButton
            app.ProcessedEmgFileSearchButton = uibutton(app.UIFigure, 'push');
            app.ProcessedEmgFileSearchButton.ButtonPushedFcn = createCallbackFcn(app, @ProcessedEmgFileSearchButtonPushed, true);
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
            app.ProcessedEMGFileEditField.ValueChangedFcn = createCallbackFcn(app, @ProcessedEMGFileEditFieldValueChanged, true);
            app.ProcessedEMGFileEditField.Position = [235 613 450 30];

            % Create ProcessedEmgFileStatus
            app.ProcessedEmgFileStatus = uiimage(app.UIFigure);
            app.ProcessedEmgFileStatus.Visible = 'off';
            app.ProcessedEmgFileStatus.Position = [728 613 28 30];
            app.ProcessedEmgFileStatus.ImageSource = fullfile(pathToMLAPP, '..', 'Images', 'error.png');

            % Create TimePairsContextMenu
            app.TimePairsContextMenu = uicontextmenu(app.UIFigure);

            % Create DeletePairMenu
            app.DeletePairMenu = uimenu(app.TimePairsContextMenu);
            app.DeletePairMenu.MenuSelectedFcn = createCallbackFcn(app, @DeletePairMenuSelected, true);
            app.DeletePairMenu.Text = 'Delete pair';

            % Assign app.TimePairsContextMenu
            app.TrialTimePairsTable.ContextMenu = app.TimePairsContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';

            % Center the window on whichever screen it lands on, as MTP
            % and GCP do
            movegui(app.UIFigure, 'center');
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

function text = ternaryText(condition, whenTrue, whenFalse)
if condition
    text = whenTrue;
else
    text = whenFalse;
end
end

% A time range as text, such as "0.29 to 1.41 s"
function text = formatRange(range)
text = sprintf('%.4g to %.4g s', range(1), range(2));
end

function deleteIfFile(path)
if isfile(path)
    delete(path);
end
end
