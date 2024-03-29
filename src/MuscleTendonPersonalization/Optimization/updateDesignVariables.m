% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes the primary values (values maintained between
% optimization rounds) and updates them based on the secondary values from
% an individual round of optimization. The params included dictate which
% primary values are updated.
%
% (2D Array of number, Array of number, Array of boolean) -> (struct)
% Updates the primary values from the optimized round secondary values

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Marleny Vega                              %
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

function newPrimaryValues = updateDesignVariables(primaryValues, ...
    secondaryValues, isIncluded)
% newPrimaryValues = zeros(size(primaryValues));
for i=1:length(isIncluded)
    if(isIncluded(i))
        [startIndex, endIndex] = findIsIncludedStartAndEndIndex( ...
            primaryValues, isIncluded, i);
        newPrimaryValues{i} = secondaryValues(startIndex:endIndex);
    else
        if i ~= 7
            newPrimaryValues{i} = primaryValues{i};
        end
    end
end
end