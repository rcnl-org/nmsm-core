% This function is part of the NMSM Pipeline, see file for full license.
%
% (Array of double, double) -> (Array of double)
% Applies a saturation function to muscle activations.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function muscleActivations = applyActivationSaturation( ...
    muscleActivations, cornerCoefficient)
% Function based on: http://dx.doi.org/10.1016/j.fss.2005.02.016
% Higher corner coefficient makes corners sharper 
% muscleActivations = log( ...
%     (1 + exp(cornerCoefficient .* (muscleActivations))) ./ ...
%     (1 + exp(cornerCoefficient .* (muscleActivations - 1)))) .* ...
%     (1 ./ cornerCoefficient);

% Revised version allows for higher corner coefficients without reaching
% infinity
numPower = cornerCoefficient .* (muscleActivations);
denomPower = cornerCoefficient .* (muscleActivations - 1);
muscleActivations = (log(exp(0.5 * numPower) + exp(-0.5 * numPower)) + ...
    log(exp(0.5 * numPower)) - log(exp(0.5 * denomPower) + ...
    exp(-0.5 * denomPower)) - log(exp(0.5 * denomPower))) .* ...
    (1 ./ cornerCoefficient);
end
