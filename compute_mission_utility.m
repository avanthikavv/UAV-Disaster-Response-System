function utilityMap = compute_mission_utility(env, priorityMap, uavs)
% COMPUTE_MISSION_UTILITY  Calculate Mission Utility Score for every cell.
%
% MU = 0.4*SurvivorScore + 0.3*SeverityScore + 0.2*AccessibilityScore
%      + 0.1*UrgencyScore
%
% All sub-scores are normalised to [0,1].

N = env.gridSize;

%% Sub-score 1: SurvivorScore (0-1)
maxSurv = max(max(env.survivor)) + 1e-6;
survivorMap=env.survivor;

survivorMap(env.detectedSurvivors==1)=0;

survivorScore=survivorMap/maxSurv;
%% Sub-score 2: SeverityScore (0-1)
severityMap=env.severity;

severityMap(env.monitoredFire==1)=0;

severityMap(env.assessedBuilding==1)=0;

severityScore=severityMap/100;
%% Sub-score 3: AccessibilityScore (inverse of blocked roads nearby)
accessScore = ones(N);
for i = 1:N
    for j = 1:N
        % Check 3x3 neighbourhood for blocked roads (type 6)
        ri = max(1,i-1):min(N,i+1);
        ci = max(1,j-1):min(N,j+1);
        hood = env.grid(ri,ci);
        blockedFrac = sum(hood(:)==6) / numel(hood);
        accessScore(i,j) = 1 - blockedFrac;
    end
end

%% Sub-score 4: UrgencyScore (based on priority normalised)
maxP = max(priorityMap(:)) + 1e-6;
urgencyScore = priorityMap / maxP;
urgencyScore(env.detectedSurvivors==1)=0;

urgencyScore(env.monitoredFire==1)=0;

urgencyScore(env.assessedBuilding==1)=0;
%% UAV distance penalty: far cells are less attractive when UAVs are scarce
distPenalty = zeros(N);
for k = 1:numel(uavs)
    if uavs(k).energy > 20   % only healthy UAVs count
        for i = 1:N
            for j = 1:N
                d = norm(uavs(k).pos - [i,j]);
                distPenalty(i,j) = distPenalty(i,j) + exp(-d/15);
            end
        end
    end
end
distPenalty = distPenalty / (numel(uavs) + 1e-6);

%% Final utility
utilityMap = 0.40*survivorScore ...
           + 0.30*severityScore ...
           + 0.10*accessScore ...
           + 0.20*urgencyScore;

% Multiply by UAV reachability
utilityMap = utilityMap .* (0.5 + 0.5*distPenalty);

% Scale to [0,100]
if rand < 0.01
    fprintf('\nUtility Range: %.2f -> %.2f\n', ...
        min(utilityMap(:)),max(utilityMap(:)));
end
utilityMap = utilityMap * 100 / (max(utilityMap(:)) + 1e-6);
end
