function activations = calcActivationsFromSynergyDesignVariables( ...
    values, inputs, params)
[weights, commands] = findSynergyWeightsAndCommands(values, inputs);
[weights, commands] = normalizeSynergiesByMaximumWeight(weights, commands);

activations = zeros(inputs.numTrials, inputs.numMuscles, inputs.numPoints);

for i = 1:inputs.numTrials
    activations(i, :, :) =  weights' * squeeze(commands(i, :, :))';
end

if inputs.use_activation_saturation
    activations_result = applyActivationSaturation(activations, ...
        inputs.activation_saturation_sharpness);
    if any(isnan(activations_result(:))) || any(isinf(activations_result(:)))
        minActivations = min(activations(:), [], 'omitnan');
        maxActivations = max(activations(:), [], 'omitnan');
        fprintf('Activation saturation produced NaN/Inf. Input range=[%g,%g]. ', minActivations, maxActivations);
    end
    activations = activations_result;
end
end