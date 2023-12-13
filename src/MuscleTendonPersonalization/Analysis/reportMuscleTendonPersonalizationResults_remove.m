% This function is part of the NMSM Pipeline, see file for full license.
%
% This function writes to console or file the results of the optimization
% for easy evaluation by the user. It may require the input model to
% produce relative results or other information for output.
%
% (struct, struct) -> (None)
% Prints and plots results from muscle tendon personalization

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Di Ao, Marleny Vega                                          %
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

function reportMuscleTendonPersonalizationResults_remove(optimizedParams, ...
    mtpInputs, precalInputs)
if nargin < 3; precalInputs = []; end
[finalValues, results, resultsSynx, resultsSynxNoResiduals] = ...
    getValuesToReport(mtpInputs, precalInputs, optimizedParams);
if ~isempty(precalInputs)
    plotMuscleTendonLengthInitializationResults(precalInputs, mtpInputs)
end

printJointMomentMatchingError(resultsSynx.muscleJointMoments, ...
    mtpInputs.inverseDynamicsMoments);
makeExcitationAndActivationPlots(results, resultsSynx, mtpInputs, ...
    mtpInputs.synergyExtrapolation);
makeModelParameterPlots(finalValues, mtpInputs, ...
    mtpInputs.synergyExtrapolation)
makeTaskSpecificMomentMatchingPlots(...
    permute(resultsSynxNoResiduals.muscleJointMoments, [3 1 2]), ...
    permute(resultsSynx.muscleJointMoments, [3 1 2]), ...
    permute(mtpInputs.inverseDynamicsMoments, [3 1 2]), ...
    mtpInputs.coordinateNames, mtpInputs.synergyExtrapolation)
makeTaskSpecificNormalizedFiberLengthsPlots( ...
    permute(resultsSynx.normalizedFiberLength, [3 1 2]), ...
    mtpInputs, mtpInputs.synergyExtrapolation)
end
function [finalValues, results, resultsSynx, resultsSynxNoResiduals] = ...
    getValuesToReport(mtpInputs, precalInputs, optimizedParams)

finalValues = makeMtpValuesAsStruct([], optimizedParams, zeros(1, 7));
save('finalvalues.mat', 'finalValues')
resultsSynx = calcMtpSynXModeledValues(finalValues, mtpInputs, struct());
finalValues.synergyWeights(mtpInputs.numberOfExtrapolationWeights + 1 : end) = 0;
resultsSynxNoResiduals = calcMtpSynXModeledValues(finalValues, mtpInputs, struct());
results = calcMtpModeledValues(finalValues, mtpInputs, struct());
results.time = mtpInputs.emgTime(:, mtpInputs.numPaddingFrames + 1 : ...
    end - mtpInputs.numPaddingFrames);
results.muscleExcitations = results.muscleExcitations(:, :, ...
    mtpInputs.numPaddingFrames + 1 : end - mtpInputs.numPaddingFrames);
resultsSynx.muscleExcitations = resultsSynx.muscleExcitations(:, :, ...
    mtpInputs.numPaddingFrames + 1 : end - mtpInputs.numPaddingFrames);
if ~isempty(precalInputs)
% finalOptimalFiberLength = ...
%     finalValues.optimalFiberLengthScaleFactors .* mtpInputs.optimalFiberLength;
% finalValues.optimalFiberLengthScaleFactors = ...
%     finalOptimalFiberLength ./ precalInputs.optimalFiberLength;
% finalTendonSlackLength = ...
%     finalValues.tendonSlackLengthScaleFactors .* mtpInputs.tendonSlackLength;
% finalValues.tendonSlackLengthScaleFactors = ...
%     finalTendonSlackLength ./ precalInputs.tendonSlackLength;
end
end
function plotMuscleTendonLengthInitializationResults(precalInputs, mtpInputs)

tempValues.optimalFiberLengthScaleFactors = ...
    mtpInputs.optimalFiberLength ./ precalInputs.optimalFiberLength;
mtpInputs.optimalFiberLength
tempValues.tendonSlackLengthScaleFactors = ...
    mtpInputs.tendonSlackLength ./ precalInputs.tendonSlackLength;
precalInputs.maxIsometricForce = mtpInputs.maxIsometricForce;
precalInputs.optimizeIsometricMaxForce = 0;
modeledValues = calcMuscleTendonLengthInitializationModeledValues(tempValues, precalInputs);
plotPassiveForceData(permute(modeledValues.passiveForce, [3 1 2]), ...
    precalInputs);
