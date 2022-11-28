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

function reportMuscleTendonPersonalizationResults(resultsSynx, results, finalValues, experimentalData, params)

lowerBounds = makeLowerBounds(experimentalData, params);
upperBounds = makeUpperBounds(experimentalData, params);

Tasks = {'0pt5','0pt8'};
nTasks = 2;
TrialIndex = {[1 2], [3 4]};
SynXMuscIndex = [experimentalData.synergyExtrapolation.missingEmgChannelPairs{:}];
printJointMomentMatchingError(resultsSynx.muscleJointMoments, ...
    experimentalData.experimentalMoments);
makeExcitationAndActivationPlots(results.muscleExcitations, ...
    resultsSynx.muscleExcitations,...
    results.muscleActivations, resultsSynx.muscleActivations, ...
    experimentalData.muscleNames, Tasks, nTasks,...
    TrialIndex, SynXMuscIndex)
makeModelParameterPlots(finalValues.electromechanicalDelays, finalValues.emgScaleFactors,...
    finalValues.activationTimeConstants, finalValues.activationNonlinearityConstants, ...
    finalValues.optimalFiberLengthScaleFactors, finalValues.tendonSlackLengthScaleFactors,...
    experimentalData.muscleNames, SynXMuscIndex, upperBounds, lowerBounds)
makeTaskSpecificMomentMatchingPlots(permute(results.muscleJointMoments, [3 1 2]), ...
    permute(resultsSynx.muscleJointMoments, [3 1 2]), ...
    permute(experimentalData.experimentalMoments, [3 1 2]), ...
    experimentalData.coordinates, experimentalData.synergyExtrapolation)
makeTaskSpecificNormalizedFiberLengthsPlots( ...
    permute(resultsSynx.normalizedFiberLength, [3 1 2]), ...
    experimentalData, experimentalData.synergyExtrapolation)
end
function printJointMomentMatchingError(muscleJointMoments, experimentalMoments)

for i = 1 : size(muscleJointMoments, 2)
jointMomentsRmse(i) = sqrt(sum((muscleJointMoments(:, i, :) - ...
    experimentalMoments(:, i, :)) .^ 2, 'all') / ...
    (numel(experimentalMoments(:, 1, :)) - 1));
jointMomentsMae(i) = sum(abs(muscleJointMoments(:, i, :) - ...
    experimentalMoments(:, i, :)) / ...
    numel(experimentalMoments(:, 1, :)), 'all');
end
fprintf(['The root mean sqrt (RMS) errors between model-predicted ' ...
    'and inverse dynamic moments are: \n' ]);
fprintf(['\n ' num2str(jointMomentsRmse) ' \n']);
fprintf(['The mean absolute errors (MAEs) between model-predicted ' ...
    'and inverse dynamic moments are: \n' ]);
fprintf(['\n ' num2str(jointMomentsMae) ' \n']);
end

function makeExcitationAndActivationPlots(muscleExcitations,muscleExcitationsResiduals,...
    muscleActivations,muscleActivationsResiduals, muscLabels,Tasks, nTasks,...
    TrialIndex,SynXMuscIndex)

nMusc = size(muscleExcitations,2);
nplot = ceil(sqrt(nMusc));

for i = 1 : nMusc
    if ismember(i,SynXMuscIndex)
        muscLabels{i} = [muscLabels{i} '(*)'];
    else
        muscLabels{i} = muscLabels{i};
    end
end

