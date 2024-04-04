% This function is part of the NMSM Pipeline, see file for full license.
%
% 
% 
% (String, string, string, double, double, double) -> ()
% Use LHS sampling to find kinematics for surrogate model fitting. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2022 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function makeSurrogateModelKinematics(modelFileName, ...
    kinematicsFileName, outputFileName, samplePoints, angularPadding, ...
    linearPadding)
if nargin < 6 || isempty(linearPadding)
    linearPadding = 0;
end
if nargin < 5 || isempty(angularPadding)
    angularPadding = 0;
end
if nargin < 4 || isempty(samplePoints)
    samplePoints = 25;
end

[coordinateNames, ~, referenceKinematics] = parseMotToComponents( ...
    Model(modelFileName), org.opensim.modeling.Storage( ...
    kinematicsFileName));
lhsKinematics = sampleSurrogateKinematics(modelFileName, ...
    referenceKinematics, coordinateNames, samplePoints, angularPadding, ...
    linearPadding);

writeToSto(coordinateNames, (1 : size(lhsKinematics, 1)) * 1e-3, ...
    lhsKinematics, outputFileName);
end
