
% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates extract muscle synergy excitations from measured %
% muscle excitations for both synX and residual excitation construction     %
%
% data:
%   extrapolationCommands - synergy excitations extracted from measured muscle excitations
%   params.numberOfSynergies - number of synergies - double
%   size(emgData,2) - number of trials in total - double
%   params.numberOfMeasuredEmgChannels - number of measured EMG channels in total - double
%   length(params.taskNames) -  number of tasks - double
%   size(emgData,1) - number of time frames for each trial - double
%   params.matrixFactorizationMethod - matrix factorization algorithm - 'PCA' or 'NMF'
%   SynXCategory - variability of synergy vector weights across trials for
%                  SynX reconstruction
%   params.residualCategorization  - variability of synergy vector weights across trials for
%                  residual excitation reconstruction
%   TrialIndex - trial index for each task - cell array (nTask cells)
%   emgData - Processed EMG signals (normalized to the maximum values over
%                   all trials)
%
% returns measured synergy excitations for constructing SynX and residual 
% muscle excitations.
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

function [extrapolationCommands, residualCommands] = ...
    getSynergyCommands(emgData, numberOfSynergies, ...
    matrixFactorizationMethod, synergyCategorizationOfTrials, ...
    residualCategorizationOfTrials) 

%--Normalize EMGs 
maxEmgOverAllTrials = max(max(emgData, [], 3), [], 1);
normalizedEMG = permute(emgData ./ maxEmgOverAllTrials, [3 2 1]);
%--Extract synergy excitations from measured muscle excitations 
if strcmpi(matrixFactorizationMethod, 'PCA')
    extrapolationCommands = getPcaCommands(normalizedEMG, numberOfSynergies, ...
        synergyCategorizationOfTrials);
    residualCommands = getPcaCommands(normalizedEMG, numberOfSynergies, ...
        residualCategorizationOfTrials);
elseif strcmpi(matrixFactorizationMethod, 'NMF')
    options = statset('Display', 'off', 'TolX', 1e-10, 'TolFun', 1e-10);
    if  ~exist('nmfResultsSynX.mat')
        extrapolationCommands = getNmfCommands(normalizedEMG, numberOfSynergies, ...
            synergyCategorizationOfTrials, options);
        residualCommands = getNmfCommands(normalizedEMG, numberOfSynergies, ...
            residualCategorizationOfTrials, options);
        save('nmfResultsSynX.mat','extrapolationCommands', 'residualCommands');
    else
        load('nmfResultsSynX.mat');
    end
end
end
function nmfCommands = getNmfCommands(normalizedEMG, ...
    numberOfSynergies, categorizationOfTrials, options)

for i = 1 : length(categorizationOfTrials)
    [nmfCommands{i}, nmfWeight] = nnmf(reshape(normalizedEMG(:, :, ...
        categorizationOfTrials{i}), size(normalizedEMG, 1) * ...
        size(categorizationOfTrials{i}, 2), size(normalizedEMG, 2)), ...
        numberOfSynergies, 'replicates', 20, 'algorithm', 'mult', ...
        'options', options);
    nmfCommands{i} = reshape(nmfCommands{i}, size(normalizedEMG, 1), ...
        size(categorizationOfTrials{i}, 2), numberOfSynergies);
for k = 1 : size(categorizationOfTrials{i}, 2)
for j = 1 : numberOfSynergies
    nmfCommands{i}(:, k, j) = spline(linspace(1, size(normalizedEMG, ...
        1), 21), nmfCommands{i}(1 : (size(normalizedEMG, 1) - 1)/(21 - ...
        1) : end, k, j), 1 : size(normalizedEMG, 1));
end
end
nmfCommands{i} = reshape(nmfCommands{i}, size(normalizedEMG, ...
    1) * size(categorizationOfTrials{i}, 2), numberOfSynergies);
NormFactor = sum(nmfWeight, 2);
nmfCommands{i} = nmfCommands{i} .* NormFactor';
end
end

function pcaCommands = getPcaCommands(normalizedEMG, numberOfSynergies, ...
    categorizationOfTrials)

for i = 1 : length(categorizationOfTrials)
    [~, principleComponents] = pca(reshape(permute(normalizedEMG(:, :, ...
        categorizationOfTrials{i}), [1 3 2]), size(normalizedEMG, 1) * ...
        size(categorizationOfTrials{i}, 2), size(normalizedEMG, 2)));
    pcaCommands{i} = principleComponents(:, (1 : numberOfSynergies));
end
end