% This function is part of the NMSM Pipeline, see file for full license.
%
% This function stores the initial muscle activations as a spline for use
% in cost terms for Treatment Optimization
%
% (string) -> (None)
% Spline input synergy activations

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function inputs = setupMuscleActivations(inputs)
if inputs.controllerTypes(3)
    if ~isfield(inputs, 'initialMuscleControlsLabels')
        inputs.initialMuscleControlsLabels = inputs.individualMuscleNames;
        [~, indices] = intersect(inputs.muscleLabels, ...
            inputs.individualMuscleNames);
        inputs.initialMuscleControls = inputs.experimentalMuscleActivations(:, indices);
        if isfield(inputs, 'synergyMuscleNames')
            [~, indices] = intersect(inputs.individualMuscleNames, ...
                inputs.synergyMuscleNames);
            inputs.initialMuscleControls(:, indices) = 0;
        end
    end
    inputs.splineMuscleControls = makeGcvSplineSet( ...
        inputs.initialTime, inputs.initialMuscleControls', ...
        inputs.initialMuscleControlsLabels);
    if strcmp(inputs.solverType, 'casadi')
        inputs.initialMuscleControls = evaluateGcvSplines( ...
            inputs.splineMuscleControls, ...
            inputs.initialMuscleControlsLabels, ...
            inputs.collocationTimeOriginalWithEnd);
    end
end
end
