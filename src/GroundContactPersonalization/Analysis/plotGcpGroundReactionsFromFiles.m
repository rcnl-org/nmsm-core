% This function is part of the NMSM Pipeline, see file for full license.
%
% Plot experimental and optimized ground reactions from Ground Contact
% Personalization results files. Moments are calculated about the midfoot 
% superior marker projected down to the resting spring length.
%
% (string, string, double) -> (None)
% Plot experimental and modeled ground reactions. 

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

function plotGcpGroundReactionsFromFiles( ...
    experimentalGroundReactionsFileName, ...
    optimizedGroundReactionsFileName, plotNumber)
% The optional plot number argument allows users to generate multiple plots
% without overwriting previous plots. By default, figure 1 is used. 
if nargin < 3
    plotNumber = 1;
end
titles = ["Anterior GRF" "Vertical GRF" "Lateral GRF" "X Moment" ...
    "Y Moment" "Z Moment"];
import org.opensim.modeling.Storage
experimentalGroundReactions = ...
    storageToDoubleMatrix(Storage(experimentalGroundReactionsFileName));
modeledGroundReactions = ...
    storageToDoubleMatrix(Storage(optimizedGroundReactionsFileName));
time = findTimeColumn(Storage(experimentalGroundReactionsFileName));

figure(plotNumber)
t = tiledlayout(2, 3, ...
    TileSpacing='compact', Padding='compact');
for i = 1:6
    nexttile(i)
    experimental = experimentalGroundReactions(i, :);
    model = modeledGroundReactions(i, :);
    plot(time, experimental, "red", "LineWidth", 2)
    hold on
    plot(time, model, "blue", "LineWidth", 2)
    error = rms(experimental - model);
    title(titles(i) + newline + " RMSE: " + error)
    xlabel('Time')
    if i == 1
        ylabel('Force (N)')
    else if i == 4
        ylabel('Moment (N*m)')
    end
    hold off
end
end

