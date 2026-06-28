% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the dynamic constraint for treatment
% optimization.
%
% (struct, struct) -> (2D matrix)
% Returns the dynamic constraint

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

function dynamics = calcDynamicConstraint(values, inputs, modeledValues)
derivatives = [values.stateVelocities, values.controlAccelerations];
if inputs.useJerk
    derivatives = [derivatives, values.controlJerks];
end
if inputs.useControlDynamicsFilter
    if inputs.controllerTypes(4)
        derivatives = [derivatives, (values.userDefinedControlDerivatives - values.userDefinedControls) / inputs.controlDynamicsFilterConstant];
    end
    if inputs.controllerTypes(3)
        derivatives = [derivatives, (values.controlMuscleActivationDerivatives - values.controlMuscleActivations) / inputs.controlDynamicsFilterConstant];
    end
    if inputs.controllerTypes(2)
        derivatives = [derivatives, (values.controlSynergyActivationDerivatives - values.controlSynergyActivations) / inputs.controlDynamicsFilterConstant];
    end
    if inputs.controllerTypes(1)
        derivatives = [derivatives, (values.torqueControlDerivatives - values.torqueControls) / inputs.controlDynamicsFilterConstant];
    end
end
if any(inputs.controllerTypes(2:3)) && inputs.useActivationDynamics
    coefficient1 = 1 ./ inputs.activationTimeConstants - ...
        1 ./ (4 * inputs.activationTimeConstants);
    coefficient2 = 1 ./ (4 * inputs.activationTimeConstants);
    derivatives = [derivatives, ...
        (coefficient1 .* values.excitationControls + coefficient2) .* ...
        (values.excitationControls - modeledValues.neuralActivations)];
end

dynamics = (inputs.maxTime - inputs.minTime) * ...
    derivatives ./ (inputs.maxState - inputs.minState);
end
