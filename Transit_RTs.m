function [Adj_Matrix_Transit_Running_Times] = Transit_RTs(Node_id,Link_input,Transit_Lines,Metro_Lines)

S_N=size(Node_id);
S_L=size(Link_input);
S_T=size(Transit_Lines);
S_M=size(Metro_Lines);

Transit_C_matrix=zeros(S_N(1,1),S_N(1,1));

for i=1:S_T(1,1)
    take_route=Transit_Lines{i,2};
    S_R=size(take_route);

    for j=2:S_R(1,2)

        arxi=take_route(1,j-1);
        peras=take_route(1,j);

        for k=1:S_N(1,1)

            if Node_id(k,1)==arxi

                arxi_k=k;

            end

            if Node_id(k,1)==peras

                peras_k=k;

            end
        end



        Transit_C_matrix(arxi_k,peras_k)=1;

    end


end

for i=1:S_M(1,1)
    take_route=Metro_Lines{i,2};
    S_R=size(take_route);

    for j=2:S_R(1,2)

        arxi=take_route(1,j-1);
        peras=take_route(1,j);

        for k=1:S_N(1,1)

            if Node_id(k,1)==arxi

                arxi_k=k;

            end

            if Node_id(k,1)==peras

                peras_k=k;

            end
        end



        Transit_C_matrix(arxi_k,peras_k)=1;

    end


end

Adj_Matrix_Transit_Running_Times=zeros(S_N(1,1),S_N(1,1));

for i=1:S_T(1,1)
    take_route=Transit_Lines{i,2};
    S_R=size(take_route);

    for j=2:S_R(1,2)

        arxi=take_route(1,j-1);
        peras=take_route(1,j);

        for k=1:S_L(1,1)
            if arxi==Link_input(k,1)
                    if peras==Link_input(k,2)

                        Adj_Matrix_Transit_Running_Times(arxi,peras)=Link_input(k,3);
                    end 
            end
        end
    end


end

for i=1:S_M(1,1)
    take_route=Metro_Lines{i,2};
    S_R=size(take_route);

    for j=2:S_R(1,2)

        arxi=take_route(1,j-1);
        peras=take_route(1,j);

        for k=1:S_L(1,1)
            if arxi==Link_input(k,1)
                    if peras==Link_input(k,2)

                        Adj_Matrix_Transit_Running_Times(arxi,peras)=Link_input(k,3);
                    end 
            end
        end
    end


end

end