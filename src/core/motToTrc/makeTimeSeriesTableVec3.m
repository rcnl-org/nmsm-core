% This function makes a TimeSeriesTableVec3 for a given model and data rate
% for use in a TRCFileAdapter. This function assumes units in meters.

% Copyright RCNL *change later*

% (Model, number) -> (TimeSeriesTableVec3)
% Builds a TimeSeriesTableVec3 from a model and dataRate
function table = makeTimeSeriesTableVec3(model, dataRate)
import org.opensim.modeling.*
table = TimeSeriesTableVec3();
table.addTableMetaDataString("DataRate", num2str(dataRate))
table.addTableMetaDataString("Units", "m")
labels = StdVectorString();
for i=0:model.getMarkerSet().getSize()-1
    labels.add(model.getMarkerSet().get(i).getName())
end
table.setColumnLabels(labels)
end

