% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns the joint function representing the function
% parameters for use as a function to be passed in the Joint Model
% Personalization and Kinematic Calibration modules.
% 
% (string, boolean, boolean, integer) -> (function)
% Returns the appropriate function for given input parameters

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

function fn = makeJointFunction(jointName, isParent, isTranslation, ...
    coordinateNumber)
if(isParent && isTranslation)
    fn = @(value, model) adjustParentTranslation(model, jointName, ...
        coordinateNumber, value);
end
if(isParent && ~isTranslation)
    fn = @(value, model) adjustParentOrientation(model, jointName, ...
        coordinateNumber, value);
end
if(~isParent && isTranslation)
    fn = @(value, model) adjustChildTranslation(model, jointName, ...
        coordinateNumber, value);
end
if(~isParent && ~isTranslation)
    fn = @(value, model) adjustChildOrientation(model, jointName, ...
        coordinateNumber, value);
end
end

