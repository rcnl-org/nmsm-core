inputs = load("inputs.mat","inputs").inputs;

%% check activation calculation correctness
activations = calcActivationsFromSynergyDesignVariables(inputs.initialValues, inputs, struct());

assertWithinRange(activations, load("activations.mat","activations").activations, 1e-9)

%% check cost calculation correctness
cost = calcNcpCost(load("activations.mat","activations").activations, inputs, struct());

assertWithinRange(cost, load("cost.mat","cost").cost, 1e-9)
