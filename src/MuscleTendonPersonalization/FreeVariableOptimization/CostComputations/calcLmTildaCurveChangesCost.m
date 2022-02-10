function cost = calcLmTildaCurveChangesCost(lMtilda, lMtildaExprimental, ...
    lmtildaPairs, params)

% Penalize violation of lMtilda similarity between paired muscles
[lmtildaMeanSimilarityError, lmtildaShapeSimilarityError] = ...
    calcChangesInNormalizedMuscleFiberLengthCurves(lMtilda, ...
    lMtildaExprimental, lmtildaPairs);
lmtildaMeanSimilarityPenalty = calcPenalizeDifferencesCostTerm( ...
    lmtildaMeanSimilarityError, params.errorCenters(8), ...
    params.maxAllowableErrors(8));
lmtildaShapeSimilarityPenalty = calcPenalizeDifferencesCostTerm( ...
    lmtildaShapeSimilarityError, params.errorCenters(8), ...
    params.maxAllowableErrors(8));
cost.lmtildaPairedSimilarity = [lmtildaMeanSimilarityPenalty; ...
    lmtildaShapeSimilarityPenalty];
end
