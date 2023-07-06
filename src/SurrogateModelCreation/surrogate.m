% This function is part of the NMSM Pipeline, see file for full license.
%
% The following script can be used to create a surrogate model of the
% muscle tendon lengths, moment arms, and muscle tendon velocities

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
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

%% Required Values
inputSettings.model = 'preprocessed\exampleModel.osim';
inputSettings.dataDirectory = 'preprocessed';
inputSettings.epsilon = 1e-4;
inputSettings.polynomialDegree = 5;
% Indicate 'true' or 'false' for performing latin hyper cube sampling 
inputSettings.performLatinHyperCubeSampling = 'false';
% Indicate the coordinates that should be used in the surrogate model
inputSettings.surrogateModelCoordinateNames = ["hip_adduction_l", ...
    "hip_flexion_l", "hip_rotation_l", "knee_angle_l", "ankle_angle_l", ...
    "subtalar_angle_l", "hip_adduction_r", "hip_flexion_r", ...
    "hip_rotation_r", "knee_angle_r", "ankle_angle_r", "subtalar_angle_r"];

% If performLatinHyperCubeSampling is set to true, set the range multiplier
% and the number of points used for latin hyper cube sampling, otherwise,
% leave blank
inputSettings.lhsRangeMultiplier = [];
inputSettings.lhsNumPoints = [];

%% *Optional* Values
% The trial prefix is the prefix of each output file, identifying the
% motion such as 'gait' or 'squat' or 'step_up'.
inputSettings.trialPrefixes = ["gait_1", "gait_2", "gait_3"];
% Results directory, if blank, results are printed to current directory
inputSettings.resultsDirectory = [];

%% Create surrogate model
SurrogateModelCreation(inputSettings);