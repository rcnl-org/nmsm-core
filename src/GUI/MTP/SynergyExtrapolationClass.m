% This class is part of the NMSM Pipeline, see file for full license.
%
% This class holds the settings for Synergy Extrapolation in the MTP
% GUI. Settings are stored as individual properties (rather than an
% array) because struct2xml requires each XML element to be a struct
% field; parameterNames maps table row indices to those properties. Use
% reset() to restore defaults in place so that listeners attached to an
% instance stay valid.

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
classdef SynergyExtrapolationClass < handle

    properties (Access = public, SetObservable)
        is_enabled
        matrix_factorization_method
        number_of_synergies
        synergy_extrapolation_categorization
        residual_categorization
        RCNLCostTerm
    end

    properties (Constant)
        parameterNames = ...
            ["matrix_factorization_method"
            "synergy_extrapolation_categorization"
            "residual_categorization"]

        costTermStruct = struct( ...
            'measured_inverse_dynamics_joint_moment',   {{'true'   0  2    false}}, ...
            'extrapolated_muscle_activation',           {{'true'   0  0.5  true}}, ...
            'residual_muscle_activation',               {{'true'   0  0.01 false}} ...
            );
    end

    methods
        function obj = SynergyExtrapolationClass()
            obj.reset();
        end

        function reset(obj)
            obj.is_enabled = 'true';
            obj.matrix_factorization_method = 'PCA';
            obj.number_of_synergies = 1;
            obj.synergy_extrapolation_categorization = 'trial';
            obj.residual_categorization = 'task';
            obj.RCNLCostTerm = makeDefaultCostTerms(obj.costTermStruct);
        end

        function s = toStruct(obj)
            s = struct();
            s.is_enabled = obj.is_enabled;
            s.matrix_factorization_method = obj.matrix_factorization_method;
            s.number_of_synergies = obj.number_of_synergies;
            s.synergy_extrapolation_categorization = ...
                obj.synergy_extrapolation_categorization;
            s.residual_categorization = obj.residual_categorization;
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
            if ~ismember(string(obj.matrix_factorization_method), ...
                    ["NMF", "PCA"])
                invalidIndices(end + 1) = 1;
                messages(end + 1) = ...
                    "matrix_factorization_method: must be NMF or PCA";
            end
            validCategories = ["trial", "task", "subject"];
            if ~ismember(string(obj.synergy_extrapolation_categorization), ...
                    validCategories)
                invalidIndices(end + 1) = 2;
                messages(end + 1) = "synergy_extrapolation_" + ...
                    "categorization: must be trial, task, or subject";
            end
            if ~ismember(string(obj.residual_categorization), ...
                    validCategories)
                invalidIndices(end + 1) = 3;
                messages(end + 1) = ...
                    "residual_categorization: must be trial, task, or subject";
            end
        end
    end
end
