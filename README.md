# Neuromusculoskeletal Modeling (NMSM) Pipeline

<p align='center'>
<a href="https://www.mathworks.com/products/matlab.html">
    <img src="https://img.shields.io/badge/MATLAB-2022b-red" alt="MATLAB 2022b Badge">
</a>
<a href="#requirements">
    <img src="https://img.shields.io/badge/platform-Windows%20|%20macOS%20Intel%20|%20macOS%20M1-brightgreen" alt="Requirements Badge">
</a>
<a href="#license">
    <img src="https://img.shields.io/badge/license-Apache%202.0-blue" alt="License Badge">
</a>
</p>

> Doctors have long known that people differ in susceptibility to disease and response to medicines. But, with little guidance for understanding and adjusting to individual differences, treatments developed have generally been standardized for the many, rather than the few. - National Academy of Engineering

## Introduction

The NMSM Pipeline is comprised of two toolsets:

1. Model Personalization - a series of tools for developing a personalized neuromusculoskeletal model to improve the accuracy and physical significance of the joints, muscles, synergies, and ground contact.
2. Treatment Optimization - a series of tools that use a personalized neuromusculoskeletal model to calculate optimal control based conclusions for research and clinical applications.

These toolsets, built in MATLAB using OpenSim, are intended to dramatically reduce the barrier to entry for research in model personalization and treatment optimization.

## Modules

### Joint Model Personalization (JMP)

JMP optimizes the joint parameters of specific joints to reduce Inverse Kinematics errors for a specified marker file. JMP also allows optimization of marker placement and body scaling.

### Data Preprocessing

This modules prepares large chunks of raw data into the specified format for use in MTP and NCP. It is required to be completed after JMP because the model created from JMP is used to calculate model specific data (IK, ID, Muscle Analysis).

### Muscle Tendon Model Personalization (MTP)

MTP personalizes the muscle properties of a model from EMG data. MTP includes Synergy Extrapolation, a process to solve for missing EMG data.

### Neural Control Model Personalization (NCP)

NCP calculates the muscle activations of muscles for which no EMG data is available through solving for optimal muscle synergies.

### Ground Contact Model Personalization (GCP)

GCP creates a personalized contact array with varying spring constants for calculating more accurate foot-ground contact interactions.

### Surrogate Model Creation

The time varying quantities muscle-tendon lengths, muscle-tendon velocities, and moment arms are calculated using polynomial functions of the joint angles and velocities that share common coefficients.

### Tracking Optimization (TO)

TO focuses on finding the optimal control strategies, either torque-driven or synergy-driven, that closely match the experimental motion, moments, external loads (if applicable), and muscle activity (if applicable). By minimizing the discrepancy between the predicted and experimental data, Tracking Optimization aims to reproduce the experimental movement.

### Verification Optimization (VO)

VO ensures that the calibrated controllers, derived from Tracking Optimization, can reproduce the experimental data even when tracking those quantities is eliminated. This validation step enhances the reliability and robustness of the predictions generated by Treatment Optimization.

### Design Optimization (DO)

DO offers users the flexibility to test and explore various treatment strategies by customizing cost functions, path constraints, and terminal conditions. Design Optimization empowers researchers, clinicians, and practitioners to tailor the treatment to the specific needs and goals of the individual, paving the way for optimized outcomes and improved patient care.

## How to Install

No installation is required, following the instructions below, download the package, open the `Project.prj` file and you are ready to personalize models and optimize treatments.

### Requirements
- MATLAB (Tested on 2022b)
    - Optimization Toolbox
    - Parallel Computing Toolbox
    - Statistics and Machine Learning Toolbox
    - Curve Fitting Toolbox
    - Symbolic Math Toolbox
    - Signal Processing Toolbox
- OpenSim 4.4 or greater
- [OpenSim MATLAB Bindings](https://simtk-confluence.stanford.edu:8443/display/OpenSim/Scripting+with+Matlab)
- [GPOPS-II Optimal Control Solver](https://www.gpops2.com/) (for Treatment Optimization, not used in Model Personalization)

### Step-by-Step
- Navigate to the [NMSM Pipeline SimTK Project](https://simtk.org/projects/nmsm).
- Go to the download section and download the latest version.
- Unzip the file in a directory of your choosing
- Double-click the `Project.prj` file
  - This adds all of the functions used in the NMSM Pipeline to your path temporarily, until the project is closed.

## Tutorial

A thorough tutorial of all modules in the NMSM Pipeline can be found at [nmsm.rice.edu/tutorial](https://nmsm.rice.edu/tutorial).

## Examples

Example uses of the NMSM Pipeline are available in the [nmsm-examples repository](https://github.com/rcnl-org/nmsm-examples)

## Testing

The NMSM Pipeline uses MATLAB's built-in testing suite alongside GitHub Action self-hosted runners to test a set of files that attempt to test a variety of possible scenarios for the use of the NMSM Pipeline. This suite can be tested by running the `runLocalTestSuite.m` file in the top level of the [nmsm-test repository](https://github.com/rcnl-org/nmsm-test). This repository requires the project (`Project.prj`) to be open.

## How to Cite

The paper for the NMSM Pipeline is pending publication.

## Acknowledgments

NMSM Pipeline is developed at Rice University and supported by the US National Institutes of Health (R01 EB030520).

## License

The NMSM Pipeline is licensed under the Apache 2.0 license. Please see [NMSM Pipeline License](https://github.com/rcnl-org/nmsm-core/blob/main/LICENSE.txt) for details.
