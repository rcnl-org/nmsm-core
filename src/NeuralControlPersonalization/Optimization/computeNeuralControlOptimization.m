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
nDesignVars = inputs.nSynergies*(inputs.nMuscles/2 + inputs.nNodes);
A = [];
b = [];
Aeq = zeros(inputs.nSynergies, nDesignVars);
beq = 1*ones(inputs.nSynergies, 1);
for i4 = 1:inputs.nSynergies
    Aeq(i4,(i4-1)*(inputs.nNodes+inputs.nMuscles/2)+inputs.nNodes+1:i4*(inputs.nNodes+inputs.nMuscles/2)) = 1;
end
lb = zeros(nDesignVars,1);
ub = [];
nonlcon = [];


options = optimoptions('fmincon','Display','iter','MaxIterations',1e3,...
    'MaxFunctionEvaluations',1e3*length(x0),'Algorithm','sqp',...
    'TypicalX',ones(nDesignVars,1),'UseParallel','always');

% NcpOptimSettings.A = A;
% NcpOptimSettings.b = b;
% NcpOptimSettings.Aeq = Aeq;
% NcpOptimSettings.beq = beq;
% NcpOptimSettings.lb = lb;
% NcpOptimSettings.ub = ub;
% NcpOptimSettings.nonlcon = nonlcon;
% NcpOptimSettings.options = options;

%         [x,~,exitflag,~] = fmincon(@(x)calculateCost(x,lMTVals,vMTVals,rVals,IDmomentVals,params),...
%             x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
[x, ~, exitflag, ~] = fmincon(@(x)computeNeuralControlCostFunction(x, inputs, struct()),...
    x0, A, b, Aeq, beq, lb, ub, nonlcon, options);
end