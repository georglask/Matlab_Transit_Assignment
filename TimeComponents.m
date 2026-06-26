function [Paths_R] = TimeComponents(Paths,Transit_Lines,Metro_Lines,R_G)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
S_Paths=size(Paths);
S_Transit_Lines=size(Transit_Lines);
S_Metro_Lines=size(Metro_Lines);
%--------------------------------------------------------------------------
%Link input conversion
L=R_G.Edges.EndNodes;
W=R_G.Edges.Weight;
S_L=size(L);
count_L=1;
for i=1:S_L(1,1)
    if isinf(W(i,1))==0
        L1(count_L,1)=L(i,1);
        L1(count_L,2)=L(i,2);
        W1(count_L,1)=W(i,1);
        count_L=count_L+1;
    end
    
end

L=L1;
W=W1;

S_L=size(L);
%--------------------------------------------------------------------------
%Time component weights 
beta_wait=0.016;
beta_inveh=0.01;
beta_transfer=0.046;
%--------------------------------------------------------------------------
Paths_R=cell(S_Paths(1,1),5);

for i=1:S_Paths(1,1)
    od=Paths{i,1};
    Paths_R{i,1}=od;
    %----------------------------------
    Load_monopatia=Paths{i,3};    
    S_Load_monopatia=size(Load_monopatia);
    
    Transfer_L={};
    count_transfer=1;
    %O arithos antistoixei sta enallaktika monopatia
    All_L_monopatia={};
    count_all_l_monopatia=1;
    %Utility=cell(S_Load_monopatia(1,1),1);
    Time_Components=cell(S_Load_monopatia(1,1),1);
     
    %Ypologismos gia kathe enallaktiko monopati
    for j=1:S_Load_monopatia(1,1)
        load_diadromes=Load_monopatia{j,1};
        S_load_diadromes=size(load_diadromes);

        %Edw arxikopoihsh gia utility diadromis
        %utility_=zeros(S_load_diadromes(1,1),1);
        time_components_=zeros(S_load_diadromes(1,1)-1,3);
        
        for k=2:S_load_diadromes(1,1)
            load_diadromi=load_diadromes(k,:);
            S_load_diadromi=size(load_diadromi);
            
            transfer_diadromi=load_diadromes(1,:);
            Transfer_L{count_transfer,1}= transfer_diadromi;
            count_transfer=count_transfer+1;
            
            no_transfers=0;
            waiting_time=0;
            %waiting time and no of transfers
            
            for k1=1:(S_load_diadromi(1,2)-1)
                if load_diadromi(1,k1+1)~=load_diadromi(1,k1)
                    no_transfers=no_transfers+1;
                    tr_line_index=load_diadromi(1,k1+1);
                    if tr_line_index~=999
                        found=0;
                        for t=1:S_Transit_Lines(1,1)
                            if tr_line_index==Transit_Lines{t,1}
                                waiting_time=waiting_time+((Transit_Lines{t,3}*60)/2);
                                found=1;
                            end
                        end
                        for t1=1:S_Metro_Lines(1,1)
                            if tr_line_index==Metro_Lines{t1,1}
                                waiting_time=waiting_time+((Metro_Lines{t1,3}*60)/2);
                                found=1;
                            end
                        end
                        
                    end  
                end
            end
            
            if no_transfers>0
                no_transfers=no_transfers-1;
            end

            %riding and walking time
            %walking_time=0;
            riding_time=0;
            for r=2:S_load_diadromi(1,2)
                if load_diadromi(1,r)~=999
                    start_riding_path=transfer_diadromi(1,r-1);
                    end_riding_path=transfer_diadromi(1,r);
                    
                    for r1=1:S_L(1,1)
                        if L(r1,1)==start_riding_path
                            if L(r1,2)==end_riding_path
                                riding_index=r1;
                            end
                        end
                        
                    end
                    riding_time=riding_time+W(riding_index,1);
                end  
%                 else
%                     
%                     start_walking_path=load_diadromi(1,r-1);
%                     end_walking_path=load_diadromi(1,r);
%                     found_wi=0;
%                     for w1=1:S_Walking_L(1,1)
%                         if Walking_L(w1,1)==start_walking_path
%                             if Walking_L(w1,2)==end_walking_path
%                                 
%                                 walking_index=Walking_W(w1,1);
%                                 found_wi=1;
%                                 break;
%                             end
%                         end
%                     end
%                     if found_wi==0
%                         walking_time=walking_time+60;
%                     else
%                         walking_time=walking_time+walking_index;
%                     end
%                     
%                 end
                
            end
            
            

            time_components_(k-1,:)=[waiting_time,riding_time,no_transfers];
            %utility_(k,1)=(waiting_time*beta_wait)+(riding_time*beta_inveh)+(no_transfers*beta_transfer)+(walking_time*beta_walk);
            All_L_monopatia{count_all_l_monopatia,1}=[transfer_diadromi;load_diadromi];
            count_all_l_monopatia=count_all_l_monopatia+1;            
        end
        %Utility{j,1}=utility_;
        Time_Components{j,1}=time_components_;
        
    end
    %Convert to one table for utility and Time Components
    %S_Utility=size(Utility);
    S_Time_Components=size(Time_Components);
    count_u=1;
    
    %Utility_one=[];
    TC_one=[];
    for u=1:S_Time_Components(1,1)
        %load_utility=Utility{u,1};
        %S_load_utility=size(load_utility);
        
        load_TC=Time_Components{u,1};
        S_load_TC=size(load_TC);
        for u1=1:S_load_TC(1,1)
            %Utility_one(count_u,1)=load_utility(u1,1);
            
            for u2=1:3
                TC_one(count_u,u2)=load_TC(u1,u2);
            end
            count_u=count_u+1;
        end
        
        
    end
   stop_here=1;

    %Register 
    Paths_R{i,2}=Transfer_L;
    Paths_R{i,3}=All_L_monopatia;
    %Paths_R{i,4}=Utility_one;
    Paths_R{i,5}=TC_one;
    
    
   
    toc
end

end

