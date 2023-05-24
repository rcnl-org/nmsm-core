function IDLoads = inverseDynamicsMatlab(time,q,qp,qpp,IKLabels,AppliedLoads,modelFile)
    % Load Library
    import org.opensim.modeling.*;

    % Open a Model by name
    osimModel = Model(modelFile);

    % Initialize the system and get the initial state
    osimState = osimModel.initSystem();
    idSolver = InverseDynamicsSolver(osimModel);
    
    % Get the number of coords and markers
    numPts = size(time,1);
    numControls = size(AppliedLoads,2);
    numCoords = osimState.getNQ;
        
    AccelsTempVec = zeros(numPts,numCoords);
     for j=1:numPts
        osimState.setTime(time(j,1));

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
                    AccelsTempVec(j,i) = qpp(j,ii);
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
            AccelsVec.set(i,AccelsTempVec(j,i+1));
        end
        
        IDLoadsVec = Vector;
        IDLoadsVec = idSolver.solve(osimState,AccelsVec);

        for i=0:numCoords-1
           IDLoads(j,i+1) = IDLoadsVec.get(i); 
        end

    end
end