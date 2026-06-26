function [A_tt2] = Adj_matrix_transit_rts(Transit_Lines,Adj_Matrix_Running_times)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

S_Transit_Lines=size(Transit_Lines);

A_tt=Adj_Matrix_Running_times/60;

S_A_tt=size(A_tt);

Transit_link_exists=zeros(S_A_tt(1,1),S_A_tt(1,1));

for i=1:S_Transit_Lines(1,1)
    route=Transit_Lines{i,2};
    S_route=size(route);
    for j=2:S_route(1,2)
        arxi=route(1,j-1);
        peras=route(1,j);
        Transit_link_exists(arxi,peras)=1;
    end



end

A_tt2=zeros(S_A_tt(1,1),S_A_tt(1,1));

for i=1:S_A_tt(1,1)
    for j=1:S_A_tt(1,1)

        if Transit_link_exists(i,j)==1
            A_tt2(i,j)=A_tt(i,j);

        end

    end
end

A_tt2=A_tt2*60;

end