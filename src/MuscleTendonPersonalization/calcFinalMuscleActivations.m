% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the resulting muscle activations following the 
% completion of the muscle tendon personalization. 
%
% (struct, struct) -> (Array of number)
% Outputs final muscle activations

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

function results = calcFinalMuscleActivations(optimizedParams, inputData)

muscleExcitations = calcMuscleExcitations(inputData.timeEMG, ...
    inputData.emgSplines, findCorrectMtpValues(1, optimizedParams), ...
    findCorrectMtpValues(4, optimizedParams));
neuralActivations = calcNeuralActivations(muscleExcitations, ...
    findCorrectMtpValues(2, optimizedParams), inputData.timeEMG, ...
    inputData.nPad);
results.muscleActivations = calcMuscleActivations(...
    findCorrectMtpValues(3, optimizedParams), neuralActivations);
results.time = inputData.timeEMG;
results.optimizedParams = optimizedParams;
end