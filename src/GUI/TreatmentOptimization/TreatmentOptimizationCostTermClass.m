% This class is part of the NMSM Pipeline, see file for full license.
%
% This class holds a single Treatment Optimization cost term. Unlike the
% cost terms of the other tools, these are built by the user rather than
% chosen from a fixed set, so each one carries its own type, the list of
% components it applies to, and whatever extra parameters that type
% accepts. componentElement is the name of the XML element the component
% list is written to, which varies by cost term type and comes from
% generateCostTermStruct.
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
classdef TreatmentOptimizationCostTermClass < handle

    properties (Access = public, SetObservable)
        name = "";
        index = 0;
        is_enabled = 'true';
        type = "";
        componentElement = "";
        componentList = string([]);
        max_allowable_error = 1;
        error_center = 0;
        uses_error_center = false;
        miscParams = struct();
    end

    properties (Constant, Access = public)
        % Elements handled explicitly; everything else is a misc parameter.
        % Public so the GUI can refuse a user defined term a parameter name
        % that would collide with one of them.
        knownElements = ["Attributes" "is_enabled" "type" ...
            "max_allowable_error" "error_center"]
    end

    methods (Access = public)
        function obj = TreatmentOptimizationCostTermClass()
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
            s.max_allowable_error = obj.max_allowable_error;
            if obj.uses_error_center
                s.error_center = obj.error_center;
            end
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
            % An element written empty, as the XML reference does, must
            % leave the default in place rather than store its blank
            if isfield(s, 'max_allowable_error')
                number = toGuiNumber(s.max_allowable_error);
                if ~isnan(number)
                    obj.max_allowable_error = number;
                end
            end
            if isfield(s, 'error_center')
                number = toGuiNumber(s.error_center);
                if ~isnan(number)
                    obj.error_center = number;
                end
                obj.uses_error_center = true;
            end
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
