% This function is part of the NMSM Pipeline, see file for full license.
%
% This function overrides the default per-muscle MTP initial guess values
% with values parsed from an osimx file. For each muscle included in the MTP
% run that is also present in the osimx file, the corresponding RCNLMuscle
% parameters are used as the initial guess. Muscles included in the run but
% absent from the osimx file keep their default initial guess. Optimal fiber
% length and tendon slack length are stored as absolute lengths in the osimx
% file and are converted to the scale factors used by MTP by dividing by the
% model value.
%
% (Cell array, struct) -> (Cell array)
% Returns the initial guess values with osimx overrides applied

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function values = applyMtpOsimxInitialGuess(values, inputs)
if ~isfield(inputs, "osimx") || ~isfield(inputs.osimx, "muscles")
    warning("input_osimx_file contains no RCNLMuscle elements; " + ...
        "using default initial guesses.");
    return
end
osimxMuscleNames = fieldnames(inputs.osimx.muscles);
sharedElectromechanicalDelays = [];
for i = 1 : length(inputs.muscleNames)
    muscleName = inputs.muscleNames(i);
    if ~ismember(muscleName, osimxMuscleNames)
        continue
    end
    muscle = inputs.osimx.muscles.(muscleName);
    if isfield(muscle, "activationTimeConstant")
        values{2}(i) = muscle.activationTimeConstant;
    end
    if isfield(muscle, "activationNonlinearityConstant")
        values{3}(i) = muscle.activationNonlinearityConstant;
    end
    if isfield(muscle, "emgScaleFactor")
        values{4}(i) = muscle.emgScaleFactor;
    end
    if isfield(muscle, "optimalFiberLength")
        values{5}(i) = ...
            muscle.optimalFiberLength / inputs.optimalFiberLength(i);
    end
    if isfield(muscle, "tendonSlackLength")
        values{6}(i) = ...
            muscle.tendonSlackLength / inputs.tendonSlackLength(i);
    end
    if isfield(muscle, "electromechanicalDelay")
        if inputs.muscleSpecificElectromechanicalDelays
            values{1}(i) = muscle.electromechanicalDelay;
        else
            sharedElectromechanicalDelays(end + 1) = ...
                muscle.electromechanicalDelay;
        end
    end
end
if ~inputs.muscleSpecificElectromechanicalDelays && ...
        ~isempty(sharedElectromechanicalDelays)
    warning("muscle_specific_electromechanical_delays is false but the " + ...
        "osimx file has per-muscle electromechanical delays; using the " + ...
        "mean as the shared initial guess.");
    values{1} = mean(sharedElectromechanicalDelays);
end
end
