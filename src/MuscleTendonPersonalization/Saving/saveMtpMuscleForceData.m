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

[activeMuscleForce, passiveMuscleForce, totalMuscleForce] = ...
    calcMuscleForce(results.normalizedFiberLength, ...
    results.normalizedFiberVelocity, mtpInputs.maxIsometricForce, ...
    results.muscleActivations);

tendonForce = calcTendonForce(results.normalizedFiberLength, ...
    results.normalizedFiberVelocity, mtpInputs.maxIsometricForce, ...
    results.muscleActivations, mtpInputs.pennationAngle);

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

