% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the passive muscle moments for a given set of
% experimental data, maximum isometric force, and normalized fiber length.
%
% Inputs:
%   experimentalData: struct containing the following fields
%       momentArms: 3d matrix of moment arms
%       pennationAngle: 3d array of (1, numMuscles, 1)
%   maxIsometricForce: 3d array of (1, numMuscles, 1)
%   normalizedFiberLength: 3d array of (1, numMuscles, 1)
%
% Outputs:
%   passiveModelMoments: 3d array of moments
%
% (struct, 3d mat, 3d mat) -> 3d mat
% returns passive model moment

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

function passiveModelMoments = calcPassiveMuscleMoments(experimentalData, ...
    maxIsometricForce, normalizedFiberLength)

expandedMaxIsometricForce = ones(1, 1, length(maxIsometricForce), 1);
expandedMaxIsometricForce(1, 1, :, 1) = maxIsometricForce;

passiveForce = passiveForceLengthCurve(normalizedFiberLength);
expandedPassiveForce = ones(size(passiveForce, 1), 1, ...
    size(passiveForce, 2), size(passiveForce, 3));
expandedPassiveForce(:, 1, :, :) = passiveForce;

parallelComponentOfPennationAngle = cos(experimentalData.pennationAngle);
expandedParallelComponentOfPennationAngle = ones(1, 1, length( ...
    parallelComponentOfPennationAngle), 1);
expandedParallelComponentOfPennationAngle(1, 1, :, 1) = ...
    parallelComponentOfPennationAngle;
readMomentArmsForPlotting(experimentalData);
passiveModelMoments = experimentalData.momentArms .* ...
    expandedMaxIsometricForce .* expandedPassiveForce .* ...
    expandedParallelComponentOfPennationAngle;

passiveModelMoments = permute(sum(passiveModelMoments, 3), [1 2 4 3]);
end
