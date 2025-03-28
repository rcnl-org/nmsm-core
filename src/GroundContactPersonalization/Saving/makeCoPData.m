% This function is part of the NMSM Pipeline, see file for full license.
%
% (Array of double) -> (Array of double)
% Convert ground reaction data to center of pressure format. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function dataCoP = makeCoPData(data)
forceCutoff = 5;
dataCoP = zeros(size(data));
Fx = data(:, 1);
Fy = data(:, 2);
Fz = data(:, 3);
px = data(:, 4);
py = data(:, 5);
pz = data(:, 6);
Tx = data(:, 7);
Ty = data(:, 8);
Tz = data(:, 9);
framesToConvert = Fy > forceCutoff;
dataCoP(~framesToConvert, :) = data(~framesToConvert, :);
dataCoP(:, 1:3) = data(:, 1:3);
qy = py;
qx = px + (Tz - Fx .* (py - qy)) ./ Fy;
qz = pz - (Tx + Fz .* (py - qy)) ./ Fy;
dataCoP(framesToConvert, 4:6) = [qx(framesToConvert), ...
    qy(framesToConvert), qz(framesToConvert)];
dataCoP(:, [7, 9]) = zeros(size(dataCoP(:, [7, 9])));
freeMoment = Ty + Fx .* (pz - qz) - Fz .* (px - qx);
dataCoP(framesToConvert, 8) = freeMoment(framesToConvert);
end
