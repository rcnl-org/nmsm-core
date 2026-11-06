% This function is part of the NMSM Pipeline, see file for full license.
%
% Reads the parameter section of a .c3d file into a struct of groups, each
% holding its parameters by name (e.g. parameters.POINT.LABELS). Character
% parameters are returned as string arrays with trailing spaces removed and
% numeric parameters as arrays of double. Parameters split across numbered
% continuations (LABELS2, LABELS3, ...) are left as separate fields.
%
% OpenSim's C3DFileAdapter only exposes LABELS, so this is used to reach
% DESCRIPTIONS, UNITS, and FORCE_PLATFORM:CHANNEL.
%
% (string) -> (struct)
% Returns the parameter groups of a .c3d file

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

function parameters = readC3dParameters(c3dFile)
[fileId, isDec] = openC3dFile(c3dFile);
cleanup = onCleanup(@() fclose(fileId));
header = fread(fileId, 2, "uint8");
sectionStart = (header(1) - 1) * 512;
fseek(fileId, sectionStart + 2, "bof");
numBlocks = fread(fileId, 1, "uint8");
fseek(fileId, sectionStart + 4, "bof");
sectionEnd = sectionStart + numBlocks * 512;

groupNames = containers.Map("KeyType", "double", "ValueType", "char");
records = {};
while ftell(fileId) < sectionEnd
    nameLength = abs(fread(fileId, 1, "int8"));
    if isempty(nameLength) || nameLength == 0
        break
    end
    id = fread(fileId, 1, "int8");
    name = char(fread(fileId, nameLength, "uchar")');
    offsetPosition = ftell(fileId);
    offset = fread(fileId, 1, "int16");
    if id < 0
        groupNames(abs(id)) = makeName(name);
    else
        records{end + 1} = {id, makeName(name), ...
            readValue(fileId, isDec)}; %#ok<AGROW>
    end
    if offset == 0
        break
    end
    fseek(fileId, offsetPosition + offset, "bof");
end

parameters = struct();
for i = 1:length(records)
    [id, name, value] = records{i}{:};
    if ~isKey(groupNames, id)
        continue
    end
    parameters.(groupNames(id)).(name) = value;
end
end

% Processor type is stored in the 4th byte of the parameter section:
% 84 = Intel (little-endian), 85 = DEC (little-endian integers, VAX
% floats), 86 = MIPS (big-endian).
function [fileId, isDec] = openC3dFile(c3dFile)
fileId = fopen(c3dFile, "r", "ieee-le");
if fileId < 0
    throw(MException("readC3dParameters:fileNotFound", ...
        "Cannot open c3d file " + c3dFile))
end
parameterBlock = fread(fileId, 1, "uint8");
fseek(fileId, (parameterBlock - 1) * 512 + 3, "bof");
processorType = fread(fileId, 1, "uint8");
isDec = processorType == 85;
if processorType == 86
    fclose(fileId);
    fileId = fopen(c3dFile, "r", "ieee-be");
end
frewind(fileId);
end

function value = readValue(fileId, isDec)
dataType = fread(fileId, 1, "int8");
numDims = fread(fileId, 1, "uint8");
dims = fread(fileId, numDims, "uint8")';
count = prod(dims);
switch dataType
    case -1
        chars = char(fread(fileId, count, "uchar")');
        value = charsToStrings(chars, dims);
    case 1
        value = fread(fileId, count, "uint8");
    case 2
        value = fread(fileId, count, "int16");
    case 4
        value = fread(fileId, count, "float32");
        if isDec
            value = value / 4;
        end
    otherwise
        value = [];
end
if dataType ~= -1 && numDims > 1
    value = reshape(value, dims);
end
end

function values = charsToStrings(chars, dims)
if isempty(dims)
    values = string(strtrim(chars));
    return
end
chars = reshape(chars, dims(1), []);
values = strings(1, size(chars, 2));
for i = 1:size(chars, 2)
    values(i) = strtrim(string(chars(:, i)'));
end
end

function name = makeName(name)
name = matlab.lang.makeValidName(upper(strtrim(name)));
end
