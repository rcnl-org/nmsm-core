# Isolated Knee Example

This example assumes the Project.prj for nmsm-core is active in order to add the appropriate functions to your path.

This example is an implementation of JMP on an isolated knee joint trial. This example was created with a gait model and a .trc file that was experimentally taken in the motion lab. Use Inverse Kinematics to see the motion (l_knee.trc). The XML file illustrates the structure required to call a single task with appropriate joint parameters optimized.

In an isolated knee example, the joint parameters to optimize are determined by Reinbolt's (2005) interpretation of the free parameters of the knee.

Simply run IsolatedKneeExample.m with the nmsm-core project loaded and it will converge. It may take a little time, but the optimizer will output the progress.

After the run is complete, you can use the script in PlotBeforeAndAfterMarkerError to visualize the different throughout the trial data.