% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
% 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function reportSurrogateModel(inputs)

[newMuscleTendonLengths, newMomentArms] = calcSurrogateModel( ...
    inputs, inputs.muscleSpecificJointAngles);
plotSurrogateModelFitting(inputs, newMuscleTendonLengths, newMomentArms);
end
function plotSurrogateModelFitting(inputs, newMuscleTendonLengths, ...
    newMomentArms)

nplots = ceil(sqrt(inputs.numMuscles));
% Plot muscle tendon lengths
figure('name', 'Muscle Tendon Lengths')
for i = 1 : inputs.numMuscles
subplot(nplots, nplots, i)
plotData(inputs.muscleTendonLengths(:, i), newMuscleTendonLengths(:, i), ...
    inputs.muscleNames{i})
axis([1 size(inputs.muscleTendonLengths, 1) min(inputs.muscleTendonLengths,  [], ...
    'all') max(inputs.muscleTendonLengths,  [], 'all')])
if i > inputs.numMuscles - nplots; xlabel('Data Points'); 
else xticklabels(''); end
if ismember(i, 1 : nplots : inputs.numMuscles)
    ylabel({'Muscle','Tendon Lengths'});
else yticklabels(''); end
if i == inputs.numMuscles
    legend('Original', 'Predicted'); 
end
end

% Plot moment arms
for j = 1 : length(inputs.surrogateModelCoordinateNames)
figure('name', 'Moment Arms')
for i = 1 : inputs.numMuscles
subplot(nplots, nplots, i)
for k = 1:length(inputs.coordinateNames)
if strcmp(inputs.surrogateModelCoordinateNames(j), inputs.coordinateNames(k))
plotData(inputs.momentArms(:,j,i), newMomentArms(:,k,i), inputs.muscleNames(i));
end
end
if i > inputs.numMuscles - nplots; xlabel('Data Points'); 
else xticklabels(''); end
if ismember(i, 1 : nplots : inputs.numMuscles)
    ylabel({'Moment','Arms'}); end
if i == inputs.numMuscles
    legend('Original', 'Predicted'); 
end
end
end
end
function plotData(original, predicted, muscleLabel)
plot(original, 'r', 'LineWidth', 2)
hold on; plot(predicted, 'k')
title(strrep(muscleLabel, '_', ' '))
end