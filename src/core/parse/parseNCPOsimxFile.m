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
% http://www.apache.org/licenses/LICENSE2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function data = parseNCPOsimxFile(filename)
if filename
tree = xml2struct(filename);
ncpMuscleSetTree = getFieldByNameOrError(tree, "NCPMuscleSet");
musclesTree = getFieldByNameOrError(ncpMuscleSetTree, "objects").RCNLMuscle;
for i = 1:length(musclesTree)
    if(length(musclesTree) == 1)
        muscle = musclesTree;
    else
        muscle = musclesTree{i};
    end
    data.(muscle.Attributes.name).optimalTendonLength = ...
        str2double(muscle.optimal_fiber_length.Text);    
    data.(muscle.Attributes.name).tendonSlackLength = ...
        str2double(muscle.slack_tendon_length.Text);
    if isfield(muscle,'max_isometric_force')
        data.(muscle.Attributes.name).maxIsometricForce = ...
            str2double(muscle.max_isometric_force.Text);
    end
end
else
    data = [];
end
end