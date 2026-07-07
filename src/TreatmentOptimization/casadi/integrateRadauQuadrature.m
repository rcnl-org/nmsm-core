% This function is part of the NMSM Pipeline, see file for full license.
%
% 
% (Array of double, struct, Array of double) -> (Array of double)
% 
% Perform Radau Quadrature to integrate cost terms or modeled values.

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

function integral = integrateRadauQuadrature(integrand, inputs, time)
integral = zeros(1, size(integrand, 2));
for mesh = 1 : inputs.numMeshes
    lowerIndex = (mesh - 1) * inputs.numCollocationPerMesh + 1;
    upperIndex = mesh * inputs.numCollocationPerMesh + 1;
    lowerBound = time(lowerIndex);
    upperBound = time(upperIndex);
    currentValues = integrand(lowerIndex + 1 : upperIndex, :);
    weights = lookupRadauQuadratureWeights(inputs.numCollocationPerMesh);
    scaledWeights = weights * (upperBound - lowerBound) / 2;
    integral = integral + sum(currentValues .* scaledWeights', 1);
end
end

% Retrieve weights for possible CasADi orders precomputed with below method
function weights = lookupRadauQuadratureWeights(order)
switch order
    case 1
        weights = 2;
    case 2
        weights = [1.50000000000000	0.500000000000000];
    case 3
        weights = [0.752806125400936	1.02497165237684	...
            0.222222222222222];
    case 4
        weights = [0.440924422353548	0.776386937686343	...
            0.657688639960119	0.125000000000000];
    case 5
        weights = [0.287427121582482	0.562712030298921	...
            0.623653045951483	0.446207802167141	0.0800000000000000];
    case 6
        weights = [0.201588385253501	0.416901334311900	...
            0.520926783189576	0.485387188468969	0.319640753220511	...
            0.0555555555555556];
    case 7
        weights = [0.148988471112046	0.318204231467304	...
            0.424703779005953	0.447109829014567	0.380949873644231	...
            0.239227489225312	0.0408163265306122];
    case 8
        weights = [0.114508814744306	0.249647901329862	...
            0.347014795634502	0.391572167452493	0.376517545389119	...
            0.304130620646785	0.185358154802978	0.0312500000000000];
    case 9
        weights = [0.0907145049233297	0.200553298024567	...
            0.286386696357221	0.337693966975931	0.348273002772966	...
            0.316843775670439	0.247189378204593	0.147654019046315	...
            0.0246913580246914];
    otherwise
        error("Order must be an integer from 1 to 9. Got " + order)
end
end

% % Method based on https://mathworld.wolfram.com/RadauQuadrature.html
% function weights = calcRadauQuadratureWeights(radauPoints, order)
% % Opposite direction and different scaling from CasADi output
% inverseRadau = -(radauPoints(end:-1:1) * 2 - 1);
% weights = (1 - inverseRadau) ./ ...
%     (order ^ 2 * (legendreP(order - 1, inverseRadau)) .^ 2);
% % Reverse weights back into CasADi order
% weights = weights(end:-1:1);
% end
