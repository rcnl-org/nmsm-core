% This function is part of the NMSM Pipeline, see file for full license.
%
% This function sets the coordinate value of a child or parent frame for a
% given joint depending on the parameters included.
%
% (Model, double, string, integer, boolean, boolean) -> (None)
% Modifies the model with the given coordinate value

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire Hammond                                               %
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

function applyFrameParameterValue(model, newValue, jointName, isParent, ...
    isTranslation, coordNum)
if(isParent)
    frame = model.getJointSet().get(jointName).getParentFrame();
    offsetFrame = org.opensim.modeling.PhysicalOffsetFrame ...
        .safeDownCast(frame);
    if(isTranslation)
        coord = offsetFrame.get_translation();
        coord.set(coordNum, newValue);
        offsetFrame.set_translation(coord);
    else
        coord = offsetFrame.get_orientation();
        coord.set(coordNum, newValue);
        offsetFrame.set_orientation(coord);
    end
else
    frame = model.getJointSet().get(jointName).getChildFrame();
    offsetFrame = org.opensim.modeling.PhysicalOffsetFrame ...
        .safeDownCast(frame);
    if(isTranslation)
        coord = offsetFrame.get_translation();
        coord.set(coordNum, newValue);
        offsetFrame.set_translation(coord);
    else
        coord = offsetFrame.get_orientation();
        coord.set(coordNum, newValue);
        offsetFrame.set_orientation(coord);
    end
end
end

