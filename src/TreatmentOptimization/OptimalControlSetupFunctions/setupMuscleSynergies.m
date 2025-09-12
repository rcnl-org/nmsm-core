% This function is part of the NMSM Pipeline, see file for full license.
%
% This function stores the initial synergy activations as a spline for use
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

function inputs = setupMuscleSynergies(inputs)
if inputs.controllerTypes(2)
    inputs.splineSynergyActivations = makeGcvSplineSet( ...
        inputs.initialTime, inputs.initialSynergyControls', ...
        inputs.initialSynergyControlsLabels);
    inputs.synergyLabels = inputs.initialSynergyControlsLabels;
    if strcmp(inputs.solverType, 'casadi')
        inputs.initialSynergyControls = evaluateGcvSplines( ...
            inputs.splineSynergyActivations, ...
            inputs.initialSynergyControlsLabels, ...
            inputs.collocationTimeOriginalWithEnd);
    end
    if inputs.useControlDerivatives && ~isfield(inputs, ...
            'initialSynergyControlDerivatives')
        if strcmp(inputs.solverType, 'casadi')
            inputs.initialSynergyControlDerivatives = evaluateGcvSplines( ...
                inputs.splineSynergyActivations, ...
                inputs.initialSynergyControlsLabels, ...
                inputs.collocationTimeOriginalWithEnd, 1);
        else
            inputs.initialSynergyControlDerivatives = evaluateGcvSplines( ...
                inputs.splineSynergyActivations, ...
                inputs.initialSynergyControlsLabels, ...
                inputs.initialTime, 1);
        end
        if inputs.useControlDynamicsFilter
            inputs.initialSynergyControlDerivatives = ...
                (inputs.initialSynergyControlDerivatives - inputs.initialSynergyControls) ...
                / inputs.controlDynamicsFilterConstant;
        end
    end
end
end
