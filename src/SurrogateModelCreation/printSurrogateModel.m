% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
% 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function printSurrogateModel(numMuscles, ...
    polynomialExpressionMuscleTendonLengths, ...
    polynomialExpressionMuscleTendonVelocities, ...
    polynomialExpressionMomentArms, jointAngles, resultsDirectory)

fid = fopen(fullfile(resultsDirectory, 'PatientSpecificSurrogateModel.m'), 'wt');
fprintf(fid, 'function [matrix] = PatientSpecificSurrogateModel(jointAngles, jointVelocities, numMuscles)\n');
fprintf(fid, 'onesCol = ones(size(jointAngles, 1), 1);\n');
fprintf(fid, 'zeroCol = zeros(size(jointAngles, 1), 1);\n');
fprintf(fid, 'switch numMuscles\n');
for i=1:numMuscles
    fprintf(fid, ['    case ' num2str(i) '\n']);
    for j=1:size(jointAngles{i}, 2)
        fprintf(fid, ['        theta' num2str(j) ' = jointAngles(:, ' num2str(j) ');\n']);
    end
    for j=1:size(jointAngles{i}, 2)
        fprintf(fid, ['        thetaDot' num2str(j) ' = jointVelocities(:, ' num2str(j) ');\n']);
    end
    fprintf(fid, '        muscleTendonLengths = [');
    for j=1:size(polynomialExpressionMuscleTendonLengths{i}, 2)
        if polynomialExpressionMuscleTendonLengths{i}(1,j) == 1
            fprintf(fid, ' onesCol,');
        else
            fprintf(fid, [' ' strrep(strrep(char(polynomialExpressionMuscleTendonLengths{i}(1,j)),'*','.*'),'^','.^') ',']);
        end
    end
    fprintf(fid, '];\n');
    fprintf(fid, '        muscleTendonVelocities = [');
    for j=1:size(polynomialExpressionMuscleTendonVelocities{i}, 2)
        if polynomialExpressionMuscleTendonVelocities{i}(1,j) == 1
            fprintf(fid, ' onesCol,');
        elseif polynomialExpressionMuscleTendonVelocities{i}(1,j) == 0
            fprintf(fid, ' zeroCol,'); 
        else
            fprintf(fid, [' ' strrep(strrep(char(polynomialExpressionMuscleTendonVelocities{i}(1,j)),'*','.*'),'^','.^') ',']);
        end
    end
    fprintf(fid, '];\n');
    for k=1:size(polynomialExpressionMomentArms{i},1)
        fprintf(fid, ['        momentArms' num2str(k) ' = [']);
        for j=1:size(polynomialExpressionMomentArms{i},2)
            if polynomialExpressionMomentArms{i}(k,j) == 0
                fprintf(fid, ' zeroCol,');     
            elseif polynomialExpressionMomentArms{i}(k,j) / coeffs(polynomialExpressionMomentArms{i}(k,j)) == 1
                fprintf(fid, [char(polynomialExpressionMomentArms{i}(k,j)) '*onesCol,']);
            else
                fprintf(fid, [' ' strrep(strrep(char(polynomialExpressionMomentArms{i}(k,j)),'*','.*'),'^','.^') ',']);
            end
        end
        fprintf(fid, '];\n');
    end
    fprintf(fid, '        matrix = [muscleTendonLengths; muscleTendonVelocities;');
    for k=1:size(polynomialExpressionMomentArms{i}, 1)
        fprintf(fid, ['momentArms' num2str(k) '; ']);
    end
    fprintf(fid, '];\n');
end
fprintf(fid, 'end\n');
fprintf(fid, 'end\n');
fclose(fid);
end