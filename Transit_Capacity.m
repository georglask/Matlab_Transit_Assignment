function [Transit_Links_F] = Transit_Capacity(Transit_Lines,Metro_Lines,Adj_Matrix_Transit_links)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%load('Mumford0_Fleet_requirements.mat')



S_Transit_Lines=size(Transit_Lines);
S_Metro_Lines=size(Metro_Lines);
%S_Fleet_type=size(Fleet_type);
S_Adj_Matrix_Transit_links=size(Adj_Matrix_Transit_links);


countL=0;
for i=1:S_Adj_Matrix_Transit_links(1,1)
    for j=1:S_Adj_Matrix_Transit_links(1,1)
        if Adj_Matrix_Transit_links(i,j)~=0
            countL=countL+1;
            L(countL,1)=i;
            L(countL,2)=j;

        end
    end
end

S_L=size(L);
Transit_Links=zeros(S_L(1,1),4);
% bus_capacity=1;
for i=1:S_Transit_Lines(1,1)
    transit_route_id=Transit_Lines{i,1};

    transit_route_freq=Transit_Lines{i,3};

    %vehicle_type=Fleet_type_per_line(i,2);

%     for k=1:S_Fleet_type(1,1)
%         if Fleet_type(k,1)==1
            bus_capacity=100;
%         end
%     end


    transit_route=Transit_Lines{i,2};
    S_transit_route=size(transit_route);

    for j=2:S_transit_route(1,2)
        
        take_link1=transit_route(1,j-1);
        take_link2=transit_route(1,j);
        for k=1:S_L(1,1)
            if take_link1==L(k,1)
                if take_link2==L(k,2)
                    Transit_Links(k,1)=take_link1;
                    Transit_Links(k,2)=take_link2;
                    Transit_Links(k,3)=Transit_Links(k,3)+1;
                    Transit_Links(k,4)=Transit_Links(k,4)+((round(60/transit_route_freq)*bus_capacity));
                    
                end
            end
        end
    end
end

tr_link_counter=1;

for i=1:S_L(1,1)
    
    if Transit_Links(i,1)~=0
        Transit_Links_F(tr_link_counter,1)=Transit_Links(i,1);
        Transit_Links_F(tr_link_counter,2)=Transit_Links(i,2);
        Transit_Links_F(tr_link_counter,3)=Transit_Links(i,3);
        Transit_Links_F(tr_link_counter,4)=Transit_Links(i,4);
        tr_link_counter=tr_link_counter+1;
        
    end
end

S_Transit_Links_F=size(Transit_Links_F);
end