% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the two coordinates
% aligned in phase to target symmetry.
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

function pathTerm = calcControllerSymmetryPathConstraint(constraintTerm, ...
    inputs, time, values, baseControllerName, shiftedControllerName)
baseControl = findControl(inputs, values, baseControllerName);
shiftedControl = findControl(inputs, values, shiftedControllerName);

method = valueOrAlternate(constraintTerm, 'shift_method', 'none');
assert(~strcmp('none', method), 'Symmetry terms need a <shift_method>.');
if strcmpi(method, 'fft')
    shiftedControl = shiftSignalWithFft(baseControl, shiftedControl);
elseif strcmpi(method, 'polyFourier')
    harmonics = 7;
    coefs = polyFourierPhaseShiftCoefs(time/time(end), shiftedControl, harmonics);
    shiftedControl = polyFourierPhaseShiftCurve(time/time(end), coefs, pi);
    coefs = polyFourierPhaseShiftCoefs(time/time(end), baseControl, harmonics);
    baseControl = polyFourierCurves(coefs, 1, time/time(end), 1, 0);
else
    throw(MException(['Symmetry term shift_method must be fft or ' ...
        'polyFourier']));        
end

pathTerm = shiftedControl - baseControl;
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
