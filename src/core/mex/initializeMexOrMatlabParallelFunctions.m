% This function is part of the NMSM Pipeline, see file for full license.
%
% This function initializes the point kinematics and inverse dynamics mex 
% files if the appropriate mex extention exists. It also clears previous
% parallel workers 
%
% (Array of string) -> (double)
% Intializes mex files or clear previous parallel workers 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams, Marleny Vega                               %
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

function version = initializeMexOrMatlabParallelFunctions(modelFile)
version = getOpenSimVersion();
if isequal(mexext, 'mexw64')
    if version >= 40501
        pointKinematicsMexWindows40501(modelFile);
        inverseDynamicsMomentumMetabolicOrientationMexWindows40501(modelFile);
    else
        pointKinematicsMexWindows40400(modelFile);
        inverseDynamicsMomentumMetabolicOrientationMexWindows40400(modelFile);
    end
end
clear inverseDynamicsMatlabParallel
clear pointKinematicsMatlabParallel

clear calcGpopsIntegrand
clear computeGpopsEndpointFunction
clear computeGpopsContinuousFunction
clear calcCasadiIntegrand
clear computeCasadiSymbolicModelFunction
clear computeCasadiFiniteDifferenceModelFunction
clear calcCasadiDynamicConstraint
clear calcSynergyBasedModeledValues
clear calcTorqueBasedModeledValues
clear calcSurrogateModel
end