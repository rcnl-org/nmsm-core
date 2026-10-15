% This function is part of the NMSM Pipeline, see file for full license.
%
% This function makes a GUI window show the hand pointer while the mouse is
% over anything clickable: an enabled button, or an image with a click
% callback. App Designer buttons have no pointer of their own, so the
% window's pointer is switched as the mouse moves. Buttons that are hidden,
% disabled or on a tab that is not selected are ignored.
%
% (Figure) -> ()
% Shows the hand pointer over a window's buttons

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
function enableButtonHoverPointerGui(fig)
fig.WindowButtonMotionFcn = @(~, ~) updatePointer(fig);
end

function updatePointer(fig)
if ~isvalid(fig)
    return
end
pointer = 'arrow';
if isOverClickable(fig, fig.CurrentPoint)
    pointer = 'hand';
end
if ~strcmp(fig.Pointer, pointer)
    fig.Pointer = pointer;
end
end

% Looked up on each move, since some windows add and remove buttons
function over = isOverClickable(fig, point)
over = false;
targets = [findall(fig, 'Type', 'uibutton'); ...
    findall(fig, 'Type', 'uistatebutton'); findall(fig, 'Type', 'uiimage')];
for target = targets'
    if target.Type == "uiimage" && isempty(target.ImageClickedFcn)
        continue
    end
    if ~target.Enable || ~isShown(target, fig)
        continue
    end
    position = getpixelposition(target, true);
    if point(1) >= position(1) && point(1) <= position(1) + position(3) && ...
            point(2) >= position(2) && point(2) <= position(2) + position(4)
        over = true;
        return
    end
end
end

% Whether a component and everything holding it are visible, counting a
% tab that is not selected as hidden
function shown = isShown(component, fig)
shown = true;
while ~isequal(component, fig)
    parent = component.Parent;
    % Tabs have no Visible property; only the selected one is shown
    if isa(component, 'matlab.ui.container.Tab')
        hidden = ~isequal(parent.SelectedTab, component);
    else
        hidden = ~component.Visible;
    end
    if hidden
        shown = false;
        return
    end
    component = parent;
end
end
