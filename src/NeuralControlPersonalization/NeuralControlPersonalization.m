% This function is part of the NMSM Pipeline, see file for full license.
%
% Neural Control Personalization uses movement and EMG data to personalize
% the muscle characteristics of the patient.
%
% inputs:
%   - model (string)
%   - jointMoment (3D array)
%   - muscleTendonLength (3D array)
%   - muscleTendonVelocity (3D array)
%   - muscleTendonMomentArm (4D array)
%   - emgData (3D array)
%   - experimentalData (struct) - see costFunction
%
% (struct, struct) -> (struct)
% Runs the Muscle Tendon Personalization algorithm

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function [finalValues, inputs] = NeuralControlPersonalization(inputs, ...
    params)
verifyInputs(inputs); % (struct) -> (None)
%verifyParams(params); % (struct) -> (None)
params = finalizeParams(params);
inputs = finalizeInputs(inputs);

inputs.use_bilateral_symmetry = false;
if any(cellfun(@(t) isfield(t,'isEnabled') && t.isEnabled && isfield(t,'type') && strcmpi(t.type,'bilateral_symmetry'),params.costTerms))
    inputs.use_bilateral_symmetry = true;
end
numSynergiesOneLeg = inputs.synergyGroups{1}.numSynergies;
numMuscleOneLeg = length(inputs.synergyGroups{1}.muscleNames);
inputs.numWeightsOneLeg = numSynergiesOneLeg*numMuscleOneLeg;

initialValues = prepareInitialValues(inputs, params);
% fprintf("First optimization...\n")
finalValues = computeNeuralControlOptimization(initialValues, inputs, ...
    params);
% % use optimized 11-nodes values as init
% % resampling
% [finalValues, inputs] = resamplingToNumNodes(finalValues, inputs);
% fprintf("Second optimization...\n")
% finalValues = computeNeuralControlOptimization(finalValues, inputs, ...
%     params);
end

function [outputValues, inputs] = resamplingToNumNodes(inputValues, inputs)
[synergyWeights, synergyCommands] = findSynergyWeightsAndCommands( ...
    inputValues, inputs);
inputs.numNodes = 26;
synergyCommandsNodes = zeros(inputs.numTrials, inputs.numNodes, inputs.numSynergies);
percent = linspace(0,100, inputs.numPoints)';
percentNodes = linspace(0,100, inputs.numNodes)';
for i = 1:inputs.numTrials
    for j = 1:inputs.numSynergies
        synergyCommandsNodes(i,:,j) = interp1(percent, squeeze(synergyCommands(i,:,j)), percentNodes, 'spline');
    end
end
outputValues = repackDesignVariables(synergyWeights, synergyCommandsNodes, inputs);
end


% (struct) -> (None)
% throws an error if any of the inputs are invalid
function verifyInputs(inputs)
verifyNoDuplicateMusclesBetweenSynergyGroups(inputs.synergyGroups);
end

% (struct) -> (None)
% throws an error if the parameter is included but is not of valid type
function verifyParams(params)
if(isfield(params, 'maxIterations'))
    verifyParam(params, 'maxIterations', @verifyNumeric, ...
        'param maxIterations is not a number');
end
if(isfield(params, 'maxFunctionEvaluations'))
    verifyParam(params, 'maxFunctionEvaluations', @verifyNumeric, ...
        'param maxFunctionEvaluations is not a number');
end
end


function inputs = finalizeInputs(inputs)
inputs.numNodes = valueOrAlternate(inputs, "numNodes", 26); %%% # of nodes!!!!!!!!!!
% NOTE: performance becomes consistently good when numNodes >= 26
% To keep runtime low while maintaining reliable performance, set nodes = 26.
inputs.numPoints = valueOrAlternate(inputs, "numPoints", ...
    size(inputs.muscleTendonLength, 3));
inputs.vMaxFactor = valueOrAlternate(inputs, "vMaxFactor", 10);
inputs.numMuscles = 0;
inputs.numSynergies = 0;
for i = 1 : length(inputs.synergyGroups)
    inputs.numMuscles = inputs.numMuscles + ...
    length(inputs.synergyGroups{i}.muscleNames);
    inputs.numSynergies = inputs.numSynergies + ...
    inputs.synergyGroups{i}.numSynergies;
end
inputs.numTrials = size(inputs.momentArms, 1);
end

function params = finalizeParams(params)
params.activationGroups = valueOrAlternate(params, "activationGroups", ...
    {});
params.normalizedFiberLengthGroups = valueOrAlternate(params, ...
    "normalizedFiberLengthGroups", {});
