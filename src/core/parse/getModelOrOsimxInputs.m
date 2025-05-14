% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
% 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function inputs = getModelOrOsimxInputs(inputs)
if ~isa(inputs.model, 'org.opensim.modeling.Model')
    model = Model(inputs.model);
else
    model = inputs.model;
end
inputs.optimalFiberLength = [];
inputs.tendonSlackLength = [];
inputs.pennationAngle = [];
inputs.maxIsometricForce = [];
if ~isfield(inputs, "osimx")
    inputs.osimx = struct();
end
for i = 1 : inputs.numMuscles
    if isfield(inputs.osimx, "muscles") && ...
            isfield(inputs.osimx.muscles, inputs.muscleNames(i))
        if ~isfield(inputs.osimx.muscles.(inputs.muscleNames(i)), ...
                "optimalFiberLength")
            inputs.optimalFiberLength(end+1) = model.getForceSet(). ...
                getMuscles().get(i-1).getOptimalFiberLength();
        else
            inputs.optimalFiberLength(end+1) = inputs.osimx.muscles. ...
                (inputs.muscleNames(i)).optimalFiberLength;
        end
        if ~isfield(inputs.osimx.muscles.(inputs.muscleNames(i)), ...
                "tendonSlackLength")
            inputs.tendonSlackLength(end+1) = model.getForceSet(). ...
                getMuscles().get(i-1).getTendonSlackLength();
        else
            inputs.tendonSlackLength(end+1) = inputs.osimx.muscles. ...
                (inputs.muscleNames(i)).tendonSlackLength;
        end
        if ~isfield(inputs.osimx.muscles.(inputs.muscleNames(i)), ...
                "maxIsometricForce")
            inputs.maxIsometricForce(end+1) = model.getForceSet(). ...
                getMuscles().get(i-1).getMaxIsometricForce();
        else
            inputs.maxIsometricForce(end+1) = inputs.osimx.muscles. ...
                (inputs.muscleNames(i)).maxIsometricForce;
        end
    else
        inputs.optimalFiberLength(end+1) = model.getForceSet(). ...
            getMuscles().get(i-1).getOptimalFiberLength();
        inputs.tendonSlackLength(end+1) = model.getForceSet(). ...
            getMuscles().get(i-1).getTendonSlackLength();
        inputs.maxIsometricForce(end+1) = model.getForceSet(). ...
            getMuscles().get(i-1).getMaxIsometricForce();
    end
    inputs.pennationAngle(end+1) = model.getForceSet(). ...
        getMuscles().get(i-1). ...
        getPennationAngleAtOptimalFiberLength();
end
end