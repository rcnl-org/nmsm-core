% This function is part of the NMSM Pipeline, see file for full license.
%
% Throws an error if any marker is unlabeled. A marker is unlabeled when
% its name is empty or follows the naming capture software uses for
% unidentified points: a leading asterisk (e.g. *12) or a name starting
% with "unlabeled" or "unnamed". Markers must be labeled in the capture
% software before extraction.
%
% (Array of string) -> (None)
% Errors if any marker is unlabeled

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

function verifyMarkerLabels(markerNames)
markerNames = string(markerNames);
unlabeled = markerNames == "" | startsWith(markerNames, "*") | ...
    startsWith(markerNames, ["unlabeled", "unnamed"], "IgnoreCase", true);
if any(unlabeled)
    throw(MException("verifyMarkerLabels:unlabeledMarkers", ...
        "The c3d file contains %d unlabeled marker(s): %s. Label or " + ...
        "delete them in the capture software before extraction.", ...
        sum(unlabeled), strjoin(markerNames(unlabeled), ", ")))
end
end
