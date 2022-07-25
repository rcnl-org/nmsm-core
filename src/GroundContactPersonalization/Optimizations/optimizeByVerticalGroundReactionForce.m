% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, struct) -> (struct)
% Optimize ground contact parameters according to Jackson et al. (2016)

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

function inputs = optimizeByVerticalGroundReactionForce(inputs, params)
[initialValues, fieldNameOrder] = makeInitialValues(inputs, params);
results = lsqnonlin(@(values) calcVerticalGroundReactionCost(values, ...
    fieldNameOrder, inputs, params), initialValues);
inputs = mergeResults(inputs, results);
end

% (struct, struct) -> (Array of double)
% generate initial values to be optimized from inputs, params
function [initialValues, fieldNameOrder] = makeInitialValues(inputs, ...
    params)
initialValues = [inputs.springConstants inputs.dampingFactors];
initialValues = [initialValues reshape(inputs.rightKinematicCurveCoefficients([2, 5:7], :)', 1, [])]; % B spline coeff right
initialValues = [initialValues reshape(inputs.leftKinematicCurveCoefficients([2, 5:7], :)', 1, [])]; % B spline coeff left
initialValues = [initialValues inputs.rightFootVerticalPosition]; % YvalR 
initialValues = [initialValues inputs.leftFootVerticalPosition]; % YvalL
fieldNameOrder = ["springConstants", "dampingFactors", "kinematicCurve", "footVerticalPosition"];
end

% (struct, Array of double) -> (struct)
% merge the results of the optimization back into the input values
function inputs = mergeResults(inputs, results)
index = 1;
inputs.springConstants = results(index, index + length(inputs.springConstants));
index = index + length(inputs.springConstants);
inputs.dampingFactors = results(index, index + length(inputs.dampingFactors));
index = index + length(inputs.dampingFactors);

end