for i = 1:nTasks
    figure('name', ['Muscle excitations/activations for ', Tasks{i}], 'units','normalized','outerposition',[0 0 1 1]);
    
    ExcitationMeans = permute(mean(muscleExcitations(TrialIndex{i},:,21:121),1),[3 2 1]);
    ExcitationMeanswithResidual = permute(mean(muscleExcitationsResiduals(TrialIndex{i},:,21:121),1),[3 2 1]);
    aMeans = permute(mean(muscleActivations(TrialIndex{i},:,:),1),[3 2 1]);
    aMeanswithResidual = permute(mean(muscleActivationsResiduals(TrialIndex{i},:,:),1),[3 2 1]);
    
    for j = 1:nMusc
        subplot(nplot,nplot,j), plot(0:100,ExcitationMeans(:,j),'b-','LineWidth',2);
        hold on
        subplot(nplot,nplot,j), plot(0:100,ExcitationMeanswithResidual(:,j),'b--','LineWidth',1);
        subplot(nplot,nplot,j), plot(0:100,aMeans(:,j),'r-','LineWidth',2);
        subplot(nplot,nplot,j), plot(0:100,aMeanswithResidual(:,j),'r--','LineWidth',1);
        axis([0 100 0 1])
        title([muscLabels{j}]);
        if j == 1
            legend ('Excitation(without residual)','Excitation(with residual)',...
                'Activation(without residual)','Activation(with residual)');
        end
    end
    set(gca, 'FontSize', 12)
end
end

function makeModelParameterPlots(timeDelay, emgScalingFactor,...
    activationTimeConstant, activationNonlinearity, ...
    muscleOptimalLength, tendonSlackLength,...
    muscLabels, SynXMuscIndex, upperBoundStruct, lowerBoundStruct)

nMusc = size(muscleOptimalLength,2);

for i = 1 : nMusc
    muscLabels{i} = strrep(muscLabels{i},'_r','');
    muscLabels{i} = strrep(muscLabels{i},'_l','');
    
    if ismember(i,SynXMuscIndex)
         muscLabels{i} = [muscLabels{i} '(*)'];
    else
         muscLabels{i} = muscLabels{i};
    end    
end

