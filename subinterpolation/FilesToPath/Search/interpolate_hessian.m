function H = interpolate_hessian(x,inter_par)
n=length(x);

% polyharmonoic spline
if inter_par{1}==1
    w=inter_par{2}; 
    xi=inter_par{4}; 
    N = size(xi, 2);
    H = zeros(n);
for ii = 1 : 1 : N
    X = x - xi(:,ii);
    if norm(X)>1e-5
        H = H + 3 * w(ii) * ((X * X') / norm(X) + norm(X) * eye(n,n));
    end
end
end

% Quadratic interpolation
if inter_par{1}==2
    H=2*diag(inter_par{2}); 
end
if inter_par{1}==3
    H=1/2*inter_par{5}; 
end

end