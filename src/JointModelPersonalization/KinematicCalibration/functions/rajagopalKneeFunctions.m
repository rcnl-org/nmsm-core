% This function builds a 1 by x cell array of functions to be passed to
% makeKinematicCalibration for optimizing the joint center of the knee for
% a standard knee joint as used in the Rajagopal model

% Copyright RCNL *change later*

% (None) -> ({1 by x} cell array)
% Returns a cell array of functions for optimizing a Rajagopal type knee
function functions = rajagopalKneeFunctions()

end

import KinematicCalibration as kincal

kincal.function.Ragap

