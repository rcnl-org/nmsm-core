% This function is part of the NMSM Pipeline, see file for full license.
%
% This function stores the initial user-defined controls as a spline for
% use in cost terms for Treatment Optimization
%
% (string) -> (None)
% Spline input user-defined controls

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2025 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function inputs = setupUserDefinedControls(inputs)
if inputs.controllerTypes(4)
    if ~isfield(inputs, 'initialUserDefinedControlLabels')
        inputs.initialUserDefinedControls = ...
            inputs.experimentalUserDefinedControls;
        inputs.initialUserDefinedControlLabels = ...
            inputs.userDefinedControlLabels;
    end
    inputs.splineUserDefinedControls = makeGcvSplineSet( ...
        inputs.initialTime, inputs.initialUserDefinedControls', ...
        inputs.initialUserDefinedControlLabels);
    if inputs.useControlDerivatives && ~isfield(inputs, ...
            'initialUserDefinedControlDerivatives')
        if strcmp(inputs.solverType, 'casadi')
            inputs.initialUserDefinedControlDerivatives = evaluateGcvSplines( ...
                inputs.splineUserDefinedControls, ...
                inputs.initialUserDefinedControlLabels, ...
                inputs.collocationTimeOriginalWithEnd, 1);
        else
            inputs.initialUserDefinedControlDerivatives = evaluateGcvSplines( ...
                inputs.splineUserDefinedControls, ...
                inputs.initialUserDefinedControlLabels, ...
                inputs.initialTime, 1);
        end
        if inputs.useControlDynamicsFilter
            inputs.initialUserDefinedControlDerivatives = ...
                (inputs.initialUserDefinedControlDerivatives - inputs.initialUserDefinedControls) ...
                / inputs.controlDynamicsFilterConstant;
        end
    end
end
end
