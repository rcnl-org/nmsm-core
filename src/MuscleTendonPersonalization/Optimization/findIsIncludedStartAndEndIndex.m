% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (2D Array of number, Array of boolean, integer) -> (integer)
% finds the start index in secondary values depending on isIncluded array

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

function [startIndex, endIndex] = findIsIncludedStartAndEndIndex( ...
    primaryValues, isIncluded, index)
startIndex = 1;
for i=1:index-1
    if(isIncluded(i))
        length(primaryValues(i, :));
        startIndex = startIndex + length(primaryValues(i, :));
    end 
end
endIndex = startIndex + length(primaryValues(index, :)) - 1;
end