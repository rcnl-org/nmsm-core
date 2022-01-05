% This function is part of the NMSM Pipeline, see file for full license.
%
% A SimTK Array of CoordinateReference is needed for the
% InverseKinematicSolver for use in a few modules. This function takes a
% model for reference and params. The params are a struct where the fields
% are the name of the coordinates for the CoordinateReference and each of
% these fields is a struct containing the parameters of the specific
% CoordinateReference.
% params.mtp_angle_l = struct('weight',100.0)
% produces a param variable such that the SimTKArrayCoordinateReference
% will contain one CoordinateReference with a weight of 100 with the name
% 'mtp_angle_l'.
%
% (Model, struct) -> (SimTKArrayCoordinateReference)
% Builds the Coordinate Reference Array for InverseKinematicSolver

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

function coordinateReferences = makeCoordinateReferences(model, params)
import org.opensim.modeling.*
coordinateReferences = SimTKArrayCoordinateReference();
tasks = string(fieldnames(params));
for i=1:length(tasks)
   value = model.getCoordinateSet().get(tasks(i)).getDefaultValue();
   coordinateReference = CoordinateReference(tasks(i), Constant(value));
   modifyWeight(coordinateReference, params.(tasks(i)));
   coordinateReferences.push_back(coordinateReference)
end
end

% (CoordinateReference, struct) -> (CoordinateReference)
% Mutates the CoordinateReference with the weight from the params, if valid
function modifyWeight(coordRef, params)
if(isfield(params, 'weight'))
    if(isnumeric(params.weight))
       coordRef.setWeight(params.weight)
    end    
end
end