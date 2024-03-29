
% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the linear inequality constraints that         %
% make unmeasured muscle excitations using synergy extrapolation (SynX)   %
% betwwen 0 and 1                                                         %
%
% data:
%   synergyCommands - synergy excitations extracted from measured muscle excitations 
%   params.numberOfSynergies - number of synergies - double
%   size(emgData,2) - number of trials in total - double
%   params.numberOfSynergies - number of SynX EMG channels in total - double
%   size(emgData,3) - number of measured EMG channels in total - double
%   length(params.taskNames) -  number of tasks - double
%   size(emgData,1) - number of time frames for each trial - double
%   params.matrixFactorizationMethod - matrix factorization algorithm - 'PCA' or 'NMF'
%   params.synergyExtrapolationCategorization - variability of synergy vector weights across trials for 
%                  SynX reconstruction
%   params.residualCategorization  - variability of synergy vector weights across trials for 
%                  residual excitation reconstruction
%   TrialIndex - trial index for each task - cell array (nTask cells)
%   numOtherDesignVariables - number of other design variables - double
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

function [A,b] = getLinearInequalityConstraints(params, ...
    numOtherDesignVariables, synergyCommands, emgData)

if strcmp(params.matrixFactorizationMethod, 'PCA')
    matrixFactorizationFactor = 1;
elseif strcmp(params.matrixFactorizationMethod, 'NMF')
    matrixFactorizationFactor = 0;
end
% Construct the linear constraint, SynX and Residual A Matrix
aMatrixSynergy = getSynxAMatrix(params, synergyCommands, ...
    emgData, matrixFactorizationFactor);
aMatrixResidual = getResidualAMatrix(emgData, params.numberOfSynergies, ...
    params.missingEmgChannelGroups, params.residualCategorizationOfTrials, ...
    matrixFactorizationFactor);
% Concatenate non-SynX design variables with SynX and Residual Matrices
A = [zeros(2 * size(params.missingEmgChannelGroups, 2) * size(emgData, 1) * ...
    size(emgData, 2), numOtherDesignVariables) [-aMatrixSynergy ...
    aMatrixResidual; aMatrixSynergy aMatrixResidual]];
% b (between 0 and 1)
b = [zeros(size(emgData, 1) * size(emgData, 2) * size( ...
    params.missingEmgChannelGroups, 2), 1); ones(size(emgData, 1) * ...
    size(emgData, 2) * size(params.missingEmgChannelGroups, 2), 1)];

% fullCommands = synergyCommands{1};
% for i = 2:length(synergyCommands)
%     fullCommands = cat(1, fullCommands, synergyCommands{i});
% end
% fullCommands(:, end+1) = ones(size(fullCommands, 1), 1);
% fullEmg = reshape(emgData, size(emgData, 1) * size(emgData, 2), ...
%     size(emgData, 3));
% 
% if strcmp(params.matrixFactorizationMethod, 'PCA')
%     totalGroups = length(params.missingEmgChannelGroups) * size(emgData, 2) + ...
%         length(params.currentEmgChannelGroups);
%     A = zeros(totalGroups * size(fullCommands, 1), ...
%         numOtherDesignVariables + totalGroups * size(fullCommands, 2));
%     for i = 1:totalGroups
%         A(size(fullCommands, 1) * (i - 1) + 1 : size(fullCommands, 1) * i, ...
%             numOtherDesignVariables + size(fullCommands, 2) * (i - 1) + 1 : ...
%             numOtherDesignVariables + size(fullCommands, 2) * i) = fullCommands;
%     end
%     A = cat(1, A, -A);
% 
%     b = ones(length(params.missingEmgChannelGroups) * ...
%         size(emgData, 2) * size(fullCommands, 1), 1);
%     for i = 1:length(params.currentEmgChannelGroups)
%         b = [b; 1 - fullEmg(:, i)];
%     end
%     b = [b; zeros(length(params.missingEmgChannelGroups) * ...
%         size(emgData, 2) * size(fullCommands, 1), 1)];
%     for i = 1:length(params.currentEmgChannelGroups)
%         b = [b; fullEmg(:, i)];
%     end
% end

end





function [aMatrix, aMatrixSynergy] = allocateSynxMatrixAMemory(emgData, ...
    numberOfSynergies, missingEmgChannelGroups, thirdMatrixDimension, ...
    matrixFactorizationFactor)

aMatrix = zeros(size(emgData, 1) * size(emgData, 2), ( ...
    numberOfSynergies + matrixFactorizationFactor) * thirdMatrixDimension);
aMatrixSynergy = zeros(size(emgData, 1) * size(emgData, 2) * ...
    size(missingEmgChannelGroups, 2), (numberOfSynergies + ...
    matrixFactorizationFactor) * thirdMatrixDimension * numberOfSynergies);
end

function aMatrixSynergy = updateHalfMatrixA(emgData, aMatrix,...
    numberOfSynergies, missingEmgChannelGroups, thirdMatrixDimension, ...
    matrixFactorizationFactor)
aMatrixSynergy = [];
for i = 1:size(missingEmgChannelGroups,2)
    aMatrixSynergy((i - 1) * size(emgData, 1) * size(emgData, 2) + 1 : ...
        i * size(emgData, 1) * size(emgData, 2), (i - 1) * ( ...
        numberOfSynergies + matrixFactorizationFactor) * ...
        thirdMatrixDimension + 1 : i * (numberOfSynergies + ...
        matrixFactorizationFactor) * thirdMatrixDimension) = aMatrix;
end 
end

function aMatrixSynergy = getSynxAMatrix(params, synergyCommands, ...
    emgData, matrixFactorizationFactor)

[aMatrix, aMatrixSynergy] = allocateSynxMatrixAMemory(emgData, ...
    params.numberOfSynergies, params.missingEmgChannelGroups, ...
    length(params.synergyCategorizationOfTrials), ...
    matrixFactorizationFactor);
for i = 1:length(params.synergyCategorizationOfTrials)
for j = 1: size(params.synergyCategorizationOfTrials{i},2)
    aMatrix(size(emgData, 1) * ...
        (params.synergyCategorizationOfTrials{i}(j) - 1) + 1 : ...
        size(emgData, 1) * (params.synergyCategorizationOfTrials{i}(j)), ...
        (i - 1) * (params.numberOfSynergies + matrixFactorizationFactor) + ...
        1 : (i - 1) * (params.numberOfSynergies + ...
        matrixFactorizationFactor) + params.numberOfSynergies) = ...
        synergyCommands{i}(size(emgData, 1) * (j - 1) + 1 : ...
        size(emgData, 1) * j, :);
    aMatrix(size(emgData, 1) * ...
        (params.synergyCategorizationOfTrials{i}(j) - 1) + 1 : ...
        size(emgData, 1) * (params.synergyCategorizationOfTrials{i}(j)), ...
        i * (params.numberOfSynergies + matrixFactorizationFactor)) = 1;
end
end
aMatrixSynergy = updateHalfMatrixA(emgData, aMatrix, ...
    params.numberOfSynergies, params.missingEmgChannelGroups, ...
    length(params.synergyCategorizationOfTrials), matrixFactorizationFactor);
end

function aMatrixResidual = getResidualAMatrix(emgData, ...
    numberOfSynergies, missingEmgChannelGroups, residualCategorization, ...
    matrixFactorizationFactor)

aMatrixResidual = zeros(size(emgData, 1) * size(emgData, 2) * ...
    size(missingEmgChannelGroups, 2), (numberOfSynergies + ...
    matrixFactorizationFactor) * length(residualCategorization) * ...
    size(emgData, 3));
end