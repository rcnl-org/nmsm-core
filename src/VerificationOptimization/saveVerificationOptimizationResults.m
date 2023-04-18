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

function saveVerificationOptimizationResults(solution, inputs, resultsDirectory)

values = getVerificationOptimizationValueStruct(solution.solution.phase, inputs);
stateLabels = inputs.coordinateNames;
for i = 1 : length(inputs.coordinateNames)
stateLabels{end + 1} = strcat(inputs.coordinateNames{i}, '_u');
end
for i = 1 : length(inputs.coordinateNames)
stateLabels{end + 1} = strcat(inputs.coordinateNames{i}, '_dudt');
end
writeToSto(stateLabels, values.time, ...
        [values.statePositions values.stateVelocities values.stateAccelerations], fullfile(resultsDirectory, ...
        "statesSolution.sto"));
if strcmp(inputs.controllerType, 'synergy_driven')
controlLabels = inputs.coordinateNames;
for i = 1 : inputs.numSynergies
controlLabels{end + 1} = strcat('command', num2str(i));
end
writeToSto(controlLabels, values.time, ...
        [values.controlJerks values.controlNeuralCommands], fullfile(resultsDirectory, ...
        "controlSolution.sto"));
elseif strcmp(inputs.controllerType, 'torque_driven')
controlLabels = inputs.coordinateNames;
for i = 1 : inputs.numTorqueControls
controlLabels{end + 1} = strcat('torqueControl', num2str(i));
end
writeToSto(controlLabels, values.time, ...
        [values.controlJerks values.controlTorques], fullfile(resultsDirectory, ...
        "controlSolution.sto"));
end
delete(inputs.mexModel);
end