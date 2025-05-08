% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the cost function values for all treatment
% optimization modules (tracking, verification and design optimization).
%
% (struct, string, struct, struct, struct) -> (2D matrix)
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

function [cost, auxdata] = calcTreatmentOptimizationCost( ...
    costTermCalculations, allowedTypes, values, modeledValues, auxdata)
cost = [];
for i = 1:length(auxdata.costTerms)
    costTerm = auxdata.costTerms{i};
    if costTerm.isEnabled
        if isfield(costTermCalculations, costTerm.type) && ...
                any(ismember(allowedTypes, costTerm.type))
            fn = costTermCalculations.(costTerm.type);
            try
                [newCost, auxdata.costTerms{i}] = ...
                    fn(values, modeledValues, auxdata, costTerm);
            catch
                newCost = fn(values, modeledValues, auxdata, costTerm);
            end
            cost = cat(2, cost, newCost);
%          else
%              throw(MException('', ['Cost term type ' costTerm.type ...
%                  ' does not exist for this tool.']))
        end
    end
end
end