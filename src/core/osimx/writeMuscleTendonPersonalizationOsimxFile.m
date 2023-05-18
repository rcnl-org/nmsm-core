% This function is part of the NMSM Pipeline, see file for full license.
%
% This function prints out the optimized muscle tendon parameters in an
% osimx file
%
% (string, 2D matrix, string) -> (None)
% Prints MuscleTendonPersonalization results in osimx file

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

function writeMuscleTendonPersonalizationOsimxFile(modelFileName, ...
    osimxFileName, optimizedParams, muscleNames, results_directory)
model = Model(modelFileName);

if isfile(osimxFileName)
    osimx = parseOsimxFile(osimxFileName);
    [~, name, ~] = fileparts(osimxFileName);
    outfile = fullfile(results_directory, strcat(name, "_mtp.xml"));
else
    osimx = buildMtpOsimxTemplate(...
        replace(model.getName().toCharArray',".","_dot_"), ...
        modelFileName);
    [~, name, ~] = fileparts(modelFileName);
    outfile = fullfile(results_directory, strcat(name, "_mtp.xml"));
end
osimx.modelName = name;
osimx.model = modelFileName;
for i = 1:length(muscleNames)
    muscleParams = makeMuscleParams(model, muscleNames(i), optimizedParams, i);
    osimx.muscles.(muscleNames(i)) = muscleParams;
end

writeOsimxFile(buildOsimxFromOsimxStruct(osimx), outfile)
end

function params = makeMuscleParams(model, muscleName, optimizedParams, index)
if isfield(optimizedParams, 'electromechanicalDelays')
    params.electromechanicalDelay = optimizedParams.electromechanicalDelays(index);
end
if isfield(optimizedParams, 'activationTimeConstants')
    params.activationTimeConstant = optimizedParams.activationTimeConstants(index);
end
if isfield(optimizedParams, 'activationNonlinearityConstants')
    params.activationNonlinearityConstant = ...
        optimizedParams.activationNonlinearityConstants(index);
end
muscle = model.getForceSet().getMuscles().get(muscleName);
if isfield(optimizedParams, 'emgScaleFactors')
    params.emgScaleFactor = optimizedParams.emgScaleFactors(index);
end
if isfield(optimizedParams, 'optimalFiberLengthScaleFactors')
    params.optimalFiberLength = muscle.get_optimal_fiber_length() * ...
        optimizedParams.optimalFiberLengthScaleFactors(index);
end
if isfield(optimizedParams, 'tendonSlackLengthScaleFactors')
    params.tendonSlackLength = muscle.get_tendon_slack_length() * ...
        optimizedParams.tendonSlackLengthScaleFactors(index);
end
if isfield(optimizedParams, 'maxIsometricForce')
    params.maxIsometricForce = optimizedParams.maxIsometricForce(index);
end
end