end

% 1. factorize MTP activations via nnmf to get initial synergy weights and commands
% 2. renormalize weights and commands to (0–1) scale
% 3. group weights using activationGroups
% 4. spline commands to num of nodes
function values = prepareInitialValues(inputs, params)  
use_nnmf_for_init = true;

numSynergiesOneLeg = inputs.synergyGroups{1}.numSynergies;
numMuscleOneLeg = length(inputs.synergyGroups{1}.muscleNames); 

fprintf("Generating nnmf solutions...\n\n")

if use_nnmf_for_init
    % rng(0)
    options = statset('Display','off','TolX',1e-10,'TolFun',1e-10,'UseParallel',true);
    mtpPerm = permute(inputs.mtpActivations, [1 3 2]);
    mtpActivations_stack = reshape(mtpPerm, inputs.numTrials*inputs.numPoints, inputs.numMuscles);
    
    numReplicates = 1000;  % for nnmf
    if inputs.use_bilateral_symmetry
        % when bilateral_symmetry is enabled, two legs use one set of weights
        if length(inputs.synergyGroups) ~= 2
            throw(MException('', ['Bilateral symmetry cost ' ...
                'requires exactly two synergy groups.']))
        end
        assert(length(inputs.synergyGroups{1}.muscleNames) == ...
            length(inputs.synergyGroups{2}.muscleNames), ...
            'Left and right groups must have the same number of muscles.');
        assert(inputs.synergyGroups{1}.numSynergies+ ...
            inputs.synergyGroups{2}.numSynergies == inputs.numSynergies, ...
            'inputs.numSynergies must equal sum of numSynergies per leg.');
        assert(inputs.synergyGroups{1}.numSynergies==inputs.synergyGroups{2}.numSynergies, ...
            'Left and right groups must have the same number of synergies.');
    
        mtpActivations_stack_stack = [mtpActivations_stack(:, 1:numMuscleOneLeg); 
                                      mtpActivations_stack(:, numMuscleOneLeg + 1:end)];
                                % (inputs.numTrials*inputs.numPoints*2, inputs.numMuscles)
        [commandsOneLeg_stack,weightsOneLeg] = nnmf(mtpActivations_stack_stack, ...
            numSynergiesOneLeg,'replicates',numReplicates,'algorithm','als','options',options);
        
        [weightsOneLeg,commandsOneLeg_stack] = renormalizeVariables(weightsOneLeg,commandsOneLeg_stack);
    
        % build weight matrix
        weightsInit = zeros(inputs.numSynergies, inputs.numMuscles);
        weightsInit(1:numSynergiesOneLeg, 1:numMuscleOneLeg) = weightsOneLeg;     
        weightsInit(numSynergiesOneLeg+1:end, numMuscleOneLeg+1:end) = weightsOneLeg;       
        % split commands    
        commandsInit_stack = zeros(inputs.numTrials * inputs.numPoints, inputs.numSynergies);
        commandsInit_stack(:, 1 :numSynergiesOneLeg) = commandsOneLeg_stack(1:(inputs.numTrials * inputs.numPoints), :);       
        commandsInit_stack(:, numSynergiesOneLeg+1:end) = commandsOneLeg_stack((inputs.numTrials * inputs.numPoints)+1:end, :);  
    else
        % when bilateral_symmetry is disabled
        if isfield(inputs,'synergyGroups') && numel(inputs.synergyGroups) == 2
            % split stacked activations into left and right
            mtpActivationsLeft  = mtpActivations_stack(:, 1:numMuscleOneLeg);
            mtpActivationsRight = mtpActivations_stack(:, numMuscleOneLeg+1:end);
    
            % nnmf left and right separately
            [commandsLeft, weightsLeft] = nnmf(mtpActivationsLeft,  numSynergiesOneLeg, ...
                'replicates',numReplicates,'algorithm','als','options',options);
            [weightsLeft,commandsLeft] = renormalizeVariables(weightsLeft,commandsLeft);
    
            [commandsRight, weightsRight] = nnmf(mtpActivationsRight, numSynergiesOneLeg, ...
                'replicates',numReplicates,'algorithm','als','options',options);
            [weightsRight,commandsRight] = renormalizeVariables(weightsRight,commandsRight);
    
            % build weight matrix
            weightsInit = zeros(inputs.numSynergies, inputs.numMuscles);
            weightsInit(1:numSynergiesOneLeg, 1:numMuscleOneLeg) = weightsLeft;
            weightsInit(numSynergiesOneLeg+1:end, numMuscleOneLeg+1:end) = weightsRight;
            % combine commands
            commandsInit_stack = zeros(inputs.numTrials * inputs.numPoints,inputs.numSynergies);
            commandsInit_stack(:, 1:numSynergiesOneLeg) = commandsLeft;
            commandsInit_stack(:, numSynergiesOneLeg+1:end) = commandsRight;
        else
            % only one leg
            [commandsInit_stack, weightsInit] = nnmf(mtpActivations_stack, ...
                inputs.numSynergies, 'replicates',numReplicates, 'algorithm','als','options',options);
            [weightsInit,commandsInit_stack] = renormalizeVariables(weightsInit,commandsInit_stack);
        end
    end
    
    % group weights based on activationGroups
    if any(cellfun(@(t) isfield(t,'isEnabled') && t.isEnabled && isfield(t,'type') && strcmpi(t.type,'grouped_activations'),params.costTerms))
        weightsInitGrouped = weightsInit;
        for i = 1 : length(params.activationGroups)
            groupWeights = weightsInit(:, params.activationGroups{i});
            groupWeights_average = mean(groupWeights, 2); 
            weightsInitGrouped(:, params.activationGroups{i}) = repmat(groupWeights_average, 1, length(params.activationGroups{i}));
        end
        weightsInit = weightsInitGrouped;  
    end
    
    % commands: #points -> #nodes
    commandsInit = reshape(commandsInit_stack,inputs.numTrials,inputs.numPoints, inputs.numSynergies);
    commandsInitNodes = zeros(inputs.numTrials, inputs.numNodes, inputs.numSynergies);
    percent = linspace(0,100, inputs.numPoints)';
    percentNodes = linspace(0,100, inputs.numNodes)';
    for i = 1:inputs.numTrials
        for j = 1:inputs.numSynergies
            commandsInitNodes(i,:,j) = interp1(percent, squeeze(commandsInit(i,:,j)), percentNodes, 'spline');
        end
    end
    
    values = repackDesignVariables(weightsInit, commandsInitNodes, inputs);
    
    % add normalization "sum" "magnitude" "none"?
