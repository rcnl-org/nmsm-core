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

function x = computeNeuralControlOptimization(x0,params)

% Constraints
nSynergies = params.nSynergies;
nMuscles = params.nMuscles;
nNodes = params.nNodes;
nDesignVars = nSynergies*(nMuscles/2 + nNodes);
A = [];
b = [];
Aeq = zeros(nSynergies,nDesignVars);
beq = 1*ones(nSynergies,1);
for i4 = 1:nSynergies
    Aeq(i4,(i4-1)*(nNodes+nMuscles/2)+nNodes+1:i4*(nNodes+nMuscles/2)) = 1;
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
[x,~,exitflag,~] = fmincon(@(x)computeNeuralControlCostFunction(x,params),...
    x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
end