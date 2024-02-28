% This function is part of the NMSM Pipeline, see file for full license.
%
% A cost is calculcated to discourage differences between the emgScaling
% factors for grouped muscles
%
% (array of number, array of string) -> (array of number)
% calculates the cost of differences in EMG groups

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function deviationsEMGScale = calcDifferencesInEmgGroups( ...
    emgScale, activationGroups)

lowestIndex = min(cell2mat(activationGroups)) - 1;
Ind = 1;
for i = 1:length(activationGroups)
    deviationsEMGScale(:, Ind:Ind + size(activationGroups{i}, 2) - 1) = ...
        calcMeanDifference2D(emgScale(activationGroups{i} - lowestIndex));
    Ind = Ind + size(activationGroups{i}, 2);
end
end