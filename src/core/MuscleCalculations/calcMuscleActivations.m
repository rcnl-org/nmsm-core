% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the muscle activations given the
% EMG signals and activation dynamic parameters
% 
% neuralActivation - 2D matrix of (length(nptsShort*numTrials), numMuscles)
%
% (Array of number, 2D array of number) -> (Array of number)
% computes the muscle activations from neural activations and nonlinearity

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function [muscleActivations] = calcMuscleActivations( ...
    activationNonlinearity, neuralActivations)

neuralActivations(neuralActivations<0) = 0; %remove negative neural activ
nonlinearityCoefficients = [29.280183270562596 4.107869238218326 ...
    1.000004740962477 -7.623282868703527 17.227022969058535 ...
    0.884220539986325]; % defined by BJ Fregly
onesCol = ones(1, size(neuralActivations, 1));
muscleActivations = (1 - activationNonlinearity(onesCol, :)) .* ...
    neuralActivations + (activationNonlinearity(onesCol, :)) .* ...
    (nonlinearityCoefficients(4) ./ (nonlinearityCoefficients(1) * ...
    (neuralActivations + nonlinearityCoefficients(6)) .^ ...
    nonlinearityCoefficients(5) + nonlinearityCoefficients(2)) + ...
    nonlinearityCoefficients(3)); % equation 8 from Meyer 2017
end
