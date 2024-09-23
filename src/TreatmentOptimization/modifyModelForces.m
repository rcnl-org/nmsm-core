% This function is part of the NMSM Pipeline, see file for full license.
%
% This function disables all muscles, if any, in the osim model. Point and
% torque actuators are also added to the model if contact surfaces exist.
% The modified model is then saved and printed. 
%
% (struct) -> (struct)
% Modifies osim model

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

function inputs = modifyModelForces(inputs)
model = disableModelMuscles(inputs.model);
if valueOrAlternate(inputs, 'calculateMetabolicCost', false)
    probe = org.opensim.modeling.Bhargava2004MuscleMetabolicsProbe( ...
        true, true, true, false, true);
    model.addProbe(probe);
    probe.setOperation("value");
    probe.set_report_total_metabolics_only(true);
    probe.setName("metabolics");
    for i = 1:length(inputs.muscleNames)
        probe.addMuscle(inputs.muscleNames(i), 0.5, 40, 133, 74, 111);
    end
end
model = addContactSurfaceActuators(inputs, model);
inputs.mexModel = strcat(strrep(inputs.modelFileName,'.osim',''), '_inactiveMuscles.osim');
model.print(inputs.mexModel);
inputs.model = Model(inputs.mexModel);
end