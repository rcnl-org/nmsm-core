% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, Array of double, Array of string, Array of string) -> 
% (Array of number, struct)
%
% Finds total controlled moment in an array given a label.

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

function [controlledMoment, term] = findControlledJointMomentByLabel( ...
    term, inputs, modeledValues, torqueControls, loadName)
if isfield(term, 'internalMuscleMomentIndex')
    muscleMomentIndex = term.internalMuscleMomentIndex;
    torqueLoadIndex = term.internalTorqueLoadIndex;
else
    if strcmpi(inputs.controllerType, "synergy")
        muscleCoordinateIndex = findCoordinateIndicesFromLoadNames( ...
            inputs.coordinateNames, loadName);
        muscleMomentIndex = find(inputs.surrogateModelIndex == ...
            muscleCoordinateIndex, 1);
        if isempty(muscleMomentIndex)
            muscleMomentIndex = -1;
        end
        term.internalMuscleMomentIndex = muscleMomentIndex;
    else
        muscleMomentIndex = -1;
        term.internalMuscleMomentIndex = -1;
    end
    torqueLoadIndex = findCoordinateIndicesFromLoadNames( ...
        inputs.torqueControllerCoordinateNames, loadName);
    term.internalTorqueLoadIndex = torqueLoadIndex;
    assert(muscleMomentIndex > 0 || torqueLoadIndex > 0, loadName ...
        + " is not a controlled load")
end

if muscleMomentIndex > 0
    synergyLoad = modeledValues.muscleJointMoments(:, muscleMomentIndex);
else
    synergyLoad = 0;
end
if torqueLoadIndex > 0
    torqueLoad = torqueControls(:, torqueLoadIndex);
else
    torqueLoad = 0;
end

controlledMoment = synergyLoad + torqueLoad;
end
