% This function is part of the NMSM Pipeline, see file for full license.
%
% This function converts the synergyGroup portion of a parsed .osimx file
% into a new .osimx struct to be printed with writeOsimxFile(). See
% buildOsimxFromOsimxStruct() for reference.
%
% The expected format of the synergyGroups comes from parseSynergyGroups() as
% used in parseNeuralControlPersonalization()
%
% (struct, struct) -> (struct)
% Adds synergyGroups to .osimxStruct

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function osimx = buildSynergyGroupOsimx(osimx, synergyGroups)
osimx.NMSMPipelineDocument.OsimxModel.RCNLSynergySet.Comment = ...
    'The set of synergies from NCP to find the values in this osimx file';
for i = 1:length(synergyGroups)
    synergyGroup.muscle_group_name.Comment = ['The name of the muscle ' ...
        'group associated with this synergy'];
    synergyGroup.muscle_group_name.Text = synergyGroups{i}.muscleGroupName;
    synergyGroup.num_synergies.Comment = ['The number of synergies ' ...
        'used by this synergy group'];
    synergyGroup.num_synergies.Text = num2str(synergyGroups{i}.numSynergies);
    osimx.NMSMPipelineDocument.OsimxModel.RCNLSynergySet.RCNLSynergy{i} = synergyGroup;
end
end

