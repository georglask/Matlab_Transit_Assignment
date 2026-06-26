function [Paths] = Assign_Transit_Lines_v4(Paths, Transit_Lines, Metro_Lines, varargin)
% Assign_Transit_Lines_optimized
% Optimized assignment of transit line combinations to path segments.
%
% Usage:
%   Paths = Assign_Transit_Lines_optimized(Paths, Transit_Lines, Metro_Lines)
%   Paths = Assign_Transit_Lines_optimized(..., maxCombinations)
%   Paths = Assign_Transit_Lines_optimized(..., maxCombinations, maxLinesPerSegment)
%
% Inputs:
%   - Paths: same format you used (cell with Paths{i,2} = node sequences)
%   - Transit_Lines, Metro_Lines: same format (each row {lineID, routeCells})
%   - maxCombinations (optional): max combinations to generate per segment-path (default 1000)
%   - maxLinesPerSegment (optional): limit candidate lines per segment (default Inf)
%
% Output:
%   - Paths: same structure with Paths{i,3} filled with transit_line_path (like your original)
%
% Notes:
%   - Node identifiers must be numeric (as in your original code).
%   - If a segment has no connecting line, the segment candidate becomes [0].
%   - We choose the combinations with minimal transfers (ties all kept).
%   - This function is written to be robust and much faster for typical inputs.

% Default optional args:
if nargin < 4 || isempty(varargin{1})
    maxCombinations = 1000;
else
    maxCombinations = varargin{1};
end
if nargin < 5 || isempty(varargin{2})
    maxLinesPerSegment = Inf;
else
    maxLinesPerSegment = varargin{2};
end

% Precompute adjacency map: key 'u_v' -> vector of lineIDs that travel from u to v
adjMap = containers.Map('KeyType','char','ValueType','any');

% helper to add pair to map
    function add_pair(u,v,lineID)
        key = sprintf('%d_%d', u, v);
        if isKey(adjMap, key)
            arr = adjMap(key);
            arr(end+1,1) = lineID;
            adjMap(key) = arr;
        else
            adjMap(key) = lineID;
        end
    end

% Process Transit_Lines
S_Transit = size(Transit_Lines,1);
for l = 1:S_Transit
    route = Transit_Lines{l,2};
    if isempty(route), continue; end
    % assume route is 1 x N numeric
    for m = 2:numel(route)
        u = route(m-1);
        v = route(m);
        add_pair(u,v, Transit_Lines{l,1});
    end
end

% Process Metro_Lines
S_Metro = size(Metro_Lines,1);
for l = 1:S_Metro
    route = Metro_Lines{l,2};
    if isempty(route), continue; end
    for m = 2:numel(route)
        u = route(m-1);
        v = route(m);
        add_pair(u,v, Metro_Lines{l,1});
    end
end

% Main loop over Paths
S_Paths = size(Paths,1);
for i = 1:S_Paths
    fprintf('Assigning path %d / %d\n', i, S_Paths);
    load_paths = Paths{i,2};
    if isempty(load_paths)
        Paths{i,3} = {};
        continue;
    end
    S_load_paths = size(load_paths,2);
    transit_line_path = cell(S_load_paths,1);

    for j = 1:S_load_paths
        take_path = load_paths{1,j};   % node sequence e.g. [n1 n2 n3 ...]
        if numel(take_path) < 2
            transit_line_path{j,1} = [];
            continue;
        end
        numSegments = numel(take_path)-1;

        % Build candidate choices for each ordered segment (u->v)
        choices = cell(1,numSegments);
        for s = 1:numSegments
            u = take_path(s);
            v = take_path(s+1);
            key = sprintf('%d_%d', u, v);
            if isKey(adjMap, key)
                cand = adjMap(key);
                % Optionally limit per-segment candidate count to keep combos manageable
                if numel(cand) > maxLinesPerSegment
                    cand = cand(1:round(maxLinesPerSegment)); % keep first ones (original code limited to 3)
                end
                choices{s} = unique(cand(:)); % ensure unique column vector
            else
                choices{s} = 0; % indicate no service
            end
        end

        % If all segments have only zeros (no connections) -> no combos
        allZero = all(cellfun(@(c) isequal(c(:),0), choices));
        if allZero
            transit_line_path{j,1} = [];
            continue;
        end

        % Compute number of combinations (product of sizes)
        sizes = cellfun(@numel, choices);
        totalComb = prod(sizes);

        % Generate combinations matrix (each row is one combination, columns per segment)
        if totalComb <= maxCombinations
            % Safe to form full cartesian product
            % Use ndgrid-like approach (works for varying sizes)
            % Build indexing grids
            revChoices = choices(end:-1:1);
            grids = cell(1,numSegments);
            [grids{:}] = ndgrid(revChoices{:});
            % reshape and reorder back
            combMat = zeros(totalComb, numSegments);
            for c = 1:numSegments
                G = grids{numSegments-c+1};
                combMat(:,c) = G(:);
            end
        else
            % Too many combos -> enumerate lexicographically up to maxCombinations
            combMat = zeros(maxCombinations, numSegments);
            idx = ones(1, numSegments); % current indices into each choices{s}
            for t = 1:maxCombinations
                for s = 1:numSegments
                    combMat(t,s) = choices{s}(idx(s));
                end
                % increment mixed-radix counter
                for k = numSegments:-1:1
                    idx(k) = idx(k) + 1;
                    if idx(k) <= sizes(k)
                        break;
                    else
                        idx(k) = 1;
                    end
                end
            end
        end

        % Remove combinations that contain zeros (segments without service)
        hasZero = any(combMat == 0, 2);
        combMat(hasZero, :) = [];
        if isempty(combMat)
            transit_line_path{j,1} = [];
            continue;
        end

        % Compute transfer counts (number of times consecutive lineIDs differ)
        % (transfers between consecutive segments)
        transfers = sum(diff(combMat(:,2:end),1,2) ~= 0, 2);
        minTransfers = min(transfers);
        
        % Keep combinations with minimal transfers (like original)
        keepMask = (transfers == minTransfers);
        keptComb = combMat(keepMask, :);

        % Build the transit_line_path_matrix with first row node IDs, subsequent rows combos
        nKept = size(keptComb,1);
        transit_matrix = zeros(nKept+1, numSegments+1); % +1 col so we can place full path?
        % In your original code, transit_line_path_matrix stored node IDs in row 1
        % and lineIDs for each combo in subsequent rows. We'll match that:
        % put node IDs in columns 1..(numSegments+1)
        nodesRow = take_path; % length numSegments+1
        transit_matrix(1,1:numSegments+1) = nodesRow;
        % for each combo row, we will put line IDs aligned with segment starting at column 1..numSegments
        % but to mirror your previous structure (where you had same width as segments),
        % create a matrix where columns correspond to nodes (so we put line IDs under the *segments*)
        % So we will make columns = numSegments+1; and put zeros where there's no line for first or last node.
        % Fill subsequent rows:
        for r = 1:nKept
            % Place a zero in the first column (before first node)
            transit_matrix(r+1,1) = 0;
            % Then fill line IDs for the remaining segments
            transit_matrix(r+1,2:numSegments+1) = keptComb(r,:);
        end

        % Store trimmed: if only nodes row (no valid combos) set empty
        if size(transit_matrix,1) <= 1
            transit_line_path{j,1} = [];
        else
            transit_line_path{j,1} = transit_matrix;
        end
    end % j over load_paths

    % remove empty entries
    transit_line_path = transit_line_path(~cellfun('isempty',transit_line_path));

    % Assign into Paths
    Paths{i,3} = transit_line_path;
end % i over Paths

end
