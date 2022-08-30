% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (struct, struct, struct) -> (struct)
% returns the modeled values for the given inputs for MTP

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function modeledValues = calcMtpModeledValues(values, ...
    experimentalData, params)
muscleExcitations = calcMuscleExcitations(experimentalData.emgTime, ...
    experimentalData.emgSplines, values.electromechanicalDelays, ...
    values.emgScaleFactors);
neuralActivations = calcNeuralActivations(muscleExcitations, ...
    values.activationTimeConstants, experimentalData.emgTime, ...
    experimentalData.numPaddingFrames);
muscleActivations = calcMuscleActivations(neuralActivations, ...
    values.activationNonlinearityConstants);
[modeledValues.normalizedFiberLength, ...
    modeledValues.normalizedFiberVelocity] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities(experimentalData, ...
    values.optimalMuscleLengths, values.tendonSlackLengths);
modeledValues.passiveForce = passiveForceLengthCurve( ...
    modeledValues.normalizedMuscleFiberLength);
modeledValues.muscleMoments = calcMuscleMoments(experimentalData, ...
    passiveForce, muscleActivations, ...
    modeledValues.normalizedFiberLength, ...
    modeledValues.normalizedFiberVelocity);
end