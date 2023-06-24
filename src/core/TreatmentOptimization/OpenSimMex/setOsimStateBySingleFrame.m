% This function is part of the NMSM Pipeline, see file for full license.
%
% This function assigns the state positions and velocities to the OpenSim
% model, for a single time frame.
%
% (struct, Model, State, Cell, number) -> (Model, State)
% 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function [osimModel, osimState] = setOsimStateBySingleFrame(values, ...
    osimModel, osimState, coordinateNames, indx)

osimState.setTime(values.time(indx, 1));
for k=1:size(coordinateNames,2)
    if ~osimModel.getCoordinateSet.get(coordinateNames{k}).get_locked
        osimModel.getCoordinateSet.get(coordinateNames{k}). ...
            setValue(osimState, values.statePositions(indx, k));
        osimModel.getCoordinateSet.get(coordinateNames{k}). ...
            setSpeedValue(osimState, values.stateVelocities(indx, k));
    end
end
osimModel.realizeVelocity(osimState);
end