% This function is part of the NMSM Pipeline, see file for full license.
%
% This is used as a built in function for JMP to adjust the position of
% markers in the model.
%
% (Model, string, number, string) -> ()
% Move the marker in the specified axis to the specified value.

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

function adjustMarkerPosition(model, ...
    markerName, value, axis)
currentPosition = model.getMarkerSet().get(markerName).get_location();
if strcmp(axis, "x")
    newPosition = org.opensim.modeling.Vec3(value, ...
        currentPosition.get(1), currentPosition.get(2));
end
if strcmp(axis, "y")
    newPosition = org.opensim.modeling.Vec3(currentPosition.get(0), ...
        value, currentPosition.get(2));
end
if strcmp(axis, "z")
    newPosition = org.opensim.modeling.Vec3(currentPosition.get(0), ...
        currentPosition.get(1), value);
end
model.getMarkerSet().get(markerName).set_location(newPosition);
end
