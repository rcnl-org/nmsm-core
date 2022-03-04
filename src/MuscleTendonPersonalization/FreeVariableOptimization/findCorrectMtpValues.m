% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns a 1D array containing the current values from the
% given index from either the primaryValues or secondaryValues depending on
% the isIncluded values. The purpose is that all primaryValues are used in
% the cost function computation, but only the secondaryValues are
% optimized. For cost function calculations that use secondaryValues, we
% want to return the values from the secondaryValues, otherwise we want to
% return the static primaryValues for those values.
%
% (number, 2D array of number, 1D array of number, array of boolean) -> ...
% (Array of number)
% returns the optimized values from Muscle Tendon optimization round

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

function output = findCorrectMtpValues(index, primaryValues, ...
    secondaryValues, isIncluded)
if(isIncluded(index))
    [startIndex, endIndex] = findIsIncludedStartAndEndIndex( ...
        primaryValues, isIncluded, index);
    output = secondaryValues(startIndex:endIndex);
else
    output = primaryValues(index, :);
end
end

