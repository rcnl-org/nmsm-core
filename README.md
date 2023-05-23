# Neuromusculoskeletal Modeling (NMSM) Pipeline

<p align='center'>
[![Uses MATLAB 2022a](https://img.shields.io/badge/MATLAB-2022a-red)](https://www.mathworks.com/products/matlab.html)
[![Platform Windows, macOS Intel, macOS M1](https://img.shields.io/badge/platform-Windows%20|%20macOS%20Intel%20|%20macOS%20M1-lightgrey)](#requirements)
[![Test - Mac Intel Status](https://github.com/rcnl-org/nmsm-test-runners/actions/workflows/matlab_tests_self_mac_intel.yml/badge.svg)](#testing)
[![Test - Mac M1 Status](https://github.com/rcnl-org/nmsm-test-runners/actions/workflows/matlab_tests_self_mac_m1.yml/badge.svg)](#testing)
[![Test - Windows Status](https://github.com/rcnl-org/nmsm-test-runners/actions/workflows/matlab_tests_self_windows.yml/badge.svg)](#testing)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-blue)](#license)
</p>

> Doctors have long known that people differ in susceptibility to disease and response to medicines. But, with little guidance for understanding and adjusting to individual differences, treatments developed have generally been standardized for the many, rather than the few. - National Academy of Engineering

## Introduction

The NMSM Pipeline is comprised of two toolsets:

1. Model Personalization - a series of tools for developing a personalized neuromusculoskeletal model to improve the accuracy and physical significance of the joints, muscles, synergies, and ground contact.
2. Treatment Optimization - a series of tools that use a personalized neuromusculoskeletal model to calculate optimal control based conclusions for research and clinical applications.

These toolsets, built in MATLAB using OpenSim, are intended to dramatically reduce the barrier to entry for research in model personalization and treatment optimization.

### Motivation



## Modules

### Joint Model Personalization (JMP)

JMP optimizes the joint parameters of specific joints to reduce Inverse Kinematics errors for a specified marker file.

### Data Preprocessing

This modules prepares large chunks of raw data into the specified format for use in MTP and NCP. It is required to be completed after JMP because the model created from JMP is used to calculate model specific data (IK, ID, Muscle Analysis).

### Muscle Tendon Personalization (MTP)

MTP personalizes the muscle properties of a model based on EMG data

### Neural Control Personalization (NCP)

NCP calculates

### Ground Contact Personalization (GCP)

GCP creates a personalized contact array with varying spring constants for calculating more accurate foot-ground contact interactions.

### Surrogate Model

### Tracking Optimization (TO)

### Verification Optimization (VO)

### Design Optimization (DO)

## How to Install

No installation is required, following the instructions below, download the package, open the `Project.prj` file and you are ready to personalize models.

### Requirements
- MATLAB (Tested on 2022b)
    - Optimization Toolbox
    - Parallel Computing Toolbox
    - Statistics and Machine Learning Toolbox
    - Curve Fitting Toolbox
- OpenSim 4.4 or greater
- OpenSim MATLAB Bindings

### Step-by-Step
- Click the green `Code` button at the top right of this page (or clone the repository if you are familiar with git)
- Click the `Download Zip` button
- Unzip the file in a directory of your choosing
- Double-click the `Project.prj` file
  - This adds all of the functions used in the NMSM Pipeline to your path temporarily, until the project is closed.

## Tutorial

A thorough tutorial of all modules in the NMSM Pipeline can be found at [nmsm.rice.edu/tutorial](https://nmsm.rice.edu/tutorial).

## Examples

Example uses of the NMSM Pipeline are available in the [nmsm-examples repository](https://github.com/rcnl-org/nmsm-examples)

## Testing

The NMSM Pipeline uses MATLAB's built-in testing suite alongside GitHub Action self-hosted runners to test a set of files that attempt to test a variety of possible scenarios for the use of the NMSM Pipeline. This suite can be tested by running the `runLocalTestSuite.m` file in the top level of the `/tests` directory. This file requires the current path to be the top level of the project (the same level as `Project.prj`).

## How to Cite

The paper for the NMSM Pipeline is pending publication.

## Acknowledgments

NMSM Pipeline is developed at Rice University and supported by the US National Institutes of Health (R01 EB030520).

## License

The NMSM Pipeline is licensed under the Apache 2.0 license. Please see [NMSM Pipeline License](https://github.com/rcnl-org/nmsm-core/blob/main/LICENSE.txt) for details.
