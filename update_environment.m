function env = update_environment(env, cycle)
% UPDATE_ENVIRONMENT  Dynamically evolve the disaster grid each cycle.
%
% Rules:
%   Fire     : spreads to 4-neighbours with probability 0.08
%   Flood    : spreads to 4-neighbours with probability 0.06
%   Landslide: expands slightly with probability 0.04
%   Survivors: may be rescued (removed) if a UAV is nearby (handled in assign)
%              new survivors may appear with small probability
%   Severity : slowly increases for active disaster cells (+1 per cycle, capped 100)

N   = env.gridSize;
rng('shuffle');

newGrid     = env.grid;
newSeverity = env.severity;
newSurvivor = env.survivor;

for i = 1:N
    for j = 1:N
        t = env.grid(i,j);

        %% Disaster severity creep
        if t > 0 && t ~= 5
            newSeverity(i,j) = min(100, env.severity(i,j) + 0.5 + rand*0.5);
        end

        %% Fire spread
        if t == 1
            neighbours = get_4neighbours(i, j, N);
            for n = 1:size(neighbours,1)
                ni = neighbours(n,1); nj = neighbours(n,2);
                if env.grid(ni,nj) == 0 && rand < 0.08
                    newGrid(ni,nj)     = 1;
                    newSeverity(ni,nj) = 40 + rand*30;
                end
            end
        end

        %% Flood spread
        if t == 3
            neighbours = get_4neighbours(i, j, N);
            for n = 1:size(neighbours,1)
                ni = neighbours(n,1); nj = neighbours(n,2);
                if env.grid(ni,nj) == 0 && rand < 0.06
                    newGrid(ni,nj)     = 3;
                    newSeverity(ni,nj) = 30 + rand*20;
                end
            end
        end

        %% Landslide slow expansion
        if t == 2 && rand < 0.03
            neighbours = get_4neighbours(i, j, N);
            for n = 1:size(neighbours,1)
                ni = neighbours(n,1); nj = neighbours(n,2);
                if env.grid(ni,nj) == 0
                    newGrid(ni,nj)     = 2;
                    newSeverity(ni,nj) = 30 + rand*30;
                    break;
                end
            end
        end
    end
end

%% Occasionally extinguish a fire cell (rescue / rain)
if rand < 0.05
    fireCells = find(env.grid == 1);
    if ~isempty(fireCells)
        idx = fireCells(randi(numel(fireCells)));
        newGrid(idx)     = 0;
        newSeverity(idx) = 0;
    end
end

env.grid     = newGrid;
env.severity = newSeverity;
env.survivor = newSurvivor;
end

%% ---- Helper ----
function nb = get_4neighbours(i, j, N)
nb = [];
if i>1, nb=[nb;i-1,j]; end
if i<N, nb=[nb;i+1,j]; end
if j>1, nb=[nb;i,j-1]; end
if j<N, nb=[nb;i,j+1]; end
end
