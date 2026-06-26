function [A] = Zero2inf(A)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
S_A=size(A);

for i=1:S_A(1,1)
    for j=1:S_A(1,2)
        if A(i,j)==0
            A(i,j)=inf;
        end

    end
end
end