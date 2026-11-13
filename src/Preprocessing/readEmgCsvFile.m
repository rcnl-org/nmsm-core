% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads raw EMG data from a .csv file as exported by motion
% capture software. Lines before the header are skipped, where the header is
% the first row whose first cell is "Time" (in any case). A row of units
% right after the header, such as "s,V,V", is skipped too. Data is read from
% the first numeric row to the next blank or non-numeric row.
%
% (string) -> (Array of string, Array of double, 2D matrix of double)
% Returns the channel names, the time column and one row of data per time

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

function [columnNames, time, data] = readEmgCsvFile(fileName)
lines = strtrim(readlines(fileName));
firstCells = strtrim(extractBefore(lines + ",", ","));
header = find(strcmpi(firstCells, "time"), 1);
if isempty(header)
    throw(MException('', "No header row starting with 'Time' was " + ...
        "found in " + fileName));
end
names = strtrim(split(lines(header), ","))';
names = names(strlength(names) > 0);
columnNames = names(2 : end);

first = header + 1;
while first <= numel(lines) && strlength(lines(first)) > 0 && ...
        isnan(str2double(firstCells(first)))
    first = first + 1;   % a row of units
end
last = first - 1;
while last < numel(lines) && strlength(lines(last + 1)) > 0 && ...
        ~isnan(str2double(firstCells(last + 1)))
    last = last + 1;
end
if last < first
    throw(MException('', "No numeric data follows the header in " + ...
        fileName));
end

cells = split(lines(first : last), ",");
if size(cells, 2) ~= 1 + numel(columnNames)
    % A trailing comma on every row adds an empty last column
    cells = cells(:, 1 : 1 + numel(columnNames));
end
values = str2double(cells);
[badRow, ~] = find(isnan(values), 1);
if ~isempty(badRow)
    throw(MException('', "Row " + (first + badRow - 1) + " of " + ...
        fileName + " has a missing or non-numeric value."));
end
time = values(:, 1);
data = values(:, 2 : end);
end
