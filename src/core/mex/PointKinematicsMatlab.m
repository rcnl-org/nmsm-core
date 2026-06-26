function [SpringPos, SpringVel] = pointKinematicsMatlab(time,q,qp,SpringMat,SpringBodyMat,...
    modelFile,IKLabels)

    % Load Library
    import org.opensim.modeling.*;

    % Open a Model by name
    osimModel = Model(modelFile);

    % Initialize the system and get the initial state
    osimState = osimModel.initSystem();
    
    % Get the number of coords and markers
    numPts = size(time,1);
    numSprings = size(SpringMat,1);

    refBodySet = osimModel.getBodySet; 
        
    for j=1:numPts
        osimState.setTime(time(j,1));
        for k=1:size(IKLabels,2)
            if ~osimModel.getCoordinateSet.get(IKLabels{k}).get_locked
                % 
                osimModel.getCoordinateSet.get(IKLabels{k}).setValue(osimState,q(j,k), false);
                osimModel.getCoordinateSet.get(IKLabels{k}).setSpeedValue(osimState,qp(j,k));
            end
        end
        osimModel.realizeVelocity(osimState);

        for i=1:numSprings
            tempRefParentBody = refBodySet.get(SpringBodyMat(i));
            tempLocalPos = Vec3(3,0);
            tempGlobalPos = Vec3(3,0);
            tempGlobalVel = Vec3(3,0);
            tempLocalPos.set(0,SpringMat(i,1));
            tempLocalPos.set(1,SpringMat(i,2));
            tempLocalPos.set(2,SpringMat(i,3));

            osimModel.getSimbodyEngine.getPosition(osimState,tempRefParentBody,tempLocalPos,tempGlobalPos);
            osimModel.getSimbodyEngine.getVelocity(osimState,tempRefParentBody,tempLocalPos,tempGlobalVel);
            
            for k=0:2
               SpringPos(j,(i-1)*3+k+1)=tempGlobalPos.get(k);
               SpringVel(j,(i-1)*3+k+1)=tempGlobalVel.get(k);
            end
        end
    end
end