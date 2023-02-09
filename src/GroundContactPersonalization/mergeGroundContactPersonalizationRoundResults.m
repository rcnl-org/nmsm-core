% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, Array of double, int in [1, 2, 3]) -> (struct)
% merge the results of the optimization back into the input values

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function inputs = mergeGroundContactPersonalizationRoundResults(inputs, ...
    results, params, task)

if nargin < 4
    task = 1;
end
if task == 0
    inputs = mergeStageZeroResults(inputs, results);
else
    inputs = mergeTaskResults(inputs, results, params, task);
end

end

function inputs = mergeStageZeroResults(inputs, results)
index = 1;
inputs.springConstants = results(index : index + length(inputs.springConstants) - 1);
index = index + length(inputs.springConstants);

inputs.restingSpringLength = results(index);
end

function inputs = mergeTaskResults(inputs, results, params, task)
index = 1;
if (params.tasks{task}.designVariables(1))
    inputs.springConstants = 1000 * results(index : index + length(inputs.springConstants) - 1);
    index = index + length(inputs.springConstants);
end
if (params.tasks{task}.designVariables(2))
    inputs.dampingFactor = results(index);
    index = index + 1;
end
if (params.tasks{task}.designVariables(3))
    bSplineCoefficientLength = length(reshape(inputs.bSplineCoefficients, 1, []));
    bSplineCoefficients = results(index : index + bSplineCoefficientLength - 1);
    bSplineCoefficients = reshape(bSplineCoefficients, [], 7);
    inputs.bSplineCoefficients = bSplineCoefficients;
    index = index + bSplineCoefficientLength;
end
if (params.tasks{task}.designVariables(4))
    inputs.dynamicFrictionCoefficient = results(index);
    index = index + 1;
end
if (params.tasks{task}.designVariables(5))
    inputs.restingSpringLength = results(index);
end
end
