% This function compares the error between two sets of markers by comparing
% them element-wise

% Copyright RCNL *change later*

% (Model, struct) -> (float)
% calculates the error between experimental marker pos and model marker pos
function error = markerError(model, params)
modelMarkerPositions = findModelMarkerPositions(model);
error = params.experimentalMarkerPositions - modelMarkerPositions;
end

