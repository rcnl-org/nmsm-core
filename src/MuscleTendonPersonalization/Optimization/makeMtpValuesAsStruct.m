% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (Array of number, Array of number, Array of number) -> (struct)
% changes optimization values into a struct for use in cost function

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

function values = makeMtpValuesAsStruct(secondaryValues, primaryValues, isIncluded)
valuesHelper.secondaryValues = secondaryValues;
valuesHelper.primaryValues = primaryValues;
valuesHelper.isIncluded = isIncluded;
values.electromechanicalDelays = findCorrectMtpValues(1, valuesHelper);
values.activationTimeConstants = findCorrectMtpValues(2, valuesHelper);
values.activationNonlinearityConstants = findCorrectMtpValues(3, valuesHelper);
values.emgScaleFactors = findCorrectMtpValues(4, valuesHelper);
values.optimalFiberLengthScaleFactors = findCorrectMtpValues(5, valuesHelper);
values.tendonSlackLengthScaleFactors = findCorrectMtpValues(6, valuesHelper);
end

function output = findCorrectMtpValues(index, valuesStruct)
if (valuesStruct.isIncluded(index))
    [startIndex, endIndex] = findIsIncludedStartAndEndIndex( ...
        valuesStruct.primaryValues, valuesStruct.isIncluded, index);
    output = valuesStruct.secondaryValues(startIndex:endIndex);
else
    output = valuesStruct.primaryValues(index, :);
end
end