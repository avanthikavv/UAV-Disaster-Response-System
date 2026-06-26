function priorityMap = compute_priority_map(env)
% COMPUTE_PRIORITY_MAP  Assign a base priority score to every grid cell.
%
% Base scores:
%   Fire              = 70
%   Landslide         = 60
%   Flood             = 50
%   Collapsed Bldg    = 80
%   Survivor          = 90
%   Blocked Road      = 40
%   Safe              =  0
%
% Final priority = base * (severity/100) -- survivors use full base.

N = env.gridSize;
baseScore = [0, 70, 60, 50, 80, 90, 40];  % index 1=safe(0)..7

priorityMap = zeros(N);

for i = 1:N
    for j = 1:N
        t = env.grid(i,j) + 1;   % shift: safe=1, fire=2, ...
        if t == 6  % survivor (type 5 -> index 6)
            priorityMap(i,j) = baseScore(t) + env.survivor(i,j)*2;
        else
            priorityMap(i,j) = baseScore(t) * (env.severity(i,j)/100 + 0.3);
        end
    end
end

% Clamp to [0,100]
priorityMap = min(priorityMap, 100);
end
