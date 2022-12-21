% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (Model, struct, string, string) -> (None)
% Plot optimized spring constants from GCP.

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

function plotSpringConstants(footModel, inputs, toesBodyName, ...
    hindfootBodyName)

[footModel, state] = Model("footModel2.osim");
calcnToToes = footModel.getBodySet().get(...
    toesBodyName).findTransformBetween(state, ...
    footModel.getBodySet().get(hindfootBodyName));
springX = zeros(1, length(inputs.springConstants));
springZ = zeros(1, length(inputs.springConstants));
for i=1:length(inputs.springConstants)
    markerPositionOnFoot = footModel.getMarkerSet().get(...
        "spring_marker_" + i).getPropertyByName("location").toString(...
        ).toCharArray';
    markerPositionOnFoot = split(markerPositionOnFoot(2:end-1));
    springX(i) = str2double(markerPositionOnFoot{1});
    springZ(i) = str2double(markerPositionOnFoot{3});
    if strcmp(getMarkerBodyName(footModel, "spring_marker_" + i), toesBodyName)
        springX(i) = springX(i) + calcnToToes.T.get(0);
    end
end
scatter(springZ, springX, 200, inputs.springConstants, "filled")
title("Spring constants")
xlabel("Z location on foot (m)")
ylabel("X location on foot (m)")
colormap jet
colorbar

end