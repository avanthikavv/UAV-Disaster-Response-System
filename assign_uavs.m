function uavs = assign_uavs(uavs, topRegions, utilityMap, cfg)
% ASSIGN_UAVS  Assign UAVs to top regions with:
%   - Sensor-aware matching  (Phase 11)
%   - Density control        (Phase 6)
%   - Energy awareness       (Phase 10)
%   - Nearest-first          (Phase 5)

if isempty(topRegions)
    return;
end

N      = numel(uavs);
numReg = numel(topRegions);

%% Track how many UAVs are already committed to each region
regionCount = zeros(1, numReg);

%% Pre-compute density cap per region
densityCap = zeros(1, numReg);
for r = 1:numReg
    s = topRegions(r).score;
    if s >= 75
        densityCap(r) = cfg.maxDensity.high;
    elseif s >= 50
        densityCap(r) = cfg.maxDensity.mid;
    else
        densityCap(r) = cfg.maxDensity.low;
    end
end

%% Build assignment order: prioritise UAVs by energy (highest first)
energies = [uavs.energy];
[~, uavOrder] = sort(energies, 'descend');

for ki = 1:N
    k = uavOrder(ki);
    if contains(uavs(k).task,'Charging')
    
        if isempty(topRegions)
            continue;
        end
    
        nearestDist=inf;
    
        for r=1:numel(topRegions)
    
            targetPos=[topRegions(r).row topRegions(r).col];
    
            d=norm(uavs(k).pos-targetPos);
    
            nearestDist=min(nearestDist,d);
    
        end
    
        travelCycles=ceil(nearestDist/5);

        travelCost=travelCycles*1.5;
        
        missionCost=cfg.missionEnergy;
        
        reserveEnergy=cfg.reserveEnergy;
        
        requiredEnergy=max(35,...
            travelCost+missionCost+reserveEnergy);
    
        if uavs(k).energy>=requiredEnergy
    
            fprintf('\n[SMART REDEPLOY] UAV %d leaving charger | Energy %.1f%% | Required %.1f%%\n',...
                uavs(k).id,uavs(k).energy,requiredEnergy);
    
            uavs(k).task='Idle';
    
        else
    
            continue;
    
        end
    
    end

   
    % Skip critically low energy UAVs
    if uavs(k).energy < 30
        uavs(k).task   = 'RTB';      % Return To Base
        uavs(k).target = [1,1];      % symbolic base
        fprintf('\n[RTB] UAV %d returning to base (%.1f%% battery)\n', ...
            uavs(k).id, uavs(k).energy);
        continue;
    end

    
    % Score each region for this UAV
    bestScore = -Inf;
    
    bestReg   = 0;

    for r = 1:numReg
        % Skip full regions
        if regionCount(r) >= densityCap(r); continue; end

        row = topRegions(r).row;
        col = topRegions(r).col;

        % Distance cost
        dist = norm(uavs(k).pos - [row, col]);
        distCost = dist / 50;   % normalise by grid size

        % Sensor match bonus
        sensorBonus = 0;
        % We use utility score as proxy; thermal UAVs get bonus for high-utility
        % (survivor-heavy) cells, RGB for severity cells
        utilScore = topRegions(r).score;
        % if strcmp(uavs(k).type, 'Thermal')
        %     sensorBonus = utilScore * 0.01;
        % else
        %     sensorBonus = utilScore * 0.008;
        % end
        if strcmp(uavs(k).type,'Thermal')

            if utilScore > 75
                sensorBonus=20;
            else
                sensorBonus=5;
            end
        
        else
        
            if utilScore > 40
                sensorBonus=15;
            else
                sensorBonus=5;
            end
        
        end

        % Energy penalty for distant targets
        if dist > 15 && uavs(k).energy < 50
            continue;  % too far for low-energy UAV
        end
        nearbyUAVs=0;

        for q=1:numel(uavs)

            if q==k
                continue;
            end

            dCrowd=norm(uavs(q).pos-[row col]);

            if dCrowd<12
                nearbyUAVs=nearbyUAVs+1;
            end

        end

        crowdPenalty=25*nearbyUAVs;
        compositeScore = ...
            utilScore*0.8 ...
            + sensorBonus*8 ...
            - distCost*35 ...
            - crowdPenalty;

        if compositeScore > bestScore
            bestScore = compositeScore;
            bestReg   = r;
        end
    end

    if bestReg > 0
        regionCount(bestReg) = regionCount(bestReg) + 1;
        fprintf('Cycle Assignment | UAV %d -> (%d,%d)\n',...
            uavs(k).id,...
            topRegions(bestReg).row,...
            topRegions(bestReg).col);
        uavs(k).target = [topRegions(bestReg).row, topRegions(bestReg).col];

        % Assign task label
        if strcmp(uavs(k).type, 'RGB')
            uavs(k).task = 'DamageAssess';
        else
            uavs(k).task = 'SurvivorDetect';
        end
    else

        randomTarget=[ ...
            randi(cfg.gridSize), ...
            randi(cfg.gridSize)];
    
        uavs(k).task='Patrol';
    
        uavs(k).target=randomTarget;
    
    end
end
end
