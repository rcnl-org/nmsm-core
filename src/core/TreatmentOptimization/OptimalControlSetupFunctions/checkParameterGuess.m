% This function is part of the NMSM Pipeline, see file for full license.
%
% This function checks that the initial guess parameters file is in the 
% correct order
%
% (struct) -> (struct)
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

function inputs = checkParameterGuess(inputs)
if isfield(inputs.initialGuess, 'parameter') || isfield(inputs,"synergyWeights") 
    if isfield(inputs.initialGuess, 'parameter')
        inputs.synergyWeightsGuess = inputs.initialGuess.parameter;
    elseif isfield(inputs,"synergyWeights") 
        inputs.synergyWeightsGuess = inputs.synergyWeights;
    end

    parameterIndex = zeros(length(inputs.synergyGroups), inputs.numMuscles);
    for i = 1 : length(inputs.synergyGroups)
        for j = 1 : inputs.numMuscles
            for k = 1 : length(inputs.synergyGroups{i}.muscleNames)
                if strcmpi(inputs.muscleNames(j), inputs.synergyGroups{i}.muscleNames(k))
                    if i <= 1 
                        parameterIndex(i, k) = j;
                    else
                        parameterIndex(i, k + length(inputs.synergyGroups{i}.muscleNames)) = j;
                    end
                end
            end
        end 
    end
    synergyWeightsFlattened = [];
    numSynergiesIndex = 0;
    for j = 1 : length(inputs.synergyGroups)
        synergyWeightsFlattened = cat(2, synergyWeightsFlattened, ...
            reshape(inputs.synergyWeightsGuess(1 + numSynergiesIndex: ...
            inputs.synergyGroups{j}.numSynergies + numSynergiesIndex, ...
            nonzeros(parameterIndex(j, :)))', 1, []));
        numSynergiesIndex = numSynergiesIndex + inputs.synergyGroups{j}.numSynergies;
    end
    inputs.synergyWeightsGuess = synergyWeightsFlattened;
end
if strcmp(inputs.controllerType, 'synergy_driven') 
    inputs = getMuscleSynergiesInitialGuess(inputs);
    for i = 1 : length(inputs.coordinateNames)
        for j = 1 : length(inputs.surrogateModelCoordinateNames)
            if strcmp(inputs.coordinateNames(i), inputs.surrogateModelCoordinateNames(j))
                inputs.surrogateModelIndex(j) = i;
            end
        end 
    end
    inputs.dofsActuatedIndex = [];
    for i = 1 : length(inputs.inverseDynamicMomentLabels)
        for j = 1 : length(inputs.surrogateModelCoordinateNames)
            if strcmp(inputs.inverseDynamicMomentLabels(i), ...
                    strcat(inputs.surrogateModelCoordinateNames(j), '_moment'))
                inputs.dofsActuatedIndex(end+1) = j;
            end
        end 
    end
end
end
function inputs = getMuscleSynergiesInitialGuess(inputs)
if isfield(inputs.initialGuess,"parameter") || isfield(inputs,"synergyWeights") 
    synergyWeights = getSynergyWeightsFromGroups(inputs.synergyWeightsGuess, inputs);
    inputs.synergyActivationsGuess = inputs.experimentalMuscleActivations / synergyWeights;    
else
    inputs.mtpActivationsColumnNames = inputs.muscleLabels;
    inputs.mtpActivations = permute(inputs.experimentalMuscleActivations, [3 2 1]);
    inputs.synergyWeightsGuess = prepareNonNegativeMatrixFactorizationInitialValues(inputs, inputs)';
    synergyWeights = getSynergyWeightsFromGroups(inputs.synergyWeightsGuess, inputs);
    inputs.synergyActivationsGuess = inputs.experimentalMuscleActivations / synergyWeights;
end
end