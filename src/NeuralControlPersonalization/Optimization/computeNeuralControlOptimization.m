% function optimizedValues = computeNeuralControlOptimization( ...
%     initialValues, primaryValues, isIncluded, lowerBounds, upperBounds, ...
%     experimentalData, params, optimizerOptions)
%
% optimizedValues = fmincon(@(values)computeMuscleTendonCostFunction( ...
%     values, primaryValues, isIncluded, experimentalData, params), ...
%     initialValues, [], [], [], [], lowerBounds, upperBounds, ...
%     @(values)calcMuscleTendonNonLinearConstraints(values, params), ...
%     optimizerOptions);
% end

function finalValues = computeNeuralControlOptimization(initialValues, inputs, params)

% Constraints
numDesignVariables = length(initialValues);
Aeq = zeros(inputs.numSynergies, numDesignVariables);
beq = 1*ones(inputs.numSynergies, 1);
column = 1; 
for i = 1:length(inputs.synergyGroups)
    for j = 1: inputs.synergyGroups{i}.numSynergies
        Aeq(column, (column - 1) * ...
            length(inputs.synergyGroups{i}.muscleNames) + 1 : ...
            column * length(inputs.synergyGroups{i}.muscleNames)) = 1;
        column = column + 1;
    end
end
lb = zeros(numDesignVariables, 1);

options = optimoptions('fmincon','Display','iter','MaxIterations',1e4,...
    'MaxFunctionEvaluations',1e4*length(initialValues), ...
    'OptimalityTolerance', 1e-3, 'StepTolerance', 1e-16, 'Algorithm', 'sqp',...
    'TypicalX',ones(numDesignVariables,1),'UseParallel','always');
% finalValues = initialValues;
finalValues = fmincon(@(values)computeNeuralControlCostFunction(values, inputs, params),...
    initialValues, [], [], Aeq, beq, lb, [], [], options);
end