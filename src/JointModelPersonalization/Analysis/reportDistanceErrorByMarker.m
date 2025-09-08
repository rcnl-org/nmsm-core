
% (Model, string, cell array) -> (None)
function reportDistanceErrorByMarker(model, markerFileName, ...
    markerNames, outputSto, timeRange)
import org.opensim.modeling.InverseKinematicsSolver
import org.opensim.modeling.SimTKArrayCoordinateReference
import org.opensim.modeling.Storage
import org.opensim.modeling.ArrayStr

model = Model(model);
params.markerNames = markerNames;
markersReference = makeJmpMarkerRef(model, markerFileName, ...
    params);
ikSolver = InverseKinematicsSolver(model, ...
    markersReference, SimTKArrayCoordinateReference());
ikSolver.setAccuracy(1e-6);
state = initModelSystem(model);
if nargin > 4
    state.setTime(timeRange(1));
else
    state.setTime(markersReference.getValidTimeRange().get(0))
end
frequency = markersReference.getSamplingFrequency();
markerTable = markersReference.getMarkerTable();
times = markerTable.getIndependentColumn();
frameCounter = 0;
ikSolver.assemble(state);
storage = Storage();
names = ArrayStr();
names.append('time');
for i=1:length(markerNames)
    if ~strcmp(ikSolver.getMarkerNameForIndex(i-1),"")
        names.append(ikSolver.getMarkerNameForIndex(i-1));
    else
        break
    end
end
storage.setColumnLabels(names);

for i=1:markersReference.getNumFrames() - 1 %start time is set so start with recording error
    ikSolver.track(state);
    error = [];
    for j=0:ikSolver.getNumMarkersInUse()-1
        error(length(error)+1) = ikSolver.computeCurrentMarkerError(j);
    end
    addToRowToStorage(state, storage, error)
    frameCounter = frameCounter + 1;
    if nargin > 4 && (state.getTime() + 1/frequency > timeRange(2))
        break
    end
    time = times.get(markerTable.getNearestRowIndexForTime( ...
        state.getTime() + 1/frequency - 0.00001));
    state.setTime(double(time));
end
storage.print(outputSto);
end

function addToRowToStorage(state, storage, array)
import org.opensim.modeling.Vector
vec = Vector(length(array), 0.0);
for i = 1:length(array)
    vec.set(i-1,array(i));
end
storage.append(state.getTime(), vec);
end

