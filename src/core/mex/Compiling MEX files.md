## Compiling MEX files

New versions of MEX files may need to be compiled with new OpenSim API versions. These directions apply to compiling new MEX files for Windows only and adding them for use in the NMSM Pipeline. 

1. Install [Visual Studio Community or Build Tools for Visual Studio](https://visualstudio.microsoft.com/vs/older-downloads/). 
   The version of Visual Studio should match your MATLAB version. Check compatibility at: https://www.mathworks.com/support/requirements/previous-releases.html
   Click your MATLAB release, then "Supported Compilers". For example, R2024b supports Microsoft Visual C++ 2022.

2. While installing Visual Studio, download the Desktop development with C++, which includes Windows SDK, MSVC v143 build tools, and C++ core features.

3. Make sure Matlab is configured to use the correct compiler by running `mex -setup C++` in the Command Window. If the configured version is not 'Microsoft Visual C++ XXXX'(the version you installed), use one of the options given to choose the correct compiler. 

4. Inside the scripts `compileInverseDynamicsMex.m` and `compilePointKinematicsMex.m` in the `nmsm-core\src\core\mex` directory, replace the references to the OpenSim installation directory with the directory on your computer for the OpenSim version you are compiling for. Keep the internal structure (such as `sdk\lib`) the same, only changing the start of the paths.
   If compilation fails, possible reasons include OpenSim requiring a newer C++ standard or changes to the SDK folder structure. Check the compiler flags and library paths in the script.

5. Change the include statement linking the Windows SDK `ucrt` directory to match your local Windows SDK installation. The only difference between your path and the one in the script is likely a version number. 

6. Run the compilation script. If everything was linked correctly, you will see `Building with 'Microsoft Visual C++ XXXX'(the version you installed). MEX completed successfully.` for each script. 

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

## Compiling the single-thread point kinematics MEX for GCP

Ground Contact Personalization (GCP) uses MATLAB's parallel computing toolbox to compute finite-difference gradients in parallel. Each parallel worker calls the point kinematics MEX function, which internally uses multiple threads. Running both at the same time causes thread over-subscription and significantly slows down GCP. To avoid this, GCP uses a separate single-thread version of the point kinematics MEX, so that MATLAB's parallel workers are the only level of parallelism.

The source file `PointKinematicsSingleThread.cpp` is identical to `PointKinematics.cpp` with one change: `#define NTHREADS 1` instead of `#define NTHREADS 20`.

To compile it:

1. Follow the same compilation steps as for the standard point kinematics MEX, but in `compilePointKinematicsMex.m` change `PointKinematics.cpp` to `PointKinematicsSingleThread.cpp` before running.

2. Rename the compiled file to `pointKinematicsSingleThreadMexWindowsXXXXX.mexw64`, where `XXXXX` is the OpenSim version number from `getOpenSimVersion()`.

3. Open `prepareGroundContactPersonalizationInputs.m` and find the `copyMexFunction` subfunction near the bottom of the file. Add a new version check at the top of the if block that routes the new version to your single-thread file:

```matlab
if version >= XXXXX
    mexPath = fullfile(mexPath, 'pointKinematicsSingleThreadMexWindowsXXXXX.mexw64');
elseif version >= 40600
    mexPath = fullfile(mexPath, 'pointKinematicsSingleThreadMexWindows40600.mexw64');
elseif version >= 40501
    ...
```

GCP will now automatically use the single-thread MEX for the new OpenSim version. Treatment Optimization continues to use the standard multi-thread MEX through `pointKinematics.m`, which is unaffected by this change.