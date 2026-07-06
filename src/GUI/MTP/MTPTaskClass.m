% This class is part of the NMSM Pipeline, see file for full license.
%
% This class holds the settings for a single Muscle-Tendon
% Personalization task: which design variables are optimized and the
% task's cost terms. Design variables are stored as individual
% properties (rather than an array) because struct2xml requires each XML
% element to be a struct field; parameterNames maps table row indices to
% those properties.

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
classdef MTPTaskClass < handle

    properties
        name = "";
        index = 0;
        is_enabled = 'true';
        muscle_specific_electromechanical_delays = 'true';
        optimize_electromechanical_delays = 'true';
        optimize_activation_time_constants = 'true';
        optimize_activation_nonlinearity_constants = 'true';
        optimize_emg_scale_factors = 'true';
        optimize_optimal_fiber_lengths = 'true';
        optimize_tendon_slack_lengths = 'true';
        RCNLCostTerm = cell(1);
    end

    properties (Constant)
        parameterNames = ...
            ["muscle_specific_electromechanical_delays"
            "optimize_electromechanical_delays"
            "optimize_activation_time_constants"
            "optimize_activation_nonlinearity_constants"
            "optimize_emg_scale_factors"
            "optimize_optimal_fiber_lengths"
            "optimize_tendon_slack_lengths"]

        costTermStruct = struct( ...
            'inverse_dynamics_joint_moment',            {{'true'   0     2.5   false}}, ...
            'activation_time_constant',                 {{'true'   0.02  0.015 true}}, ...
            'activation_nonlinearity_constant',         {{'true'   0     0.1   true}}, ...
            'optimal_muscle_fiber_length',              {{'true'   0     0.1   false}}, ...
            'tendon_slack_length',                      {{'true'   0     0.1   false}}, ...
            'electromechanical_delay',                  {{'true'   0     0.1   true}}, ...
            'electromechanical_delay_deviation',        {{'false'  0.1   0.05  true}}, ...
            'emg_scale_factor',                         {{'true'   0.3   0.2   true}}, ...
            'normalized_muscle_fiber_length',           {{'true'   0     0.01  false}}, ...
            'passive_muscle_force',                     {{'false'  0     50    false}}, ...
            'grouped_normalized_muscle_fiber_length',   {{'true'   0     0.05  false}}, ...
            'grouped_emg_scale_factor',                 {{'true'   0     0.1   false}}, ...
            'grouped_electromechanical_delay',          {{'true'   0     0.2   false}}, ...
            'muscle_excitation_penalty',                {{'true'   0.5   0.25  true}} ...
            );
    end

    methods
        function obj = MTPTaskClass()
            obj.RCNLCostTerm = makeDefaultCostTerms(obj.costTermStruct);
        end

        function s = toStruct(obj)
            s = struct();
            s.Attributes.name = obj.name;
            s.index = obj.index;
            s.is_enabled = obj.is_enabled;
            for i = 1:length(obj.parameterNames)
                s.(obj.parameterNames(i)) = obj.(obj.parameterNames(i));
            end
            s.RCNLCostTermSet = makeCostTermSetStruct(obj.RCNLCostTerm);
        end

        function loadFromStruct(obj, s)
            if isfield(s, 'Attributes') && isfield(s.Attributes, 'name')
                obj.name = s.Attributes.name;
            end
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

        function anyEnabled = anyParameterEnabled(obj)
            anyEnabled = false;
            for i = 1:length(obj.parameterNames)
                if strcmp(obj.(obj.parameterNames(i)), 'true')
                    anyEnabled = true;
                    return
                end
            end
        end
    end
end
