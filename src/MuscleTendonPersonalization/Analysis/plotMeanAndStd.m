% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes a mean and standard deviation and plots the mean with
% a solid line and shades +/- 1 standard deviation from the mean. 
%
% (Array), (Array), (Array), (String) -> (None)
% Plot passive moment curves from file.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
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
function plotMeanAndStd(mean, std, time, color)
    plot(time, mean, color, linewidth=2)
    FillRegion = [(mean+std); flipud(mean-std)];
    fill([time, fliplr(time)]', FillRegion, color, FaceAlpha=0.2, ...
        EdgeColor='none', HandleVisibility='off')
end