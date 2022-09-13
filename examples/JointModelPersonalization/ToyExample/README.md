# Toy Example

This example assumes the Project.prj for nmsm-core is active in order to add the appropriate functions to your path.

This example is a very basic implementation of JMP on a single joint parameter. This example was created by isolating an elbow joint, creating an .mot file of a constant speed elbow flexion and creating a perfect (error <1e-5 meters) trc file from the .mot.

To create simple_arm_oriented_away.osim, the joint parameter was updated to include a dramatic translation offset. Similarly for simple_arm_oriented_away.osim, a significant orientation change was made to the model. These models can be opened in OpenSim and inverse kinematics can be used to understand the motion of the data.

The three example files are: XMLToyExample.m, SingleTranslationExample.m, and SingleOrientationExample.m

## XMLToyExample.m

This script shows how to use an XML file to converge the x translation back to the original simple_arm.osim value (as expect since the .trc data is a perfect match of the original motion from simple_arm.osim).

## SingleTranslationExample.m

This script sets up a JMP optimization of the x translation programmatically. This can allow for additional functionality if necessary over using an XML file.

## SingleOrientationExample.m

This script sets up a JMP optimization of the x orientation programmatically. This can allow for additional functionality if necessary over using an XML file.

