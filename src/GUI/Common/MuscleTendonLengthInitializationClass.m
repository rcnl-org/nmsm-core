% This class is part of the NMSM Pipeline, see file for full license.
%
% This class holds the settings for Muscle-Tendon Length Initialization,
% shared by the MTP and NCP GUIs. Settings are stored as individual
% properties (rather than an array) because struct2xml requires each XML
% element to be a struct field; parameterNames maps table row indices to
% those properties. Use reset() to restore defaults in place so that
% listeners attached to an instance stay valid.

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
classdef MuscleTendonLengthInitializationClass < handle

    properties (Access = public, SetObservable)
        is_enabled
        passive_data_input_directory
        max_normalized_muscle_fiber_length
        min_normalized_muscle_fiber_length
        optimize_maximum_muscle_stress
        optimize_isometric_max_force
        optimize_absolute_length_changes
        maximum_muscle_stress
        RCNLCostTerm
    end

    properties (Constant)
        parameterNames = ...
            ["optimize_maximum_muscle_stress"
            "optimize_isometric_max_force"
            "optimize_absolute_length_changes"
            "maximum_muscle_stress"]

        costTermStruct = struct( ...
            'passive_joint_moment',                             {{'true'   0     2     false}}, ...
            'optimal_muscle_fiber_length',                      {{'true'   1     0.3   true}}, ...
            'tendon_slack_length',                              {{'true'   1     0.3   true}}, ...
            'minimum_normalized_muscle_fiber_length',           {{'true'   0     0.3   false}}, ...
            'maximum_normalized_muscle_fiber_length',           {{'true'   0     0.03  false}}, ...
            'maximum_muscle_stress',                            {{'true'   1.2   0.1   true}}, ...
            'passive_muscle_force',                             {{'false'  0     10    false}}, ...
            'grouped_normalized_muscle_fiber_length',           {{'true'   0     0.1   false}}, ...
            'grouped_maximum_normalized_muscle_fiber_length',   {{'true'   0     0.1   false}} ...
            );
    end

    methods
        function obj = MuscleTendonLengthInitializationClass()
            obj.reset();
        end

        function reset(obj)
            obj.is_enabled = 'false';
            obj.passive_data_input_directory = "";
            obj.max_normalized_muscle_fiber_length = 1.0;
            obj.min_normalized_muscle_fiber_length = 0.7;
            obj.optimize_maximum_muscle_stress = 'true';
            obj.optimize_isometric_max_force = 'true';
            obj.optimize_absolute_length_changes = 'true';
            obj.maximum_muscle_stress = 610000;
            obj.RCNLCostTerm = makeDefaultCostTerms(obj.costTermStruct);
        end

        function s = toStruct(obj)
            s = struct();
            s.is_enabled = obj.is_enabled;
            s.passive_data_input_directory = obj.passive_data_input_directory;
            s.max_normalized_muscle_fiber_length = ...
                obj.max_normalized_muscle_fiber_length;
            s.min_normalized_muscle_fiber_length = ...
                obj.min_normalized_muscle_fiber_length;
            for i = 1:length(obj.parameterNames)
                s.(obj.parameterNames(i)) = obj.(obj.parameterNames(i));
            end
            s.RCNLCostTermSet = makeCostTermSetStruct(obj.RCNLCostTerm);
        end

        function loadFromStruct(obj, s)
            applyStructToHandle(obj, s);
            costTerms = parseCostTermsFromStruct(s);
            if ~isempty(costTerms)
                obj.RCNLCostTerm = costTerms;
            end
        end

        function setParameterValueByIndex(obj, index, value)
            obj.(obj.parameterNames(index)) = value;
        end

        function value = getParameterValueByIndex(obj, index)
            value = obj.(obj.parameterNames(index));
        end

        function [invalidIndices, messages] = validateParameters(obj)
            invalidIndices = [];
            messages = strings(0, 1);
            for i = 1:3
                if ~ismember(string(obj.(obj.parameterNames(i))), ...
                        ["true", "false"])
                    invalidIndices(end + 1) = i;
                    messages(end + 1) = obj.parameterNames(i) + ...
                        ": must be true or false";
                end
            end
            stressValue = str2double(string(obj.maximum_muscle_stress));
            if isnan(stressValue) || stressValue <= 0
                invalidIndices(end + 1) = 4;
                messages(end + 1) = ...
                    "maximum_muscle_stress: must be a positive number";
            end
        end
    end
end
