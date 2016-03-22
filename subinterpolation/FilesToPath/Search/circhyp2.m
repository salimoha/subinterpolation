function [xC, R2] = circhyp2(x, N)
%circhyp     Circumhypersphere of simplex
%   [xC, R2] = circhyp(x, N) calculates the coordinates of the circumcenter 
%   and the square of the radius of the N-dimensional hypersphere
%   encircling the simplex defined by its N+1 vertices.

for ii=1:N
    B(ii)=norm(x(:,1))^2-norm(x(:,ii+1))^2;
end
A=repmat(x(:,1),1,N)-x(:,2:N+1); A=2*A.'; B=B.';

xC = A\B;
R2 = norm(x(:,1)-xC)^2;

end