In_width = 0.145; % witdth of each subplot
fig = figure('units','normalized','outerposition',[0 0 1 1]);
for iElem=1:6
    subplot_tight(1, 6, iElem, [0.04,0.001]);
    switch iElem 
        case 1 %activationTimeConstant
            bar(1:nMusc,activationTimeConstant,'barwidth',0.8, 'Horizontal','on','FaceAlpha',0.6); hold on
            set(gca, 'YTick', 1:nMusc, 'yTickLabel', muscLabels);
            set(gca, 'XTick', linspace(0,round(upperBoundStruct{2},4),2));
            set(gca, 'Fontsize', 11);
            title('activationTimeConstant')
            xlim([0 upperBoundStruct{2}*1.1]);
            ylim([0 nMusc+1]);
            pos_in = get(gca, 'Position');
            pos_in(3) = In_width;
            pos_in(1) = pos_in(1)+0.05;
            set(gca,'Position',pos_in);
            xtickangle(45)
            line([lowerBoundStruct{2} lowerBoundStruct{2}],...
                [0 nMusc+1],'Color',[.8 0 .4],'LineStyle','-.','LineWidth', 2);
            line([upperBoundStruct{2} upperBoundStruct{2}],...
                [0 nMusc+1],'Color',[.8 0 .4],'LineStyle','-.','LineWidth', 2);            
            
        case 2 %activationNonlinearity
            bar(activationNonlinearity, 'Horizontal','on','barwidth',0.8,'FaceAlpha',0.6);
            set(gca, 'YTick', [], 'yTickLabel', []);
            set(gca, 'XTick', linspace(0,round(upperBoundStruct{3},4),2));
            title('activationNonlinearity')
            xlim([0 upperBoundStruct{3}*1.1]);
            ylim([0 nMusc+1]);
            pos_in(1) = pos_in(1)+pos_in(3)+0.015;
            set(gca,'Position',pos_in);
            set(gca, 'Fontsize', 11);
            xtickangle(45)
            line([lowerBoundStruct{3} lowerBoundStruct{3}],...
                [0 nMusc+1],'Color',[.8 0 .4],'LineStyle','-.','LineWidth', 2);
            line([upperBoundStruct{3} upperBoundStruct{3}],...
                [0 nMusc+1],'Color',[.8 0 .4],'LineStyle','-.','LineWidth', 2);
                        
        case 3 %timeDelay
            bar(timeDelay, 'Horizontal','on','barwidth',0.8,'FaceAlpha',0.6);
            set(gca, 'YTick', [], 'yTickLabel', []);
            set(gca, 'XTick', linspace(0,round(upperBoundStruct{1},4),2));
            title('timeDelay')
            xlim([0 upperBoundStruct{1}*1.1]);
            ylim([0 nMusc+1]);
            pos_in(1) = pos_in(1)+pos_in(3)+0.015;
            set(gca,'Position',pos_in);
            set(gca, 'Fontsize', 11);
            xtickangle(45)
            line([lowerBoundStruct{1} lowerBoundStruct{1}],...
                [0 nMusc+1],'Color',[.8 0 .4],'LineStyle','-.','LineWidth', 2);
            line([upperBoundStruct{1} upperBoundStruct{1}],...
                [0 nMusc+1],'Color',[.8 0 .4],'LineStyle','-.','LineWidth', 2);
                        
        case 4 % emgScalingFactor
            bar(emgScalingFactor, 'Horizontal','on','barwidth',0.8,'FaceAlpha',0.6);
            set(gca, 'YTick', [], 'yTickLabel', []);
            set(gca, 'XTick', linspace(0,round(upperBoundStruct{4},4),2));
            set(gca, 'Fontsize', 11);
            title('emgScalingFactor')
            xlim([0 upperBoundStruct{4}*1.1])
            ylim([0 nMusc+1]);
            pos_in(1) = pos_in(1)+pos_in(3)+0.015;
            set(gca,'Position',pos_in);
            xtickangle(45)
            line([lowerBoundStruct{4} lowerBoundStruct{4}],...
                [0 nMusc+1],'Color',[.8 0 .4],'LineStyle','-.','LineWidth', 2);
            line([upperBoundStruct{4} upperBoundStruct{4}],...
                [0 nMusc+1],'Color',[.8 0 .4],'LineStyle','-.','LineWidth', 2);
            
        case 5 %muscleOptimalLength
            bar(muscleOptimalLength, 'Horizontal','on','barwidth',0.8,'FaceAlpha',0.6);
            set(gca, 'YTick', [], 'yTickLabel', []);
            set(gca, 'XTick', linspace(0,round(upperBoundStruct{5},4),2));
            set(gca, 'Fontsize', 11);
            title('muscleOptimalLength (m)')
            xlim([0 upperBoundStruct{5}*1.1])
            ylim([0 nMusc+1]);
            pos_in(1) = pos_in(1)+pos_in(3)+0.015;
            set(gca,'Position',pos_in);
            xtickangle(45)
            line([lowerBoundStruct{5} lowerBoundStruct{5}],...
                [0 nMusc+1],'Color',[.8 0 .4],'LineStyle','-.','LineWidth', 2);
            line([upperBoundStruct{5} upperBoundStruct{5}],...
                [0 nMusc+1],'Color',[.8 0 .4],'LineStyle','-.','LineWidth', 2);
        case 6 %tendonSlackLength            
            bar(tendonSlackLength, 'Horizontal','on','barwidth',0.8,'FaceAlpha',0.6);
            set(gca, 'YTick', [], 'yTickLabel', []);
            set(gca, 'XTick', linspace(0,round(upperBoundStruct{6},4),2));
            set(gca, 'Fontsize', 11);
            title('tendonSlackLength (m)')
            xlim([0 upperBoundStruct{6}*1.1])
            ylim([0 nMusc+1]);
            pos_in(1) = pos_in(1)+pos_in(3)+0.015;
            set(gca,'Position',pos_in);
            xtickangle(45)
            line([lowerBoundStruct{6} lowerBoundStruct{6}],...
                [0 nMusc+1],'Color',[.8 0 .4],'LineStyle','-.','LineWidth', 2);
            line([upperBoundStruct{6} upperBoundStruct{6}],...
                [0 nMusc+1],'Color',[.8 0 .4],'LineStyle','-.','LineWidth', 2);
    end
end
end

function vargout=subplot_tight(m, n, p, margins, varargin)
%% Default params
isWrapper=false;
if (nargin<4) || isempty(margins)
    margins=[0.04,0.04]; % default margins value- 4% of figure
end
if length(margins)==1
    margins(2)=margins;
end

