function visualize_simulation(env, priorityMap, utilityMap, uavs, flState, cycle, cfg, latestDetection)% VISUALIZE_SIMULATION  Render a 6-panel real-time simulation view.
%
% Panels:
%   1. Disaster Environment
%   2. Priority Map
%   3. Mission Utility Map
%   4. UAV Positions + Assignments
%   5. UAV Energy Levels
%   6. Federated Learning Loss

clf reset;

%% Color map for disaster types
%  0=Safe(white), 1=Fire(red), 2=Landslide(brown), 3=Flood(blue),
%  4=Collapsed(gray), 5=Survivor(green), 6=BlockedRoad(orange)
disasterCmap = [
    1.00 1.00 1.00;  % 0 Safe
    0.90 0.10 0.10;  % 1 Fire
    0.55 0.27 0.07;  % 2 Landslide
    0.10 0.40 0.90;  % 3 Flood
    0.50 0.50 0.50;  % 4 Collapsed Building
    0.10 0.80 0.10;  % 5 Survivor
    1.00 0.55 0.00;  % 6 Blocked Road
];

%% ---- Panel 1: Disaster Environment ----
subplot(2,3,1);
imgData = zeros(env.gridSize, env.gridSize, 3);
for t = 0:6
    mask = (env.grid == t);
    for ch = 1:3
        layer = imgData(:,:,ch);
        layer(mask) = disasterCmap(t+1, ch);
        imgData(:,:,ch) = layer;
    end
end
imagesc(imgData);
title(sprintf('Disaster Environment (Cycle %d)', cycle), ...
    'FontSize',12,'FontWeight','bold');axis off; axis equal tight;
% Legend
legendLabels = {'Safe','Fire','Landslide','Flood','Collapsed','Survivor','BlockedRoad'};
hold on;
for t = 0:6
    plot(NaN, NaN, 's', 'MarkerFaceColor', disasterCmap(t+1,:), ...
         'MarkerEdgeColor','k', 'MarkerSize',8, 'DisplayName', legendLabels{t+1});
end
legend('Location','southoutside','NumColumns',4,'FontSize',6);
hold off;

%% ---- Panel 2: Priority Map ----
subplot(2,3,2);
imagesc(priorityMap, [0 100]);
colorbar; colormap(gca, hot);
title('Priority Map (0-100)', ...
    'FontSize',12,'FontWeight','bold');
axis off; axis equal tight;

%% ---- Panel 3: Mission Utility Map ----
subplot(2,3,3);
imagesc(utilityMap, [0 100]);
colorbar; colormap(gca, parula);
title('Mission Utility Score', ...
    'FontSize',12,'FontWeight','bold');
axis off; axis equal tight;

%% ---- Panel 4: UAV Positions ----
subplot(2,3,4);
% Background: utility
imagesc(utilityMap, [0 100]);
colormap(gca, gray);
hold on;

% Draw target lines and UAV icons
rgbColor     = [1 0.3 0.3];
thermalColor = [0.3 0.6 1.0];
for k = 1:numel(uavs)
    r = uavs(k).pos(1); c = uavs(k).pos(2);
    if strcmp(uavs(k).type, 'RGB')
        col = rgbColor;
        mrk = 'o';
    else
        col = thermalColor;
        mrk = '^';
    end

    % Draw line to target
    if ~isempty(uavs(k).target)
        plot([c, uavs(k).target(2)], [r, uavs(k).target(1)], ...
     '-', 'Color', col, 'LineWidth', 0.8);
    end

    % Draw UAV marker
    sz = 8 + (uavs(k).energy/100)*6;
    plot(c, r, mrk, 'Color', col, 'MarkerFaceColor', col, ...
         'MarkerSize', sz, 'LineWidth', 1.2);

    % UAV ID label
    text(c+0.5, r, num2str(uavs(k).id), 'Color','w', ...
         'FontSize',6, 'FontWeight','bold');
end

% Legend
plot(NaN,NaN,'o','Color',rgbColor,'MarkerFaceColor',rgbColor,'MarkerSize',8,'DisplayName','RGB UAV');
plot(NaN,NaN,'^','Color',thermalColor,'MarkerFaceColor',thermalColor,'MarkerSize',8,'DisplayName','Thermal UAV');
legend('Location','southoutside','NumColumns',2,'FontSize',7,'TextColor','w');

title('UAV Assignments', ...
    'FontSize',12,'FontWeight','bold');
axis([0.5 env.gridSize+0.5 0.5 env.gridSize+0.5]);
axis ij; hold off;

%% ---- Panel 5: UAV Energy Bar Chart ----
subplot(2,3,5);
energies = [uavs.energy];
types    = {uavs.type};
colors   = zeros(numel(uavs), 3);
for k = 1:numel(uavs)
    if strcmp(types{k},'RGB')
        colors(k,:) = [0.85 0.3 0.3];
    else
        colors(k,:) = [0.3 0.5 0.9];
    end
end
b = bar(1:numel(uavs), energies, 'FaceColor','flat');
b.CData = colors;
ylim([0 105]);
xlabel('UAV ID','FontSize',8); ylabel('Energy (%)','FontSize',8);
title('UAV Energy Levels', ...
    'FontSize',12,'FontWeight','bold');
hold on;
yline(20,'r--','LineWidth',1.5);  % critical threshold
hold off;
grid on; grid minor;

%% ---- Panel 6: FL Loss + Round Info ----
subplot(2,3,6);
if ~isempty(flState.lossHistory)
    plot(1:numel(flState.lossHistory), flState.lossHistory, ...
         'b-o', 'LineWidth', 1.5, 'MarkerSize', 5);
    xlabel('FL Round','FontSize',8);
    ylabel('Agg. Model Norm','FontSize',8);
    title(sprintf('Federated Learning (Round %d)', flState.round), ...
    'FontSize',12,'FontWeight','bold');
    grid on;

    % Annotate last selected clients
    if ~isempty(flState.selectedHistory)
        lastSel = flState.selectedHistory{end};
        annStr  = sprintf('Last selected UAVs: %s', num2str(lastSel));
        text(1, max(flState.lossHistory)*0.9, annStr, 'FontSize',7, 'Color','r');
    end
else
    text(0.5, 0.5, 'FL not started yet', 'HorizontalAlignment','center', ...
         'FontSize', 10, 'Units','normalized');
    title('Federated Learning','FontSize',9);
    axis off;
end

%% ---- Super title ----
sgtitle(sprintf('UAV Disaster Response Simulation  |  Cycle: %d / %d  |  Grid: %dx%d  |  UAVs: %d', ...
    cycle, cfg.numCycles, cfg.gridSize, cfg.gridSize, numel(uavs)), ...
    'FontSize', 11, 'FontWeight','bold');

drawnow;
end