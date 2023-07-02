# NMSM Pipeline Archictecture

This document is included to help clarify the organization of the NMSM Pipeline's core codebase and additional auxillary repositories.

## Overview

The NMSM Pipeline is a MATLAB Project, initiated by opening the Project.prj file in the MATLAB GUI. The nmsm-core codebase is contained in the /src directory and contains a directory for each tool and sub-tool as well as a core directory. The purpose of the core directory is to include functions that may be used by more than one tool or have value beyond an individual tool's utility.

Additional repositories exist to facilitate the NMSM Pipeline:

- nmsm-examples - examples from code used during development of the pipeline.
- nmsm-test - a repository of tests to ensure functionality is correct and maintained over time.
- nmsm-test-runner - a private repository for running local test runners on Windows, Mac Intel and Mac M1 to ensure compatibility.

## Additional Information

Because of MATLAB's immature project management ecosystem, a few issues may arise from attempting to build a large codebase in MATLAB.

- Shadowing may occur due to the large number of functions and unique function names are not actively monitored. Developers should start their development of a new function with typing 'help *function name*' into the GUI console to see if any functions in the namespace already have that name.
- Parsing XML files is especially difficult in MATLAB and the result is a series of parse functions that pose the opportunity to be an issue as the pipeline matures.

Other items of note:

- Auxillary plotting functions
