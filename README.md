# Mission Utility Based Dynamic Multi-UAV Disaster Response System

## Project Overview

This project simulates a fleet of UAVs (drones) performing disaster response operations in dynamic environments.

The system integrates:

* Mission Utility Based UAV Selection
* Dynamic Priority Mapping
* Federated Learning Framework
* Energy-Aware UAV Scheduling
* Return-To-Base (RTB) and Charging Logic
* Survivor Detection
* Multi-Disaster Monitoring

## Disaster Classes

The CNN model is designed to classify:

1. Fire
2. Flood
3. Landslide
4. Building Damage
5. Smoke
6. Normal Environment

## CNN Model

Architecture:

* ResNet18 (Transfer Learning)

Framework:

* MATLAB Deep Learning Toolbox

## Dataset

Dataset collected from Kaggle and public disaster image repositories.

Classes include:

* Fire
* Flood
* Landslide
* Building Damage
* Smoke
* Normal

## Training Procedure

* Dataset split: 70% Training
* Dataset split: 30% Testing

Training performed using MATLAB Deep Learning Toolbox and ResNet18 transfer learning.

## Future Integration

CNN predictions will be integrated into:

* Mission Utility Score computation
* Priority Map generation
* UAV task assignment
* Federated Learning participation

## Current Status

Completed:

* UAV Simulation
* Federated Learning Framework
* Energy Management
* Survivor Detection
* Dynamic Priority Mapping
* Visualization Dashboard

In Progress:

* CNN Training
* Real Drone Footage Integration
* UAV Path Planning with Obstacle Avoidance
