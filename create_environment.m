function env = create_environment(gridSize)
% CREATE_ENVIRONMENT  Build the initial 2D disaster grid.
%
% Cell types (stored in env.grid):
%   0 = Safe
%   1 = Fire
%   2 = Landslide
%   3 = Flood
%   4 = Collapsed Building
%   5 = Survivor
%   6 = Blocked Road
%
% env.severity  : 0-100 per cell
% env.survivor  : survivor count per cell

N = gridSize;

env.grid=zeros(N);
env.severity=zeros(N);
env.survivor=zeros(N);

env.gridSize=N;

env.detectedSurvivors=zeros(N);
env.monitoredFire=zeros(N);
env.assessedBuilding=zeros(N);

rng(42);

%% ---- Place disaster zones ----

env=place_cluster(env,1,3,round(N*0.1),60,90);

env=place_cluster(env,2,2,round(N*0.08),40,70);

env=place_cluster(env,3,4,round(N*0.12),30,60);

env=place_cluster(env,4,2,round(N*0.06),50,85);

env = place_survivors(env, round(N*0.08));

env=place_cluster(env,6,2,round(N*0.05),20,50);

fprintf('  Environment created: %dx%d grid\n',N,N);

fprintf('  Fire cells: %d | Landslide: %d | Flood: %d | Collapsed: %d | Survivor Groups: %d | Total People: %d\n',...
sum(env.grid(:)==1),...
sum(env.grid(:)==2),...
sum(env.grid(:)==3),...
sum(env.grid(:)==4),...
sum(env.survivor(:)>0),...
sum(env.survivor(:)));
end

%% ---------------------------------------------------------
function env = place_cluster(env,type,numClusters,radius,sevMin,sevMax)

N=env.gridSize;

for k=1:numClusters

cx=randi(N);
cy=randi(N);

r=max(1,round(radius*(0.5+rand*0.5)));

for i=max(1,cx-r):min(N,cx+r)

    for j=max(1,cy-r):min(N,cy+r)

        if rand<0.6

            env.grid(i,j)=type;
            env.severity(i,j)=sevMin+rand*(sevMax-sevMin);

        end

    end

end


end
end

%% ---------------------------------------------------------
function env = place_survivors(env,numGroups)

N=env.gridSize;

placed=0;

while placed<numGroups


r=randi(N);
c=randi(N);

if env.survivor(r,c)==0

    env.grid(r,c)=5;
    env.survivor(r,c)=randi([1 8]);
    env.severity(r,c)=85+rand*10;

    placed=placed+1;

end


end
end
