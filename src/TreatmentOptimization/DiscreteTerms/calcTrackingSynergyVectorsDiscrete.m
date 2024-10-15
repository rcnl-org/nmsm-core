% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the original and current
% synergy weights. 
%
% (2D matix, struct, struct) -> (Array of number)
% 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Spencer Williams                               %
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

function cost = calcTrackingSynergyVectorsDiscrete(synergyWeights, ...
    inputs, costTerm)

counter = 1;
for i = 1 : length(inputs.synergyGroups)
    if strcmp(inputs.synergyGroups{i}.muscleGroupName, ...
            costTerm.synergy_group)
        break;
    end
    counter = counter + inputs.synergyGroups{i}.numSynergies;
end

numSynergies = inputs.synergyGroups{i}.numSynergies;
errorCenter = valueOrAlternate(costTerm, "errorCenter", 0);

weightErrors = synergyWeights(counter : counter + numSynergies - 1, :) ...
    - inputs.initialSynergyWeights( ...
    counter : counter + numSynergies - 1, :) - errorCenter;

cost = mean((weightErrors / costTerm.maxAllowableError) .^ 2, 'all');
end
