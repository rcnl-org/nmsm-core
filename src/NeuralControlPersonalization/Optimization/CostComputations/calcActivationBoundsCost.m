function rawCost = calcActivationBoundsCost(activations, costTerm)
% Smooth penalty for activations outside [0, 1]. Only needed when
% allow_negative_synergy_vector_weights lets weighted sums fall outside
% that range; shape-agnostic and CasADi MX/SX-safe (elementwise sqrt).
sharpness = valueOrAlternate(costTerm, 'sharpness', 76);
lowerViolation = ((-activations) + sqrt(activations.^2 + ...
    (1 / sharpness)^2)) / 2 - 1 / (2 * sharpness);
upperViolation = ((activations - 1) + sqrt((activations - 1).^2 + ...
    (1 / sharpness)^2)) / 2 - 1 / (2 * sharpness);
rawCost = [lowerViolation(:); upperViolation(:)];
end
