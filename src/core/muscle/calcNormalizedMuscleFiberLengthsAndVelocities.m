% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the model normalized muscle fiber lengths and
% velocities
%
% Inputs:
% In the experimentalData struct:
% muscleTendonLength - 3d mat (numFrames, numTrials, numMuscles)
% muscleTendonVelocity - 3D mat (numFrames, numTrials, numMuscles)
% vMaxFactor - number
% pennationAngle - 3D mat (1, 1, numMuscles)
% optimalFiberLength - 3D mat (1, 1, numMuscles)
% tendonSlackLength - 3D mat (1, 1, numMuscles)
%
% Other inputs:
% optimalFiberLengthScaleFactors - 3D mat (1, 1, numMuscles)
% tendonSlackLengthScaleFactors - 3D mat (1, 1, numMuscles)
%
% Outputs:
% normalizedFiberLengths - 3D mat (numFrames, numTrials, numMuscles)
% normalizedFiberVelocities - 3D mat (numFrames, numTrials, numMuscles)
%
% (struct, num array, num array) => (3D num array, 3D num array)
% returns computed muscle fiber lengths and velocities with scale factor

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond, Spencer Williams            %
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

function [normalizedFiberLengths, normalizedFiberVelocities] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities(experimentalData, ...
    optimalFiberLengthScaleFactors, tendonSlackLengthScaleFactors)
scaledOptimalFiberLength = experimentalData.optimalFiberLength .* ...
    optimalFiberLengthScaleFactors;
scaledTendonSlackLength = experimentalData.tendonSlackLength .* ...
    tendonSlackLengthScaleFactors;
% Normalized muscle fiber length, equation 2 from Meyer 2017
if isfield(experimentalData, 'muscleTendonLength')
normalizedFiberLengths = (experimentalData.muscleTendonLength - ...
    scaledTendonSlackLength) ./ (scaledOptimalFiberLength .* ...
    cos(experimentalData.pennationAngle));
else
    normalizedFiberLengths = [];
end
% Normalized muscle fiber velocity, equation 3 from Meyer 2017
if isfield(experimentalData, 'muscleTendonVelocity')
normalizedFiberVelocities = (experimentalData.muscleTendonVelocity) ./ ...
    (experimentalData.vMaxFactor .* scaledOptimalFiberLength .* ...
    cos(experimentalData.pennationAngle));
else
    normalizedFiberVelocities = [];
end
end
