function [A,a] = uniformsimplexrecursive(N)                                                                   
%unifrom simplex around origin with radius 1.
if N==1
    A=[-1/2 1/2];
    a=0.5;
end
if N>1
    [A,a]=uniformsimplexrecursive(N-1);
    x=(1-2*a^2)/(2*sqrt(1-a^2));
    a=sqrt(a^2+x^2);
    A=[A;-x*ones(1,N)];
    A=[A,[zeros(N-1,1);a]];
end 

