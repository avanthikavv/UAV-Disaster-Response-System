# Mission Utility Based Dynamic Multi-UAV Disaster Response System
## MATLAB Implementation

---

## FILES

| File | Phase | Purpose |
|------|-------|---------|
| `main_simulation.m` | Entry | Master script – run this |
| `create_environment.m` | 1 | Generate 2D disaster grid |
| `compute_priority_map.m` | 2 | Priority scores per cell |
| `deploy_uavs.m` | 3 | Initialise UAV structs |
| `find_top_k_regions.m` | 4 | Spatially diverse top-K targets |
| `assign_uavs.m` | 5/6/11 | Density + sensor-aware assignment |
| `move_uavs.m` | 6 | Move UAVs toward targets |
| `update_environment.m` | 7 | Fire/flood spread, new survivors |
| `compute_mission_utility.m` | 9 | MU = 0.4*Surv + 0.3*Sev + 0.2*Access + 0.1*Urgency |
| `update_energy.m` | 10 | Battery drain + RTB recharge |
| `client_selection.m` | 13 | FL client selection scoring |
| `federated_learning.m` | 12 | Async FedAvg aggregation |
| `visualize_simulation.m` | 14 | 6-panel live visualisation |

---

## HOW TO RUN

1. Open MATLAB (R2020b or newer recommended).
2. Set your working directory to this folder:
   ```
   cd('path/to/UAV_Disaster_Sim')
   ```
3. Run:
   ```matlab
   main_simulation
   ```

---

## KEY CONFIGURATION (in main_simulation.m)

| Parameter | Default | Description |
|-----------|---------|-------------|
| `cfg.gridSize` | 50 | Grid dimension (NxN) |
| `cfg.numRGB` | 5 | Number of RGB UAVs |
| `cfg.numThermal` | 5 | Number of Thermal UAVs |
| `cfg.numCycles` | 80 | Total simulation cycles |
| `cfg.topK` | 6 | Top-K priority regions |
| `cfg.maxDensity` | 3/2/1 | Max UAVs per high/mid/low region |
| `cfg.flThreshold` | 10 | FL round every N cycles |
| `cfg.animPause` | 0.15 | Seconds between frames |

---

## VISUALIZATION PANELS

1. **Disaster Environment** – colour-coded grid (fire/flood/landslide/survivor…)
2. **Priority Map** – 0-100 heat map
3. **Mission Utility Map** – composite scoring heat map
4. **UAV Assignments** – UAV positions + target lines on utility background
5. **UAV Energy Levels** – bar chart; red dashed line = critical (20%)
6. **Federated Learning** – aggregated model norm over FL rounds

---

## NOVELTIES IMPLEMENTED

- Dynamic disaster spread (fire, flood, landslide)
- Density-capped UAV allocation (no overcrowding)
- Sensor-aware assignment (RGB → damage; Thermal → survivors)
- Mission Utility Score (4-factor weighted formula)
- Energy-aware scheduling + RTB recharge
- Asynchronous Federated Learning with FedAvg
- Mission-utility + energy + data-quality client selection
