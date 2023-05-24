function IDLoads = inverseDynamics(time,q,qp,qpp,IKLabels,AppliedLoads,modelFile)
% Load Library
import org.opensim.modeling.*;

% Open a Model by name
osimModel = Model(modelFile);

% Initialize the system and get the initial state
osimState = osimModel.initSystem();

% Get the number of coords and markers
numPts = size(time,1);
numControls = size(AppliedLoads,2);
numCoords = osimState.getNQ;

% Split time points into parallel problems
numWorkers = gcp().NumWorkers;
IDLoadsJobs = cell(1, numWorkers);
AccelsTempVec = cell(1, numWorkers);

clear osimModel
clear osimState

parfor worker = 1:numWorkers

    osimModel = Model(modelFile);
    osimState = osimModel.initSystem();
    idSolver = InverseDynamicsSolver(osimModel);

    for j = 1 + (worker - 1) * ceil(numPts / numWorkers) : min(worker * ceil(numPts / numWorkers), numPts)
        osimState.setTime(time(j,1));

        indexOffset = (worker - 1) * ceil(numPts / numWorkers);

        for k=1:size(IKLabels,2)
            if ~osimModel.getCoordinateSet.get(IKLabels{k}).get_locked
                osimModel.getCoordinateSet.get(IKLabels{k}).setValue(osimState,q(j,k));
                osimModel.getCoordinateSet.get(IKLabels{k}).setSpeedValue(osimState,qp(j,k));
            end
        end
        osimModel.realizeVelocity(osimState);

        for i=1:osimState.getNQ
            StateQ = osimState.getQ.get(i-1);

            for ii = 1:size(q,2)
                if abs(q(j,ii)-StateQ) <= 1e-6
                    AccelsTempVec{worker}(j-indexOffset,i) = qpp(j,ii);
                end
            end
        end

        tempMarkerGlobalPos=Vec3;

        newControls = Vector(numControls,0);

        for i=0:numControls-1
            newControls.set(i,AppliedLoads(j,i+1));
        end

        osimModel.setControls(osimState,newControls);
        osimModel.markControlsAsValid(osimState);
        osimModel.realizeDynamics(osimState);

        AccelsVec = Vector(osimState.getNQ,0);

        for i=0:osimState.getNQ-1
            AccelsVec.set(i,AccelsTempVec{worker}(j-indexOffset,i+1));
        end

        IDLoadsVec = Vector;
        IDLoadsVec = idSolver.solve(osimState,AccelsVec);

        for i=0:numCoords-1
            IDLoadsJobs{worker}(j-indexOffset,i+1) = IDLoadsVec.get(i);
        end
    end

end

IDLoads = IDLoadsJobs{1};
for job = 2 : numWorkers
    IDLoads = cat(1, IDLoads, IDLoadsJobs{job});
end

end