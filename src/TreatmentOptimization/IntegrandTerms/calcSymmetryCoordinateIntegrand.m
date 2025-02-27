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

function cost = calcSymmetryCoordinateIntegrand(costTerm, inputs, time, ...
    positions, baseCoordinateName, shiftedCoordinateName)
normalizeByFinalTime = valueOrAlternate(costTerm, ...
    "normalize_by_final_time", true);
if normalizeByFinalTime && all(size(time) == size(inputs.collocationTimeOriginal))
    time = time * inputs.collocationTimeOriginal(end) / time(end);
end

indx1 = find(strcmp(convertCharsToStrings(inputs.coordinateNames), ...
    baseCoordinateName));
if isempty(indx1)
    throw(MException('CostTermError:CoordinateNotInState', ...
        strcat("Coordinate ", baseCoordinateName, " is not in the ", ...
        "<states_coordinate_list>")))
end
indx2 = find(strcmp(convertCharsToStrings(inputs.coordinateNames), ...
    shiftedCoordinateName), 1);
if isempty(indx2)
    throw(MException('CostTermError:CoordinateNotInState', ...
        strcat("Coordinate ", shiftedCoordinateName, " is not in the ", ...
        "<states_coordinate_list>")))
end

baseCoordinate = positions(:, indx1);
shiftedCoordinate = positions(:, indx2);

method = valueOrAlternate(costTerm, 'shift_method', 'none');
assert(~strcmp('none', method), 'Symmetry terms need a <shift_method>.');
if strcmpi(method, 'fft')
    shiftedCoordinate = shiftSignalWithFft(baseCoordinate, shiftedCoordinate);
elseif strcmpi(method, 'polyFourier')
    harmonics = 7;
    coefs = polyFourierPhaseShiftCoefs(time/time(end), shiftedCoordinate, harmonics);
    shiftedCoordinate = polyFourierPhaseShiftCurve(time/time(end), coefs, pi);
else
    throw(MException(['Symmetry term shift_method must be fft or ' ...
        'polyFourier']));
end

cost = shiftedCoordinate - baseCoordinate;

if normalizeByFinalTime
    if all(size(time) == size(inputs.collocationTimeOriginal))
        cost = cost / time(end);
    else
        cost = cost / inputs.collocationTimeOriginal(end);
    end
end
end

function shifted = shiftSignalWithFft(base, shifted)
magnitude = abs(fft(shifted));
phase = angle(fft(base));

shifted = real(ifft(magnitude .* exp(1i * phase)));
end
