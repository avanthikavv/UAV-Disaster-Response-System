function uavs = move_uavs(uavs, gridSize)
% MOVE_UAVS  Move each UAV one step toward its target.
%   Uses 8-connected grid movement (Chebyshev step).

N = gridSize;
step = 5;   % cells per cycle

for k = 1:numel(uavs)
    if isempty(uavs(k).target); continue; end

    curr = uavs(k).pos;
    tgt  = uavs(k).target;

    delta = tgt - curr;
    dist  = norm(delta);

    if dist <= step

        uavs(k).pos=tgt;
        uavs(k).target=[];
        if contains(uavs(k).task,'Patrol')

            uavs(k).target=[ ...
                randi(gridSize), ...
                randi(gridSize)];

        end
        if strcmp(uavs(k).task,'RTB')
    
            uavs(k).task='Charging';
    
            fprintf('\n[BASE] UAV %d reached charging station\n', ...
                uavs(k).id);
    
        else
    
            if ~contains(uavs(k).task,'OnSite')
                uavs(k).task=[uavs(k).task,'(OnSite)'];
            end
    
        end
    else
        % Move step cells in direction of target
        direction = delta / dist;
        newPos    = curr + round(direction * step);
        newPos    = max(1, min(N, newPos));   % clamp
        uavs(k).pos = newPos;
    end
end
end
