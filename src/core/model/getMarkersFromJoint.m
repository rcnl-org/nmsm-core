% This function returns the markers attached to the distal and proximal
% bodies of a given model and joint name.
% REQUIRES PREREQUISITE system initialized model: model.initSystem()
% or using nmsm-core's shadow Model() function which initSystem's
% automatically

% Copyright RCNL *change later*

% (Model, string) -> (1D Array of strings)
% Returns the names of markers attached to the bodies around a given joint
function markerNames = getMarkersFromJoint(model, jointName)
markerNames = {};
[parentName, childName] = getJointBodyNames(model, jointName);
for j=0:model.getMarkerSet().getSize()-1
    markerName = model.getMarkerSet().get(j).getName().toCharArray';
    markerParentName = getMarkerBodyName(model, markerName);
    if(strcmp(markerParentName, parentName) || strcmp(markerParentName, childName))
        if(~markerIncluded(markerNames, markerName))
            markerNames{length(markerNames)+1} = markerName;
        end
    end
end
end

% returns true if the marker is in the list of marker names
function output = markerIncluded(markerNames, marker)
for i=1:length(markerNames)
    if(strcmp(markerNames{i}, marker))
        output=true;
        return
    end
end
output=false;
end