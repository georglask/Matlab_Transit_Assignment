function [amatrix] = netcostmatrix(dgraph)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

Links=dgraph.Edges.EndNodes;
Weights=dgraph.Edges.Weight;
Nodes=dgraph.Nodes;

S_Nodes=size(Nodes);
S_Links=size(Links);


amatrix=zeros(S_Nodes(1,1),S_Nodes(1,1));

for i=1:S_Links(1,1)
    or=Links(i,1);
    des=Links(i,2);
    w=Weights(i,1);
    amatrix(or,des)=w;
end

for i=1:S_Nodes(1,1)
    for j=1:S_Nodes(1,1)
        if amatrix(i,j)==0
            amatrix(i,j)=Inf;
        end
        
    end
end

end
