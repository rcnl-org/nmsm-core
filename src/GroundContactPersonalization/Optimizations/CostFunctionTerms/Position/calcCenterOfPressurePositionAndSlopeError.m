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

function [valueError, slopeError] = ...
    calcCenterOfPressurePositionAndSlopeError(values, experimentalData, ...
    params)

xq = ECData(1,1) + Moment_z./Fyvals_Calculated;
xq(isnan(xq)) = ECData(1,1);
xq(64:end) = ECData(1,1);
zq = ECData(3,1) - Moment_x./Fyvals_Calculated;
zq(isnan(zq)) = ECData(3,1);
zq(64:end) = ECData(3,1);
COPxdiff = abs(COPvals(tfs(Fyvals>100),1) - xq(tfs(Fyvals>100),1));
COPzdiff = abs(COPvals(tfs(Fyvals>100),3) - zq(tfs(Fyvals>100),1));

xcop_real_diff = diff(COPvals(tfs(Fyvals>100),1));
xcop_calc_diff = diff(xq(tfs(Fyvals>100),1));
xcop_slope_diff = abs(abs(xcop_real_diff) - abs(xcop_calc_diff))/0.01;
zcop_real_diff = diff(COPvals(tfs(Fyvals>100),2));
zcop_calc_diff = diff(zq(tfs(Fyvals>100),1));
zcop_slope_diff = abs(abs(zcop_real_diff) - abs(zcop_calc_diff))/0.01;
end
