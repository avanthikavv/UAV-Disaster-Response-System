%% =========================================================
%  MISSION UTILITY BASED DYNAMIC MULTI-UAV DISASTER RESPONSE
%  Main Simulation Entry Point
%  =========================================================
clear; clc; close all;

%% ---- CONFIGURATION ----
cfg.gridSize        = 50;       % NxN grid
cfg.numRGB          = 5;        % RGB UAVs
cfg.numThermal      = 5;        % Thermal UAVs
cfg.numCycles       = 100;       % Simulation cycles
cfg.topK            = 15;        % Top-K priority regions to consider
cfg.maxDensity = struct('high',1,'mid',1,'low',1); % UAV density caps
cfg.flThreshold     = 10;       % FL aggregation every N cycles
cfg.animPause       = 0.15;     % Pause between frames (seconds)
cfg.energyPerCell=1.5;
cfg.missionEnergy=10;
cfg.reserveEnergy=15; 
%% ---- PHASE 1: Environment Creation ----
fprintf('[PHASE 1] Creating disaster environment...\n');
env = create_environment(cfg.gridSize);
totalSurvivorPopulation=sum(env.survivor(:));
fprintf('Total Survivor Population = %d\n',totalSurvivorPopulation);
latestDetection='No detections yet';
%% ---- PHASE 2: Priority Map ----
fprintf('[PHASE 2] Generating priority map...\n');
priorityMap = compute_priority_map(env);

%% ---- PHASE 3: Multi-UAV Deployment ----
fprintf('[PHASE 3] Deploying UAVs...\n');
uavs = deploy_uavs(cfg.numRGB, cfg.numThermal, cfg.gridSize);

%% ---- FEDERATED LEARNING STATE ----
flState = init_fl_state(cfg.numRGB + cfg.numThermal);
coverageMap=zeros(cfg.gridSize,cfg.gridSize);
collisionWarnings=0;
collisionPairs={};
%% ---- MAIN SIMULATION LOOP ----
fprintf('[SIM] Starting main simulation loop (%d cycles)...\n', cfg.numCycles);
figure('Name','UAV Disaster Response Simulation','Position',[50 50 1400 750]);

