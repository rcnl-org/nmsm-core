function metabolicCost = calcBhargavaMetabolicCost(mass, ...
    allMuscleActivations, normalizedMuscleFiberLengths, ...
    normalizedMuscleFiberVelocities, maxIsometricForce, optimalFiberLength)
fiberTypeRatio = 0.5;
metabolicCost = zeros(size(allMuscleActivations, 1), 1);
for i = 1:size(allMuscleActivations, 2)
    activations = allMuscleActivations(:, i);
    fastActivation = fiberTypeRatio * (1 - cos(pi / 2 * activations));
    slowActivation = (1 - fiberTypeRatio) * (sin(pi / 2 * activations));
    contractileElementForce = (maxIsometricForce(i) .* activations .* ...
        activeForceLengthCurve(normalizedMuscleFiberLengths(:, i)) .* ...
        forceVelocityCurve(normalizedMuscleFiberVelocities(:, i)));

    activationHeatCost = calcActivationHeatCost(mass, fastActivation, ...
        slowActivation);
    maintenanceHeatCost = calcMaintenanceHeatCost(mass, fastActivation, ...
        slowActivation, normalizedMuscleFiberLengths(:, i));
    shorteningHeatCost = calcShorteningHeatCost(activations, ...
        normalizedMuscleFiberLengths(:, i), normalizedMuscleFiberVelocities(:, i), ...
        optimalFiberLength(i), contractileElementForce);
    
    workRateCost = calcWorkRateCost(contractileElementForce, ...
        optimalFiberLength(i), normalizedMuscleFiberVelocities(:, i));
    muscleSpecificMetabolicCost = activationHeatCost + ...
        maintenanceHeatCost + shorteningHeatCost + ...
        workRateCost;
    metabolicCost = metabolicCost + muscleSpecificMetabolicCost;
end
basalRateCost = calcBasalRateCost(mass);
metabolicCost = metabolicCost + basalRateCost;
end

function activationHeatCost = calcActivationHeatCost(mass, ...
    fastActivation, slowActivation)

fastActivationConstant = 133;
slowActivationConstant = 40;

% assume phi = 1
activationHeatCost = mass .* (fastActivation .* fastActivationConstant ...
    + slowActivation .* slowActivationConstant);
end

function maintenanceHeatCost = calcMaintenanceHeatCost(mass, ...
    fastActivation, slowActivation, normalizedMuscleFiberLengths)

fastMaintenanceConstant = 111;
slowMaintenanceConstant = 74;

lengthFactor = zeros(length(normalizedMuscleFiberLengths), 1);
for i = 1:length(normalizedMuscleFiberLengths)
    if normalizedMuscleFiberLengths(i) <= 0.5
        lengthFactor(i) = 0.5;
    elseif normalizedMuscleFiberLengths(i) <= 1
        lengthFactor(i) = normalizedMuscleFiberLengths(i);
    elseif normalizedMuscleFiberLengths(i) <= 1.5
        lengthFactor(i) = -2 * normalizedMuscleFiberLengths(i) + 3;
    end
end

maintenanceHeatCost = mass .* lengthFactor .* ...
    ((fastMaintenanceConstant * fastActivation) + ...
    (slowMaintenanceConstant * slowActivation));
end

function shorteningHeatCost = calcShorteningHeatCost(activations, ...
    normalizedMuscleFiberLengths, normalizedMuscleFiberVelocities, ...
    optimalFiberLength, contractileElementForce)

isometricForce = activations .* ...
    activeForceLengthCurve(normalizedMuscleFiberLengths) .* ...
    contractileElementForce;

forceProportionality = zeros(length(normalizedMuscleFiberVelocities), 1);
for i = 1:length(normalizedMuscleFiberVelocities)
    if normalizedMuscleFiberVelocities(i) <= 0
        forceProportionality(i) = 0.16 * isometricForce(i) + 0.18 * contractileElementForce(i);
    else
        forceProportionality(i) = 0.157 * contractileElementForce(i);
    end
end

shorteningHeatCost = -forceProportionality .* ...
    normalizedMuscleFiberVelocities * optimalFiberLength;

end

function basalRateCost = calcBasalRateCost(mass)
basalRateCost = 0.0225 * mass;
end

function workRateCost = calcWorkRateCost(contractileElementForce, ...
    optimalFiberLength, normalizedMuscleFiberVelocities)
workRateCost = -contractileElementForce .* ...
    (normalizedMuscleFiberVelocities * optimalFiberLength);
end