% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates and saves active, passive, and total muscle
% force from the MTP run.
%
% (string) -> (None)
% Plot passive force curves from file.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Di Ao, Marleny Vega, Robert Salati                           %
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

function saveMtpMuscleForceData(mtpInputs, resultsStruct, resultsDirectory)
if isfield(resultsStruct, "resultsSynx")
    results = resultsStruct.resultsSynx;
else
    results = resultsStruct.results;
end
expandedMaxIsometricForce = ones(1, 1, ...
    length(mtpInputs.maxIsometricForce), 1);
expandedMaxIsometricForce(1, 1, :, 1) = mtpInputs.maxIsometricForce;

expandedMuscleActivations = ones(size(results.muscleActivations, 1), 1, ...
    size(results. muscleActivations, 2), size(results. muscleActivations, 3));
expandedMuscleActivations(:, 1, :, :) = results.muscleActivations;

activeForce = activeForceLengthCurve(results.normalizedFiberLength);
expandedActiveForce = ones(size(activeForce, 1), 1, ...
    size(activeForce, 2), size(activeForce, 3));
expandedActiveForce(:, 1, :, :) = activeForce;

muscleVelocity = forceVelocityCurve(results.normalizedFiberVelocity);
expandedMuscleVelocity = ones(size(muscleVelocity, 1), 1, ...
    size(muscleVelocity, 2), size(muscleVelocity, 3));
expandedMuscleVelocity(:, 1, :, :) = muscleVelocity;

passiveForce = passiveForceLengthCurve(results.normalizedFiberLength);
expandedPassiveForce = ones(size(passiveForce, 1), 1, ...
    size(passiveForce, 2), size(passiveForce, 3));
expandedPassiveForce(:, 1, :, :) = passiveForce;

parallelComponentOfPennationAngle = cos(mtpInputs.pennationAngle);
expandedParallelComponentOfPennationAngle = ones(1, 1, length( ...
    parallelComponentOfPennationAngle), 1);
expandedParallelComponentOfPennationAngle(1, 1, :, 1) = ...
    parallelComponentOfPennationAngle;

totalMuscleForce = ...
    expandedMaxIsometricForce .* (expandedMuscleActivations .* ...
    expandedActiveForce .* expandedMuscleVelocity + ...
    expandedPassiveForce);
activeMuscleForce = ...
    expandedMaxIsometricForce .* (expandedMuscleActivations .* ...
    expandedActiveForce .* expandedMuscleVelocity);
passiveMuscleForce = ...
    expandedMaxIsometricForce .* expandedPassiveForce;
tendonForce = totalMuscleForce .* expandedParallelComponentOfPennationAngle;

totalMuscleForce = reshape(totalMuscleForce, [size(totalMuscleForce,1), ...
    size(totalMuscleForce,3), size(totalMuscleForce,4)]);
activeMuscleForce = reshape(activeMuscleForce, [size(activeMuscleForce,1), ...
    size(activeMuscleForce,3), size(activeMuscleForce,4)]);
passiveMuscleForce = reshape(passiveMuscleForce, [size(passiveMuscleForce,1), ...
    size(passiveMuscleForce,3), size(passiveMuscleForce,4)]);
tendonForce = reshape(tendonForce, [size(tendonForce,1), ...
    size(tendonForce,3), size(tendonForce,4)]);

writeMtpDataToSto(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    totalMuscleForce, results.time, ...
    fullfile(resultsDirectory, "totalMuscleForces"), "_totalMuscleForces.sto");
writeMtpDataToSto(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    activeMuscleForce, results.time, ...
    fullfile(resultsDirectory, "activeMuscleForces"), "_activeMuscleForces.sto");
writeMtpDataToSto(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    passiveMuscleForce, resultsStruct.results.time, ...
    fullfile(resultsDirectory, "passiveMuscleForces"), "_passiveMuscleForces.sto");
writeMtpDataToSto(mtpInputs.muscleNames, mtpInputs.prefixes, ...
    tendonForce, resultsStruct.results.time, ...
    fullfile(resultsDirectory, "tendonForces"), "_tendonForces.sto");
end

