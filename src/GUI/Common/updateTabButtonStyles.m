% This function is part of the NMSM Pipeline, see file for full license.
%
% This function highlights the navigation button matching the currently
% selected tab and restores the base style on all other buttons. The tabs
% and tabButtons arrays must be the same length and ordered so that
% tabButtons(i) navigates to tabs(i).
%
% (Tab, Array of Tab, Array of Button) -> ()
% Highlights the navigation button for the selected tab

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
function updateTabButtonStyles(selectedTab, tabs, tabButtons)
highlightColor = [1 1 1];
baseColor = [0.1294 0.1804 0.4];
for i = 1:length(tabButtons)
    if tabs(i) == selectedTab
        tabButtons(i).BackgroundColor = highlightColor;
        tabButtons(i).FontColor = baseColor;
    else
        tabButtons(i).BackgroundColor = baseColor;
        tabButtons(i).FontColor = highlightColor;
    end
end
end
