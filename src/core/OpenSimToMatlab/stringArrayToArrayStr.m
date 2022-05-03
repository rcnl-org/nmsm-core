function arrayStr = stringArrayToArrayStr(stringArray)
import org.opensim.modeling.ArrayStr
arrayStr = ArrayStr();
arrayStr.setSize(length(stringArray));
for i=1:length(stringArray)
    arrayStr.set(i-1, stringArray(i));
end
end

