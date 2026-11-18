% This function is part of the NMSM Pipeline, see file for full license.
%
% Advanced feature for users who edit ipopt.opt by hand. IPOPT reads
% ipopt.opt from the current folder by itself, but the IPOPT build GPOPS-II
% ships crashes MATLAB once that file adds about 5 options (see
% gpopsIpoptWrapper/ipopt.m). When ipopt.opt exists, this puts
% gpopsIpoptWrapper/ipopt.m in front of that IPOPT for one gpops2 run, which
% removes the limit and prints IPOPT's own option table. Without ipopt.opt
% it does nothing. The folder stays off the project path; the returned
% onCleanup object takes it off the MATLAB path again when cleared, also on
% error or Ctrl+C.
%
% How to write ipopt.opt:
%   - Plain text file named ipopt.opt in MATLAB's current folder, one
%     option per line
%   - Its options replace the values GPOPS-II passes: those from the
%     solver settings file and those GPOPS-II sets by itself,
%     e.g. hessian_approximation limited-memory,
%     mu_strategy, ma57_automatic_scaling
%   - Use IPOPT 3.12.9 option names (the version GPOPS-II ships); a
%     misspelled name stops the run. List, for a newer IPOPT:
%     https://coin-or.github.io/Ipopt/OPTIONS.html
%   - "used" in the table printed before the solve tells whether IPOPT
%     read each option
%   Example, for a warm start from a converged solution:
%     bound_push 1e-8                 # avoid IPOPT pushing the initial
%                                     # start away and losing feasibility
%     slack_bound_push 1e-8
%     limited_memory_max_history 20   # default 6
%     theta_max_fact 0.01             # default 1e4
%
% () -> (onCleanup or empty)
% Routes GPOPS-II's IPOPT calls through gpopsIpoptWrapper if ipopt.opt exists

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

function cleanup = useGpopsIpoptWrapper()
cleanup = [];
if ~isfile("ipopt.opt")
    return
end
wrapperFolder = fullfile(fileparts(mfilename("fullpath")), ...
    "gpopsIpoptWrapper");
addpath(wrapperFolder, "-begin");
cleanup = onCleanup(@() rmpath(wrapperFolder));
ipopt("reset");
fprintf("\nNOTE: using %s\n      Its options override those from " + ...
    "the solver settings file and GPOPS-II. Rename or delete it to " + ...
    "run without it.\n\n", fullfile(pwd, "ipopt.opt"));
end
