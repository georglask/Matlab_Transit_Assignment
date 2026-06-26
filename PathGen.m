function [Paths] = PathGen(OD,A,k,Origins,Destinations)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

S_OD=size(OD);
A = Zero2inf(A);
count_shortest_paths=0;
count_no_connections=0;
for o=1:S_OD(1,1)
    for d=1:S_OD(1,1)
        
        
        if and(o~=d,OD(o,d)~=0)
            fprintf('\n [ %d , %d ]\n ',o,d)
            [shortestPaths, totalCosts] = kShortestPath(A, Origins(o,1), Destinations(1,d), k);

            S_shortestPaths=size(shortestPaths);

            if S_shortestPaths(1,1)~=0
                count_shortest_paths=count_shortest_paths+1;
                Paths{count_shortest_paths,1}=[Origins(o,1),Destinations(1,d)];
                Paths{count_shortest_paths,2}=shortestPaths;
                Paths{count_shortest_paths,3}=totalCosts;
            else
                count_no_connections=count_no_connections+1;
                Unsatisfied_Connection{count_no_connections,1}=[o,d];
            end
            toc

        end
    end
end
end

