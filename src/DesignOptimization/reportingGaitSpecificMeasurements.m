% This function is part of the NMSM Pipeline, see file for full license.
%
% This function prints to console gait specific measurements: step length
% asymmetry, step time asymmetry, stride lengh, and final time.
%
% (struct, struct, struct) -> ()
% Prints to console gait specific measurements

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

function reportingGaitSpecificMeasurements(values, modeledValues, params)
for i = 1:length(params.costTerms)
    if isfield(params.costTerms{i}, 'reference_body')
        referenceBody = params.costTerms{i}.reference_body;
    end
end
if ~exist('referenceBody', 'var')
    referenceBody = input('Name of refence body (ex. pelvis): ', 's');
end
stepLengthAsymmetry = calcStepLengthAsymmetry(values, ...
    modeledValues, params, referenceBody);
stepTimeAsymmetry = calcStepTimeAsymmetry(values, ...
    modeledValues, params);
strideLength = calcStrideLength(values, modeledValues,...
    params, referenceBody);
finalTime = values.time(end);

table(stepLengthAsymmetry, stepTimeAsymmetry, strideLength, finalTime, ...
    'VariableNames', ["Step Length Symmetry[Symmetrical = 1]"; ...
    "Step Time Symmetry [Symmetrical = 1]"; "Stride Length [m]"; ...
    "Final Time [s]"])
end