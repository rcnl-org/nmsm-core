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

function [inputs] = SurrogateModelCreation(inputs)

if inputs.performLatinHyperCubeSampling
    [inputs.muscleTendonLengths, inputs.momentArms, ... 
        inputs.experimentalJointAngles] = performLhsSampling(inputs);
end
inputs = getMuscleSpecificSurrogateModelData(inputs);
[inputs.polynomialExpressionMuscleTendonLengths, ...
    inputs.polynomialExpressionMomentArms, inputs.coefficients] = ...
    createSurrogateModel(inputs.muscleSpecificJointAngles, ...
    inputs.muscleTendonLengths, inputs.muscleSpecificMomentArms, ...
    inputs.polynomialDegree);
end

function [muscleTendonLengths, momentArms, ...
    experimentalJointAngles] = performLhsSampling(inputs)

offset = mean(inputs.experimentalJointAngles);
dataPoints = round(linspace(1, size(inputs.experimentalJointAngles, ...
    1), inputs.lhsNumPoints));
experimentalJointAngles = inputs.experimentalJointAngles - offset;
lhsUpperBound = experimentalJointAngles + ...
    range(experimentalJointAngles) * inputs.lhsRangeMultiplier;
lhsLowerBound = experimentalJointAngles - ...
    range(experimentalJointAngles) * inputs.lhsRangeMultiplier;
lhsData = lhsdesign(inputs.lhsNumPoints, ...
    length(inputs.coordinateNames)) .* (lhsUpperBound(dataPoints, :));
lhsData = cat(1, lhsData, lhsdesign(inputs.lhsNumPoints, ...
    length(inputs.coordinateNames)) .* (lhsLowerBound(dataPoints, :)));
lhsData = lhsData + offset;

import org.opensim.modeling.*
model = Model(inputs.model);
state = model.initSystem();
for i = 1 : inputs.numMuscles
    for j = 1 : size(lhsData, 1)
       for k = 1 : size(inputs.coordinateNames, 2)
            if ~model.getCoordinateSet.get(inputs.coordinateNames(k)).get_locked
                model.getCoordinateSet.get(inputs.coordinateNames(k)).setValue(state, lhsData(j, k));
            end
        end
        muscleTendonLengthsLhs(j, i) = model.getMuscles().get(i-1).getGeometryPath().getLength(state);
        for k = 1 : length(inputs.surrogateModelCoordinateNames)
            coordinate = model.getCoordinateSet.get(inputs.surrogateModelCoordinateNames(k));
            momentArmsLhs(j, k, i) = model.getMuscles().get(i-1).getGeometryPath().computeMomentArm(state, coordinate);
        end
    end
end
muscleTendonLengths = cat(1, inputs.muscleTendonLengths, muscleTendonLengthsLhs);
momentArms = cat(1, inputs.momentArms, momentArmsLhs);
experimentalJointAngles = cat(1, inputs.experimentalJointAngles, lhsData);
end