if precalInputs.passiveMomentDataExists
plotPassiveMomentData(permute(modeledValues.passiveModelMoments, [3 1 2]), ...
    permute(precalInputs.passiveData.inverseDynamicsMoments, [3 1 2]), ...
    precalInputs.passivePrefixes)
end
end
function plotPassiveMomentData(modeledValue, experimentalValue, titleName)

columnsWithAllZeros = all(experimentalValue == 0, 1);
inverseDynamicsMoments = experimentalValue(repmat(~columnsWithAllZeros, ...
    size(experimentalValue, 1), 1, 1));
passiveModelMoments = modeledValue(repmat(~columnsWithAllZeros, ...
    size(experimentalValue, 1), 1, 1));

inverseDynamicsMoments = ...
    reshape(inverseDynamicsMoments, size(modeledValue, 1), []);
passiveModelMoments = ...
    reshape(passiveModelMoments, size(modeledValue, 1), []);
figure('name', 'MuscleTendonLengthInitialization Passive Moment Matching'); 
nplot = ceil(sqrt(size(passiveModelMoments, 2)));
for i = 1 : size(passiveModelMoments, 2)
subplot(nplot, nplot, i)
plot(passiveModelMoments(:, i), 'r', 'LineWidth', 1.25); hold on; 
plot(inverseDynamicsMoments(:, i), 'k', 'LineWidth', 1.75); 
if i == 1; ylabel('Passive Moments [Nm]'); 
elseif i == size(passiveModelMoments, 2); legend('Model','Experimental')
end
axis([1 size(modeledValue, 1) min([inverseDynamicsMoments; ...
    passiveModelMoments], [], 'all') max([inverseDynamicsMoments; ...
    passiveModelMoments], [],'all')])
xlabel('Time Points'); 
title(strrep(titleName{i}, '_', ' '))
end
end
function plotPassiveForceData(modeledValue, experimentalData)

meanModeledValue = squeeze(mean(modeledValue, 2));
stdModeledValue = squeeze(std(modeledValue, [], 2));
figure('name', 'MuscleTendonLengthInitialization Passive Forces'); 
nplots = ceil(sqrt(length(experimentalData.muscleNames)));

t = 1 : size(meanModeledValue, 1);
for i = 1 : size(meanModeledValue, 2)
subplot(nplots, nplots, i);
plot(meanModeledValue(:, i), 'LineWidth', 2); hold on
fill([t'; flipud(t')], ...
    [meanModeledValue(:,i) - stdModeledValue(:,i); ...
    flipud(meanModeledValue(:, i) + stdModeledValue(:, i))], ...
    'b', 'linestyle', 'None', 'FaceAlpha', 0.5);
axis([1 size(modeledValue, 1) min(modeledValue,[],'all') max(modeledValue,[],'all')])
title(strrep(experimentalData.muscleNames{i}, '_', ' '))
if i > length(experimentalData.muscleNames) - nplots; xlabel('Time Points'); 
else xticklabels(''); end
if ismember(i, 1 : nplots : length(experimentalData.muscleNames))
    ylabel({'Passive','Force [N]'});
else yticklabels(''); end
end
end
function printJointMomentMatchingError(muscleJointMoments, inverseDynamicsMoments)

for i = 1 : size(muscleJointMoments, 2)
jointMomentsRmse(i) = sqrt(sum((muscleJointMoments(:, i, :) - ...
    inverseDynamicsMoments(:, i, :)) .^ 2, 'all') / ...
    (numel(inverseDynamicsMoments(:, 1, :)) - 1));
jointMomentsMae(i) = sum(abs(muscleJointMoments(:, i, :) - ...
    inverseDynamicsMoments(:, i, :)) / ...
    numel(inverseDynamicsMoments(:, 1, :)), 'all');
end
fprintf(['The root mean sqrt (RMS) errors between model-predicted ' ...
    'and inverse dynamic moments are: \n' ]);
fprintf(['\n ' num2str(jointMomentsRmse) ' \n']);
fprintf(['The mean absolute errors (MAEs) between model-predicted ' ...
    'and inverse dynamic moments are: \n' ]);
fprintf(['\n ' num2str(jointMomentsMae) ' \n']);
end
function makeExcitationAndActivationPlots(results, resultsSynx, ...
    experimentalData, synergyParameters)

muscleLabels = getSynxMuscleNames(experimentalData.muscleNames, ...
    synergyParameters.missingEmgChannelGroups);

for i = 1 : numel(synergyParameters.taskNames)
figure('name', ['Muscle excitations/activations for ', ...
    synergyParameters.taskNames{i}]);

