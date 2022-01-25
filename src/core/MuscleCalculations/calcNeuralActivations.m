% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the neural activations given the
% EMG signals using backward finite difference approximation
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

function [NeuralActivations] = calcNeuralActivations(params,EMG)

deactivationTimeConst = 4*params.activationTimeConstant;

c2(1,1,:) = 1./deactivationTimeConst;
c1(1,1,:) = 1./params.activationTimeConstant-c2;
c3 = c1(ones(params.nptsLong,1), ones(params.numTrials,1),:).*EMG+...
    c2(ones(params.nptsLong,1), ones(params.numTrials,1),:);
dt(1,:,1) = mean(diff(params.Time));
c4 = 2*dt(ones(params.nptsLong,1),:,ones(params.numMuscles,1)).*c3;

EMG = c4.*EMG;

NeuralActivations = zeros(size(EMG));
for j = 3:params.nptsLong
    NeuralActivations(j,:,:) = (EMG(j,:,:)+4.*NeuralActivations(j-1,:,:)-...
        NeuralActivations(j-2,:,:))./(c4(j,:,:)+3);
end

end