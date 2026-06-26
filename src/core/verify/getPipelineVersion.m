% This function is part of the NMSM Pipeline, see file for full license.
%
% This function hard codes the version of the software. It is used to
% check compatibility between the software and the settings files for
% different versions of the software.
%
% This value should be updated with each release. Please use semantic
% versioning (https://semver.org/) to determine the version number.
%
% Specifically, versions are of the form MAJOR.MINOR.PATCH
% MAJOR version when you make incompatible API changes,
% MINOR version when you add functionality in a backwards compatible manner,
% PATCH version when you make backwards compatible bug fixes.
%
% () -> (string)
% return: version number of the software as a string

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

function version = getPipelineVersion()
version = "1.5.2";
end
