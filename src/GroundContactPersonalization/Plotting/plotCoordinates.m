% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (Model, struct, string, string) -> (None)
% Plot optimized kinematic coordinates from GCP.

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

function plotCoordinates(inputs)
[modeledJointPositions, ~] = calcGCPJointKinematics( ...
    inputs.experimentalJointPositions, inputs.jointKinematicsBSplines, ...
    inputs.bSplineCoefficients);
coordinates = ["Toe Angle", "X Rotation", "Y Rotation", "Z Rotation", ...
    "X Translation", "Y Translation", "Z Translation"];
for i = 1:7
    subplot(2,4,i)
    
    if i <= 4
        experimental = rad2deg(inputs.experimentalJointPositions(i, :));
        model = rad2deg(modeledJointPositions(i, :));
    else
        experimental = inputs.experimentalJointPositions(i, :);
        model = modeledJointPositions(i, :);
    end

    scatter(inputs.time, experimental, [], "red")
    hold on
    scatter(inputs.time, model, [], "blue")
    title(coordinates(i))
    xlabel('Time')
    if i == 1
        ylabel('Angle (deg)')
    elseif i == 5
        ylabel('Translation (m)')
    end
    hold off
end
end
