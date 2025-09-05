% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the value of marker position
%
% (struct, Array of number, 2D matrix, Array of string) -> (Array of number)
% returns the  calculated marker position

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

function [pathTerm, constraintTerm] = ...
    calcMarkerPositionValuePathConstraint( ...
    constraintTerm, time, markerPositions, inputs)
assert(isfield(constraintTerm, "marker"), constraintTerm.type + ...
    " must have a marker specified.");
assert(isfield(constraintTerm, "axes"), constraintTerm.type + ...
    " must have axes specified.");
[positions, constraintTerm] = findMarkerPositionDataByLabels( ...
    constraintTerm, inputs, markerPositions, time, ...
    constraintTerm.marker, constraintTerm.axes);

assert(all(size(positions, [2, 3]) == [1, 1]), "Marker " + ...
    "constraints may only use one axis.")
pathTerm = positions;
end
