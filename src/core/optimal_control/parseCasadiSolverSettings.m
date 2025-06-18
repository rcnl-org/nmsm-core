% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads the optimal control settings (CasADi based) from a
% separate XML file.
%
% (struct) -> (Array of string)
% CasADi ptimal control solver settings are loaded

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

function inputs = parseCasadiSolverSettings(settingsTree, inputs)
% Required user-defined settings
try
    inputs.numMeshes = getDoubleFromField(getFieldByNameOrError( ...
        settingsTree, "num_meshes"));
    inputs.numCollocationPerMesh = getDoubleFromField( ...
        getFieldByNameOrError(settingsTree, ...
        "num_collocation_points_per_mesh"));
catch
    error("<num_meshes> and <num_collocation_points_per_mesh> are " + ...
        "required CasADi settings elements.")
end

% Default settings that are strongly recommended not to overwrite
inputs.casadi.detect_simple_bounds = true;
inputs.casadi.ipopt.hessian_approximation = 'limited-memory';

% Other default settings
inputs.casadi.ipopt.output_file = 'TreatmentOptimizationIPOPTinfo.txt';
inputs.casadi.ipopt.tol = 1e-4;
inputs.casadi.ipopt.constr_viol_tol = 1e-4;

% Other user-defined settings, which can overwrite above options, and
% assume field names are correct
settingsFields = setdiff(fieldnames(settingsTree.CasadiSettings), ...
    ["num_meshes", "num_collocation_points_per_mesh"])';
for field = settingsFields
    value = settingsTree.CasadiSettings.(field).Text;
    % Convert values to numeric when possible
    if ~isnan(str2double(value))
        value = str2double(value);
    end
    
    settingName = lower(field);
    % Differentiate between CasADi and IPOPT settings
    if startsWith(settingName, "ipopt_")
        settingName = eraseBetween(settingName, 1, 6);
        inputs.casadi.ipopt.(settingName) = value;
    else
        inputs.casadi.(settingName) = value;
    end
end
end
