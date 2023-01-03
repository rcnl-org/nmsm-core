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

function x = computeNeuralControlOptimization(x0, inputs, params)

% Constraints
numDesignVars = inputs.numSynergies*(inputs.numMuscles/2 + inputs.numNodes);
A = [];
b = [];
Aeq = zeros(inputs.numSynergies, numDesignVars);
beq = 1*ones(inputs.numSynergies, 1);
for i4 = 1:inputs.numSynergies
    Aeq(i4, (i4-1) * (inputs.numNodes + inputs.numMuscles/2) + ...
     inputs.numNodes + 1 : i4 * (inputs.numNodes + inputs.numMuscles ...
      / 2)) = 1;
end
lb = zeros(numDesignVars, 1);
ub = [];
nonlcon = [];

options = optimoptions('fmincon','Display','iter','MaxIterations',1e3,...
    'MaxFunctionEvaluations',1e3*length(x0),'Algorithm','sqp',...
    'TypicalX',ones(numDesignVars,1),'UseParallel','always');

[x, ~, exitflag, ~] = fmincon(@(x)computeNeuralControlCostFunction(x, inputs, params),...
    x0, A, b, Aeq, beq, lb, ub, nonlcon, options);
end