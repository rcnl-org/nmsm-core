% This function is part of the NMSM Pipeline, see file for full license.
%
% Returns a handle to the IPOPT mex GPOPS-II ships, which ipopt.m in this
% folder shadows. A function handle binds to the function visible where it
% is created, and the current folder outranks the path, so the handle is
% made from inside the mex's folder. This has to be its own file: inside
% ipopt.m, the name ipopt would resolve to that file itself.
%
% () -> (function_handle)
% Returns a handle to GPOPS-II's IPOPT mex

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Xuanning Liu                                                 %
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

function handle = getGpopsIpoptMex()
wrapperFolder = fileparts(mfilename("fullpath"));
candidates = string(which("ipopt", "-all"));
candidates = candidates(endsWith(candidates, "." + mexext) & ...
    ~startsWith(candidates, wrapperFolder));
if isempty(candidates)
    error("GPOPS-II's ipopt.%s is not on the MATLAB path", mexext)
end
previousFolder = cd(fileparts(candidates(1)));
returnToFolder = onCleanup(@() cd(previousFolder));
handle = str2func("ipopt");
end
