% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
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

function inputs = reorderPreprocessedDataByMuscleNames(inputs, muscleNames)

indexesInParsedMuscleData = ...
    ismember(inputs.muscleTendonColumnNames, muscleNames);

inputs.muscleTendonColumnNames = ...
    inputs.muscleTendonColumnNames(indexesInParsedMuscleData);
inputs.muscleTendonLength = inputs.muscleTendonLength(:, ...
    indexesInParsedMuscleData, :);
inputs.muscleTendonVelocity = inputs.muscleTendonVelocity(:, ...
    indexesInParsedMuscleData, :);

indexesInParsedCoordinateData = ...
    ismember( ...
        inputs.inverseDynamicsMomentsColumnNames, ...
        inputs.coordinateNames ...
    );
indexesInParsedMuscleAnalysisData = ...
    ismember( ...
        inputs.momentArmsCoordinateNames, ...
        inputs.coordinateNames ...
    );

inputs.inverseDynamicsMoments = ...
    inputs.inverseDynamicsMoments(:, indexesInParsedCoordinateData, :);
inputs.momentArms = inputs.momentArms(:, indexesInParsedMuscleAnalysisData, ...
    indexesInParsedMuscleData, :);

if (isfield(inputs, "mtpActivationsColumnNames"))
indexesInParsedActivationData = ...
    ismember(inputs.mtpActivationsColumnNames, muscleNames);

inputs.mtpActivationsColumnNames = ...
    inputs.mtpActivationsColumnNames(indexesInParsedActivationData);
inputs.mtpActivations = ...
    inputs.mtpActivations(:, indexesInParsedActivationData, :);
end

end

