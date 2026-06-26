function uavs = avoid_collisions(uavs,gridSize)

safeDist=6;

for i=1:length(uavs)-1

    for j=i+1:length(uavs)

        d=norm(uavs(i).pos-uavs(j).pos);

        if d<safeDist

            dir=uavs(i).pos-uavs(j).pos;

            if norm(dir)==0
                dir=randi([-1 1],1,2);
            end

            dir=round(dir/max(norm(dir),1));

            uavs(i).pos=max(1,min(gridSize,...
                uavs(i).pos+dir));

            uavs(j).pos=max(1,min(gridSize,...
                uavs(j).pos-dir));

        end

    end

end

end