function uavs = deploy_uavs(numRGB, numThermal, gridSize)
% DEPLOY_UAVS  Initialise all UAVs with random starting positions.
%
% UAV struct fields:
%   id          - unique integer
%   type        - 'RGB' | 'Thermal'
%   pos         - [row, col]
%   target      - [row, col]  ([] = no target)
%   energy      - 0-100
%   task        - string description
%   flModel     - simple weight vector (for federated learning)
%   dataQuality - 0-1 (updated per cycle)

N = gridSize;
totalUAVs = numRGB + numThermal;
uavs = struct();

for k = 1:totalUAVs
    uavs(k).id          = k;
    uavs(k).pos         = [randi(N), randi(N)];
    uavs(k).target      = [];
    uavs(k).energy      = 85 + rand*15;   % start at 85-100%
    uavs(k).task        = 'Idle';
    uavs(k).dataQuality = 0.5 + rand*0.5;
    uavs(k).flModel     = rand(1,10);      % dummy 10-dim weight vector
    uavs(k).commQuality = 0.6 + rand*0.4;
    uavs(k).dataAge=10;

    uavs(k).lastUploadCycle=0;

    uavs(k).lastGlobalRound=0;
    uavs(k).lastGlobalRound=0;
    uavs(k).dataAge=0;
    uavs(k).lastUploadCycle=0;
    uavs(k).firesMonitored=0;

    uavs(k).survivorsDetected=0;

    uavs(k).buildingsAssessed=0;
    uavs(k).detectionLog={};
    if k <= numRGB
        uavs(k).type = 'RGB';
    else
        uavs(k).type = 'Thermal';
    end
end

fprintf('  Deployed %d RGB + %d Thermal UAVs\n', numRGB, numThermal);
end
