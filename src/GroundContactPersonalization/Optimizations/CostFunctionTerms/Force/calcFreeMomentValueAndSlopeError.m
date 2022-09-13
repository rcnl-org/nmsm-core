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

function [valueError, slopeError] = calcFreeMomentValueAndSlopeError( ...
    values, experimentalData, params)
xq = ECData(1,1) + Moment_z./Fyvals_Calculated;
xq(isnan(xq)) = ECData(1,1);
xq(64:end) = ECData(1,1);
zq = ECData(3,1) - Moment_x./Fyvals_Calculated;
zq(isnan(zq)) = ECData(3,1);
zq(64:end) = ECData(3,1);
free_Torque = Moment_y + Fxvals_Calculated.*(repmat(ECData(3,1)',nframes,1) - zq) - Fzvals_Calculated.*(repmat(ECData(1,1)',nframes,1) - xq);
tfs = linspace(1,nframes,nframes);
FTdiff = abs(COPvals(tfs(Fyvals>100),7) - free_Torque(tfs(Fyvals>100),1));

ft_real_diff = diff(COPvals(tfs(Fyvals>100),7));
ft_calc_diff = diff(free_Torque(tfs(Fyvals>100),1));
ft_slope_diff = abs(abs(ft_real_diff) - abs(ft_calc_diff))/0.01;
end
