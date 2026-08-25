% This function is part of the NMSM Pipeline, see file for full license.
%
% (3D matrix, 3D matrix, 3D matrix) -> (2D matrix, 2D matrix, 2D matrix)
% Combines the force plates applied to one contact surface into the single
% wrench the rest of the pipeline expects.
%
% Each force plate reports its moment about its own electrical center, so
% raw moments cannot simply be summed. Every plate is transferred onto the
% first listed plate's electrical center, which leaves the result exact and
% continuous, and reduces to the untouched inputs for a single plate.
%
% Inputs are numTime x 3 x numForcePlates.

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

function [forces, moments, electricalCenter] = mergeForcePlateWrenches( ...
    plateForces, plateMoments, plateElectricalCenters)
electricalCenter = plateElectricalCenters(:, :, 1);
forces = sum(plateForces, 3);
moments = zeros(size(electricalCenter));
for plate = 1:size(plateForces, 3)
    moments = moments + transferMoments( ...
        plateElectricalCenters(:, :, plate), electricalCenter, ...
        plateMoments(:, :, plate), plateForces(:, :, plate));
end
end
