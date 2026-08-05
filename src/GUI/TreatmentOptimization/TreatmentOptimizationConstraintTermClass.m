% This class is part of the NMSM Pipeline, see file for full license.
%
% This class holds a single Treatment Optimization constraint term. Like
% the cost terms, these are built by the user rather than chosen from a
% fixed set, so each one carries its own type, the list of components it
% applies to, and whatever extra parameters that type accepts.
% componentElement is the name of the XML element the component list is
% written to, which varies by constraint term type and comes from
% generateConstraintTermStruct.
%
% Constraint terms are bounded above and below rather than by a single
% allowable error. parseTreatmentOptimizationInputs also accepts
% <max_value> and <min_value> as aliases for <max_error> and <min_error>,
% so both spellings are read here and the max_error spelling is written.
%
% The component list and the miscellaneous parameters are left as string
% arrays here; formatGuiDataForXml joins them when the settings file is
% written and formatXmlDataForGui splits them when it is read.

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
classdef TreatmentOptimizationConstraintTermClass < handle

    properties (Access = public, SetObservable)
        name = "";
        index = 0;
        is_enabled = 'true';
        type = "";
        componentElement = "";
        componentList = string([]);
        max_error = 1;
        min_error = -1;
        miscParams = struct();
    end

    properties (Constant, Access = private)
        % Elements handled explicitly; everything else is a misc parameter
        knownElements = ["Attributes" "is_enabled" "type" "max_error" ...
            "min_error" "max_value" "min_value"]
    end

    methods (Access = public)
        function obj = TreatmentOptimizationConstraintTermClass()
        end

        function s = toStruct(obj)
            s = struct();
            if ~isEmptyStringList(obj.name)
                s.Attributes.name = obj.name;
            end
            s.is_enabled = obj.is_enabled;
            s.type = obj.type;
            if ~isEmptyStringList(obj.componentElement) && ...
                    ~isEmptyStringList(obj.componentList)
                s.(obj.componentElement) = obj.componentList;
            end
            s.max_error = obj.max_error;
            s.min_error = obj.min_error;
            params = fieldnames(obj.miscParams);
            for i = 1 : numel(params)
                if ~isEmptyStringList(obj.miscParams.(params{i}))
                    s.(params{i}) = obj.miscParams.(params{i});
                end
            end
        end

        function loadFromStruct(obj, s, componentElement)
            if nargin < 3
                componentElement = "";
            end
            obj.componentElement = componentElement;
            if isfield(s, 'Attributes') && isfield(s.Attributes, 'name')
                obj.name = string(s.Attributes.name);
            end
            if isfield(s, 'is_enabled')
                obj.is_enabled = s.is_enabled;
            end
            if isfield(s, 'type')
                obj.type = string(s.type);
            end
            % convertValueToError treats the value spelling as the bound.
            % An element written empty, as the XML reference does, must
            % leave the default in place rather than store its blank.
            obj.max_error = firstNumberOrDefault(s, ...
                ["max_error" "max_value"], obj.max_error);
            obj.min_error = firstNumberOrDefault(s, ...
                ["min_error" "min_value"], obj.min_error);
            obj.componentList = string([]);
            if ~isEmptyStringList(componentElement) && ...
                    isfield(s, componentElement)
                obj.componentList = toStringList(s.(componentElement));
            end
            % The settings file may carry any extra element the backend
            % supports, so keep everything that is not handled above
            obj.miscParams = struct();
            handled = [obj.knownElements, string(componentElement)];
            fields = fieldnames(s);
            for i = 1 : numel(fields)
                if ~any(strcmp(fields{i}, handled))
                    obj.miscParams.(fields{i}) = s.(fields{i});
                end
            end
        end
    end
end

function values = toStringList(value)
if ischar(value)
    values = string(strsplit(value, " "));
elseif isstring(value)
    values = value(:)';
else
    values = string(value);
end
values = values(~strcmp(values, ""));
end

function number = firstNumberOrDefault(s, names, default)
number = default;
for i = 1 : numel(names)
    if ~isfield(s, names(i))
        continue
    end
    candidate = toGuiNumber(s.(names(i)));
    if ~isnan(candidate)
        number = candidate;
        return
    end
end
end
