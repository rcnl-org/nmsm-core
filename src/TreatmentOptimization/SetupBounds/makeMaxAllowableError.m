% This function is part of the NMSM Pipeline, see file for full license.
%
% This function gathers the maximum and minimum bounds for all continuous
% cost term function values.
%
% (struct) -> (struct)
% Computes max and min integral bounds

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function [continuousMaxAllowableError, discreteMaxAllowableError] = ...
    makeMaxAllowableError(toolName, controllerTypes, costTerms)
[~, continuousAllowedTypes] = generateCostTermStruct("continuous", controllerTypes, toolName);
[~, discreteAllowedTypes] = generateCostTermStruct("discrete", controllerTypes, toolName);

continuousMaxAllowableError = [];
discreteMaxAllowableError = [];
for i = 1:length(costTerms)
    costTerm = costTerms{i};
    if costTerm.isEnabled
        if any(ismember(costTerm.type, continuousAllowedTypes)) && ...
                ~strcmp(costTerm.type, "user_defined")
            continuousMaxAllowableError = cat(2, ...
                continuousMaxAllowableError, costTerm.maxAllowableError);
        elseif strcmp(costTerm.type, "user_defined")
            if strcmp(costTerm.cost_term_type, "continuous")
                continuousMaxAllowableError = cat(2, ...
                    continuousMaxAllowableError, ...
                    costTerm.maxAllowableError);
            elseif strcmp(costTerm.cost_term_type, "discrete")
                discreteMaxAllowableError = cat(2, ...
                    discreteMaxAllowableError, ...
                    costTerm.maxAllowableError);
            else
                throw(MException('', "User-defined cost terms must " + ...
                    "be specified as either discrete or continuous " + ...
                    "in the cost_term_type field."))
            end
        elseif any(ismember(costTerm.type, discreteAllowedTypes))
            discreteMaxAllowableError = cat(2, ...
                discreteMaxAllowableError, costTerm.maxAllowableError);
        elseif ~any(ismember(costTerm.type, continuousAllowedTypes)) || ...
                    ~any(ismember(costTerm.type, discreteAllowedTypes))
            throw(MException('', ['Cost term type ' costTerm.type ...
                ' does not exist for this tool.']))
        end
    end
end
end
