% This function is part of the NMSM Pipeline, see file for full license.
%
% This function computes the relative path from a base directory to a
% target file path, handling cross-platform path separators and returning
% the original path unchanged when the paths span different drives.
%
% (string, string) -> (string)
% Returns the relative path from basePath to filePath

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
% function relativePath = getRelativePath(filePath, basePath)
%     if strcmp(filePath, "")
%         relativePath = filePath;
%         return
%     end
%     if nargin < 2
%         basePath = pwd;
%     end
% 
%     % If the path given is already relative, or is in a different drive, we
%     % are not dealing with it.
%     basePathParts = strsplit(fileparts(basePath), ["\", "/"]);
%     if ~startsWith(fileparts(filePath), basePathParts(1))
%         relativePath = filePath;
%         return
%     end
% 
%     file = java.io.File(filePath).getCanonicalFile();
%     base = java.io.File(basePath).getCanonicalFile();
% 
%     relativePath = char(base.toURI().relativize(file.toURI()).getPath());
% end

function relativePath = getRelativePath(filePath, basePath)
    if strcmp(filePath, "")
        relativePath = filePath;
        return
    end
    if nargin < 2 || isempty(basePath)
        basePath = pwd;
    end

    % Normalize both paths to absolute, canonical forms with consistent separators
    filePath = strrep(GetFullPath(filePath), '\', '/');
    basePath = strrep(GetFullPath(basePath), '\', '/');

    % Split into parts, filtering empty strings from leading/trailing slashes
    fileParts = strsplit(filePath, '/');
    baseParts = strsplit(basePath, '/');
    fileParts = fileParts(~cellfun('isempty', fileParts));
    baseParts = baseParts(~cellfun('isempty', baseParts));

    % On Windows, check for different drives — cannot relativize across drives
    if ~isempty(fileParts) && ~isempty(baseParts)
        if ~strcmpi(fileParts{1}, baseParts{1}) && ...
                ~isempty(regexp(fileParts{1}, '^[A-Za-z]:$', 'once'))
            relativePath = filePath;
            return
        end
    end

    % Find the index of the last common ancestor
    numCommon = 0;
    maxCommon = min(numel(fileParts), numel(baseParts));
    while numCommon < maxCommon && strcmpi(fileParts{numCommon+1}, baseParts{numCommon+1})
        numCommon = numCommon + 1;
    end

    % One '../' for each remaining segment in basePath beyond the common root,
    % then append the remaining segments of filePath
    numUp = numel(baseParts) - numCommon;
    upParts = repmat({'..'},  1, numUp);
    downParts = fileParts(numCommon+1:end);

    allParts = [upParts, downParts];
    if isempty(allParts)
        relativePath = '.';
    else
        relativePath = strjoin(allParts, '/');
    end
end