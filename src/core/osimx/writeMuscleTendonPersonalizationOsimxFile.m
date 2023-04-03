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
    optimizedParams, muscleNames, outfile)
model = Model(modelFileName);

osimx = buildMtpOsimxTemplate(...
    replace(model.getName().toCharArray',".","_dot_"), ...
    modelFileName);

for i = 1:length(muscleNames)
    muscleParams = makeMuscleParams(model, muscleNames(i), optimizedParams, i);
    osimx = addRcnlMuscle(osimx, muscleNames(i), muscleParams);
end

outfile = strrep(outfile, 'osimx', 'xml');
struct2xml(osimx, outfile)
copyfile(outfile, fullfile(strrep(outfile, ...
    'xml','osimx')))
delete(outfile) 
end

function params = makeMuscleParams(model, muscleName, optimizedParams, index)
params.electromechanicalDelay = optimizedParams.electromechanicalDelays(index);
params.activationTimeConstant = optimizedParams.activationTimeConstants(index);
params.activationNonlinearityConstant = ...
    optimizedParams.activationNonlinearityConstants(index);

muscle = model.getForceSet().getMuscles().get(muscleName);

params.emgScaleFactor = optimizedParams.emgScaleFactors(index);
params.optimalFiberLength = muscle.get_optimal_fiber_length() * ...
    optimizedParams.optimalFiberLengthScaleFactors(index);
params.tendonSlackLength = muscle.get_tendon_slack_length() * ...
    optimizedParams.tendonSlackLengthScaleFactors(index);
end