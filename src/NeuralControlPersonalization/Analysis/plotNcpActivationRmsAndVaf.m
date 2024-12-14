% This function is part of the NMSM Pipeline, see file for full license.
%
% Plot total VAF and RMS error for invdividual NCP muscle activations
% compared to tracked activations. RMS error is used for individual muscles
% instead of VAF because it better describes the fit of smaller
% activations. 
%
% (string, string, string) -> (None)
% Plot total VAF and RMS error for NCP muscle activations.

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

function plotNcpActivationRmsAndVaf(weightsFile, commandsFile, ...
    mtpActivationsFile)
import org.opensim.modeling.Storage
params = getPlottingParams();
weightsStorage = Storage(weightsFile);
ncpMuscleNames = getStorageColumnNames(weightsStorage);
synergyWeights = storageToDoubleMatrix(weightsStorage);
commandsStorage = Storage(commandsFile);
synergyCommands = storageToDoubleMatrix(commandsStorage);
ncpActivations = synergyWeights * synergyCommands;

mtpStorage = Storage(mtpActivationsFile);
mtpMuscleNames = getStorageColumnNames(mtpStorage);
mtpActivations = storageToDoubleMatrix(mtpStorage);

[sharedMuscleNames, ncpIndices, mtpIndices] = ...
    intersect(ncpMuscleNames, mtpMuscleNames);
ncpSubset = ncpActivations(ncpIndices, :);
mtpSubset = mtpActivations(mtpIndices, :);

rmsError = zeros(1, length(sharedMuscleNames));
for i = 1 : length(sharedMuscleNames)
    rmsError(i) = rms(mtpSubset(i, :) - ncpSubset(i, :));
end
totalVaf = calcPercentVaf(reshape(mtpSubset, 1, []), ...
    reshape(ncpSubset, 1, []));
[worstError, worstMuscleIndex] = max(rmsError);
worstMuscleName = sharedMuscleNames(worstMuscleIndex);

splitFileName = split(commandsFile, "_synergyCommands.sto");
figureName = splitFileName(1);
figure(name = figureName)
set(gcf, color=params.plotBackgroundColor)
boxplot(rmsError)
set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
title("RMS error for muscles with tracked activations", ...
    "Total VAF: " + sprintf('\\bf{%.2f}%%\\rm', totalVaf) + newline + ...
    "Worst individual muscle: " + strrep(worstMuscleName, '_', '\_') + ...
    sprintf(" (RMSE: %.3f)", worstError), ...
    fontsize = params.subplotTitleFontSize)
ylabel("RMSE", fontsize=params.axisLabelFontSize)
set(gca, 'XTick', [])

end

function percentVaf = calcPercentVaf(experimental, reconstructed)
sr = sum((experimental - reconstructed) .^ 2);
st = sum(experimental .^ 2);

percentVaf = (1 - sr/st) * 100;
end
