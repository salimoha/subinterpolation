function inter_par=quad_inter_paramterization(xi1,yi1)
global n y0 xi yi w
%keyboard
[tt,ind]=min(yi1);
xi=xi1; yi=yi1;
xmin=xi(:,ind); xi(:,ind)=[];
xi=xi-repmat(xmin,1,size(xi,2));
ymin=tt; yi(ind)=[];
yi=yi-ymin;
%keyboard
f=zeros(n,1); A=eye(n);
x0=[f;reshape(A,n^2,1)];
%keyboard
% weights of the interpolation
Tol=1e-3;
w=1./(yi-min([yi-Tol,y0]));
% keyboard
% Define the smoothing metric 
fun=@quad_error_cost;
%options = optimoptions('fminunc','Algorithm','trust-region','GradObj','on');
options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton');
x = fminunc(fun,x0);
f=x(1:n);
A=reshape(x(n+1:end),n,n);
H=A'*A;

inter_par{1}=3;
inter_par{2}=ymin;
inter_par{3}=xmin;
inter_par{4}=f;
inter_par{5}=H;

end

function [y Dy]=quad_error_cost(x)
global n xi yi w
%keyboard
f=x(1:n); A=x(n+1:end);
A=reshape(A,n,n);
y=0;
for l=1:length(yi)
y=y+w(l)^2*(norm(A*xi(:,l))^2+f'*xi(:,l)-yi(l))^2;
end
    
[Df,DA]=quad_error_grad(f,A);
Dy=[Df;reshape(DA,n^2,1)];    
end

function [Df,DA]=quad_error_grad(f,A) 
global n xi yi w
% g=2*w_l*(p(x_l)-y(x_l))^2,  p(x_l)=(A*x_l)^2+f*x_l+d
for l=1:length(yi)
g(l)=2*w(l)^2*(norm(A*xi(:,l))^2+f'*xi(:,l)-yi(l));
end

% Dd=1^T g
%Dd=sum(g);
% Df_j= g(x_l)*x_j^l
Df=zeros(n,1);
for l=1:length(yi)
Df=Df+xi(:,l)*g(l);
end
% DA_{i,j}= 2*g(l)*x_l(j)*A*x_l
DA=zeros(n,n);
for l=1:length(yi)
for ii=1:n
    for jj=1:n
DA1(ii,jj)=2*xi(jj,l)*A(ii,:)*xi(:,l);
    end
end
DA=DA+g(l)*DA1;
end
end