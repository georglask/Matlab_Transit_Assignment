function [All_paths] = Utility(Paths_R,utility_type)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
beta_wait=0.0016;
beta_inveh=0.001;
beta_transfer=0.0046;
beta_walk=0.0016;
beta_path=-0.0101;

All_paths=Paths_R;
S_All_paths=size(All_paths);

switch utility_type
    case 1
        %Calculate Utility / Update Utility
        for i=1:S_All_paths(1,1)
            load_components=All_paths{i,5};
            S_load_components=size(load_components);
            Up_Utility=zeros(S_load_components(1,1),1);
            for j=1:S_load_components(1,1)
                path_time_components=load_components(j,:);
                Up_Utility_value=(beta_wait*path_time_components(1,1))+(beta_inveh*path_time_components(1,2))+(beta_transfer*path_time_components(1,3));
                Up_Utility(j,1)=Up_Utility_value;
            end
            All_paths{i,4}=Up_Utility;
        end
        toc
        for i=1:S_All_paths(1,1)
            load_utilities=All_paths{i,4};
            S_load_utilities=size(load_utilities);
            load_utilities=(-1)*load_utilities;
            
            exp_utilities=zeros(S_load_utilities(1,1),1);
            for j=1:S_load_utilities(1,1)
                exp_utilities(j,1)=exp(load_utilities(j,1));
            end
            
            
            Sum_exp_utilities=sum(exp_utilities);
            
            prop_select_path=zeros(S_load_utilities(1,1),1);
            
            for j=1:S_load_utilities(1,1)
                
                prop_select_path(j,1)=exp_utilities(j,1)/Sum_exp_utilities;
                
            end
            
            
            
            All_paths{i,6}=exp_utilities;
            All_paths{i,7}=prop_select_path;
            
        end
    case 2
        load('Amsterdam.mat');
        L=D_G.Edges.EndNodes;
        S_L=size(L);
        W=D_G.Edges.Weight;
        for i=1:S_All_paths(1,1)
            
            load_alternative_paths=All_paths{i,2};
            %number of paths
            S_load_alternative_paths=size(load_alternative_paths);
            %separate links and create link table
            link_counter=1;
            path_size_utility=zeros(S_load_alternative_paths(1,1),1);
            
            for j=1:S_load_alternative_paths(1,1)
                take_path=load_alternative_paths{j,1};
                S_take_path=size(take_path);
                no_of_links_in_path=S_take_path(1,2)-1;
                
                for k=1:no_of_links_in_path
                    if link_counter==1
                        Links_matrix(link_counter,1)=take_path(1,k);
                        Links_matrix(link_counter,2)=take_path(1,k+1);
                        %find length
                        for k2=1:S_L(1,1)
                            if Links_matrix(link_counter,1)==L(k2,1)
                                if Links_matrix(link_counter,2)==L(k2,2)
                                    Links_matrix(link_counter,3)=W(k2,1);
                                end
                            end
                        end
                        
                        %occurence
                        Links_matrix(link_counter,4)=1;
                        link_counter=link_counter+1;
                    else
                        %kainourgio h exei perastei hdh
                        is_new=1;
                        for k_1=1:(link_counter-1)
                            if Links_matrix(k_1,1)==take_path(1,k)
                                if Links_matrix(k_1,2)==take_path(1,k+1)
                                    Links_matrix(k_1,4)=Links_matrix(k_1,4)+1;
                                    is_new=0;
                                end
                            end
                            
                        end
                        
                        if is_new==1
                            Links_matrix(link_counter,1)=take_path(1,k);
                            Links_matrix(link_counter,2)=take_path(1,k+1);
                            for k2=1:S_L(1,1)
                                if Links_matrix(link_counter,1)==L(k2,1)
                                    if Links_matrix(link_counter,2)==L(k2,2)
                                        Links_matrix(link_counter,3)=W(k2,1);
                                    end
                                end
                            end
                            
                            Links_matrix(link_counter,4)=1;
                            link_counter=link_counter+1;
                            
                        end
                        
                        
                        
                    end
                end
            end
            S_Links_matrix=size(Links_matrix);
            
            for j=1:S_load_alternative_paths(1,1)
                
                sum_total_length=0;
                sum_ut_r=0;
                
                take_path=load_alternative_paths{j,1};
                S_take_path=size(take_path);
                no_of_links_in_path=S_take_path(1,2)-1;
                
                
                for k=1:no_of_links_in_path
                    for k_1=1:S_Links_matrix(1,1)
                        if Links_matrix(k_1,1)==take_path(1,k)
                            if Links_matrix(k_1,2)==take_path(1,k+1)
                                sum_total_length=sum_total_length+Links_matrix(k_1,3);
                            end
                        end
                    end
                    
                end
                for k=1:no_of_links_in_path
                    for k_1=1:S_Links_matrix(1,1)
                        if Links_matrix(k_1,1)==take_path(1,k)
                            if Links_matrix(k_1,2)==take_path(1,k+1)
                                term1=(Links_matrix(k_1,3)/sum_total_length);
                                term2=(1/Links_matrix(k_1,4));
                                sum_ut_r=sum_ut_r+(term1*term2);
                            end
                        end
                    end
                end
                V_r=log(sum_ut_r);
                path_size_utility(j,1)=V_r;
            end
            check_here=1;
            %we have here path size utility per path
            %utility modification 
            load_utilities=All_paths{i,4};
            S_load_utilities=size(load_utilities);
            load_time_components=All_paths{i,5};
            S_load_time_components=size(load_time_components);
            %size of exp and final utility
            count_all_utilities=0;
            for x1=1:S_load_alternative_paths(1,1)
                %ALLAGH EDW
                take_utilities=load_utilities(x1,1);
                S_take_utilities=size(take_utilities);
                
                count_all_utilities=count_all_utilities+S_take_utilities(1,1);
                
            end
            
            exp_utilities=zeros(count_all_utilities,1);
            prop_select_path=zeros(count_all_utilities,1);
            
            c_u=1;
            
            for j1=1:S_load_alternative_paths(1,1)
                %ALLAGH EDW
                take_utilities=load_utilities(j1,1);
                S_take_utilities=size(take_utilities);
                
                take_utilities=(-1)*take_utilities;
                take_utilities=take_utilities+((beta_path)*path_size_utility(j1,1));
                
                
                
                
                for j2=1:S_take_utilities(1,1)
                    exp_utilities(c_u,1)=exp(take_utilities(j2,1));
                    c_u=c_u+1;
                end
            end
            Sum_exp_utilities=sum(exp_utilities);
            for j=1:count_all_utilities
                
                prop_select_path(j,1)=exp_utilities(j,1)/Sum_exp_utilities;
                
            end
            


            All_paths{i,6}=exp_utilities;
            All_paths{i,7}=prop_select_path;
            
        end
        
end


end

