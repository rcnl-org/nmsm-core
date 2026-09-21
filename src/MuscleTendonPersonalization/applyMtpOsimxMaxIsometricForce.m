% This function is part of the NMSM Pipeline, see file for full license.
%
% This function overrides the maximum isometric force for each muscle with
% the value parsed from an osimx file, when present. Maximum isometric force
% is otherwise obtained from the osim model (or from muscle-tendon length
% initialization when that step is enabled). For each muscle included in the
% run that is also present in the osimx file and has a max_isometric_force
% value, that value is used instead. Muscles absent from the osimx file, or
% without a max_isometric_force value, keep their existing value.
%
% (struct) -> (struct)
% Returns inputs with osimx maximum isometric force values applied

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

function inputs = applyMtpOsimxMaxIsometricForce(inputs)
if ~isfield(inputs, "osimx") || ~isfield(inputs.osimx, "muscles")
    return
end
osimxMuscleNames = fieldnames(inputs.osimx.muscles);
for i = 1 : length(inputs.muscleNames)
    muscleName = inputs.muscleNames(i);
    if ~ismember(muscleName, osimxMuscleNames)
        continue
    end
    muscle = inputs.osimx.muscles.(muscleName);
    if isfield(muscle, "maxIsometricForce")
        inputs.maxIsometricForce(i) = muscle.maxIsometricForce;
    end
end
end
