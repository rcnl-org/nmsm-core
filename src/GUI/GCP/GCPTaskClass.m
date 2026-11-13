% This class is part of the NMSM Pipeline, see file for full license.
%
% This class holds the settings for a single Ground Contact
% Personalization task: which design variables that round optimizes, the
% neighbor spring standard deviation, and the task's cost terms. Design
% variables are stored as individual properties (rather than an array)
% because struct2xml requires each XML element to be a struct field;
% parameterNames maps table row indices to those properties.
%
% parameterNames is also the order the backend reads them in:
% getTaskDesignVariables fills designVariables(1:10) positionally and
% GroundContactPersonalizationTool indexes 7:9 and 10 by number, so the
% order here is load bearing and must not be rearranged.
%
% Unlike the rest of the settings file these element names are camelCase,
% matching the parser.

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
classdef GCPTaskClass < handle

    properties
        name = "";
        index = 0;
        is_enabled = 'true';
        springConstants = 'false';
        dampingFactor = 'false';
        dynamicFrictionCoefficient = 'false';
        viscousFrictionCoefficient = 'false';
        restingSpringLength = 'false';
        kinematicsBSplineCoefficients = 'false';
        electricalCenterX = 'false';
        electricalCenterY = 'false';
        electricalCenterZ = 'false';
        forcePlateRotation = 'false';
        neighborStandardDeviation = 0.2;
        RCNLCostTerm = cell(1);
    end

    properties (Constant)
        parameterNames = ...
            ["springConstants"
            "dampingFactor"
            "dynamicFrictionCoefficient"
            "viscousFrictionCoefficient"
            "restingSpringLength"
            "kinematicsBSplineCoefficients"
            "electricalCenterX"
            "electricalCenterY"
            "electricalCenterZ"
            "forcePlateRotation"]

        parameterLabels = ...
            ["Spring Constants"
            "Damping Factor"
            "Dynamic Friction Coefficient"
            "Viscous Friction Coefficient"
            "Resting Spring Length"
            "Kinematics B-Spline Coefficients"
            "Electrical Center X"
            "Electrical Center Y"
            "Electrical Center Z"
            "Force Plate Rotation"]

        % {is_enabled, error_center, max_allowable_error,
        % uses_error_center}. Every term starts disabled with the
        % backend's own default allowable error of 1, because which terms
        % belong in a round depends entirely on which design variables
        % that round optimizes; there is no set that is right by default.
        % uses_error_center is false throughout: GCP parses error_center
        % through the shared RCNLCostTermSet reader but never reads it.
        costTermStruct = struct( ...
            'marker_position',                     {{'false' 0 1 false}}, ...
            'marker_slope',                        {{'false' 0 1 false}}, ...
            'rotation',                            {{'false' 0 1 false}}, ...
            'translation',                         {{'false' 0 1 false}}, ...
            'kinematic_periodicity',               {{'false' 0 1 false}}, ...
            'vertical_grf',                        {{'false' 0 1 false}}, ...
            'vertical_grf_slope',                  {{'false' 0 1 false}}, ...
            'horizontal_grf',                      {{'false' 0 1 false}}, ...
            'horizontal_grf_slope',                {{'false' 0 1 false}}, ...
            'ground_reaction_moment',              {{'false' 0 1 false}}, ...
            'ground_reaction_moment_slope',        {{'false' 0 1 false}}, ...
            'spring_constant_mean',                {{'false' 0 1 false}}, ...
            'neighbor_spring_constant',            {{'false' 0 1 false}}, ...
            'electrical_center_regularization',    {{'false' 0 1 false}}, ...
            'force_plate_rotation_regularization', {{'false' 0 1 false}} ...
            );
    end

    methods
        function obj = GCPTaskClass()
            obj.RCNLCostTerm = makeDefaultCostTerms(obj.costTermStruct);
        end

        function s = toStruct(obj)
            s = struct();
            s.Attributes.name = obj.name;
            s.is_enabled = obj.is_enabled;
            % orderByIndex throws without this element as soon as there
            % is more than one task.
            s.index = obj.index;
            for i = 1 : length(obj.parameterNames)
                s.(obj.parameterNames(i)) = obj.(obj.parameterNames(i));
            end
            s.neighborStandardDeviation = obj.neighborStandardDeviation;
            s.RCNLCostTermSet = makeCostTermSetStruct(obj.RCNLCostTerm);
            % An empty <max_allowable_error> parses to NaN, which is
            % never rejected and turns the whole cost into NaN. Dropping
            % the element leaves the backend's own default of 1.
            terms = s.RCNLCostTermSet.RCNLCostTerm;
            for i = 1 : numel(terms)
                if ~isfield(terms{i}, 'max_allowable_error')
                    continue
                end
                allowableError = terms{i}.max_allowable_error;
                if isempty(allowableError) || any(isnan(allowableError))
                    terms{i} = rmfield(terms{i}, 'max_allowable_error');
                end
            end
            s.RCNLCostTermSet.RCNLCostTerm = terms;
        end

        function loadFromStruct(obj, s)
            if isfield(s, 'Attributes') && isfield(s.Attributes, 'name')
                obj.name = string(s.Attributes.name);
            end
            % Every field is pulled out by hand rather than through
            % applyStructToHandle. A GCPTask carries a name attribute,
            % so formatXmlDataForGui returns early and leaves each child
            % as the struct xml2struct produced - and
            % applyStructToHandle skips struct values, so it would read
            % nothing at all here.
            obj.is_enabled = obj.toBooleanText(obj.rawField(s, ...
                'is_enabled'));
            taskIndex = obj.toNumberOrNaN(obj.rawField(s, 'index'));
            if ~isnan(taskIndex)
                obj.index = taskIndex;
            end
            % An absent design variable is false, matching the parser's
            % own default of 0.
            for i = 1 : length(obj.parameterNames)
                obj.(obj.parameterNames(i)) = obj.toBooleanText( ...
                    obj.rawField(s, obj.parameterNames(i)));
            end
            deviation = obj.toNumberOrNaN(obj.rawField(s, ...
                'neighborStandardDeviation'));
            if isnan(deviation)
                deviation = 0.2;
            end
            obj.neighborStandardDeviation = deviation;
            obj.RCNLCostTerm = obj.loadCostTerms(s);
        end

        % Not parseCostTermsFromStruct: that hands the raw struct to
        % RCNLCostTermClass, which reads s.max_allowable_error without
        % checking, so a term that omits the element - as this class
        % writes when the error is blank, and as any hand-written file
        % may - throws on load.
        %
        % Loaded values are merged onto the full default set by type
        % rather than replacing it, so a file listing three terms still
        % leaves the other twelve available to switch on. Types the
        % file carries that this tool does not know are appended, so
        % nothing in the file is silently dropped.
        function costTerms = loadCostTerms(obj, s)
            costTerms = makeDefaultCostTerms(obj.costTermStruct);
            loaded = obj.readCostTermStructs(s);
            for i = 1 : numel(loaded)
                type = obj.toName(loaded{i}, 'type');
                if strcmp(type, "")
                    continue
                end
                termIndex = obj.findCostTermByType(costTerms, type);
                if isempty(termIndex)
                    costTerms{end + 1} = RCNLCostTermClass(); %#ok<AGROW>
                    termIndex = numel(costTerms);
                    costTerms{termIndex}.type = type;
                end
                costTerms{termIndex}.is_enabled = obj.toBooleanText( ...
                    obj.rawField(loaded{i}, 'is_enabled'));
                allowable = obj.toNumberOrNaN(obj.rawField(loaded{i}, ...
                    'max_allowable_error'));
                if isnan(allowable)
                    % Absent, or written as an empty element: keep the
                    % backend's own default rather than storing a NaN.
                    allowable = 1;
                end
                costTerms{termIndex}.max_allowable_error = allowable;
                % GCP parses error_center through the shared cost term
                % reader but never uses it, so the field stays off
                % whether or not the file carried one.
                costTerms{termIndex}.error_center = 0;
                costTerms{termIndex}.uses_error_center = false;
            end
        end

        function setParameterValueByIndex(obj, index, value)
            obj.(obj.parameterNames(index)) = value;
        end

        function value = getParameterValueByIndex(obj, index)
            value = obj.(obj.parameterNames(index));
        end

        function anyEnabled = anyParameterEnabled(obj)
            anyEnabled = false;
            for i = 1 : length(obj.parameterNames)
                if strcmp(obj.(obj.parameterNames(i)), 'true')
                    anyEnabled = true;
                    return
                end
            end
        end
    end

    methods (Access = private, Static)

        % getBooleanLogicFromField is a case-sensitive strcmp against
        % 'true', so anything that is not exactly that text has to become
        % 'false' here rather than reaching the settings file as-is.
        function value = toBooleanText(raw)
            text = GCPTaskClass.toTextSafely(raw);
            if strcmpi(text, "true")
                value = 'true';
            else
                value = 'false';
            end
        end

        % A GCPTask carries a name attribute, so formatXmlDataForGui
        % returns early on it and every child - including the whole cost
        % term set - is still whatever xml2struct produced. These three
        % absorb the shapes that follows from: a struct with a Text
        % field, a struct without one, raw char, or a missing field.
        function raw = rawField(s, field)
            raw = [];
            if isstruct(s) && isfield(s, field)
                raw = s.(field);
            end
        end

        function text = toTextSafely(raw)
            if isstruct(raw)
                if ~isfield(raw, 'Text')
                    text = "";
                    return
                end
                raw = raw.Text;
            end
            if isempty(raw)
                text = "";
                return
            end
            text = toGuiText(raw);
        end

        function number = toNumberOrNaN(raw)
            text = GCPTaskClass.toTextSafely(raw);
            if strcmp(text, "")
                number = NaN;
                return
            end
            number = str2double(text);
        end

        function name = toName(s, field)
            name = GCPTaskClass.toTextSafely( ...
                GCPTaskClass.rawField(s, field));
        end

        function terms = readCostTermStructs(s)
            terms = {};
            if ~isstruct(s) || ~isfield(s, 'RCNLCostTermSet')
                return
            end
            set = s.RCNLCostTermSet;
            if ~isstruct(set) || ~isfield(set, 'RCNLCostTerm')
                return
            end
            raw = set.RCNLCostTerm;
            if isstruct(raw)
                terms = num2cell(raw);
            elseif iscell(raw)
                terms = raw;
            end
        end

        function index = findCostTermByType(costTerms, type)
            index = [];
            for i = 1 : numel(costTerms)
                if isempty(costTerms{i})
                    continue
                end
                if strcmp(string(costTerms{i}.type), type)
                    index = i;
                    return
                end
            end
        end
    end
end
