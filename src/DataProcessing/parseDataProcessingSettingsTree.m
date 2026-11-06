% This function is part of the NMSM Pipeline, see file for full license.
%
% Parses the <DataProcessingTool> settings into inputs (files and what to
% extract), params (processing settings for each data type), and the
% results directory. Every element except <c3d_file> is optional. An
% element that is omitted or left empty takes its default value.
%
% (struct) -> (struct, struct, string)
% Parses Data Processing settings

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

function [inputs, params, resultsDirectory] = ...
    parseDataProcessingSettingsTree(settingsTree)
tree = settingsTree.NMSMPipelineDocument.DataProcessingTool;
inputs.c3dFile = parseText(tree, "c3d_file", "");
if inputs.c3dFile == ""
    throw(MException("parseDataProcessingSettingsTree:missingC3dFile", ...
        "<c3d_file> is required."))
end
[~, c3dName] = fileparts(inputs.c3dFile);
inputs.trialName = parseText(tree, "trial_name", string(c3dName));
resultsDirectory = parseText(tree, "results_directory", ...
    "DataProcessingResults");

params.saveIntermediateFiles = parseBoolean(tree, ...
    "save_intermediate_files", true);
params.labToOpenSimAxes = parseAxes(tree);
params.gaitCycle = parseGaitCycle(getChild(tree, "GaitCycle"));
params.markers = parseMarkerProcessing(getChild(tree, ...
    "MarkerProcessing"));
params.groundReactions = parseGroundReactionProcessing(getChild(tree, ...
    "GroundReactionProcessing"));
params.emg = parseEmgProcessing(getChild(tree, "EmgProcessing"));
params.requiresGaitCycleTime = isempty(params.gaitCycle.gaitCycleTime) ...
    && usesGaitCycleMultiple(params);

if ~params.markers.isEnabled && ~params.groundReactions.isEnabled && ...
        ~params.emg.isEnabled
    throw(MException("parseDataProcessingSettingsTree:nothingEnabled", ...
        "At least one of <MarkerProcessing>, " + ...
        "<GroundReactionProcessing>, or <EmgProcessing> must be enabled."))
end
inputs.extract.extractMarkers = params.markers.isEnabled;
inputs.extract.extractGroundReactions = ...
    params.groundReactions.isEnabled || params.requiresGaitCycleTime;
inputs.extract.extractEmg = params.emg.isEnabled;
inputs.extract.emgChannelNames = params.emg.channelNames;
end

function gaitCycle = parseGaitCycle(tree)
gaitCycle.gaitCycleTime = parseNumber(tree, "gait_cycle_time", [], ...
    "positive", "GaitCycle");
gaitCycle.forcePlateLayout = parseChoice(tree, "force_plate_layout", ...
    "treadmill", ["treadmill", "overground"], "GaitCycle");
gaitCycle.heelStrikeForceThreshold = parseNumber(tree, ...
    "heel_strike_force_threshold", 20, "nonnegative", "GaitCycle");
end

function markers = parseMarkerProcessing(tree)
block = "MarkerProcessing";
markers.isEnabled = parseBoolean(tree, "is_enabled", true);
markers.gapFill = parseGapFill(getChild(tree, "GapFill"), block);
markers.lowPassFilter = parseFilter(getChild(tree, "LowPassFilter"), ...
    block + "/LowPassFilter", 4, [], 7);
end

function groundReactions = parseGroundReactionProcessing(tree)
block = "GroundReactionProcessing";
groundReactions.isEnabled = parseBoolean(tree, "is_enabled", true);
groundReactions.gapFill = parseGapFill(getChild(tree, "GapFill"), block);
groundReactions.removeOffset = parseBoolean(tree, "remove_offset", false);
groundReactions.forceThreshold = parseNumber(tree, "force_threshold", ...
    [], "nonnegative", block);
groundReactions.lowPassFilter = parseFilter(getChild(tree, ...
    "LowPassFilter"), block + "/LowPassFilter", 1, [], 14);
end

function emg = parseEmgProcessing(tree)
block = "EmgProcessing";
emg.isEnabled = parseBoolean(tree, "is_enabled", true);
channelNames = parseText(tree, "emg_channel_names", "");
if channelNames == ""
    emg.channelNames = string([]);
else
    emg.channelNames = split(channelNames)';
end
emg.highPassFilter = parseFilter(getChild(tree, "HighPassFilter"), ...
    block + "/HighPassFilter", 4, 40, []);
emg.lowPassFilter = parseFilter(getChild(tree, "LowPassFilter"), ...
    block + "/LowPassFilter", 4, [], 3.5);
emg.normalize = parseBoolean(tree, "normalize", true);
end

function gapFill = parseGapFill(tree, block)
block = block + "/GapFill";
gapFill.interpolationMethod = parseChoice(tree, ...
    "interpolation_method", "pchip", ["linear", "pchip", "spline", ...
    "makima", "nearest", "previous", "next"], block);
