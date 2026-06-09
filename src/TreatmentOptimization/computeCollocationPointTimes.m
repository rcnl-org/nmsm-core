function inputs = computeCollocationPointTimes(inputs)

if isfield(inputs, "finalTimeRange")
    inputs.maxTime = inputs.finalTimeRange(2);
else
    inputs.maxTime = max(inputs.experimentalTime);
end
inputs.minTime = min(inputs.experimentalTime);

if strcmp(inputs.solverType, 'gpops')
    inputs = computeGpopsCollocationPointTimes(inputs);
end
end

function inputs = computeGpopsCollocationPointTimes(inputs)
setup.guess.phase.time = scaleToBounds(inputs.initialTime, ...
    inputs.maxTime, inputs.minTime);
setup.auxdata = inputs;
N = inputs.gpops.numCollocationPoints;
P = inputs.gpops.numIntervals;
setup.mesh.phase.colpoints = P * ones(1, N);
setup.mesh.phase.fraction = ones(1, N) / N;

tempSetup = makeMinimalSetup(setup);
collocationPointTimes = findCollocationPointsForSetup(tempSetup);

inputs.collocationTimeBound = collocationPointTimes;
time = scaleToOriginal(collocationPointTimes, setup.auxdata.maxTime, ...
    setup.auxdata.minTime);
inputs.collocationTimeOriginal = time;
end

function collocationPointTimes = findCollocationPointsForSetup(tempSetup)
[~, output] = evalc('gpops2(tempSetup)');
collocationPointTimes = output.result.solution.phase.timeRadau;
end

function tempSetup = makeMinimalSetup(setup)
tempSetup.name = 'Test';
tempSetup.functions.continuous = @continuous;
tempSetup.functions.endpoint = @endpoint;

tempSetup.guess.phase.time = setup.guess.phase.time;

tempSetup.guess.phase.state = zeros(size(tempSetup.guess.phase.time));
tempSetup.guess.phase.control = zeros(size(tempSetup.guess.phase.time));
tempSetup.guess.phase.integral = 0;

tempSetup.bounds.phase.initialtime.lower = tempSetup.guess.phase.time(1);
tempSetup.bounds.phase.initialtime.upper = tempSetup.guess.phase.time(1);
tempSetup.bounds.phase.finaltime.lower = tempSetup.guess.phase.time(end);
tempSetup.bounds.phase.finaltime.upper = tempSetup.guess.phase.time(end);
tempSetup.bounds.phase.initialstate.lower = -1;
tempSetup.bounds.phase.initialstate.upper = 1;
tempSetup.bounds.phase.state.lower = -1;
tempSetup.bounds.phase.state.upper = 1;
tempSetup.bounds.phase.finalstate.lower = -1;
tempSetup.bounds.phase.finalstate.upper = 1;
tempSetup.bounds.phase.control.lower = -1;
tempSetup.bounds.phase.control.upper = 1;
tempSetup.bounds.phase.integral.lower = -1e9;
tempSetup.bounds.phase.integral.upper = 1e9;
tempSetup.derivatives.derivativelevel= 'first';
tempSetup.nlp.ipoptoptions.maxiterations = 1;
tempSetup.scales.method = 'none';

tempSetup.mesh.phase.colpoints = setup.mesh.phase.colpoints;
tempSetup.mesh.phase.fraction = setup.mesh.phase.fraction;
tempSetup.mesh.maxiterations = 0;
tempSetup.displaylevel = 0;
tempSetup.auxdata = setup.auxdata;
end

function output = continuous(input)
output.dynamics = zeros(size(input.phase.time));
output.integrand = zeros(size(input.phase.time));
if valueOrAlternate(input.auxdata, 'calculateMetabolicCost', false)
    if isfield(input.auxdata, "initialMetabolicCost") && ...
            length(input.phase.time) == length(input.auxdata.initialMetabolicCost) - 1
        output.integrand(:, 1) = input.auxdata.initialMetabolicCost(1:end-1);
    end
end
end

function output = endpoint(input)
global initialMetabolicCost
initialMetabolicCost = input.phase.integral;
output.objective = 0;
end