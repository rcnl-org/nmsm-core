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

function [cost, costTerm] = calcTrackingSynergyVectorsDiscrete( ...
    synergyWeights, inputs, costTerm)
if isfield(costTerm, 'vectorNumber')
    vectorNumber = costTerm.vectorNumber;
    numWeights = costTerm.numWeights;
else
    synergyName = getTermFieldOrError(costTerm, "synergy");
    delimiterIndex = find(synergyName == '_', 1, 'last');
    assert(~isempty(delimiterIndex), "Synergy names must be given " + ...
        "as GroupName_Index (ex: RightLeg_2). Found " + synergyName + ...
        " instead.")
    synergyGroupName = synergyName(1 : delimiterIndex - 1);
    synergyIndex = str2double(synergyName(delimiterIndex + 1 : end));

    counter = 0;
    synergyGroups = inputs.synergyGroups;
    for i = 1 : length(synergyGroups)
        if strcmp(synergyGroups{i}.muscleGroupName, synergyGroupName)
            break;
        end
        if i == length(synergyGroups)
            error(synergyGroupName + " is not an included synergy group.")
        end
        counter = counter + synergyGroups{i}.numSynergies;
    end
    synergyGroupNumber = i;
    vectorNumber = counter + synergyIndex;
    assert(vectorNumber <= size(synergyWeights, 1), ...
        "Synergy number " + synergyIndex + " is not valid.")
    numWeights = length(inputs.synergyGroups{synergyGroupNumber} ...
        .muscleNames);

    costTerm.vectorNumber = vectorNumber;
    costTerm.numWeights = numWeights;
end

indices = inputs.initialSynergyWeights(vectorNumber, :) ~= 0 | ...
    synergyWeights(vectorNumber, :) ~= 0;

errorCenter = valueOrAlternate(costTerm, "errorCenter", 0);
cost = norm([(synergyWeights(vectorNumber, indices) - ...
    inputs.initialSynergyWeights(vectorNumber, indices) - errorCenter) ...
    zeros(1, numWeights - sum(indices))]);
end
