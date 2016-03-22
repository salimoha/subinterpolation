function [xC, R2] = circhyp(x, N)
%circhyp     Circumhypersphere of simplex
%   [xC, R2] = circhyp(x, N) calculates the coordinates of the circumcenter 
%   and the square of the radius of the N-dimensional hypersphere
%   encircling the simplex defined by its N+1 vertices.

M = [sum(x.'.^2,2), x.', ones(N+1,1)];
a = det(M(:,2:N+2));
c = (-1) ^ (N+1) * det(M(:,1:N+1));
D = zeros(N,1);
for ii = 1 : 1 : N
    M_tmp = M;
    M_tmp(:,ii+1) = [];
    D(ii) = (-1) ^ ii * det(M_tmp);
end
xC = - D / (2 * a);
R2 = (sum(D.^2) - 4 * a * c) / (4 * a ^ 2);

end
