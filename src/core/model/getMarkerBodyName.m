% This function takes a model and marker name and returns the name of the
% body the marker is attached to

% Copyright RCNL *change later*

% (Model, string) -> (string)
% Returns a body name for a given model and marker name
function bodyName = getMarkerBodyName(model, markerName)
bodyName = model.findComponent(model.getMarkerSet().get(markerName)...
    .getSocket('parent_frame').getConnecteePath()).getName().toCharArray';
end

