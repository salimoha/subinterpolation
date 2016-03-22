function g = interpolate_grad(x,inter_par)
% Calculate te interpolatated value at points x
% inter_par{1}=1 polyharmonic spline
% inter_par{1}=2 Quadratic interpolation

n=length(x);

% polyharmonoic spline
if inter_par{1}==1
    w=inter_par{2}; v=inter_par{3};
    xi=inter_par{4}; 
    N = size(xi, 2);
    g = zeros(n, 1);
for ii = 1 : N
    X = x - xi(:,ii);
    g = g + 3 *w(ii)* X*norm(X);
end
    g=g+v(2:end);
end

% Quadratic interpolation

if inter_par{1}==2
    k=inter_par{2}; v=inter_par{3};
    xmin=inter_par{4};
    g=2*k'*(x-xmin)+v;
end

if inter_par{1}==3
   % ymin=inter_par{2}; 
    xmin=inter_par{3};
    f=inter_par{4};
    H=inter_par{5};
    g=2*H*(x-xmin)+f;
end
end