%note n and m are switched as Matlab indexing is column-wise, while subplot indexing is row-wise :(
[subplot_col,subplot_row]=ind2sub([n,m],p);


height=(1-(m+1)*margins(1))/m; % single subplot height
width=(1-(n+1)*margins(2))/n;  % single subplot width

% note subplot suppors vector p inputs- so a merged subplot of higher dimentions will be created
subplot_cols=1+max(subplot_col)-min(subplot_col); % number of column elements in merged subplot
subplot_rows=1+max(subplot_row)-min(subplot_row); % number of row elements in merged subplot

merged_height=subplot_rows*( height+margins(1) )- margins(1);   % merged subplot height
merged_width= subplot_cols*( width +margins(2) )- margins(2);   % merged subplot width

merged_bottom=(m-max(subplot_row))*(height+margins(1)) +margins(1); % merged subplot bottom position
merged_left=min(subplot_col)*(width+margins(2))-width;              % merged subplot left position
pos=[merged_left, merged_bottom, merged_width, merged_height];


if isWrapper
    h=subplot(m, n, p, varargin{:}, 'Units', 'Normalized', 'Position', pos);
else
    h=axes('Position', pos, varargin{:});
end

if nargout==1
    vargout=h;
end
end
function lowerBounds = makeLowerBounds(inputs, params)
if isfield(params, 'lowerBounds')
    lowerBounds = params.lowerBounds;
else
    numMuscles = 1;
    lowerBounds{1} = repmat(0.0, 1, numMuscles); % electromechanical delay
    lowerBounds{2} = repmat(0.75, 1, numMuscles); % activation time
    lowerBounds{3} = repmat(0.0, 1, numMuscles); % activation nonlinearity
    lowerBounds{4} = repmat(0.05, 1, numMuscles); % EMG scale factors
    lowerBounds{5} = repmat(0.6, 1, numMuscles); % optimal fiber length scale factor
    lowerBounds{6} = repmat(0.6, 1, numMuscles); % tendon slack length scale factor
    lowerBounds{7} = repmat(-100, 1, inputs.numberOfExtrapolationWeights + ...
        inputs.numberOfResidualWeights); % synergy commands
end
end

% (struct, struct) -> (6 x numEnabledMuscles matrix of number)
function upperBounds = makeUpperBounds(inputs, params)
if isfield(params, 'upperBounds')
    upperBounds = params.upperBounds;
else
    numMuscles = 1;
    upperBounds{1} = repmat(1.25, 1, numMuscles); % electromechanical delay
    upperBounds{2} = repmat(3.5, 1, numMuscles); % activation time
    upperBounds{3} = repmat(0.35, 1, numMuscles); % activation nonlinearity
    upperBounds{4} = repmat(1, 1, numMuscles); % EMG scale factors
    upperBounds{5} = repmat(1.4, 1, numMuscles); % optimal fiber length scale factor
    upperBounds{6} = repmat(1.4, 1, numMuscles); % tendon slack length scale factor
    upperBounds{7} = repmat(100, 1, inputs.numberOfExtrapolationWeights + ...
        inputs.numberOfResidualWeights); % synergy commands    
end
end

function makeTaskSpecificMomentMatchingPlots(jointMoments, jointMomentsSynx, ...
    experimentalMoments, coordinates, synergyParameters)

t = 1 : size(jointMoments,1);
for i = 1 : numel(synergyParameters.taskNames)
figure('name', ['Joint moments for ', synergyParameters.taskNames{i}]);
plotJointMoments(jointMoments(:, synergyParameters.trialIndex{i}, :), ...
    experimentalMoments(:, synergyParameters.trialIndex{i}, :), ...
    synergyParameters.taskNames{i}, coordinates, 0,...
    {'','Predicted (w/o residual excitations)','','Inverse dynamics'});
plotJointMoments(jointMomentsSynx(:, synergyParameters.trialIndex{i}, :), ...
    experimentalMoments(:, synergyParameters.trialIndex{i}, :), ...
    synergyParameters.taskNames{i}, coordinates, numel(coordinates), ...
    {'','Predicted (with residual excitations)','','Inverse dynamics'});
end
end
function plotJointMoments(jointMoments, experimentalMoments, taskName, ...
    coordinates, subplotIndex, legendName)

meanJointMoments = squeeze(mean(jointMoments, 2));
stdJointMoments = squeeze(std(jointMoments, [], 2));
meanExperimentalMoments = squeeze(mean(experimentalMoments, 2));
stdExperimentalMoments = squeeze(std(experimentalMoments, [], 2));
t = 1 : size(jointMoments,1);
for j = 1:size(jointMoments,3)
subplot(2, size(jointMoments, 3), j + subplotIndex);
plot(-meanJointMoments(:, j), 'r', 'LineWidth', 2); hold on
fill([t'; flipud(t')], ...
    [-meanJointMoments(:,j) - stdJointMoments(:,j); ...
    flipud(-meanJointMoments(:, j) + stdJointMoments(:, j))], ...
    'r', 'linestyle', 'None', 'FaceAlpha', 0.5);
