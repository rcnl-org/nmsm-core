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

