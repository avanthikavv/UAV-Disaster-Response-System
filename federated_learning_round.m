function flState = federated_learning_round(flState, uavs, selectedUAVs, cycle)
% FEDERATED_LEARNING_ROUND  Async FL: aggregate only from selected clients.
%
% Each selected UAV:
%   1. Simulates local training (gradient step on dummy loss)
%   2. Sends updated model weights to server
%
% Server aggregates via FedAvg (weighted by data quality).

flState.round = flState.round + 1;
fprintf('  [FL] Round %d | Cycle %d | Selected UAVs: %s\n', ...
    flState.round, cycle, num2str(selectedUAVs));

rgbWeights     = [];
thermalWeights = [];
rgbQual        = [];
thermalQual    = [];

for ki = 1:numel(selectedUAVs)
    k = selectedUAVs(ki);

    % Simulate local training: small gradient step (dummy)
    lr       = 0.01;
    gradient = randn(1,10) * 0.1;   % fake gradient
    uavs(k).flModel = uavs(k).flModel - lr * gradient;
    update.model=uavs(k).flModel;
    update.time=cycle;
    update.type=uavs(k).type;
    update.dataQuality=uavs(k).dataQuality;
    flState.pendingUpdates{end+1}=update;
    % Separate by type
    if strcmp(uavs(k).type, 'RGB')
        rgbWeights = [rgbWeights; uavs(k).flModel];
        rgbQual    = [rgbQual,    uavs(k).dataQuality];
    else
        thermalWeights = [thermalWeights; uavs(k).flModel];
        thermalQual    = [thermalQual,    uavs(k).dataQuality];
    end
end

%% Weighted FedAvg aggregation
rgbWeights=[];
thermalWeights=[];
rgbQual=[];
thermalQual=[];

keepUpdates={};

for p=1:length(flState.pendingUpdates)

    upd=flState.pendingUpdates{p};

    age=cycle-upd.time;

    if age>20
        continue;
    end

    keepUpdates{end+1}=upd;

    weight=((1/(1+age))*0.7 + 0.3) * upd.dataQuality;

    if strcmp(upd.type,'RGB')

        rgbWeights=[rgbWeights;upd.model];
        rgbQual=[rgbQual weight];

    else

        thermalWeights=[thermalWeights;upd.model];
        thermalQual=[thermalQual weight];

    end

end

flState.pendingUpdates=keepUpdates;

if ~isempty(rgbWeights)

    w=rgbQual/sum(rgbQual);

    flState.globalModelRGB=w*rgbWeights;

end

if ~isempty(thermalWeights)

    w=thermalQual/sum(thermalQual);

    flState.globalModelThermal=w*thermalWeights;

end

flState.stalenessHistory(end+1)=mean([rgbQual thermalQual]);

flState.lossHistory(end+1)=...
    norm(flState.globalModelRGB)+...
    norm(flState.globalModelThermal);

flState.selectedHistory{end+1}=selectedUAVs;