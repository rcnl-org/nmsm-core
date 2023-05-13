
[![Uses MATLAB 2022a](https://img.shields.io/badge/MATLAB-2022a-red)](https://www.mathworks.com/products/matlab.html)
[![Platform Windows, macOS Intel, macOS M1](https://img.shields.io/badge/platform-Windows%20|%20macOS%20Intel%20|%20macOS%20M1-lightgrey)](#requirements)
[![Test - Mac Intel Status](https://github.com/rcnl-org/nmsm-core/actions/workflows/matlab_tests_self_mac_intel.yml/badge.svg)](#testing)
[![Test - Mac M1 Status](https://github.com/rcnl-org/nmsm-core/actions/workflows/matlab_tests_self_mac_m1.yml/badge.svg)](#testing)
[![Test - Windows Status](https://github.com/rcnl-org/nmsm-core/actions/workflows/matlab_tests_self_windows.yml/badge.svg)](#testing)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-blue)](#license)

> Doctors have long known that people differ in susceptibility to disease and response to medicines. But, with little guidance for understanding and adjusting to individual differences, treatments developed have generally been standardized for the many, rather than the few. - National Academy of Engineering

# Table of Contents
- [Table of Contents](#table-of-contents)
- [Introduction](#introduction)
	- [Motivation](#motivation)
- [Modules](#modules)
	- [Joint Model Personalization (JMP)](#joint-model-personalization-jmp)
	- [Data Preprocessing](#data-preprocessing)
	- [Muscle Tendon Personalization (MTP)](#muscle-tendon-personalization-mtp)
	- [Neural Control Personalization (NCP)](#neural-control-personalization-ncp)
	- [Ground Contact Personalization (GCP)](#ground-contact-personalization-gcp)
- [How to Install](#how-to-install)
	- [Requirements](#requirements)
	- [Step-by-Step](#step-by-step)
- [How to Use](#how-to-use)
- [Tutorial](#tutorial)
- [Examples](#examples)
- [Testing](#testing)
- [How to Cite](#how-to-cite)
- [Acknowledgments](#acknowledgments)
- [License](#license)

# Introduction

## Motivation

# Modules
## Joint Model Personalization (JMP)
JMP optimizes the joint parameters of specific joints to reduce Inverse Kinematics errors for a specified marker file.
## Data Preprocessing
This modules prepares large chunks of raw data into the specified format for use in MTP and NCP. It is required to be completed after JMP because the model created from JMP is used to calculate model specific data (IK, ID, Muscle Analysis).
## Muscle Tendon Personalization (MTP)
MTP personalizes the muscle properties of a model based on EMG data
## Neural Control Personalization (NCP)
## Ground Contact Personalization (GCP)
GCP creates a personalized contact array with varying spring constants for calculating more accurate foot-ground contact interactions.
# How to Install

No installation is required, following the instructions below, download the package, open the `Project.prj` file and you are ready to personalize models.

## Requirements
- MATLAB (Tested on 2022b)
    - Optimization Toolbox
    - Parallel Computing Toolbox
    - Statistics and Machine Learning Toolbox
    - Curve Fitting Toolbox
- OpenSim 4.4 or greater
- OpenSim MATLAB Bindings

## Step-by-Step
- Click the green `Code` button at the top right of this page
- Click the `Download Zip` button (or clone the repository if you are familiar with git)
- Unzip the file in a directory of your choosing
- Double-click the `Project.prj` file
  - This adds all of the functions used in the NMSM Pipeline to your path temporarily, until the project is closed.
- Look in the `/example` directory for code snippets to run/test

# How to Use

# Tutorial

A thorough tutorial of all modules in the NMSM Pipeline can be found at [nmsm.rice.edu/tutorial](nmsm.rice.edu/tutorial).

# Examples

# Testing

The NMSM Pipeline uses MATLAB's built-in testing suite alongside GitHub Action self-hosted runners to test a set of files that attempt to test a variety of possible scenarios for the use of the NMSM Pipeline. This suite can be tested by running the `runLocalTestSuite.m` file in the top level of the `/tests` directory. This file requires the current path to be the top level of the project (the same level as `Project.prj`).

# How to Cite

The paper for the NMSM Pipeline is pending publication.

# Acknowledgments



# License

The NMSM Pipeline is licensed under the Apache 2.0 license. Please see [NMSM Pipeline License](https://github.com/rcnl-org/nmsm-core/blob/main/LICENSE.txt) for details.