subplot(2, size(jointMoments, 3), j + subplotIndex); 
plot(-meanExperimentalMoments(:, j), 'k', 'LineWidth', 2);
fill([t'; flipud(t')], ...
    [-meanExperimentalMoments(:, j) - stdExperimentalMoments(:, j); ...
    flipud(-meanExperimentalMoments(:, j) + stdExperimentalMoments(:, j))], ...
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
    synergyParameters.missingEmgChannelPairs);

for i = 1 : numel(synergyParameters.taskNames)
figure('name', ['Normalized Fiber Lengths for ', ...
    synergyParameters.taskNames{i}]);

plotNormalizedFiberLength(normalizedFiberLengths(:, ...
    synergyParameters.trialIndex{i}, :), muscleLabels)
end
end
function plotNormalizedFiberLength(normalizedFiberLengths, ...
    muscleLabels)

nplot = ceil(sqrt(numel(muscleLabels)));
subplot(nplot, nplot + 2, [1 : (nplot + 2) : (nplot + 2) * ...
    (nplot - 1) + 1, 2 : (nplot + 2) : (nplot + 2) * (nplot - 1) + 2])
boxplot(reshape(normalizedFiberLengths, [], numel(muscleLabels)), ...
    'orientation', 'horizontal','Whisker', 2); hold on
set(gca, 'YTick', 1 : numel(muscleLabels), 'yTickLabel', muscleLabels, ...
 'XTick', 0.1 : 0.4 : 1.4, 'xTickLabel', {'0.1', '0.5', '0.9', '1.3'});
set(gca, 'Fontsize', 11);
title('Normalized Fiber Length'); 
ylim([0 numel(muscleLabels) + 1]); 
xlim([0 1.4]);
line([1 1], [0 numel(muscleLabels) + 1], 'Color','red','LineStyle','--');
xtickangle(45)
for j = 1 : numel(muscleLabels)
if mod(j, nplot)
    subplot(nplot, nplot + 2, (nplot + 2) * floor(j / nplot) + ...
        mod(j, nplot) + 2)
else
    subplot(nplot, nplot + 2, (nplot + 2) * (floor(j / nplot) - ...
        1) + nplot + 2)
end
plot(0 : 100, squeeze(mean(normalizedFiberLengths(:, :, j), 2)), ...
    'b-', 'LineWidth', 2); hold on; 
plot([0 100], [1 1], 'r--', 'LineWidth', 1);
axis([0 100 0 1.5]); 
title([muscleLabels{j}]);
if j > numel(muscleLabels) - nplot; xlabel('Time Points'); 
else xticklabels(''); end
if ~ismember(j, 1 : nplot : numel(muscleLabels)); yticklabels(''); end
set(gca, 'FontSize', 10); 
end
end
function muscleLabels = getSynxMuscleNames(muscleNames, ...
    missingEmgChannelPairs)

for i = 1 : numel(muscleNames)
    if ismember(i, [missingEmgChannelPairs{:}])
        muscleLabels{i} = [muscleNames{i} '(*)'];
    else
        muscleLabels{i} = muscleNames{i};
    end
end
end