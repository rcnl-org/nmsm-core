% This class is part of the NMSM Pipeline, see file for full license.
%
% This class holds the settings for a single Ground Contact
% Personalization contact surface: which foot it is, the time range and
% belt speed of the trial, the ground reaction columns it reads, and the
% model body and markers that define the foot. Property names are the XML
% element names, so toStruct can write them straight out.
%
% Unlike GCPTaskClass there is no index property: GCPContactSurfaceSet is
% not ordered by the parser, which simply skips the surfaces whose
% is_enabled is not 'true'.

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
classdef GCPContactSurfaceClass < handle

    properties
        name = "";
        is_enabled = 'true';
        is_left_foot = 'false';
        start_time = 0;
        end_time = 1;
        belt_speed = 0;
        % Ordered X, Y, Z. Held as three-element string arrays because
        % formatGuiDataForXml joins a string array with spaces, which is
        % exactly the shape the parser splits back apart.
        force_columns = ["" "" ""];
        moment_columns = ["" "" ""];
        electrical_center_columns = ["" "" ""];
        hindfoot_body = "";
        toe_marker = "";
        medial_marker = "";
        lateral_marker = "";
        heel_marker = "";
        midfoot_superior_marker = "";
    end

    properties (Transient)
        % True while start_time and end_time are still whatever the app
        % supplied, so loading a ground reaction force file may replace
        % them with that file's range. Typing a time, or loading a
        % settings file that carries one, turns this off and the value is
        % then left alone. Deliberately absent from elementNames: it is
        % GUI bookkeeping and is never written to the settings file.
        timeRangeIsDefault = true;
    end

    properties (Constant)
        % Every element the parser reads with getFieldByNameOrError, so
        % all of them must be written even when blank.
        elementNames = ...
            ["is_enabled"
            "is_left_foot"
            "start_time"
            "end_time"
            "belt_speed"
            "force_columns"
            "moment_columns"
            "electrical_center_columns"
            "hindfoot_body"
            "toe_marker"
            "medial_marker"
            "lateral_marker"
            "heel_marker"
            "midfoot_superior_marker"]

        columnNames = ...
            ["force_columns"
            "moment_columns"
            "electrical_center_columns"]
    end

    methods
        function s = toStruct(obj)
            s = struct();
            s.Attributes.name = obj.name;
            for i = 1 : length(obj.elementNames)
                s.(obj.elementNames(i)) = obj.(obj.elementNames(i));
            end
        end

        function loadFromStruct(obj, s)
            if isfield(s, 'Attributes') && isfield(s.Attributes, 'name')
                obj.name = string(s.Attributes.name);
            end
            % formatXmlDataForGui returns early on a struct carrying an
            % Attributes field, so every sibling here is still raw char
            % and has to be coerced by hand.
            obj.is_enabled = obj.toBooleanText(s, 'is_enabled', ...
                obj.is_enabled);
            obj.is_left_foot = obj.toBooleanText(s, 'is_left_foot', ...
                obj.is_left_foot);
            obj.start_time = obj.toNumber(s, 'start_time', obj.start_time);
            obj.end_time = obj.toNumber(s, 'end_time', obj.end_time);
            % Times that came from a file are the user's, so a ground
            % reaction force file must not overwrite them.
            obj.timeRangeIsDefault = ~(isfield(s, 'start_time') || ...
                isfield(s, 'end_time'));
            obj.belt_speed = obj.toNumber(s, 'belt_speed', obj.belt_speed);
            for i = 1 : length(obj.columnNames)
                obj.(obj.columnNames(i)) = obj.toColumnTriple(s, ...
                    obj.columnNames(i));
            end
            obj.hindfoot_body = obj.toName(s, 'hindfoot_body');
            obj.toe_marker = obj.toName(s, 'toe_marker');
            obj.medial_marker = obj.toName(s, 'medial_marker');
            obj.lateral_marker = obj.toName(s, 'lateral_marker');
            obj.heel_marker = obj.toName(s, 'heel_marker');
            obj.midfoot_superior_marker = obj.toName(s, ...
                'midfoot_superior_marker');
        end
    end

    methods (Access = private, Static)

        % A GCPContactSurface carries a name attribute, so
        % formatXmlDataForGui returns early on it and every child is
        % still whatever xml2struct produced. These absorb the shapes
        % that follows from: a struct with a Text field, a struct
        % without one, raw char, or a missing field.
        function text = toTextSafely(s, field)
            text = "";
            if ~isstruct(s) || ~isfield(s, field)
                return
            end
            raw = s.(field);
            if isstruct(raw)
                if ~isfield(raw, 'Text')
                    return
                end
                raw = raw.Text;
            end
            if isempty(raw)
                return
            end
            text = toGuiText(raw);
        end

        % An element written empty carries no value, so the default is
        % kept rather than storing a blank.
        function value = toNumber(s, field, default)
            value = default;
            text = GCPContactSurfaceClass.toTextSafely(s, field);
            if strcmp(text, "")
                return
            end
            parsed = str2double(text);
            if ~isnan(parsed)
                value = parsed;
            end
        end

        function value = toBooleanText(s, field, default)
            value = default;
            text = GCPContactSurfaceClass.toTextSafely(s, field);
            if strcmpi(text, "true") || strcmpi(text, "false")
                value = char(lower(text));
            end
        end

        function value = toName(s, field)
            value = GCPContactSurfaceClass.toTextSafely(s, field);
        end

        function value = toColumnTriple(s, field)
            value = ["" "" ""];
            text = GCPContactSurfaceClass.toTextSafely(s, field);
            if strcmp(text, "")
                return
            end
            % char, not string: toGuiStringList splits char on spaces
            % but returns a string scalar untouched, which would store
            % all three names in the first slot and write the element
            % back with trailing spaces. The backend splits that into
            % empty entries and cell2mat then fails.
            names = toGuiStringList(char(text));
            for i = 1 : min(3, numel(names))
                value(i) = names(i);
            end
        end
    end
end
