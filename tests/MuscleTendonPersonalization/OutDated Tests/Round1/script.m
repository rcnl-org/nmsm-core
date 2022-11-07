
clear

load("costFunctionTestingRound1.mat")
scaledOptimalFiberLength = permute(inputData.lMo .* ...
    guess.Round1(1,1:inputData.nMusc), [1 3 2]);

scaledTendonSlackLength = permute(experimentalData.tendonSlackLength .* ...
    findCorrectMtpValues(5, valuesStruct), [1 3 2]);

load("round1test.mat")
newScaledOptimalFiberLength = inputData.optimalFiberLength .* valuesStruct.optimalFiberLengthScaleFactors;

% newNew = ones(1, 1, 34);
% newNew(1, 1, :) = newScaledOptimalFiberLength;

% assertWithinRange(newNew, scaledOptimalFiberLength, 0.01)

% assertWithinRange(newNew, scaledTendonSlackLength, 0.01)

% onesCol = ones(size(experimentalData.muscleTendonLength, 1:1), ...
%     size(experimentalData.muscleTendonLength, 2));
% % Normalized muscle fiber length, equation 2 from Meyer 2017
% lMtilda = (experimentalData.muscleTendonLength - onesCol .* ...
%     scaledTendonSlackLength) ./ (onesCol .* ...
%     (scaledOptimalFiberLength .* permute(cos(experimentalData.pennationAngle), ...
%     [1 3 2])));
% % Normalized muscle fiber velocity, equation 3 from Meyer 2017
% vMtilda = experimentalData.muscleTendonVelocity ./ ...
%     (experimentalData.vMaxFactor * onesCol .* (scaledOptimalFiberLength .* ...
%     permute(cos(experimentalData.pennationAngle), [1 3 2])));