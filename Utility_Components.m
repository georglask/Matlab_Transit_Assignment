function [Paths_R] = Utility_Components(Paths_R)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
S_Paths_R=size(Paths_R);

%--------------------------------------------------------------------------
%Time component weights 
beta_wait=0.0016;
beta_inveh=0.001;
beta_transfer=0.0046;
%--------------------------------------------------------------------------


for i=1:S_Paths_R(1,1)

    load_tc=Paths_R{i,5};
    S_load_tc=size(load_tc);

    Utility1=zeros(S_load_tc(1,1),1);
    Utility=zeros(S_load_tc(1,1),1);

    for j=1:S_load_tc(1,1)
        waiting_time=load_tc(j,1);
        riding_time=load_tc(j,2);
        no_transfers=load_tc(j,3);
        Utility1(j,1)=(waiting_time*beta_wait)+(riding_time*beta_inveh)+(no_transfers*beta_transfer);
    end

    Sum_U=sum(Utility1);

    for k=1:S_load_tc(1,1)
        Utility(k,1)=Utility1(k,1)/Sum_U;
    end

    Paths_R{i,4}=Utility;

end
end