plotMuscleExcitationsAndActivations(...
    results.muscleExcitations(synergyParameters.trialIndex{i}, :, :), ...
    resultsSynx.muscleExcitations(synergyParameters.trialIndex{i}, :, :), ...
    results.muscleActivations(synergyParameters.trialIndex{i}, :, :), ...
    resultsSynx.muscleActivations(synergyParameters.trialIndex{i}, :, :), ...
    muscleLabels)
end
end
function plotMuscleExcitationsAndActivations(muscleExcitations, ...
    muscleExcitationsSynx, muscleActivations, muscleActivationsSynx, ...
    muscleLabels)

meanMuscleExcitation = permute(mean(muscleExcitations, 1), [3 2 1]);
stdMuscleExcitation = permute(std(muscleExcitations, [], 1), [3 2 1]);
meanMuscleExcitationSynx = permute(mean(muscleExcitationsSynx, 1), [3 2 1]);
stdMuscleExcitationSynx = permute(std(muscleExcitationsSynx, [], 1), [3 2 1]);
meanMuscleActivation = permute(mean(muscleActivations, 1), [3 2 1]);
stdMuscleActivation = permute(std(muscleActivations, [], 1), [3 2 1]);
meanMuscleActivationSynx = permute(mean(muscleActivationsSynx, 1), [3 2 1]);
stdMuscleActivationSynx = permute(std(muscleActivationsSynx, [], 1), [3 2 1]);

t = 1 : size(meanMuscleExcitation, 1);
nplot = ceil(sqrt(numel(muscleLabels)));
for j = 1 : numel(muscleLabels)
    subplot(nplot,nplot,j);
    plot(meanMuscleExcitation(:, j), 'b-', 'LineWidth', 2); hold on
    fill([t'; flipud(t')], ...
    [meanMuscleExcitation(:, j) - stdMuscleExcitation(:, j); ...
    flipud(meanMuscleExcitation(:, j) + stdMuscleExcitation(:, j))], ...
    'b', 'linestyle', 'None', 'FaceAlpha', 0.5);
    hold on
    plot(meanMuscleExcitationSynx(:, j), 'b--', 'LineWidth', 2); hold on
    fill([t'; flipud(t')], ...
    [meanMuscleExcitationSynx(:, j) - stdMuscleExcitationSynx(:, j); ...
    flipud(meanMuscleExcitationSynx(:, j) + stdMuscleExcitationSynx(:, j))], ...
    'b', 'linestyle', 'None', 'FaceAlpha', 0.3);
    plot(meanMuscleActivation(:, j), 'r-', 'LineWidth', 2); hold on
    fill([t'; flipud(t')], ...
    [meanMuscleActivation(:, j) - stdMuscleActivation(:, j); ...
    flipud(meanMuscleActivation(:, j) + stdMuscleActivation(:, j))], ...
    'r', 'linestyle', 'None', 'FaceAlpha', 0.5);
    plot(meanMuscleActivationSynx(:, j), 'r--', 'LineWidth', 2); hold on
    fill([t'; flipud(t')], ...
    [meanMuscleActivationSynx(:, j) - stdMuscleActivationSynx(:, j); ...
    flipud(meanMuscleActivationSynx(:, j) + stdMuscleActivationSynx(:, j))], ...
    'r', 'linestyle', 'None', 'FaceAlpha', 0.3);
    axis([1 size(meanMuscleExcitation, 1) 0 1])
    title(muscleLabels{j});
    if j == 1
        legend ('Excitation(without residual)', '', ...
            'Excitation(with residual)', '', ...
            'Activation(without residual)', '', ...
            'Activation(with residual)', '');
    end
end
set(gca, 'FontSize', 12)
end
function makeModelParameterPlots(finalValues, experimentalData, synergyParameters)

muscleLabels = getSynxMuscleNames(experimentalData.muscleNames, ...
    synergyParameters.missingEmgChannelGroups);

In_width = 0.145; % witdth of each subplot
figure('name', 'Model Parameters', 'units', 'normalized', ...
    'outerposition', [0 0 1 1]);
