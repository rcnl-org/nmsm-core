% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the muscle activations given the
% EMG signals and activation dynamic parameters
%
% (struct,Array of number) -> (Array of number)
% returns the muscle activations

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

function [muscleActivations] = calcMuscleActivations(params,NeuralActivations)

NeuralActivations = NeuralActivations(params.nPad+1:params.SampleStep:...
    params.numFrames-params.nPad,:,:);
NeuralActivations = reshape(NeuralActivations, params.nptsShort*params.numTrials, ...
    params.numMuscles);
NeuralActivations(NeuralActivations<0) = 0;

nonlincoefs = [29.280183270562596 4.107869238218326 1.000004740962477...
    -7.623282868703527 17.227022969058535 0.884220539986325];

muscleActivations = (1-params.Anonlin(onesCol,:)).*NeuralActivations+...
    (params.Anonlin(onesCol,:)).*(nonlincoefs(4)./(nonlincoefs(1)*...
    (NeuralActivations+nonlincoefs(6)).^nonlincoefs(5)+...
    nonlincoefs(2))+nonlincoefs(3));
end