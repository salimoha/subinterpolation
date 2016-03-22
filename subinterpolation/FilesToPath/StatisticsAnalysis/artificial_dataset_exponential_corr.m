function [y]=artificial_dataset_exponential_corr(n,kt,transtime)
% n:length of the random process.
% transient time: the initial time which is equivalent to 1.
% Generate the Artificial DataSet: rho(k)=exp(-kt k).
% There is also an initial transient time:transtime: 


y(1:transtime)=1; n1=n-transtime;
for i=1:n1 
    for j=1:n1 
        sigma(i,j)=exp(-kt*abs(i-j)); 
    end
end
y1=mvnrnd(zeros(1,n1),sigma);
y=[y y1];



end