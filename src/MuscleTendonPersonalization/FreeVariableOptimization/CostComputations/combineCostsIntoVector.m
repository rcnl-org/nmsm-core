% This function is part of the NMSM Pipeline, see file for full license.
%
% Combines all tracking and penalization costs into a large vector
%
% (array of number, struct) -> (column vector of number)
% calculates the combined cost for the muscle tendon personalization module

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function output = combineCostsIntoVector(costWeight, costs)
output = [ ...
    % Minimize joint moment tracking errors
    sqrt(costWeight(1)).* costs.momentMatching(:); ...  
    % Penalize difference of tact from set point
    sqrt(costWeight(2)).* costs.activationTimePenalty(:); ...
    % Penalize difference of Anonlin from set point
    sqrt(costWeight(3)).* costs.activationNonlinearityPenalty(:); ...
    % Penalize difference of lmo values from pre-calibrated values
    sqrt(costWeight(4)).* costs.lMoPenalty(:);... 
    % Penalize difference of lts values from pre-calibrated values
    sqrt(costWeight(5)).* costs.lTsPenalty(:);...    
    % Penalize difference of EMGScale from set point
    sqrt(costWeight(6)).* costs.emgScalePenalty(:);... 
    % Penalize change of lMtilda from pre-calibrated values
    sqrt(costWeight(7)).* costs.lMtildaPenalty(:);...    
    % Penalize violation of lMtilda similarity between paired muscles
    sqrt(costWeight(8)).* costs.lmtildaPairedSimilarity(:);...
    % Penalize violation of EMGScales similarity between paired muscles
    sqrt(costWeight(9)).* costs.emgScalePairedSimilarity(:);...  
    % Penalize violation of tdelay similarity between paired muscles
    sqrt(costWeight(10)).*costs.tdelayPairedSimilarity(:);... 
    % Minimize passive force
    sqrt(costWeight(11)).*costs.minPassiveForce(:);...            
    ];
end

