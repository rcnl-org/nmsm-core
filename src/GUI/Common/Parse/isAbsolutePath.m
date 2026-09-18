% This function is part of the NMSM Pipeline, see file for full license.
%
% Reports whether a path is already absolute, so a path read from a
% settings file is only resolved against that file's directory when it is
% actually relative. Handles Windows drive letters and UNC shares as well
% as POSIX roots, since settings files travel between platforms.
%
% (string) -> (logical)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function isAbsolute = isAbsolutePath(path)
path = string(path);
isAbsolute = false;
if strlength(path) == 0
    return
end
% \\server\share or //server/share
if startsWith(path, "\\") || startsWith(path, "//")
    isAbsolute = true;
    return
end
% C:\ or C:/
if ~isempty(regexp(path, '^[A-Za-z]:[\\/]', 'once'))
    isAbsolute = true;
    return
end
isAbsolute = startsWith(path, "/") || startsWith(path, "\");
end