for subplotElement = 1 : 6
    subplotTight(1, 6, subplotElement, [0.04, 0.001]);
    switch subplotElement 
        case 1 %activationTimeConstant
            bar(1 : numel(muscleLabels), finalValues.activationTimeConstants, ...
                'barwidth', 0.8, 'Horizontal', 'on', 'FaceAlpha', 0.6); 
            hold on;
            title('Activation Time Constant (cs)')
            pos_in = get(gca, 'Position');
            pos_in(3) = In_width;
            pos_in(1) = pos_in(1) + 0.05;
            set(gca, 'YTick', 1 : numel(muscleLabels), 'yTickLabel', ...
                muscleLabels, 'Fontsize', 11, 'Position', pos_in);
        case 2 %activationNonlinearity
            bar(finalValues.activationNonlinearityConstants, 'Horizontal', 'on', ...
                'barwidth', 0.8, 'FaceAlpha', 0.6);
            title('Activation Nonlinearity')
            pos_in(1) = pos_in(1) + pos_in(3) + 0.015;
            set(gca, 'YTick', [], 'yTickLabel', [], 'Position', pos_in, ...
                'Fontsize', 11);
        case 3 %timeDelay
            bar(finalValues.electromechanicalDelays, 'Horizontal', 'on', 'barwidth', 0.8, ...
                'FaceAlpha', 0.6);
            title('Electromechanical Time Delay (ds)')
            pos_in(1) = pos_in(1) + pos_in(3) + 0.015;
            set(gca, 'YTick', [], 'yTickLabel', [],'Position', pos_in, ...
                'Fontsize', 11);
        case 4 % emgScalingFactor
            bar(finalValues.emgScaleFactors, 'Horizontal', 'on', 'barwidth', 0.8, ...
                'FaceAlpha', 0.6);
            title('Emg Scaling Factor')
            pos_in(1) = pos_in(1) + pos_in(3) + 0.015;
            set(gca, 'YTick', [], 'yTickLabel', [],'Position', pos_in, ...
                'Fontsize', 11);
        case 5 %muscleOptimalLength
            bar(finalValues.optimalFiberLengthScaleFactors, 'Horizontal', 'on', 'barwidth', ...
                0.8, 'FaceAlpha', 0.6);
            title('Optimal Fiber Length Scaling Factor')
            pos_in(1) = pos_in(1) + pos_in(3) + 0.015;
            set(gca, 'YTick', [], 'yTickLabel', [],'Position', pos_in, ...
                'Fontsize', 11);
        case 6 %tendonSlackLength            
            bar(finalValues.tendonSlackLengthScaleFactors, 'Horizontal', 'on', 'barwidth', ...
                0.8, 'FaceAlpha', 0.6);
            title('Tendon Slack Length Scaling Factor')
            pos_in(1) = pos_in(1) + pos_in(3) + 0.015;
            set(gca, 'YTick', [], 'yTickLabel', [],'Position', pos_in, ...
                'Fontsize', 11);
    end
end
end
function vargout=subplotTight(m, n, p, margins, varargin)
%% Default params
isWrapper=false;
if (nargin<4) || isempty(margins)
    margins=[0.04, 0.04]; % default margins value- 4% of figure
end
if length(margins)==1
    margins(2)=margins;
end

%note n and m are switched as Matlab indexing is column-wise, while subplot indexing is row-wise :(
[subplot_col, subplot_row] = ind2sub([n, m], p);

height = (1 - (m + 1) * margins(1)) / m; % single subplot height
width = (1 - (n + 1) * margins(2)) / n;  % single subplot width

% note subplot suppors vector p inputs- so a merged subplot of higher dimentions will be created
subplotColumns = 1 + max(subplot_col) - min(subplot_col); % number of column elements in merged subplot
subplotRows = 1 + max(subplot_row) - min(subplot_row); % number of row elements in merged subplot

mergedHeight = subplotRows * (height + margins(1)) - margins(1);   % merged subplot height
mergedWidth = subplotColumns * (width + margins(2)) - margins(2);   % merged subplot width

mergedBottom = (m - max(subplot_row)) * (height + margins(1)) + margins(1); % merged subplot bottom position
mergedLeft = min(subplot_col) * (width + margins(2)) - width;              % merged subplot left position
pos = [mergedLeft, mergedBottom, mergedWidth, mergedHeight];


if isWrapper
    h=subplot(m, n, p, varargin{:}, 'Units', 'Normalized', 'Position', pos);
else
    h=axes('Position', pos, varargin{:});
end

if nargout == 1;vargout=h; end
end
function makeTaskSpecificMomentMatchingPlots(jointMoments, jointMomentsSynx, ...
    inverseDynamicsMoments, coordinates, synergyParameters)

t = 1 : size(jointMoments,1);
for i = 1 : numel(synergyParameters.taskNames)
figure('name', ['Joint moments for ', synergyParameters.taskNames{i}]);
plotJointMoments(jointMoments(:, synergyParameters.trialIndex{i}, :), ...
    inverseDynamicsMoments(:, synergyParameters.trialIndex{i}, :), ...
    synergyParameters.taskNames{i}, coordinates, 0,...
    {'','Predicted (w/o residual excitations)','','Inverse dynamics'});
plotJointMoments(jointMomentsSynx(:, synergyParameters.trialIndex{i}, :), ...
    inverseDynamicsMoments(:, synergyParameters.trialIndex{i}, :), ...
    synergyParameters.taskNames{i}, coordinates, numel(coordinates), ...
    {'','Predicted (with residual excitations)','','Inverse dynamics'});
end
end
function plotJointMoments(jointMoments, inverseDynamicsMoments, taskName, ...
    coordinates, subplotIndex, legendName)

meanJointMoments = squeeze(mean(jointMoments, 2));
stdJointMoments = squeeze(std(jointMoments, [], 2));
meaninverseDynamicsMoments = squeeze(mean(inverseDynamicsMoments, 2));
stdinverseDynamicsMoments = squeeze(std(inverseDynamicsMoments, [], 2));
t = 1 : size(jointMoments,1);
for j = 1:size(jointMoments,3)
subplot(2, size(jointMoments, 3), j + subplotIndex);
plot(-meanJointMoments(:, j), 'r', 'LineWidth', 2); hold on
fill([t'; flipud(t')], ...
    [-meanJointMoments(:,j) - stdJointMoments(:,j); ...
    flipud(-meanJointMoments(:, j) + stdJointMoments(:, j))], ...
    'r', 'linestyle', 'None', 'FaceAlpha', 0.5);
