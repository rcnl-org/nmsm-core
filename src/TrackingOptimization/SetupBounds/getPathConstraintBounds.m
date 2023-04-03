% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
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

function inputs = getPathConstraintBounds(inputs)
inputs.maxPath = [];
inputs.minPath = [];
rootSegmentResidualsPathConstraint = valueOrAlternate(inputs, ...
    "rootSegmentResidualLoadPathConstraint", 0);
if rootSegmentResidualsPathConstraint
    maxAllowablePathError = getMaximumAllowableErrors( ...
        inputs.rootSegmentResidualLoad, inputs.inverseDynamicMomentLabels);
    inputs.maxPath = nonzeros(maxAllowablePathError)';
    inputs.rootSegmentResidualsIndex = find(maxAllowablePathError);
    minAllowablePathError = getMinimumAllowableErrors( ...
        inputs.rootSegmentResidualLoad, inputs.inverseDynamicMomentLabels);
    inputs.minPath = nonzeros(minAllowablePathError)';
end
muscleModelLoadPathConstraint = valueOrAlternate(inputs, ...
    "muscleModelLoadPathConstraint", 0);
if muscleModelLoadPathConstraint
    maxAllowablePathError = getMaximumAllowableErrors( ...
        inputs.muscleModelLoad, inputs.inverseDynamicMomentLabels);
    inputs.maxPath = cat(2, inputs.maxPath, ...
        nonzeros(maxAllowablePathError)');
    inputs.muscleActuatedMomentsIndex = find(maxAllowablePathError);
    minAllowablePathError = getMinimumAllowableErrors( ...
        inputs.muscleModelLoad, inputs.inverseDynamicMomentLabels);
    inputs.minPath = cat(2, inputs.minPath, ...
        nonzeros(minAllowablePathError)');
    for i = 1 : length(inputs.coordinateNames)
        for j = 1 : length(inputs.surrogateModelCoordinateNames)
            if contains(inputs.coordinateNames(i), inputs.surrogateModelCoordinateNames(j))
                inputs.surrogateModelIndex(j) = i;
            end
        end 
    end
    inputs.dofsActuatedIndex = [];
    for i = 1 : length(inputs.inverseDynamicMomentLabels)
        for j = 1 : length(inputs.surrogateModelCoordinateNames)
            if contains(inputs.inverseDynamicMomentLabels(i), ...
                    strcat(inputs.surrogateModelCoordinateNames(j), '_moment'))
                inputs.dofsActuatedIndex(end+1) = j;
            end
        end 
    end
end
controllerModelLoadPathConstraint = valueOrAlternate(inputs, ...
    "controllerModelLoadPathConstraint", 0);
if controllerModelLoadPathConstraint
    maxAllowablePathError = getMaximumAllowableErrors( ...
        inputs.controllerModelLoad, inputs.inverseDynamicMomentLabels);
    inputs.maxPath = cat(2, inputs.maxPath, ...
        nonzeros(maxAllowablePathError)');
    inputs.torqueActuatedMomentsIndex = find(maxAllowablePathError);
    minAllowablePathError = getMinimumAllowableErrors( ...
        inputs.controllerModelLoad, inputs.inverseDynamicMomentLabels);
    inputs.minPath = cat(2, inputs.minPath, ...
        nonzeros(minAllowablePathError)');
end
end