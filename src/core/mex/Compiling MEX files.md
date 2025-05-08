## Compiling MEX files

New versions of MEX files may need to be compiled with new OpenSim API versions. These directions apply to compiling new MEX files for Windows only and adding them for use in the NMSM Pipeline. 

1. Install [Visual Studio Community Edition 2019](https://visualstudio.microsoft.com/vs/older-downloads/).

2. While installing Visual Studio, download the Windows SDK (tested with Windows 10), available during Visual Studio Community setup or [alternatively here](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/).

3. Make sure Matlab is configured to use the correct compiler by running `mex -setup C++` in the Command Window. If the configured version is not 'Microsoft Visual C++ 2019', use one of the options given to choose the correct compiler. 

4. Inside the scripts `compileInverseDynamicsMex.m` and `compilePointKinematicsMex.m` in the `nmsm-core\src\core\mex` directory, replace the references to the OpenSim installation directory with the directory on your computer for the OpenSim version you are compiling for. Keep the internal structure (such as `sdk\lib`) the same, only changing the start of the paths.

5. Change the include statement linking the Windows SDK `ucrt` directory to match your local Windows SDK installation. The only difference between your path and the one in the script is likely a version number. 

6. Run the compilation script. If everything was linked correctly, you will see `Building with 'Microsoft Visual C++ 2019'.
MEX completed successfully.` for each script. 

These steps will compile new MEX files. To add them to the NMSM Pipeline:

1. You will need the OpenSim API version number in a number format. Assuming the API version linked to Matlab is the same as the one you just compiled, run getOpenSimVersion() in the Command Window to get this number. As an example, running this function on OpenSim 4.7 should return `40700`.

2. Rename the compiled inverse dynamics and point kinematics MEX functions to `inverseDynamicsWithExtraCalcsMexWindowsXXXXX.mexw64` and `pointKinematicsMexWindowsXXXXX.mexw64` respectively. The `XXXXX` should be replaced with the version number from the previous step. 

3. Open `inverseDynamics.m` and `pointKinematics.m`. These files have a similar structure, each with a portion inside an `if isequal(mexext, 'mexw64')` statement. 

4. In each file, copy the first if statement inside the `mexw64` case and paste a copy above it. As an example, if 4.5.1 is the most recent MEX version, you would copy this:

```
    if version >= 40501
        [inverseDynamicsMoments, angularMomentum, metabolicCost, ...
            massCenterVelocity] = ...
            inverseDynamicsWithExtraCalcsMexWindows40501(time, ...
            jointAngles, jointVelocities, jointAccelerations, ...
            coordinateLabels, appliedLoads, muscleActivations, ...
            computeAngularMomentum, computeMetabolicCost);
```

5. Change the original if statement below your copy to an elseif statement. 

6. Change the version number in your copied if statement at the top of the block to your current version number from the first step, and change the function call inside this if statment to use your new MEX file. 

The NMSM Pipeline will now be able to use your new MEX functions when needed. 