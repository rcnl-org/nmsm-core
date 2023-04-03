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

function inputs = getIntegralBounds(inputs)
inputs.integralOptions = {};
inputs.maxIntegral = [];
inputs.isEnabled = zeros(1, 6);

trackCoordinates = valueOrAlternate(inputs, "trackedCoordinateEnabled", 0);
if trackCoordinates
    [inputs.integralOptions{end+1}, inputs.maxIntegral, ...
        inputs.trackedCoordinateIndex] = getIntegralSettings( ...
        inputs.trackedCoordinate, inputs.coordinateNames, inputs.maxIntegral);
    inputs.isEnabled(1) = 1;
end
trackLoads = valueOrAlternate(inputs, "trackedLoadEnabled", 0);
if trackLoads
    [inputs.integralOptions{end+1}, inputs.maxIntegral, ...
        inputs.trackedInverseDynamicMomentsIndex] = getIntegralSettings( ...
        inputs.trackedLoad, inputs.inverseDynamicMomentLabels, ...
        inputs.maxIntegral);
    inputs.isEnabled(2) = 1;
end
trackExternalForces = valueOrAlternate(inputs, "trackedExternalForceEnabled", 0);
if trackExternalForces
    [inputs.integralOptions{end+1}, inputs.maxIntegral, ...
        inputs.trackedExternalForcesIndex] = getIntegralSettings( ...
        inputs.trackedExternalForce, [inputs.rightGroundReactionLabels, ...
        inputs.leftGroundReactionLabels], inputs.maxIntegral);
    inputs.isEnabled(3) = 1;
end
trackExternalMoments = valueOrAlternate(inputs, "trackedExternalMomentEnabled", 0);
if trackExternalMoments
    [inputs.integralOptions{end+1}, inputs.maxIntegral, ...
        inputs.trackedExternalMomentsIndex] = getIntegralSettings( ...
        inputs.trackedExternalMoment, [inputs.rightGroundReactionLabels, ...
        inputs.leftGroundReactionLabels], inputs.maxIntegral);
    inputs.isEnabled(4) = 1;
end
trackMuscleActivation = valueOrAlternate(inputs, "trackedMuscleActivationEnabled", 0);
if trackMuscleActivation
    inputs.integralOptions{end+1} = ...
        inputs.trackedMuscleActivationMaxAllowableError * ...
        ones(1, inputs.numMuscles);
    inputs.maxIntegral = cat(2, inputs.maxIntegral, ...
        nonzeros(inputs.integralOptions{end})');
    inputs.isEnabled(5) = 1;
end
minimizeJointJerk = valueOrAlternate(inputs, "minimizedCoordinateEnabled", 0);
if minimizeJointJerk
    inputs.integralOptions{end+1} = ...
        inputs.minimizedCoordinateMaxAllowableError * ...
        range(inputs.experimentalJointJerks);
    inputs.maxIntegral = cat(2, inputs.maxIntegral, ...
        nonzeros(inputs.integralOptions{end})');
    inputs.isEnabled(6) = 1;
 end
inputs.minIntegral = zeros(1, length(inputs.maxIntegral));
end
function [integralOptions, maxIntegral, trackedQuantityIndex] = ...
    getIntegralSettings(trackedQuantity, modelComponentNames, tempMaxIntegral)
integralOptions = getMaximumAllowableErrors( ...
    trackedQuantity, modelComponentNames);
maxIntegral = cat(2, tempMaxIntegral, nonzeros(integralOptions)');
trackedQuantityIndex = find(integralOptions);
integralOptions(integralOptions == 0) = [];
end