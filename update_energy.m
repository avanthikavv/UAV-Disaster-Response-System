function uavs = update_energy(uavs)
% UPDATE_ENERGY  Drain energy based on activity.
%
% Drain rates per cycle:
%   Movement (has target)   : 1.5
%   Sensing on site         : 1.0
%   Idle / Patrol           : 0.5
%   RTB                     : 0.8
%
% Recharge: UAVs that reach base (pos=[1,1]) recover +20 per cycle (capped 100).

for k = 1:numel(uavs)
    task = uavs(k).task;

    if contains(task, 'RTB')
        drain = 0.8;
      
    elseif contains(task,'Charging')

        uavs(k).energy=min(100,uavs(k).energy+5);

        fprintf('\n[CHARGING] UAV %d | %.1f%%\n', ...
            uavs(k).id,uavs(k).energy);
        
        uavs(k).dataQuality = 0.3 + 0.7*(uavs(k).energy/100);
        uavs(k).dataAge=uavs(k).dataAge+1;
        continue;
    elseif contains(task, 'OnSite')
        drain = 1.0;
    elseif contains(task, 'Patrol') || contains(task, 'Idle')
        drain = 0.5;
    else
        drain = 1.5;   % moving to target
    end

    % Small random fluctuation (sensor comm overhead)
    drain = drain + rand*0.3;

    uavs(k).energy = max(0, uavs(k).energy - drain);

    % Update data quality based on energy (low energy -> worse sensing)
    uavs(k).dataQuality = 0.3 + 0.7*(uavs(k).energy/100);
end
end
