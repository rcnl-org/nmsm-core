% This class is part of the NMSM Pipeline, see file for full license.
%
% This class holds the GUI-side settings for the RCNLMuscleModel (surrogate
% muscle model) used by Treatment Optimization's Synergy/Muscle controllers.
% parameterNames maps advanced-settings table row indices to individual
% properties. Use reset() to restore defaults in place so that listeners
% attached to an instance stay valid.

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
classdef RCNLMuscleModelClass < handle

    properties (Access = public, SetObservable)
        coordinate_list
        data_directory
        file_name
        muscle_activations_file
        surrogate_model_coordinate_value_threshold
        surrogate_model_polynomial_degree
        maximum_shortening_velocity_multiplier
        activation_saturation_sharpness
        initial_activation_value
    end

    properties (Constant)
        parameterNames = ...
            ["surrogate_model_coordinate_value_threshold"
            "surrogate_model_polynomial_degree"
            "maximum_shortening_velocity_multiplier"
            "activation_saturation_sharpness"
            "initial_activation_value"]

        defaultParameterValues = ...
            [1e-4
            5
            10
            600
            0.1]
    end

    methods
        function obj = RCNLMuscleModelClass()
            obj.reset();
        end

        function reset(obj)
            obj.coordinate_list = string([]);
            obj.data_directory = "";
            obj.file_name = "";
            obj.muscle_activations_file = "";
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
