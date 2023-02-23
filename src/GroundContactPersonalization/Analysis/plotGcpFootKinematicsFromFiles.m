% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (string, string, double) -> (None)
% Plot experimental and optimized foot kinematics from Ground Contact
% Personalization results. 

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

function plotGcpFootKinematicsFromFiles(experimentalKinematicsFileName, ...
    optimizedKinematicsFileName, plotNumber)
if nargin < 3
    plotNumber = 1;
end
coordinates = ["Toe Angle", "X Rotation", "Y Rotation", "Z Rotation", ...
    "X Translation", "Y Translation", "Z Translation"];
import org.opensim.modeling.Storage
experimentalKinematics = ...
    storageToDoubleMatrix(Storage(experimentalKinematicsFileName));
modeledKinematics = ...
    storageToDoubleMatrix(Storage(optimizedKinematicsFileName));
time = findTimeColumn(Storage(experimentalKinematicsFileName));
figure(plotNumber)
for i = 1:7
    subplot(2, 4, i)
    if i <= 4
        experimental = rad2deg(experimentalKinematics(i, :));
        model = rad2deg(modeledKinematics(i, :));
    else
        experimental = experimentalKinematics(i, :);
        model = modeledKinematics(i, :);
    end
    plot(time, experimental, "red", "LineWidth", 2)
    hold on
    plot(time, model, "blue", "LineWidth", 2)
    error = rms(experimental - model);
    title(coordinates(i) + newline + " RMSE: " + error)
    xlabel('Time')
    if i == 1
        ylabel('Angle (deg)')
    elseif i == 5
        ylabel('Translation (m)')
    end
    hold off
end
end

