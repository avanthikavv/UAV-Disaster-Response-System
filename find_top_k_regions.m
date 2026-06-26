function topRegions = find_top_k_regions(utilityMap, K)
% FIND_TOP_K_REGIONS  Return the K cells with highest utility score.
%
% Returns struct array with fields: row, col, score

N = size(utilityMap,1);

% Flatten and sort descending
scores = utilityMap(:);
[sortedScores, idx] = sort(scores, 'descend');

topRegions = struct('row',{},'col',{},'score',{});

added = 0;
for t = 1:length(idx)
    if added >= K; break; end
    [r,c] = ind2sub([N,N], idx(t));
    score = sortedScores(t);
    if score < 1; break; end   % skip near-zero regions

    % Spatial diversity: skip if too close to an already-selected region
    tooClose = false;
    for m = 1:added
        dist = norm([r,c] - [topRegions(m).row, topRegions(m).col]);
        if dist < 15   % minimum 4-cell separation
            tooClose = true;
            break;
        end
    end
    if tooClose; continue; end

    added = added + 1;
    topRegions(added).row   = r;
    topRegions(added).col   = c;
    topRegions(added).score = score;
end
end
