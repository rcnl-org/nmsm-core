% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
%

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

function inputs = getIntegralBounds(inputs)
[~, allowedTypes] = generateCostTermStruct("continuous", inputs.toolName);
inputs.maxIntegral = [];
inputs.minIntegral = [];
for i = 1:length(inputs.costTerms)
    costTerm = inputs.costTerms{i};
    if costTerm.isEnabled
        if any(ismember(costTerm.type, allowedTypes)) && ...
                ~strcmp(costTerm.type, "user_defined")
            inputs.maxIntegral = cat(2, inputs.maxIntegral, ...
                costTerm.maxAllowableError);
        elseif strcmp(costTerm.type, "user_defined")
            if strcmp(costTerm.cost_term_type, "continuous")
                inputs.maxIntegral = cat(2, inputs.maxIntegral, ...
                    costTerm.maxAllowableError);
            end
        else
            throw(MException('', ['Cost term type ' costTerm.type ...
                ' does not exist for this tool.']))
        end
    end
end
inputs.minIntegral = zeros(1, length(inputs.maxIntegral));
end