subplot(2, size(jointMoments, 3), j + subplotIndex); 
plot(-meaninverseDynamicsMoments(:, j), 'k', 'LineWidth', 2);
fill([t'; flipud(t')], ...
    [-meaninverseDynamicsMoments(:, j) - stdinverseDynamicsMoments(:, j); ...
    flipud(-meaninverseDynamicsMoments(:, j) + stdinverseDynamicsMoments(:, j))], ...
    'k', 'linestyle', 'None', 'FaceAlpha', 0.5);
title({taskName, [strrep(coordinates{j}, '_', ' ') ],'Moment (N-m)'});
xlabel('Time Frames'); axis([0 100 -80 120]);
if j == 1; ylabel('Moment (N-m)');
elseif j == numel(coordinates)
    lgd = legend(legendName);
    lgd.Orientation ='horizontal';
    lgd.NumColumns = 2;
end
set(gca, 'FontSize', 12)
end
end
function makeTaskSpecificNormalizedFiberLengthsPlots(...
    normalizedFiberLengths, experimentalData, synergyParameters)

muscleLabels = getSynxMuscleNames(experimentalData.muscleNames, ...
    synergyParameters.missingEmgChannelGroups);

for i = 1 : numel(synergyParameters.taskNames)
figure('name', ['Normalized Fiber Lengths for ', ...
    synergyParameters.taskNames{i}]);

plotNormalizedFiberLength(normalizedFiberLengths(:, ...
    synergyParameters.trialIndex{i}, :), muscleLabels)
end
end
function plotNormalizedFiberLength(normalizedFiberLengths, ...
    muscleLabels)

nplots = ceil(sqrt(numel(muscleLabels)));
meanNormalizedFiberLengths = squeeze(mean(normalizedFiberLengths, 2));
stdNormalizedFiberLengths = squeeze(std(normalizedFiberLengths, [], 2));
t = 1 : size(normalizedFiberLengths,1);
for i = 1 : numel(muscleLabels)
    subplot(nplots,nplots,i)
    hold on
    plot(meanNormalizedFiberLengths(:, i), 'b', 'LineWidth', 2); hold on
    fill([t'; flipud(t')], ...
        [meanNormalizedFiberLengths(:, i) - stdNormalizedFiberLengths(:, i); ...
        flipud(meanNormalizedFiberLengths(:, i) + stdNormalizedFiberLengths(:, i))], ...
        'b', 'linestyle', 'None', 'FaceAlpha', 0.3);
    plot(0.7*ones(1, size(normalizedFiberLengths, 1)),'r--','LineWidth',2)
    plot(1*ones(1, size(normalizedFiberLengths, 1)),'r--','LineWidth',2)
    title(muscleLabels{i})
    axis([1 size(normalizedFiberLengths, 1) 0 1.5])
    if i > numel(muscleLabels) - nplots; xlabel('Time Points'); 
    else xticklabels(''); end
    if ismember(i, 1 : nplots : numel(muscleLabels))
        ylabel({'Normalized','Fiber Length'});
    else yticklabels(''); end
end
end
function muscleLabels = getSynxMuscleNames(muscleNames, ...
    missingEmgChannelGroups)

for i = 1 : numel(muscleNames)
    if ismember(i, [missingEmgChannelGroups{:}])
        muscleLabels{i} = [muscleNames{i} '(*)'];
    else
        muscleLabels{i} = muscleNames{i};
    end
end
end