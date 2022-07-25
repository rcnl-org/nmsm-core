% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a model and returns a tree struct with the ground as
% the top element and each child body exists within the struct. It's
% possible to use getFieldByName(bodyStructure, fieldOfInterest) to find
% the body and children of interest.
%
% (Model) -> (struct)
% Create and return a struct tree of bodies and their children

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

function bodyStructure = makeBodyTree(model)
bodyStructure = struct();
bodyStructure.ground = struct();

for i = 0 : model.getJointSet().getSize()-1
    [parent, child] = getJointBodyNames(model, ...
        model.getJointSet().get(i).getName().toCharArray');
    [parentBodyInStructure, path] = getFieldByName(bodyStructure, parent);
    if(isstruct(parentBodyInStructure))
        temp = cellstr(path);
        temp{end+1} = child;
        bodyStructure = setfield(bodyStructure, temp{:}, struct());
    else
        bodyStructure.(parent) = struct();
        bodyStructure.(parent).(child) = struct();
    end
end
end

