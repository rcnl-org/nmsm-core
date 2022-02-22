% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the cost associated to joint moment matching   %
% while penalizing muscle parameter differences and violations.           %
%
% inputs
%
% (Array of number, struct) -> (Array of number)
% returns the cost for all rounds of the Muscle Tendon optimization

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

function [outputCost] = computeMuscleTendonCostFunction(secondaryValues, ...
    primaryValues, IsIncluded, params)

% Update these functions to call findCorrectValues
[~,EMG] = calcMuscleExcitations(params);
[NeuralActivations] = calcNeuralActivations(params,EMG);
[muscleActivations] = calcMuscleActivations(params,NeuralActivations);

% Update these functions to call findCorrectValues
[passiveForce, muscleForce, muscleMoments, modelMoments] = ...
    calcMuscleMomentsAndForces(momentArms, hillTypeParams, ...
    muscleActivations);
[lMtilda, vMtilda] = ...
    calcNormalizedMusceFiberLengthsAndVelocities(hillTypeParams);

% valuesStruct needs to be created to contain (primaryValues, ...
% secondaryValues, IsIncluded)
costs = calcAllTrackingCosts(valuesStruct, params, ...
    modelMoments, lMtilda);
costs = calcAllDeviationPenaltyCosts(valuesStruct, params, ...
    passiveForce);
costs = calcLmTildaCurveChangesCost(lMtilda, lMtildaExprimental, ...
    lmtildaPairs, params);
costs = calcPairedMusclePenalties(valuesStruct, ActivationPairs, ...
    params);

% Combine all costs into single vector
outputCost = combineCostsIntoVector(params.costWeight, costs);
Cost(isnan(Cost))=0;
end







