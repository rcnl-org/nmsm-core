function gcpSensitivityAnalysis(values, valuesIndexOfInterest, ...
    upperBound, lowerBound, fieldNameOrder, inputs, params, stage)

if stage == 1
    costFn = @calcVerticalGroundReactionCost;
elseif stage == 2
    costFn = @calcGroundReactionCost;
elseif stage == 3
    costFn = @calcGroundReactionForcesAndMomentsCost;
end

xPoints = linspace(upperBound, lowerBound);
yPoints = zeros(1, length(xPoints));

parfor i = 1 : length(xPoints)
    newValues = values
    newValues(valuesIndexOfInterest) = xPoints(i);
    costs = costFn(newValues, fieldNameOrder, inputs, params);
    yPoints(i) = sum(costs .^ 2, 'all');
end

plot(xPoints, yPoints)

end

