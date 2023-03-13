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

function inputs = getModelorOsimxInputs(inputs)
if ~isa(inputs.model, 'org.opensim.modeling.Model')
    model = Model(inputs.model);
end
inputs.numMuscles = getNumEnabledMuscles(inputs.model);
inputs.optimalFiberLength = [];
inputs.tendonSlackLength = [];
inputs.pennationAngle = [];
inputs.maxIsometricForce = [];
inputs.muscleNames = '';
for i = 0:model.getForceSet().getMuscles().getSize()-1
    if model.getForceSet().getMuscles().get(i).get_appliesForce()
        inputs.muscleNames{end+1} = char(model.getForceSet(). ...
            getMuscles().get(i).getName);
        if isfield(inputs.ncpDataInputs, inputs.muscleNames{end})
            inputs.optimalFiberLength(end+1) = inputs.ncpDataInputs. ...
                (inputs.muscleNames{end}).optimalTendonLength;
            inputs.tendonSlackLength(end+1) = inputs.ncpDataInputs. ...
                (inputs.muscleNames{end}).tendonSlackLength;
            if isfield(inputs.ncpDataInputs. ...
                    (inputs.muscleNames{end}), 'maxIsometricForce')
                inputs.maxIsometricForce(end+1) = inputs.ncpDataInputs. ...
                    (inputs.muscleNames{end}).maxIsometricForce;
            else
                inputs.maxIsometricForce(end+1) = model.getForceSet(). ...
                    getMuscles().get(i).getMaxIsometricForce();
            end
        else
            inputs.optimalFiberLength(end+1) = model.getForceSet(). ...
                getMuscles().get(i).getOptimalFiberLength();
            inputs.tendonSlackLength(end+1) = model.getForceSet(). ...
                getMuscles().get(i).getTendonSlackLength();
            inputs.maxIsometricForce(end+1) = model.getForceSet(). ...
                getMuscles().get(i).getMaxIsometricForce();
        end
        inputs.pennationAngle(end+1) = model.getForceSet(). ...
            getMuscles().get(i). ...
            getPennationAngleAtOptimalFiberLength();
    end
end
end