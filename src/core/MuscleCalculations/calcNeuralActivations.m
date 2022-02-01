% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the neural activations given the
% muscleExcitation signals using backward finite difference approximation
%
% (struct,Array of number) -> (Array of number)
% returns the neural activations

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                          %
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
    activationTimeConstant, time)

deactivationTimeConst = 4 * activationTimeConstant;
c2(1, 1, :) = 1 ./ deactivationTimeConst; % equation 6 from Meyer 2017
c1(1, 1, :) = 1 ./ activationTimeConstant - c2; % eq 5 from Meyer 2017
dt(1,:,1) = mean(diff(time)); % delta time
% partialEquation is a part of equation 7, Meyer 2017
partialEquation = 2 * dt(ones(size(muscleExcitation, 1), 1), :, ...
    ones(size(muscleExcitation, 3), 1)) .* (c1(ones(size(muscleExcitation, ...
    1), 1), ones(size(muscleExcitation, 2), 1), :) .* muscleExcitation + ...
    c2(ones(size(muscleExcitation, 1), 1), ones(size(muscleExcitation, 2), ...
    1), :));
% preallocate memory
neuralActivations = zeros(size(muscleExcitation));
% equation 7 from Meyer 2017
for j = 3:size(muscleExcitation, 1)
    neuralActivations(j, :, :) = (partialEquation(j, :, :) .* ...
        muscleExcitation(j, :, :) + 4 .* neuralActivations(j-1, :, :) - ...
        neuralActivations(j-2, :, :)) ./ (partialEquation(j ,: ,:) + 3); 
end
end


% function neuralActivations = calcNeuralActivations(muscleExcitation, ...
%     activationTimeConstant, time)
% 
% deactivationTimeConst = 4 * activationTimeConstant;
% c2(1, 1, :) = 1 ./ deactivationTimeConst; % equation 6 from Meyer 2017
% c1(1, 1, :) = 1 ./ activationTimeConstant - c2; % eq 5 from Meyer 2017
% % c3 = (c1*e + c2) from eq 7, Meyer 2017
% c3 = c1(ones(size(muscleExcitation, 1), 1), ones(size(muscleExcitation, ...
%     2), 1), :) .* muscleExcitation + c2(ones(size(muscleExcitation, 1), ...
%     1), ones(size(muscleExcitation, 2), 1), :); 
% dt(1,:,1) = mean(diff(time)); % delta time
% % c4 is the denominator from eq 7, Meyer 2017
% c4 = 2 * dt(ones(size(muscleExcitation, 1), 1), :, ...
%     ones(size(muscleExcitation, 3), 1)) .* c3;
% muscleExcitation = c4 .* muscleExcitation;
% % preallocate memory
% neuralActivations = zeros(size(muscleExcitation));
% for j = 3:size(muscleExcitation, 1)
%     neuralActivations(j, :, :) = (muscleExcitation(j,:,:) + 4 .* ...
%         neuralActivations(j-1,:,:) - neuralActivations(j-2, :, :)) ./ ...
%         (c4(j ,: ,:) + 3); % complete equation 7 from Meyer 2017
% end
% 
% end