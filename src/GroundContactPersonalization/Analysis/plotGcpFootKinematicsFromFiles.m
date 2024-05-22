% This function is part of the NMSM Pipeline, see file for full license.
%
% Plot experimental and optimized foot kinematics from Ground Contact
% Personalization results files. 
%
% (string, string, double) -> (None)
% Plot experimental and optimized foot kinematics.

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
% The optional plot number argument allows users to generate multiple plots
% without overwriting previous plots. By default, figure 1 is used. 
if nargin < 3
    plotNumber = 1;
end
coordinates = ["Toe Angle", "Y Rotation", "X Rotation", "Z Rotation", ...
    "X Translation", "Y Translation", "Z Translation"];
import org.opensim.modeling.Storage
experimentalKinematics = ...
    storageToDoubleMatrix(Storage(experimentalKinematicsFileName));
modeledKinematics = ...
    storageToDoubleMatrix(Storage(optimizedKinematicsFileName));
time = findTimeColumn(Storage(experimentalKinematicsFileName));

splitFileName = split(optimizedKinematicsFileName, "_optimized");
figureName = splitFileName(1);
figure(Name = figureName, ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
t = tiledlayout(2, 4, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Time [s]")
for i = 1:7
    nexttile(i)
    % Rotational coordinate data are converted to degrees. 
    if i <= 4
        experimental = rad2deg(experimentalKinematics(i, :));
        model = rad2deg(modeledKinematics(i, :));
    else
        experimental = experimentalKinematics(i, :);
        model = modeledKinematics(i, :);
    end
    plot(time, experimental, Color="#0072BD", LineWidth=2)
    hold on
    plot(time, model, Color="#D95319", LineWidth=2)
    error = rms(experimental - model);
    title(coordinates(i) + newline + " RMSE: " + error)
    if i == 1
        ylabel('Angle (deg)')
        legend("Experimental", "Model")
    elseif i == 5
        ylabel('Translation (m)')
    end
    hold off
end
end

