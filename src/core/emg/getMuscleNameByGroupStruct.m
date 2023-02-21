% This function is part of the NMSM Pipeline, see file for full license.
%
% This function creates a struct where each fieldname corresponds to a list
% of the muscle names in that muscle group for a given model.
%
% (Model, Array of string) -> (struct)
% Get name to group relationship struct from model and group names

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

function groupToName = getMuscleNameByGroupStruct(model, emgDataNames)
for i=1:length(emgDataNames) % struct group names with muscle names inside
    groupSize = model.getForceSet().getGroup(emgDataNames(i)) ...
        .getMembers().size();
    groupToName.(emgDataNames(i)) = string(zeros(1,groupSize));
    for j=0:groupSize-1
        groupToName.(emgDataNames(i))(j+1) = model.getForceSet() ...
            .getGroup(emgDataNames(i)).getMembers().get(j).getName() ...
            .toCharArray';
    end
end
end