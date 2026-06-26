#DATASET LINK:
https://drive.google.com/drive/folders/1Em0JmZ_F3pPrlOAA3fX83cngL3Rsns_i?usp=drive_link



# Mission Utility Based Dynamic Multi-UAV Disaster Response System

## Project Overview

This project focuses on developing a Mission Utility Based Multi-UAV Disaster Response Framework capable of assisting rescue operations during natural disasters.

The system simulates multiple UAVs (drones) operating in a disaster environment and dynamically assigns tasks based on mission importance, disaster severity, UAV energy level, and operational priorities.

The project combines:

* Multi-UAV Coordination
* Mission Utility Based UAV Selection
* Dynamic Priority Mapping
* Federated Learning Framework
* CNN-Based Disaster Recognition
* Energy-Aware Task Scheduling
* Survivor Detection
* UAV Deployment and Monitoring

The final goal is to create an intelligent disaster response platform where UAVs autonomously identify disaster regions, prioritize critical zones, detect survivors, and coordinate rescue operations efficiently.

---

# Disaster Categories

The CNN model is expected to classify the following disaster classes:

1. Fire
2. Flood
3. Landslide
4. Building Damage
5. Smoke
6. Normal Environment

These classifications will later be used by the UAV framework to determine disaster severity and mission priority.

---

# Project Architecture

The project consists of two major modules.

## Module 1: UAV Disaster Response Framework

Implemented using MATLAB.

Main functionalities:

* Dynamic Disaster Environment Generation
* UAV Deployment
* Mission Utility Calculation
* UAV Selection
* Dynamic Priority Map Generation
* Survivor Detection
* Energy Consumption Tracking
* Return-To-Base Logic
* Federated Learning Simulation
* Visualization Dashboard

Important Files:

### main_simulation.m

Main execution file.

Runs the complete UAV disaster simulation.

---

### create_environment.m

Creates the disaster environment.

Generates:

* Fire Zones
* Flood Zones
* Landslide Zones
* Survivors
* Disaster Severity Map

---

### deploy_uavs.m

Deploys UAVs into the environment.

---

### assign_uavs.m

Assigns UAVs to disaster regions based on mission utility scores.

---

### compute_mission_utility.m

Calculates mission utility score using:

* Remaining Energy
* Distance
* Priority Score
* Task Urgency

---

### compute_priority_map.m

Creates dynamic priority maps used for UAV decision-making.

---

### move_uavs.m

Updates UAV movement throughout the simulation.

---

### avoid_collisions.m

Handles UAV collision avoidance logic.

Future work:

* Improve using Improved Artificial Potential Field (IAPF)
* Maintain minimum 4-meter separation between UAVs

---

### update_environment.m

Dynamically updates the disaster environment.

Simulates:

* Fire Spread
* Flood Expansion
* Landslide Growth
* Severity Changes

---

### federated_learning.m

Simulates federated learning updates between UAVs.

---

### async_fl_update.m

Performs asynchronous federated learning updates.

---

### client_selection.m

Selects UAVs that participate in each FL round.

---

# Module 2: CNN-Based Disaster Recognition

Implemented using MATLAB Deep Learning Toolbox.

Purpose:

Train a CNN model capable of recognizing disaster images.

The CNN output will later be integrated into the UAV framework.

Instead of manually assigning disaster labels, UAV observations will be classified automatically using the trained CNN.

---

# Dataset

Dataset contains images from:

* Fire
* Flood
* Landslide
* Building Damage
* Smoke
* Normal

Dataset location:

Google Drive link will be provided.

Dataset sources:

Public disaster image datasets and Kaggle repositories.

---

# CNN Training

Training file:

train_cnn.m

Current CNN architecture:

ResNet18 (Transfer Learning)

Toolbox Required:

* Deep Learning Toolbox
* Computer Vision Toolbox
* Image Processing Toolbox

Training Process:

1. Load dataset
2. Split dataset into training and validation sets
3. Resize images
4. Apply preprocessing
5. Replace ResNet18 output layer
6. Train model
7. Save trained model

Output:

trained_disaster_cnn.mat

---

# Current CNN Status

Current objective:

Train the CNN model using the complete dataset.

Suggested Split:

* 70% Training
* 30% Testing

Training may be performed using:

* MATLAB Local Machine
* MATLAB Parallel Toolbox
* Google Colab GPU
* External GPU Workstation

---

# Future CNN Integration

After training:

CNN predictions will be integrated into:

1. Disaster Classification
2. Mission Utility Calculation
3. Priority Map Generation
4. UAV Task Assignment
5. Federated Learning Participation

Example Workflow:

Drone Image
↓
CNN Classification
↓
Disaster Type
↓
Priority Score
↓
Mission Utility
↓
UAV Assignment

---

# Current Project Status

Completed:

* Multi-UAV Simulation
* UAV Deployment
* Mission Utility Framework
* Dynamic Priority Mapping
* Survivor Detection
* Energy Management
* Federated Learning Simulation
* Environment Updates
* Visualization

In Progress:

* CNN Training
* Real Drone Footage Collection
* CNN Integration
* Improved Artificial Potential Field Path Planning
* Advanced Collision Avoidance

Planned:

* Real-Time UAV Decision Making
* RGB + Thermal Drone Support
* Obstacle Avoidance
* 4 Meter UAV Separation Constraint
* End-to-End Disaster Response Demonstration

Highest Priority:
- Complete CNN training using train_cnn.m
- Obtain accuracy, confusion matrix and evaluation metrics
- Generate trained_disaster_cnn.mat

---

# How To Run

Open MATLAB Project:

UAV_Disaster_Sim.prj

Run:

main_simulation.m

To train CNN:

Run:

train_cnn.m

To analyze CNN architecture:

net = resnet18;
analyzeNetwork(net);

---

# Notes For Contributors

The immediate priority is completing CNN training and obtaining classification accuracy results.

Once the CNN model is trained successfully, the next phase is integrating CNN outputs into the UAV disaster response framework.

The project is intended to demonstrate a complete disaster response pipeline combining UAV coordination, disaster recognition, and intelligent mission planning.


# Important Note For CNN Training

The file `train_cnn.m` is the primary file responsible for CNN model training.

Anyone working on the CNN module should begin by reviewing and executing this file.

Responsibilities of `train_cnn.m`:

* Load the disaster image dataset
* Create training and validation splits
* Perform image preprocessing
* Load the ResNet18 architecture
* Replace the final classification layers
* Train the CNN model
* Save the trained model (`trained_disaster_cnn.mat`)

If any training-related issue occurs, it is most likely associated with one of the following:

1. Dataset path errors
2. Missing images or corrupted image files
3. Class imbalance issues
4. Image format incompatibilities
5. ResNet18 support package installation
6. MATLAB toolbox dependencies
7. Memory or hardware limitations during training

Before modifying other project files, contributors should first verify that `train_cnn.m` executes successfully and produces a valid trained model.

Expected Output:

`trained_disaster_cnn.mat`

Current Priority:

The highest priority task is obtaining a properly trained CNN model and evaluating its classification accuracy on the disaster dataset.
