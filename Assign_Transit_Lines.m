function [Paths] = Assign_Transit_Lines(Paths,Transit_Lines,Metro_Lines)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

S_Paths=size(Paths);
S_Transit_Lines=size(Transit_Lines);
S_Metro_Lines=size(Metro_Lines);

for i=1:S_Paths(1,1)
    fprintf('\n assigning path %d to transit lines \n ',i)
    load_paths=Paths{i,2};
    S_load_paths=size(load_paths);

    transit_line_path=cell(S_load_paths(1,2),1);

    for j=1:S_load_paths(1,2)
        take_path=load_paths{1,j};
        S_take_path=size(take_path);

        tr_lines_path=cell(3,S_take_path(1,2));
        tr_lines_path{2,1}=0;
        tr_lines_path{3,1}=0;


        for k=2:S_take_path(1,2)
            
            proto_node=take_path(1,k-1);
            deutero_node=take_path(1,k);
            tr_lines_path{1,k-1}=proto_node;
            tr_lines_path{1,k}= deutero_node;
            count_lines=0;
            tr_lines=[];

            for l=1:S_Transit_Lines(1,1)
                load_route=Transit_Lines{l,2};
                S_load_route=size(load_route);

                for m=2:S_load_route(1,2)
                    if proto_node==load_route(1,m-1)
                        if deutero_node==load_route(1,m)
                            count_lines=count_lines+1;
                            tr_lines(count_lines,1)=Transit_Lines{l,1}; %id
                        end
                    end
                end
            end
            
            for l1=1:S_Metro_Lines(1,1)
                load_route=Metro_Lines{l1,2};
                S_load_route=size(load_route);
                
                for m1=2:S_load_route(1,2)
                    if proto_node==load_route(1,m1-1)
                        if deutero_node==load_route(1,m1)
                            count_lines=count_lines+1;
                            tr_lines(count_lines,1)=Metro_Lines{l1,1}; %id
                        end
                    end
                end
            end
            
            
            
            

            tr_lines_path{2,k}=tr_lines;
            tr_lines_path{3,k}=count_lines;

        end

        Beta=cell(1,S_take_path(1,2));
        for s=1:S_take_path(1,2)
            Alpha=0;
            grammes_2=tr_lines_path{2,s};
            S_grammes=size(grammes_2);
            if S_grammes(1,1)>0

                if S_take_path(1,2)<15

                if S_grammes(1,1)>3
                    Alpha=1:3;
                else

                    Alpha=1:S_grammes(1,1);

                end
                else
                    Alpha=1;
                end
            else
                Alpha=0;
            end
            Beta{1,s}=Alpha;
        end

        n_Beta = length(Beta);
        [Beta{:}] = ndgrid(Beta{end:-1:1});
        Beta = cat(n_Beta+1,Beta{:});
        Beta = fliplr(reshape(Beta,[],n_Beta));
        S_Beta=size(Beta);
        if S_Beta(1,1)>10
            Comb_matrix=Beta(1:10,:);
        else
            Comb_matrix=Beta;
        end
        clear Beta;
        
        S_Comb_matrix=size(Comb_matrix);
        
        
       if S_Comb_matrix(1,1)<10
           
          S_Comb_matrix2=S_Comb_matrix;
           combis=zeros(S_Comb_matrix(1,1),S_Comb_matrix(1,2));
       else
           S_Comb_matrix2(1,1)=10;
           S_Comb_matrix2(1,2)=S_Comb_matrix(1,2);
           combis=zeros(10,S_Comb_matrix(1,2));
       end

            
       
        for s=1:S_Comb_matrix(1,2)
            grammes=tr_lines_path{2,s};
            statement=isempty(grammes);
            if statement==0
            if s==1
                for s1=1:S_Comb_matrix2(1,1)
                    combis(s1,1)=0;
                end
            else
                for s1=1:S_Comb_matrix2(1,1)
                    combis(s1,s)=grammes(Comb_matrix(s1,s),1);
                end
            end
            else
                for s1=1:S_Comb_matrix2(1,1)
                    combis(s1,s)=0;
                end
            end
        end
        
        transit_line_path_matrix=zeros(S_Comb_matrix2(1,1)+1,S_Comb_matrix(1,2));
        for ik=1:S_Comb_matrix(1,2)
            transit_line_path_matrix(1,ik)=take_path(1,ik);

        end
        for ii=2:(S_Comb_matrix2(1,1)+1)
            for ij=1:S_Comb_matrix(1,2)
                transit_line_path_matrix(ii,ij)=combis(ii-1,ij);
            end
        end
        %eliminate paths without transit connections

        check_incomplete_chains=zeros(S_Comb_matrix2(1,1),1);

        for iii=2:(S_Comb_matrix2(1,1)+1)
            
            for iij=2:S_Comb_matrix(1,2)
                if transit_line_path_matrix(iii,iij)==0
                    check_incomplete_chains(iii-1,1)=1;
                end
            end
        end

        count_delete=0;
        delete_matrix=[];
        for iik=1:S_Comb_matrix2(1,1)
            if check_incomplete_chains(iik,1)==1
                count_delete=count_delete+1;
                delete_matrix(1,count_delete)=iik+1;
            end

        end

        transit_line_path_matrix(delete_matrix,:)=[];

        S_transit_line_path_matrix=size(transit_line_path_matrix);
        if S_transit_line_path_matrix(1,1)==1
            transit_line_path{j,1}=[];
        else
            transit_line_path{j,1}=transit_line_path_matrix;
        end
 

    end


transit_line_path=transit_line_path(~cellfun('isempty',transit_line_path));



% Check for transfers and eliminate
S_transit_line_path=size(transit_line_path);

for z1=1:S_transit_line_path(1,1)
    take_routes=transit_line_path{z1,1};
    S_take_routes=size(take_routes);
    no_transfers=zeros(S_take_routes(1,1)-1,1);
    
    for z2=2:S_take_routes(1,1)
        diadromi=take_routes(z2,:);
        S_diadromi=size(diadromi);
        no_tr=0;
        for z3=1:(S_diadromi(1,2)-1)
            if diadromi(1,z3)~=diadromi(1,z3+1)
                no_tr=no_tr+1;
            end
        end
        no_transfers(z2-1,1)=no_tr;

    end

    Min_transfers=min(no_transfers);

    check_zero=1;
    del_row_index=0;
    Del_row=[];
    for z3=2:S_take_routes(1,1)
        if no_transfers(z3-1,1)>Min_transfers
            check_zero=0;
            del_row_index=del_row_index+1;
            Del_row(1,del_row_index)=z3;
        end
    end

    if check_zero==0
        if del_row_index>0
            take_routes(Del_row,:) = [];
        end
    end

transit_line_path{z1,1}=take_routes;

end


%


 
Paths{i,3}=transit_line_path;



end



end

