% This class is part of the NMSM Pipeline, see file for full license.
%
% This class holds the GUI-side settings for the RCNLSynergyController used
% by Treatment Optimization. parameterNames maps advanced-settings table
% row indices to individual properties. Use reset() to restore defaults in
% place so that listeners attached to an instance stay valid.

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
classdef RCNLSynergyControllerClass < handle

    properties (Access = public, SetObservable)
        is_enabled
        optimize_synergy_vectors
        synergy_vector_normalization_method
        maximum_allowable_synergy_activation
        synergy_vector_normalization_value
        synergy_control_derivatives_range_scale_factor
        synergy_control_derivatives_minimum_range
    end

    properties (Constant)
        parameterNames = ...
            ["maximum_allowable_synergy_activation"
            "synergy_vector_normalization_value"
            "synergy_control_derivatives_range_scale_factor"
            "synergy_control_derivatives_minimum_range"]

        defaultParameterValues = ...
            [5
            1
            1
            0]
    end

    methods
        function obj = RCNLSynergyControllerClass()
            obj.reset();
        end

        function reset(obj)
            obj.is_enabled = 'false';
            obj.optimize_synergy_vectors = 'false';
            obj.synergy_vector_normalization_method = 'Magnitude';
            for i = 1 : length(obj.parameterNames)
                obj.(obj.parameterNames(i)) = obj.defaultParameterValues(i);
            end
        end

        function setParameterValueByIndex(obj, index, value)
            obj.(obj.parameterNames(index)) = value;
        end

        function value = getParameterValueByIndex(obj, index)
            value = obj.(obj.parameterNames(index));
        end
    end
end
