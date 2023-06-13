% This function is part of the NMSM Pipeline, see file for full license.
%
% This function converts the muscles portion of a parsed .osimx file
% into a new .osimx struct to be printed with writeOsimxFile(). See
% buildOsimxFromOsimxStruct() for reference.
%
% (struct, struct) -> (struct)
% Adds muscles to .osimxStruct

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Marleny Vega                              %
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

function osimx = buildRcnlMuscle(osimx, muscleName, muscleParameters)
muscleObjects = osimx.NMSMPipelineDocument.OsimxModel.RCNLMuscleSet;

if(~isstruct(muscleObjects))
    i = 1;
    muscleObjects.RCNLMuscle = {};
else
    i = length(muscleObjects.RCNLMuscle) + 1;
end

muscles = muscleObjects.RCNLMuscle;
muscles{i}.Attributes.name = convertStringsToChars(muscleName);

muscles{i}.electromechanical_delay.Comment = 'Optimized electromechanical delay';
muscles{i}.electromechanical_delay.Text = convertStringsToChars( ...
    num2str(muscleParameters.electromechanicalDelay, 15));

muscles{i}.activation_time_constant.Comment = 'Optimized activation time constant';
muscles{i}.activation_time_constant.Text = convertStringsToChars( ...
    num2str(muscleParameters.activationTimeConstant, 15));

muscles{i}.activation_nonlinearity_constant.Comment = 'Optimized activation nonlinearity constant';
muscles{i}.activation_nonlinearity_constant.Text = convertStringsToChars( ...
    num2str(muscleParameters.activationNonlinearityConstant, 15));

muscles{i}.emg_scale_factor.Comment = 'Optimized EMG scale factor';
muscles{i}.emg_scale_factor.Text = convertStringsToChars( ...
    num2str(muscleParameters.emgScaleFactor, 15));

muscles{i}.optimal_fiber_length.Comment = 'Optimized optimal fiber length';
muscles{i}.optimal_fiber_length.Text = convertStringsToChars( ...
    num2str(muscleParameters.optimalFiberLength, 15));

muscles{i}.tendon_slack_length.Comment = 'Optimized tendon slack length';
muscles{i}.tendon_slack_length.Text = convertStringsToChars( ...
    num2str(muscleParameters.tendonSlackLength, 15));

muscles{i}.max_isometric_force.Comment = 'Optimized max isometric force';
muscles{i}.max_isometric_force.Text = convertStringsToChars( ...
    num2str(muscleParameters.maxIsometricForce, 15));

osimx.NMSMPipelineDocument.OsimxModel.RCNLMuscleSet.RCNLMuscle = muscles;
end

