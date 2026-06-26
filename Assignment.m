function [FORTISI] = Assignment(All_paths,OD,R_G,A,Origins,Destinations)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
%--------------------------------------------------------------------------
%Sizes
S_All_paths=size(All_paths);
S_OD=size(OD);

%Links from Running Times graph
L=R_G.Edges.EndNodes;
W=R_G.Edges.Weight;
S_L=size(L);
count_l=0;
for i=1:S_L(1,1)
    if isinf(W(i,1))==0
        count_l=count_l+1;
        Links1(count_l,1)=L(i,1);
        Links1(count_l,2)=L(i,2);
        W_L(count_l,1)=W(i,1);
    end
    
end

L=Links1;
W=W_L;
S_L=size(L);
%--------------------------------------------------------------------------
%Assignment Matrix Initialization
Adj_Matrix=A;
%Adj_Matrix=netcostmatrixAdj_Matrix_Running_times;
FORTISI=cell(S_L(1,1),4);


S_Origins=size(Origins);
S_Destinations=size(Destinations);

for i=1:S_L(1,1)
    F_odpair=L(i,:);
    FORTISI{i,1}=L(i,:);
    FORTISI{i,2}=0;
    FORTISI{i,3}=Adj_Matrix(F_odpair(1,1),F_odpair(1,2)); %Running Time
    FORTISI{i,4}=0;
    
end
toc
%--------------------------------------------------------------------------

for i=1:S_All_paths(1,1)
    if isempty(All_paths{i,1})==0
    take_od_pair=All_paths{i,1};
    take_proelefsi=take_od_pair(1,1);
    take_proorismos=take_od_pair(1,2);
    for o1=1:S_Origins(1,1)
        if take_proelefsi==Origins(o1,1)
            o_index=o1;
        end
    end
    for d1=1:S_Destinations(1,2)
        if take_proorismos==Destinations(1,d1)
            d_index=d1;
        end
    end
    take_demand=OD(o_index,d_index);
    take_probabilities=All_paths{i,7};
    
    demand_per_path=take_demand*take_probabilities;

    take_all_shortest_paths=All_paths{i,2};
    
    S_take_all_shortest_paths=size(take_all_shortest_paths);
    
    S_demand_per_path=size(demand_per_path);
    
    
    
    for k=1:S_take_all_shortest_paths(1,1)
        take_shortest_path=take_all_shortest_paths{k,1};
        S_take_shortest_path=size(take_shortest_path);

        for j=2:S_take_shortest_path(1,2)
            fortisi_proelefsi=take_shortest_path(1,j-1);
            fortisi_proorismos=take_shortest_path(1,j);
            for k1=1:S_L(1,1)
                if fortisi_proelefsi==L(k1,1)
                    if fortisi_proorismos==L(k1,2)
                        fortosi_existing_demand=FORTISI{k1,2};


                        fortosi_existing_demand=fortosi_existing_demand+demand_per_path(k,1);
                        FORTISI{k1,2}=fortosi_existing_demand;


                    end
                end


            end
        end
    end
    end
end

S_Fortisi=size(FORTISI);

for i=1:S_Fortisi(1,1)
    FORTISI{i,4}=FORTISI{i,2}*FORTISI{i,3};
end
end

