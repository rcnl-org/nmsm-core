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
% Author(s): Claire V. Hammond                                            %
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
    results, stage)

if ~any([1 2 3] == stage)
    error("Stage value is not valid");
end
if stage == 1
    inputs = mergeStageOneResults(inputs, results);
end
if stage == 2
    inputs = mergeStageTwoResults(inputs, results);
end
if stage == 3
    inputs = mergeStageThreeResults(inputs, results);
end

end

function inputs = mergeStageOneResults(inputs, results)
index = 1;
inputs.springConstants = results(index : index + length(inputs.springConstants) - 1);
index = index + length(inputs.springConstants);
inputs.dampingFactors = results(index : index + length(inputs.dampingFactors) - 1);
index = index + length(inputs.dampingFactors);

bSplineCoefficientLength = length(reshape(inputs.bSplineCoefficientsVerticalSubset, 1, []));
bSplineCoefficientsVerticalSubset = results(index : index + bSplineCoefficientLength - 1);
bSplineCoefficientsVerticalSubset = reshape(bSplineCoefficientsVerticalSubset, [], 5);

inputs.bSplineCoefficients(:, [1, 3, 5:7]) = bSplineCoefficientsVerticalSubset;
index = index + bSplineCoefficientLength;

inputs.restingSpringLength = results(index);
end

function inputs = mergeStageTwoResults(inputs, results)

end

function inputs = mergeStageThreeResults(inputs, results)

end