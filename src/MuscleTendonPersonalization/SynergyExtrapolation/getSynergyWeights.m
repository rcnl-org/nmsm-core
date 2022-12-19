% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns the vector of SynX variables (including both SynX
%   and residual vector weights)
%
% data:
%   nSynX - number of synergies - double
%   nTrials - number of trials in total - double
%   nSynXEMG - number of SynX EMG channels in total - double
%   nMeasuredEMG - number of measured EMG channels in total - double
%   nTasks -  number of tasks - double
%   SynXalgorithm - matrix factorization algorithm - 'PCA' or 'NMF'
%   SynXCategory - variability of synergy vector weights across trials for
%     SynX reconstruction
%   ResiduakCategory  - variability of synergy vector weights across 
%     trials for residual excitation reconstruction
%
% returns linear inequality constraints A and b for optimization using
% fmincon

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

function [synergyWeights, numberOfExtrapolationWeights, ...
    numberOfResidualWeights] = getSynergyWeights(params, numberOfTrials, ...
    numberOfMeasuredEmgChannels, numberOfUnmeasuredEmgChannels)

% Construct variable vector for SynX
extrapolationWeights = getSizeMatrix(params.synergyExtrapolationCategorization, ...
    params.matrixFactorizationMethod, params.numberOfSynergies, ...
    numberOfUnmeasuredEmgChannels, length(params.taskNames), numberOfTrials);
% Construct variable vector for residual excitations
residualWeights = getSizeMatrix(params.residualCategorization, ...
    params.matrixFactorizationMethod, params.numberOfSynergies, ...
    numberOfMeasuredEmgChannels, length(params.taskNames), numberOfTrials);
synergyWeights= [extrapolationWeights(:)', residualWeights(:)'];
numberOfExtrapolationWeights = numel(extrapolationWeights);
numberOfResidualWeights = numel(residualWeights);
end

function matrixPlaceholder = getSizeMatrix(catergorizationMethod, ...
    factorizationMethod, numberOfSynergies, numberOfEmgChannels, ...
    numberOfTasks, numberOfTrials)

if strcmpi(catergorizationMethod, 'subject')
    matrixPlaceholder = createSizeMatrix( ...
        factorizationMethod, numberOfSynergies, numberOfEmgChannels, ...
        1);
elseif strcmpi(catergorizationMethod, 'task')
    matrixPlaceholder = createSizeMatrix( ...
        factorizationMethod, numberOfSynergies, numberOfEmgChannels, ...
        numberOfTasks);
elseif strcmpi(catergorizationMethod, 'trial')
    matrixPlaceholder = createSizeMatrix( ...
        factorizationMethod, numberOfSynergies, numberOfEmgChannels, ...
        numberOfTrials);
end
end
function matrixPlaceholder = createSizeMatrix( ...
    factorizationMethod, numberOfSynergies, numberOfEmgChannels, ...
    sizeThirdDimension)

if strcmpi(factorizationMethod, 'PCA')
    matrixPlaceholder = zeros(numberOfSynergies + 1, ...
        numberOfEmgChannels, sizeThirdDimension);
elseif strcmpi(factorizationMethod, 'NMF')
    matrixPlaceholder = zeros(numberOfSynergies, ...
        numberOfEmgChannels, sizeThirdDimension);
end    
end