else
    values = [];
    for i = 1:length(inputs.synergyGroups)
        values = [values; 0.01 * ...
            ones(inputs.synergyGroups{i}.numSynergies * ...
            length(inputs.synergyGroups{i}.muscleNames), 1)];
    end
    values = [values; ones(inputs.numSynergies * ...
        inputs.numNodes * inputs.numTrials, 1)];
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% values = [];
% for i = 1:length(inputs.synergyGroups)
%     values = [values; 0.01 * ...
%         ones(inputs.synergyGroups{i}.numSynergies * ...
%         length(inputs.synergyGroups{i}.muscleNames), 1)];
% end
% values = [values; ones(inputs.numSynergies * ...
%     inputs.numNodes * inputs.numTrials, 1)];
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

function [weightsNormalized,commandsNormalized] = renormalizeVariables(weights,commands)
% Added: renormalize nnmf init to make sum(weight vector) = 0.5*nMuscs
% so fmincon takes better-scaled inputs
numMuscs = size(weights,2);
ratio = 0.5*numMuscs./sum(weights,2)/5;  % size: numSynergyOneLeg
% ratio = 1;
commandsNormalized = commands./ratio';
weightsNormalized = weights.*ratio;

fprintf('[renormalizeVariables] Compare old and new: \n');
fprintf('  Before renorm: Weight(min/max/mean)=%.3g/%.3g/%.3g, Command(min/max/mean)=%.3g/%.3g/%.3g\n', ...
    min(weights(:)), max(weights(:)), mean(weights(:)), ...
    min(commands(:)), max(commands(:)), mean(commands(:)));
fprintf('  After renorm: Weight(min/max/mean)=%.3g/%.3g/%.3g, Command(min/max/mean)=%.3g/%.3g/%.3g\n\n', ...
    min(weightsNormalized(:)), max(weightsNormalized(:)), mean(weightsNormalized(:)), ...
    min(commandsNormalized(:)), max(commandsNormalized(:)), mean(commandsNormalized(:)));

% figure;
% tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
% nexttile; hold on;
% plot(mean(weights,1), 'LineWidth', 1.5);      
% plot(mean(weightsNormalized,1), 'LineWidth', 1.5);
% ylim([0,1]);
% 
% nexttile; hold on;
% plot(mean(commands,2), 'LineWidth', 1.5);     
% plot(mean(commandsNormalized,2), 'LineWidth', 1.5);
% ylim([0,1]);
end