for cycle = 1:cfg.numCycles
    %% Phase 2 (dynamic): Update priority map
    priorityMap = compute_priority_map(env);

    %% Phase 9: Mission Utility Scores
    utilityMap = compute_mission_utility(env, priorityMap, uavs);

    %% Phase 4: Identify Top-K regions
    topRegions = find_top_k_regions(utilityMap, cfg.topK);

    %% Phase 5+6+11: Assign UAVs (density + sensor aware)
    uavs = assign_uavs(uavs, topRegions, utilityMap, cfg);

    %% Phase 6: Move UAVs toward targets
    uavs = move_uavs(uavs, cfg.gridSize);

    uavs = avoid_collisions(uavs,cfg.gridSize);
    for i=1:length(uavs)-1

        for j=i+1:length(uavs)
    
            d=norm(uavs(i).pos-uavs(j).pos);
    
            pair=sprintf('%d-%d',min(i,j),max(i,j));
    
            if d<=1
    
                if ~ismember(pair,collisionPairs)
    
                    collisionWarnings=collisionWarnings+1;
    
                    collisionPairs{end+1}=pair;
    
                    fprintf('[COLLISION WARNING] UAV %d <-> UAV %d\n', ...
                        uavs(i).id,uavs(j).id);
    
                end
    
            end
    
        end
    
    end
    for k=1:numel(uavs)

        r=uavs(k).pos(1);
        c=uavs(k).pos(2);

        radius=2;

        for rr=max(1,r-radius):min(cfg.gridSize,r+radius)
        
            for cc=max(1,c-radius):min(cfg.gridSize,c+radius)
        
                coverageMap(rr,cc)=1;
        
            end
        
        end

    end
    for k = 1:length(uavs)

        if contains(uavs(k).task,'OnSite')
    
            r=uavs(k).pos(1);
            c=uavs(k).pos(2);
    
            if env.grid(r,c)==5
    
                if env.detectedSurvivors(r,c)==0
    
                    uavs(k).survivorsDetected = ...
                        uavs(k).survivorsDetected + env.survivor(r,c);
    
                    logEntry=sprintf( ...
                        'Cycle %d : Survivor at (%d,%d) : %d people', ...
                        cycle,r,c,env.survivor(r,c));
                    fprintf('Cell Population = %d\n',env.survivor(r,c));
                    latestDetection=logEntry;
                    disp(' ')
                    disp('***** SURVIVOR DETECTED *****')
                    disp(logEntry)
                    disp(['Detected By UAV ',num2str(uavs(k).id)])
                    disp('*****************************')
    
                    uavs(k).detectionLog{end+1}=logEntry;
    
                    env.detectedSurvivors(r,c)=1;
                    uavs(k).dataAge=0;
                end
    
            
            elseif env.grid(r,c)==1

                if env.monitoredFire(r,c)==0
            
                    uavs(k).firesMonitored = ...
                        uavs(k).firesMonitored + 1;
            
                    env.monitoredFire(r,c)=1;
                    uavs(k).dataAge=0;
                    fprintf('\n[FIRE] Cycle %d | UAV %d | Location (%d,%d)\n', ...
                        cycle,uavs(k).id,r,c);
            
                end
    
            elseif env.grid(r,c)==4

                if env.assessedBuilding(r,c)==0
            
                    uavs(k).buildingsAssessed = ...
                        uavs(k).buildingsAssessed + 1;
            
                    env.assessedBuilding(r,c)=1;
                    uavs(k).dataAge=0;
                    fprintf('\n[BUILDING] Cycle %d | UAV %d | Location (%d,%d)\n', ...
                        cycle,uavs(k).id,r,c);
            
                end
            
            end
            uavs(k).task='Idle';
            uavs(k).target=[];
        end
    
    end
    %% Phase 10: Update energy
    uavs = update_energy(uavs);

    %% Phase 7: Dynamic environment update
    %% ===== ASYNC FL =====

    for k=1:length(uavs)

        if contains(uavs(k).task,'RTB') || ...
                contains(uavs(k).task,'Charging')

            continue;

        end

        enoughData=uavs(k).dataQuality>0.6;

        enoughEnergy=uavs(k).energy>40;

        enoughDelay=...
            cycle-uavs(k).lastUploadCycle>=5;

        if enoughData && ...
                enoughEnergy && ...
                enoughDelay

            flState=...
                async_fl_update(...
                flState,...
                uavs(k),...
                cycle);

            uavs(k).lastUploadCycle=cycle;

            uavs(k).lastGlobalRound=...
                flState.globalRound;

        end

    end
    env = update_environment(env, cycle);

    %% Phase 12-13: Federated Learning (every flThreshold cycles)
    if mod(cycle, cfg.flThreshold) == 0
        selectedUAVs = client_selection(uavs, utilityMap);
        flState      = federated_learning_round(flState, uavs, selectedUAVs, cycle);
    end

    %% Phase 14: Visualize
    visualize_simulation(env, priorityMap, utilityMap, uavs, flState, cycle, cfg, latestDetection);
    pause(cfg.animPause);
end

totalSurvivors=0;
totalFires=0;
totalBuildings=0;

for k=1:length(uavs)

    totalSurvivors=totalSurvivors+uavs(k).survivorsDetected;

    totalFires=totalFires+uavs(k).firesMonitored;

    totalBuildings=totalBuildings+uavs(k).buildingsAssessed;

end

disp(['Survivors Detected: ',num2str(totalSurvivors)])
successRate=100*totalSurvivors/max(totalSurvivorPopulation,1);

fprintf('Detection Success Rate / Object Detection Accuracy: %.2f%%\n',successRate);
disp(['Fires Monitored: ',num2str(totalFires)])

disp(['Buildings Assessed: ',num2str(totalBuildings)])
coverageRate=100*nnz(coverageMap)/numel(coverageMap);

fprintf('Coverage Rate: %.2f%%\n',coverageRate);


avgEnergy=mean([uavs.energy]);

activeUAVs=0;

for k=1:length(uavs)

    if ~contains(uavs(k).task,'Charging') && ...
       ~contains(uavs(k).task,'RTB')

        activeUAVs=activeUAVs+1;

    end

end
fprintf('Active UAVs: %d/%d\n',...
    activeUAVs,length(uavs));

fprintf('Average Remaining Energy: %.2f%%\n',avgEnergy);

disp(' ')
disp('===== SURVIVOR DETECTION LOG =====')

for k=1:length(uavs)

    if ~isempty(uavs(k).detectionLog)

        fprintf('\nUAV %d\n',uavs(k).id)

        for j=1:length(uavs(k).detectionLog)

            disp(uavs(k).detectionLog{j})

        end

    end

end
collisionRate=collisionWarnings/cfg.numCycles;

fprintf('Collision Warnings: %d\n',collisionWarnings);
fprintf('Collision Rate: %.2f\n',collisionRate);
fprintf('[SIM] Simulation complete.\n');
disp('thank you')