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
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function integralTerms = parseIntegral(integral, params)
integralStruct.integral = integral;
integralStruct.isEnabled = params.isEnabled;
integralStruct.integralOptions = params.integralOptions;
integralTerms.trackingJointAngles = findCorrectIntegralTerms(1, integralStruct);
integralTerms.trackingJointVelocities = findCorrectIntegralTerms(2, integralStruct);
integralTerms.trackingRightGroundReactions = findCorrectIntegralTerms(3, integralStruct);
integralTerms.trackingLeftGroundReactions = findCorrectIntegralTerms(4, integralStruct);
integralTerms.trackingJointMoments = findCorrectIntegralTerms(5, integralStruct);
integralTerms.trackingMuscleActivations = findCorrectIntegralTerms(6, integralStruct);
integralTerms.minimizingJointAccelerations = findCorrectIntegralTerms(7, integralStruct);
integralTerms.minimizingJointJerk = findCorrectIntegralTerms(8, integralStruct);
end
function output = findCorrectIntegralTerms(index, integralStruct)
output = [];
if integralStruct.isEnabled(index)
[startIndex, endIndex] = findIntegralStartAndEndIndex( ...
    integralStruct.isEnabled, integralStruct.integralOptions, index);
output = integralStruct.integral(:, startIndex:endIndex);
end
end
function [startIndex, endIndex] = findIntegralStartAndEndIndex( ...
    isEnabled, integralOptions, index)
startIndex = 1;
for i=1:index-1
    if isEnabled(i)
        length(integralOptions{i});
        startIndex = startIndex + length(integralOptions{i});
    end
end
endIndex = startIndex + length(integralOptions{index}) - 1;
end