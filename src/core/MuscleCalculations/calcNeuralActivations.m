% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the neural activations given the
% muscleExcitation signals using backward finite difference approximation
%
% (3D matrix of numbers, 3D matrix of numbers, 2D array of numbers) -> 
% (3D matrix of numbers)
% returns the neural activations

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond, Spencer Williams            %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function neuralActivations = calcNeuralActivations(muscleExcitation, ...
    activationTimeConstants, emgTime, numPaddingFrames)
activationTimeConstants = activationTimeConstants / 100;
deactivationTimeConstants = 4 * activationTimeConstants;
% equation 6 from Meyer 2017
inverseDeactivationTimeConstants = 1 ./ deactivationTimeConstants;
% equation 5 from Meyer 2017
differenceOfTimeConstants = (1 ./ activationTimeConstants) - ...
    inverseDeactivationTimeConstants; 
% Each emg trial could have different time interval
trialSpecificTimeInterval = mean(diff(emgTime, 1, 2), 2); 
neuralActivations = zeros(size(muscleExcitation));
% equation 7 from Meyer 2017
for j = 3:size(muscleExcitation, 3)
    finiteDifferenceTimeConstants = 2 * trialSpecificTimeInterval .* ...
        (differenceOfTimeConstants .* muscleExcitation(:, :, j) + ...
        inverseDeactivationTimeConstants);
    finiteDifferenceDenominator = finiteDifferenceTimeConstants + 3;
    finiteDifferenceNumerator = finiteDifferenceTimeConstants .* ...
        muscleExcitation(:, :, j) + 4 * neuralActivations(:, :, j-1) - ...
        neuralActivations(:, :, j-2);
    neuralActivations(:, :, j) = finiteDifferenceNumerator ./ ...
        finiteDifferenceDenominator;
end
neuralActivations = neuralActivations(:, :, numPaddingFrames + ...
    1:size(emgTime, 2) - numPaddingFrames);
neuralActivations(neuralActivations < 0) = 0; %remove negative neural activ
end