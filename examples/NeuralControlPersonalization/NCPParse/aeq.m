clear
inputs.numSynergies = 4;
inputs.numMuscles = 6;
inputs.numNodes = 11;
inputs.numPoints = 101;
inputs.numTrials = 2;
numDesignVariables = inputs.numSynergies * ...
    (inputs.numMuscles + (inputs.numNodes * inputs.numTrials));
inputs.synergyGroups{1}.numSynergies = 2;
inputs.synergyGroups{1}.muscleNames = ["one", "two", "three"];

inputs.synergyGroups{2}.numSynergies = 2;
inputs.synergyGroups{2}.muscleNames = ["four", "five", "six"];

numTrials = 3;
initialValues = [];
for i = 1:length(inputs.synergyGroups)
    initialValues = [initialValues; 0.1 * i * ones(inputs.synergyGroups{i}.numSynergies * length(inputs.synergyGroups{i}.muscleNames), 1)];
end
initialValues = [initialValues; 0.2 * ones(inputs.numSynergies * ...
    (inputs.numNodes * inputs.numTrials), 1)];
calcActivationsFromSynergyDesignVariables(initialValues, inputs, struct());

% Aeq = zeros(inputs.numSynergies, numDesignVariables);
% beq = 1*ones(inputs.numSynergies, 1);
% row = 1; 
% column = 1; % the sum of the muscles in the previous synergy groups
% for i = 1:length(inputs.synergyGroups)
%     for j = 1: inputs.synergyGroups{i}.numSynergies
%         Aeq(row, column : ...
%             column + length(inputs.synergyGroups{i}.muscleNames) - 1) = 1;
%         row = row + 1;
%     end
%     column = column + length(inputs.synergyGroups{i}.muscleNames);
% end
% 
% x = 0.1 * ones(numDesignVariables, 1);
% 
% Aeq(:, 1)