function [x]= Lin_last_point_find(x0,xi)
% Finding the n+1 point of simplex which maximizes the volume
% Using primial-dual barrier function to minize a^Tx s.t. x=0; 
global Ain bin n
% initilize the barrier factor
xic=xi(:,2:n)-repmat(xi(:,1),1,n-1);
a=null(xic.');
if a'*x0>a'*xi(:,1)
    a=-a;
end
options=optimoptions('linprog','Display','off');
x=linprog(a,Ain,bin,[],[],[],[],[],options);
end

