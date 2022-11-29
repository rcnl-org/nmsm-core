function totalCost = calcNcpCost(values, modeledValues, ...
    experimentalData, params)
totalCost = calcMomentTrackingCost(modeledValues, experimentalData, ...
    params);
totalCost = totalCost + calcActivationCost( ...
    values, experimentalData, params);  % This should be ONLY for those that DO NOT have EMG activations to track.
totalCost = totalCost + calcActivationTrackingCost( ...
    values, experimentalData, params);  % This should be for those that DO have EMG activations to track.

end