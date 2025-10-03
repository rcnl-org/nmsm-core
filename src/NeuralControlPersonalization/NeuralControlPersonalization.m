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
initialValues = prepareInitialValues(inputs, params);
finalValues = computeNeuralControlOptimization(initialValues, inputs, ...
    params);
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
        'param maxFunctionEvaluations is not a number');
end
if(isfield(params, 'maxFunctionEvaluations'))
    verifyParam(params, 'maxFunctionEvaluations', @verifyNumeric, ...
        'param maxFunctionEvaluations is not a number');
end
end


function inputs = finalizeInputs(inputs)
inputs.numNodes = valueOrAlternate(inputs, "numNodes", 21);
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

% (struct, struct) -> (6 x numEnabledMuscles matrix of number)
% extract initial version of optimized values from inputs/params
function values = prepareInitialValues(inputs, params)    
rng(0)
options = statset('Display','off','TolX',1e-10,'TolFun',1e-10,'UseParallel',false);
mtpPerm = permute(inputs.mtpActivations, [1 3 2]);
mtpActivations_stack = reshape(mtpPerm, inputs.numTrials*inputs.numPoints, inputs.numMuscles);

if any(cellfun(@(t) isfield(t,'isEnabled') && t.isEnabled && isfield(t,'type') && strcmpi(t.type,'bilateral_symmetry'),params.costTerms))
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

    numSynergies_leg = inputs.synergyGroups{1}.numSynergies;
    numMuscle_leg = length(inputs.synergyGroups{1}.muscleNames);

    mtpActivations_stack_stack = [mtpActivations_stack(:, 1:numMuscle_leg); 
                                  mtpActivations_stack(:, numMuscle_leg + 1:end)];
    [commands_leg_stack,weights_leg] = nnmf(mtpActivations_stack_stack, ...
        inputs.synergyGroups{1}.numSynergies,'replicates',500,'algorithm','mult','options',options);

    % build weight matrix
    weights_init = zeros(inputs.numSynergies, inputs.numMuscles);
    weights_init(1:numSynergies_leg, 1:numMuscle_leg) = weights_leg;     
    weights_init(numSynergies_leg+1:end, numMuscle_leg+1:end) = weights_leg;       
    % split commands    
    commands_init_stack = zeros(inputs.numTrials * inputs.numPoints, inputs.numSynergies);
    commands_init_stack(:, 1 :numSynergies_leg) = commands_leg_stack(1:(inputs.numTrials * inputs.numPoints), :);       
    commands_init_stack(:, numSynergies_leg+1:end) = commands_leg_stack((inputs.numTrials * inputs.numPoints)+1:end, :);  

else
    [commands_init_stack,weights_init] = nnmf(mtpActivations_stack,inputs.numSynergies,'replicates',...
        500,'algorithm','mult','options',options);
end

commands_init = reshape(commands_init_stack,inputs.numTrials,inputs.numPoints, inputs.numSynergies);

percent = linspace(0,100, inputs.numPoints)';
percentNodes = linspace(0,100, inputs.numNodes)';
commands_init_nodes = zeros(inputs.numTrials, inputs.numNodes, inputs.numSynergies);
for i = 1:inputs.numTrials
    for j = 1:inputs.numSynergies
        commands_init_nodes(i,:,j) = interp1(percent, squeeze(commands_init(i,:,j)), percentNodes, 'spline');
    end
end

length_weights   = 0;
for i = 1:length(inputs.synergyGroups)
    length_weights = length_weights + length(inputs.synergyGroups{i}.muscleNames) * ...
        inputs.synergyGroups{i}.numSynergies;
end
length_commands = inputs.numTrials*inputs.numNodes*inputs.numSynergies;
values = zeros(length_weights + length_commands, 1);

idx = 1; 
row = 1; 
idx_ratio = 1;
idx_group = 1;
ratio = ones(inputs.numSynergies,1);
% radius = inputs.synergy_vector_normalization_value;
for i = 1:numel(inputs.synergyGroups)
    sum_target = length(inputs.synergyGroups{i}.muscleNames) / 100;
    for j = 1:inputs.synergyGroups{i}.numSynergies
        weight_list = weights_init(row, idx_group:idx_group+length(inputs.synergyGroups{i}.muscleNames)-1);
        if strcmpi(inputs.synergy_vector_normalization_method,'magnitude')
            ratio(idx_ratio) = inputs.synergy_vector_normalization_value/norm(weight_list);
        elseif strcmpi(inputs.synergy_vector_normalization_method,'sum')
            ratio(idx_ratio) = sum_target/sum(weight_list);
        else
            error('Unknown normalization method: %s', ...
                inputs.synergy_vector_normalization_method);
        end
        weight_list = (weight_list * ratio(idx_ratio)).';
        values(idx:idx+length(inputs.synergyGroups{i}.muscleNames)-1) = weight_list(:);
        idx = idx + length(inputs.synergyGroups{i}.muscleNames) ;
        row = row + 1;
        idx_ratio = idx_ratio+1;
    end
    idx_group = idx_group+length(inputs.synergyGroups{i}.muscleNames);
end

for i = 1:inputs.numTrials
    for j = 1:inputs.numSynergies
        command_list = squeeze(commands_init_nodes(i,:,j));
        command_list = command_list/ratio(j);
        values(idx:idx+inputs.numNodes-1) = command_list(:);
        idx = idx + inputs.numNodes;
    end
end
end