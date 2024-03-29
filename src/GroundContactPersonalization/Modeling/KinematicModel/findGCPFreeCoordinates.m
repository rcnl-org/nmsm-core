% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns an array of names of coordinates that connect the
% ground to the contact bodies. These coordinates all will be modeled in
% the kinematic model for GCP.
%
% (Model, Array of string) -> (Array of string)
% Create an array of coordinate names connecting the bodies to ground

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

function coordinatesOfInterest = findGCPFreeCoordinates(model, ...
    contactBodies)
model = Model(model);
bodyStructure = makeBodyTree(model);

bodiesOfInterest = string([]);
for i=1:length(contactBodies)
    [~, path] = getFieldByName(bodyStructure, contactBodies(i));
    bodiesOfInterest = unique([bodiesOfInterest, string(path)]);
end

coordinatesOfInterest = getCoordinatesFromBodies(model, bodiesOfInterest);
end

