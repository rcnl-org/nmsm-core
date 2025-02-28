% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the aperiodicity of a control. This is handled
% as a path constraint because control endpoints cannot be used to
% guarantee control periodicity with GPOPS-II.
%
% (struct, Array of number, 2D matrix, Array of string) -> (Array of number)
%

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
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

function pathTerm = calcControllerPeriodicityPathConstraint( ...
    inputs, values, controllerName)
control = findControl(inputs, values, controllerName);

% pathTerm = linspace(0, control(end) - control(1), length(control))';
pathTerm = zeros(size(control));
pathTerm(end) = control(end) - control(1);
end

function shifted = shiftSignalWithFft(base, shifted)
magnitude = abs(fft(shifted));
phase = angle(fft(base));

shifted = real(ifft(magnitude .* exp(1i * phase)));
end

function control = findControl(inputs, values, controllerName)
if strcmp(inputs.controllerType, 'synergy')
    indx = find(strcmp(convertCharsToStrings( ...
        inputs.synergyLabels), controllerName));
    if ~isempty(indx)
        control = values.controlSynergyActivations(:, indx);
        return
    end
end
indx = find(strcmp(convertCharsToStrings( ...
    strcat(inputs.torqueControllerCoordinateNames, '_moment')), ...
    controllerName));
control = values.torqueControls(:, indx);
end
