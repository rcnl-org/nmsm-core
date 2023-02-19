% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, struct) -> (None)

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

function groups = getSynergyGroups(tree, model)
synergySetTree = getFieldByNameOrError(tree, "SynergySet");
groupsTree = getFieldByNameOrError(synergySetTree, "objects").Synergy;
groups = {};
for i=1:length(groupsTree)
    if(length(groupsTree) == 1)
        group = groupsTree;
    else
        group = groupsTree{i};
    end
    groups{i}.numSynergies = ...
        str2double(group.num_synergies.Text);
    groupMembers = model.getForceSet().getGroup( ...
        group.muscle_group_name.Text).getMembers();
    muscleNames = string([]);
    for j=0:groupMembers.getSize() - 1
        muscleNames(end + 1) = groupMembers.get(j);
    end
    groups{i}.muscleNames = muscleNames;
    groups{i}.muscleGroupName = group.muscle_group_name.Text;
end
end