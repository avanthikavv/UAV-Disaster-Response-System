function selectedUAVs = client_selection(uavs, utilityMap)

N=numel(uavs);

scores=zeros(1,N);

maxU=max(utilityMap(:))+1e-6;

fprintf('\n===== CLIENT SELECTION =====\n');

for k=1:N
    if contains(uavs(k).task,'RTB') || contains(uavs(k).task,'Charging')
        scores(k)=0;

        fprintf('UAV %d | %s -> Excluded from FL\n',k,uavs(k).task);

        continue;

    end
    r=uavs(k).pos(1);
    c=uavs(k).pos(2);

    uScore=utilityMap(r,c)/maxU;
    eScore=uavs(k).energy/100;
    dScore=uavs(k).dataQuality;
    freshness=max(0,1-uavs(k).dataAge/25);
    cScore=uavs(k).commQuality;

    scores(k)=0.50*uScore + ...
          0.08*eScore + ...
          0.20*dScore + ...
          0.12*cScore + ...
          0.10*freshness;
    

    fprintf('UAV %d | Utility=%.2f | Energy=%.2f | Data=%.2f | Comm=%.2f | Final=%.3f\n',...
        k,uScore,eScore,dScore,cScore,scores(k));

end

valid=find(scores>0);

[~,idx]=sort(scores(valid),'descend');

valid=valid(idx);

numSelect=min(max(2,round(0.4*N)),length(valid));

selectedUAVs=valid(1:numSelect);

if isempty(selectedUAVs)

    selectedUAVs=[];

end

fprintf('\nSelected UAVs: ');

fprintf('%d ',selectedUAVs);

fprintf('\n');

end