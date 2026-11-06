% This function is part of the NMSM Pipeline, see file for full license.
%
% Scales data recorded in a length unit (mm, cm, or m) to meters. Moments
% recorded in N*mm are converted to N*m by the same factor, so the c3d
% point units are passed for both positions and moments.
%
% (Array of double, string) -> (Array of double)
% Converts length data to meters

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function data = convertLengthUnitsToMeters(data, units)
switch lower(strtrim(string(units)))
    case "mm"
        data = data / 1000;
    case "cm"
        data = data / 100;
    case "m"
    otherwise
        throw(MException("convertLengthUnitsToMeters:unknownUnits", ...
            "Unrecognized length units '%s' in the c3d file. Expected " + ...
            "mm, cm, or m.", units))
end
end
