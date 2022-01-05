% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns the coordinate value of the joint's parent or child
% translation or orientation frame depending on input arguments. The
% arguments are set as follows:
%
% jointName -> The name of the joint (string) (i.e. 'hip_r')
% coordNum -> The number of the coordinate for the given frame, typically
%   0 = 'x', 1 = 'y', 2 = 'z'
% isParent -> True if you want the coordinate value of the parent frame,
%   otherwise it returns the coordinate value of the child frame.
% isTranslation -> True if you want the coordinate to be the translation
%   coordinate value, false if you want orientation.
%
% (Model, string, integer, boolean, boolean) -> (number)

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

function value = getFrameParameterValue(model, jointName, isParent, ...
    isTranslation, coordNum)
import org.opensim.modeling.*
if(isParent)
    frame = model.getJointSet().get(jointName).getParentFrame();
    offsetFrame = PhysicalOffsetFrame.safeDownCast(frame);
    if(isTranslation)
        value = offsetFrame.get_translation();
    else
        value = offsetFrame.get_orientation();
    end
else
    frame = model.getJointSet().get(jointName).getChildFrame();
    offsetFrame = PhysicalOffsetFrame.safeDownCast(frame);
    if(isTranslation)
        value = offsetFrame.get_translation();
    else
        value = offsetFrame.get_orientation();
    end
end
value = value.get(coordNum);
end