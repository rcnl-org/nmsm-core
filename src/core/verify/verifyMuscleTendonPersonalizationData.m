% This function is part of the NMSM Pipeline, see file for full license.
%
% This function sees if the first 3 dimensions of inputs.jointMoment,
% inputs.muscleTendonLength, inputs.muscleTendonVelocity,
% inputs.muscleTendonMomentArm, and inputs.emgData have the same size.
%
%
% (struct) -> (None)
% Checks if first 3 dimensions of each data type matches

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

function verifyMuscleTendonPersonalizationData(inputs)
verifyFieldsExist(inputs)
try
    sizeReference = size(inputs.muscleTendonLength);
    verifyLength(sizeReference, 3)
%     if(~all(sizeReference == size(inputs.muscleTendonLength)))
%         error(); end
%     momentArmSize = size(inputs.muscleTendonMomentArm);
%     if(~all(sizeReference == momentArmSize(1:3)))
%         error(); end
%     if(~all(sizeReference == size(inputs.emgData))) error(); end
catch
    throw(MException('','data value dimensions do not match'))
end
end

function verifyFieldsExist(inputs)
verifyField(inputs, 'jointMoment')
verifyField(inputs, 'muscleTendonLength')
verifyField(inputs, 'muscleTendonVelocity')
verifyField(inputs, 'muscleTendonMomentArm')
verifyField(inputs, 'emgData')
end

