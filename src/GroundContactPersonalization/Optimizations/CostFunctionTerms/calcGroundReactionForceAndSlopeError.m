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
    calcGroundReactionForceAndSlopeError(values, experimentalData, params)

yPens = zeros(nframes,nvals);
normvel = zeros(nframes,nvals);
for j = 1:nframes
    for i = 1:nvals
         ClearanceVars = footcontactoutvecallparams(JointLocRa,JRotR,SPLocR(i,:)',RQDataHF_opt(j,:)',RQDataT_opt(j,1),RQpDataHF_opt(j,:)',RQpDataT_opt(j,1),[0;0;0]);
        if i <= numhfr     
            yPens(j,i) = max(-ClearanceVars(2,1),0);
            normvel(j,i) = -(ClearanceVars(8,1));
        else     
            yPens(j,i) = max(-ClearanceVars(13,1),0);
            normvel(j,i) = -(ClearanceVars(19,1));
        end
    end
end


Fy = repmat(Kvals',nframes,1).*yPens.*(1+repmat(cvals',nframes,1).*normvel);
Fyvals_Calculated = sum(Fy,2);
valueError = abs(Fyvals - Fyvals_Calculated);
y_real_diff = diff(Fyvals);
y_calc_diff = diff(Fyvals_Calculated);
slopeError = ((abs(abs(y_real_diff) - abs(y_calc_diff)))/5);
end