gapFill.maxGapFrames = parseNumber(tree, "max_gap_frames", 10, ...
    "nonnegativeInteger", block);
end

% A filter cutoff is either a frequency in Hz or a multiple of the gait
% cycle frequency (cutoff = multiple / gait cycle time), never both. If
% neither is given the default is used.
function filter = parseFilter(tree, block, defaultOrder, ...
    defaultFrequency, defaultMultiple)
filter.order = parseNumber(tree, "filter_order", defaultOrder, ...
    "positiveInteger", block);
frequency = parseNumber(tree, "cutoff_frequency", [], "positive", block);
multiple = parseNumber(tree, "cutoff_gait_cycle_multiple", [], ...
    "positive", block);
if ~isempty(frequency) && ~isempty(multiple)
    throw(MException("parseDataProcessingSettingsTree:twoCutoffs", ...
        "<%s> has both <cutoff_frequency> and " + ...
        "<cutoff_gait_cycle_multiple>. Give only one.", block))
end
if isempty(frequency) && isempty(multiple)
    frequency = defaultFrequency;
    multiple = defaultMultiple;
end
filter.cutoffFrequency = frequency;
filter.cutoffGaitCycleMultiple = multiple;
end

function uses = usesGaitCycleMultiple(params)
filters = {};
if params.markers.isEnabled
    filters{end + 1} = params.markers.lowPassFilter;
end
if params.groundReactions.isEnabled
    filters{end + 1} = params.groundReactions.lowPassFilter;
end
if params.emg.isEnabled
    filters{end + 1} = params.emg.highPassFilter;
    filters{end + 1} = params.emg.lowPassFilter;
end
uses = any(cellfun(@(filter) ~isempty(filter.cutoffGaitCycleMultiple), ...
    filters));
end

% Each entry gives the lab axis (1 = x, 2 = y, 3 = z) that becomes the
% OpenSim x, y, or z axis, negated if the lab axis points the other way.
% The result must be a rotation, so the data are not mirrored.
function axes = parseAxes(tree)
text = parseText(tree, "lab_to_opensim_axes", "1 2 3");
axes = str2double(split(text))';
if numel(axes) ~= 3 || any(isnan(axes)) || ...
        ~isequal(sort(abs(axes)), [1 2 3])
    throw(MException("parseDataProcessingSettingsTree:invalidAxes", ...
        "<lab_to_opensim_axes> must be three signed lab axis numbers " + ...
        "using each of 1, 2, and 3 once (e.g. -3 2 1). Got '%s'.", text))
end
rotation = zeros(3);
for i = 1:3
    rotation(abs(axes(i)), i) = sign(axes(i));
end
if det(rotation) < 0
    throw(MException("parseDataProcessingSettingsTree:mirroredAxes", ...
        "<lab_to_opensim_axes> '%s' mirrors the data (left-handed " + ...
        "axes). Negate one axis to make it a rotation.", text))
end
end

function child = getChild(tree, name)
if isstruct(tree) && isfield(tree, name)
    child = tree.(name);
    if iscell(child)
        throw(MException( ...
            "parseDataProcessingSettingsTree:repeatedElement", ...
            "<%s> appears more than once.", name))
    end
else
    child = struct();
end
end

function text = parseText(tree, name, default)
text = default;
element = getChild(tree, name);
if isfield(element, "Text")
    value = strtrim(string(element.Text));
    if value ~= ""
        text = value;
    end
end
end

function value = parseBoolean(tree, name, default)
text = lower(parseText(tree, name, ""));
if text == ""
    value = default;
elseif text == "true" || text == "false"
    value = text == "true";
else
    throw(MException("parseDataProcessingSettingsTree:invalidBoolean", ...
        "<%s> must be true or false. Got '%s'.", name, text))
end
end

function value = parseChoice(tree, name, default, choices, block)
value = lower(parseText(tree, name, default));
if ~ismember(value, choices)
    throw(MException("parseDataProcessingSettingsTree:invalidChoice", ...
        "<%s> in <%s> must be one of: %s. Got '%s'.", name, block, ...
        strjoin(choices, ", "), value))
end
end

function value = parseNumber(tree, name, default, rule, block)
text = parseText(tree, name, "");
if text == ""
    value = default;
    return
end
value = str2double(text);
switch rule
    case "positive"
        valid = value > 0;
    case "nonnegative"
        valid = value >= 0;
    case "positiveInteger"
        valid = value > 0 && value == round(value);
    case "nonnegativeInteger"
        valid = value >= 0 && value == round(value);
end
if isnan(value) || ~valid
    throw(MException("parseDataProcessingSettingsTree:invalidNumber", ...
        "<%s> in <%s> must be a %s number. Got '%s'.", name, block, ...
        regexprep(rule, "([A-Z])", " ${lower($1)}"), text))
end
end
