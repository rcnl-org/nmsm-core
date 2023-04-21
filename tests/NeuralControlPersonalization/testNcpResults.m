inputs = load("inputs.mat","inputs").inputs;
params = load("params.mat","params").params;
optimizedValues = load("optimizedValues.mat", "optimizedValues").optimizedValues;

%% check activation calculation correctness
activations = calcActivationsFromSynergyDesignVariables(optimizedValues, inputs, params);

assertWithinRange(activations, load("activations.mat","activations").activations, 1e-9)

%% check cost calculation correctness
cost = calcNcpCost(load("activations.mat","activations").activations, inputs, params, optimizedValues);

assertWithinRange(cost, load("cost.mat","cost").cost, 1e-9)
