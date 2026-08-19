% This function is part of the NMSM Pipeline, see file for full license.
%
% Reads the structure a Ground Contact Personalization contact surface
% needs out of an OpenSim model: which body each marker is attached to,
% and the parent and child body of every joint. Together those let the
% Contact Surfaces tab offer only the markers on the foot - the hindfoot
% body a surface names and the toes body hanging off it - instead of
% every marker in the model.
%
% The joints are resolved with getJointBodyNames, the same helper
% prepareGroundContactPersonalizationInputs uses to find the toes body,
% so the GUI's idea of the foot matches the one the run computes.
%
% An unreadable model clears both lists rather than throwing, matching
% parseModelFileGui, because the caller has already reported the bad file
% through the field's status icon.
%
% (App, string) -> (None)
% Parses marker and joint body structure for the GCP GUI.

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

function parseGcpModelFileGui(app, input_model_file)
import org.opensim.modeling.Model
if strcmp(input_model_file, "")
    clearGcpModelStructure(app);
    return
end
try
    model = Model(char(input_model_file));
    % A model straight off disk has unconnected sockets, so asking a
    % marker for its parent frame throws until this is called.
    model.finalizeConnections();
    [parents, children] = readJointBodies(model);
    [markers, bodies] = readMarkerBodies(model);
    % Joints first: setting the marker names is what fires the app's
    % refresh, and by then the joints have to be in place or the toes
    % body cannot be found and the dropdowns rebuild without it.
    app.setModelJointBodies(parents, children);
    app.setModelMarkerBodies(markers, bodies);
catch
    clearGcpModelStructure(app);
end
end

function clearGcpModelStructure(app)
app.setModelJointBodies(string([]), string([]));
app.setModelMarkerBodies(string([]), string([]));
end

% (Model) -> (Array of string, Array of string)
% Marker names and the body each one sits on, index for index.
function [markers, bodies] = readMarkerBodies(model)
markerSet = model.getMarkerSet();
markers = strings(1, markerSet.getSize());
bodies = strings(1, markerSet.getSize());
for i = 1 : markerSet.getSize()
    marker = markerSet.get(i - 1);
    markers(i) = string(marker.getName().toCharArray');
    bodies(i) = baseFrameName(marker.getParentFrame());
end
end

% (Frame) -> (string)
% A marker usually hangs directly off a body, but it may sit on a
% PhysicalOffsetFrame instead, so walk down to the base frame.
function name = baseFrameName(frame)
try
    name = string(frame.findBaseFrame().getName().toCharArray');
catch
    name = string(frame.getName().toCharArray');
end
end

% (Model) -> (Array of string, Array of string)
% Parent and child body of every joint, index for index.
function [parents, children] = readJointBodies(model)
jointSet = model.getJointSet();
parents = strings(1, jointSet.getSize());
children = strings(1, jointSet.getSize());
for i = 1 : jointSet.getSize()
    try
        [parents(i), children(i)] = getJointBodyNames(model, ...
            jointSet.get(i - 1).getName().toCharArray');
    catch
        % One joint whose frames do not resolve should not cost the
        % whole model its structure; it just cannot name a toes body.
    end
end
end
