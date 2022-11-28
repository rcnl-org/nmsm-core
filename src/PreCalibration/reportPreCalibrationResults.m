% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (Array, struct) -> (None)
% Prints and plots results from muscle tendon personalization

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

function reportPreCalibrationResults(parameterChange, experimentalData)

values = makePreCalibrationValuesAsStruct(parameterChange, experimentalData);
modeledValues = calcPreCalibrationModeledValues(values, experimentalData);
getPassiveMomentRmse(modeledValues, experimentalData);
plotChangesInMuscleTendonProperties( ...
    values.optimalFiberLengthScaleFactors - 1, experimentalData, ...
    'Optimal Fiber Length Scaling Factors');
plotChangesInMuscleTendonProperties( ...
    values.tendonSlackLengthScaleFactors - 1, experimentalData, ...
    'Tendon Slack Length Scaling Factors');
plotNormalizedFiberLength(permute(modeledValues.normalizedFiberLength, ...
    [3 1 2]), experimentalData)
plotPassiveMomentData(permute(modeledValues.passiveModelMoments, [3 1 2]), ...
    permute(experimentalData.passiveData.experimentalMoments, [3 1 2]))
plotPassiveForceData(permute(modeledValues.passiveForce, [3 1 2]), ...
    experimentalData);
end
function getPassiveMomentRmse(modeledValues, experimentalData)

columnsWithAllZeros = ...
    all(experimentalData.passiveData.experimentalMoments == 0, 3);
experimentalMoments = ...
    experimentalData.passiveData.experimentalMoments( ...
    repmat(~columnsWithAllZeros, 1, 1, ...
    size(experimentalData.passiveData.experimentalMoments, 3)));
passiveModelMoments = modeledValues.passiveModelMoments( ...
    repmat(~columnsWithAllZeros, 1, 1, ...
    size(modeledValues.passiveModelMoments, 3)));


rmsePassive = sqrt(sum((passiveModelMoments - ...
    experimentalMoments) .^ 2) / size(passiveModelMoments, 1));
fprintf(['\nPassive moment tracking error is ' num2str(rmsePassive) ' Nm.\n']);
end
function plotChangesInMuscleTendonProperties(modeledValue, ...
    experimentalData, figureTitle)

figure
bar(modeledValue,'FaceColor',[1 0.2 0.2]);  
set(gca,'XTick',1:numel(modeledValue), 'XTickLabel',experimentalData.muscleNames)
title(figureTitle)
end
function plotNormalizedFiberLength(modeledValue, experimentalData)

figure; nplots = ceil(sqrt(experimentalData.numMuscles));
for i = 1 : experimentalData.numMuscles
    subplot(nplots,nplots,i)
    hold on
    plot(modeledValue(:,:,i),'b')
    plot(0.7*ones(1, size(modeledValue, 1)),'g','LineWidth',2)
    plot(1*ones(1, size(modeledValue, 1)),'g','LineWidth',2)
    title(strrep(experimentalData.muscleNames{i}, '_', ' '))
    axis([1 size(modeledValue, 1) 0.4 1.3])
    if i > experimentalData.numMuscles - nplots; xlabel('Time Points'); 
    else xticklabels(''); end
    if ismember(i, 1 : nplots : experimentalData.numMuscles)
        ylabel({'Normalized','Fiber Length'});
    else yticklabels(''); end
end
end
function plotPassiveMomentData(modeledValue, experimentalValue)

columnsWithAllZeros = all(experimentalValue == 0, 1);
experimentalMoments = experimentalValue(repmat(~columnsWithAllZeros, ...
    size(experimentalValue, 1), 1, 1));
passiveModelMoments = modeledValue(repmat(~columnsWithAllZeros, ...
    size(experimentalValue, 1), 1, 1));

figure; plot(passiveModelMoments, 'r', 'LineWidth', 1.25); hold on; 
plot(experimentalMoments, 'k', 'LineWidth', 1.75); 
ylabel('Passive Moments [Nm]'); xlabel('Time Points'); 
legend('Model','Experimental')
end
function plotPassiveForceData(modeledValue, experimentalData)

figure; nplots = ceil(sqrt(experimentalData.numMuscles));
for i = 1 : experimentalData.numMuscles
    subplot(nplots,nplots,i)
    hold on
    plot(modeledValue(:,:,i),'b')
    axis([1 size(modeledValue, 1) min(modeledValue,[],'all') max(modeledValue,[],'all')])
    title(strrep(experimentalData.muscleNames{i}, '_', ' '))
    if i > experimentalData.numMuscles - nplots; xlabel('Time Points'); 
    else xticklabels(''); end
    if ismember(i, 1 : nplots : experimentalData.numMuscles)
        ylabel({'Passive','Force [N]'});
    else yticklabels(''); end
end
end