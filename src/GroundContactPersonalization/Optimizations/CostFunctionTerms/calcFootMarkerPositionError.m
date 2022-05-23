% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (Array of double, struct, struct) -> (struct)
% Optimize ground contact parameters according to Jackson et al. (2016)

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

function error = calcFootMarkerPositionError(values, experimentalData, ...
    params)

footError = zeros(size(experimentalData.position, 1), 12);
for i = 1:size(experimentalData.position, 1)
    footError(i, :) = calcModeledMarkerPositions(values, ...
        experimentalData, params);
end

nmm = 2;
toenmm = 3;
footTolerance = HFtol(1,1:9) + nmm;
footTolerance(1,10:12) = Toetol(1,1:3) + toenmm;
error = 1000*footError / (repmat( ...
    experimentalData.initialMarkerErrors + footTolerance, ...
    length(experimentalData.position), 1));

end

function positions = calcModeledMarkerPositions(values, ...
    experimentalData, params)
positions = footcontactmarkermotionlaw2()
end
