function inter_par= interpolateparametarization(xi1,yi1,inter_method,interpolate_index)
global xi yi y0 w

xi=xi1; yi=yi1;
n=size(xi,1);


%keyboard
% polyharmonic spline interpolation
if inter_method==1
    N = size(xi,2); A = zeros(N,N);
for ii = 1 : 1 : N
    for jj = 1 : 1 : N
        A(ii,jj) = ((xi(:,ii) - xi(:,jj))' * (xi(:,ii) - xi(:,jj))) ^ (3 / 2);
    end
end
%keyboard
V = [ones(1,N); xi];
A = [A V'; V zeros(n+1,n+1)];
wv = A \ [yi.'; zeros(n+1,1)]; % solve the associated linear system
inter_par{1}=1;
inter_par{2} = wv(1:N); inter_par{3} = wv(N+1:N+n+1); 
inter_par{4}= xi;
end

% polyharmonic_spline for less point
if inter_method==2
    N = size(xi,2); A = zeros(N,N);
for ii = 1 : 1 : N
    for jj = 1 : 1 : N
        A(ii,jj) = ((xi(:,ii) - xi(:,jj))' * (xi(:,ii) - xi(:,jj))) ^ (3 / 2);
    end
end
V = [ones(1,N); xi];
A = [A V'; V zeros(n+1,n+1)];
b=[yi.'; zeros(n+1,1)];
%keyboard
eq_index=[interpolate_index, ones(1, n+1)]; 
ineq_index=ones(1,N+n+1)-eq_index;
index=1:N+n+1; eq_index=index(eq_index==1);  ineq_index=index(ineq_index==1); 
Aeq=A(eq_index,:); beq=b(eq_index);
Aineq=A(ineq_index,:); bineq=b(ineq_index);
wv=Aeq\beq; V=null(Aeq);
if size(V,2)>0
options=optimoptions('quadprog','Algorithm','active-set','Display','none');
r=quadprog(V'*V,wv'*V,[Aineq ;-Aineq]*V,[bineq; bineq*0-min(yi)]-[Aineq ;-Aineq]*wv,[],[],[],[],zeros(size(V,2),1),options); 
wv=wv+V*r; 
end

inter_par{1}=1;
inter_par{2} = wv(1:N); inter_par{3} = wv(N+1:N+n+1); 
inter_par{4}= xi;
end



% if inter_method==2
% [ymin,ind]=min(yi);
% xmin=xi(:,ind);
% xi(:,ind)=[];
% yi(:,ind)=[];
% X=xi-repmat(xmin,1,size(xi,2));
% Xcl=zeros(n,n); Xul=zeros(n,2);
% for ii=1:n
% Xcl(ii,ii)=bnd1(ii)-xmin(ii); Xcu(ii,ii)=bnd2(ii)-xmin(ii);
% end
% A=[X' (X.^2)' zeros(size(X,2),n); -X' -(X.^2)' zeros(size(X,2),n); zeros(n,n) -eye(n) zeros(n,n); -Xcl' -(Xcl.^2)' eye(n); -Xcu' -(Xcu.^2)' eye(n,n)];
% B=[yi.'-ymin; 0*yi'; zeros(3*n,1)];
% f=[zeros(1,2*n) -ones(1,n)];
% options=optimoptions('linprog','Display','none','Algorithm','dual-simplex','MaxIter',100);
% x = linprog(f,A,B,[],[],[],[],[],options);
% inter_par{1}=2;
% inter_par{2}=x(n+1:2*n);
% inter_par{3}=x(1:n);
% inter_par{4}=xmin;
% inter_par{5}=ymin;
%end



% quadratic interpolation: p(x)=x'*A*x+f'*x+d
if inter_method==3
    keyboard
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
%w=1./(yi-min([yi-Tol,y0]));
%w=w./max(w);
%w(w<0.1)=0;
w=yi*0+1;
%keyboard
% keyboard
% Define the smoothing metric 
fun=@quad_error_cost;
%options = optimoptions('fminunc','Algorithm','trust-region','GradObj','on');
options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton');

x = fminunc(fun,x0);
f=x(1:n);
A=reshape(x(n+1:end),n,n);

inter_par{1}=3;
inter_par{2}=ymin;
inter_par{3}=xmin;
inter_par{4}=f;
inter_par{5}=A'*A;
end

% p(x)=xT*H*x+f^T (x-x0)+y0
if inter_method==4
   % keyboard
% find the center of the interpolation
[tt,ind]=min(yi1);
xi=xi1; yi=yi1;
xmin=xi(:,ind); xi(:,ind)=[];
xi=xi-repmat(xmin,1,size(xi,2));
ymin=tt; yi(ind)=[];
yi=yi-ymin;


A=quadratic_coefficient_finder(w); 
options=optimoptions('quadprog','Algorithm','active-set','Display','none');
theta=quadprog(2*H_w,f_w,[A;-A],[yi.' ;(yi*0).'],[],[],[],[],zeros(n^2+n,1),options); 
%theta=quadprog(2*H_w,f_w,-A,(yi*0).',[],[],[],[],zeros(n^2+n+1,1),options);
%theta=quadprog(2*H_w,f_w,[],[],[],[],[],[],zeros(n^2+n+1,1),options); 

inter_par{1}=3;
inter_par{2}=ymin;
inter_par{3}=xmin;
inter_par{4}=theta(1:n);
inter_par{5}=(reshape(theta(n+1:end),n,n)+reshape(theta(n+1:end),n,n)')/2;
end

% same as p^k, by minimize L_1 norm
if inter_method==5
    
% find the center of the interpolation
[tt,ind]=min(yi1);
xi=xi1; yi=yi1;
xmin=xi(:,ind); xi(:,ind)=[];
xi=xi-repmat(xmin,1,size(xi,2));
ymin=tt; yi(ind)=[];
yi=yi-ymin;
w=0*yi;
% weights of the interpolation
%keyboard
%w(w<1)=0;

w=ones(size(xi,2),1);
%keyboard
A=quadratic_coefficient_finder(w); 
options=optimoptions('linprog','Algorithm','simplex','Display','none');
[theta,sss,eee,fff,lambda]=linprog(-A'*ones(size(xi,2),1),[A;-A],[yi.' ;(yi*0).'],[],[],[],[],zeros(n^2+n,1),options);
%[theta,sss,eee,fff,lambda]=linprog(-A'*w,A,yi.',[],[],[],[],zeros(n^2+n+1),options);
lambda=lambda.ineqlin(1:size(A,1)); ind=1:size(A,1); lambda=ind(lambda>1e-7);
Aa=A(ind,:); V=null(Aa);
if size(V,2)>0
% permutation matrix to constrcut transpose
for ii=1:n
     for jj=1:n
     e=zeros(1,n^2);
     e((jj-1)*n+ii)= e((jj-1)*n+ii)+ 1;  e((ii-1)*n+jj)= e((ii-1)*n+jj)+ 1;
     Dw((ii-1)*n+jj,:)=e;
     end
end
%keyboard
Dw=[zeros(n,n+n^2) ;zeros(n^2,n) eye(n^2)];
options=optimoptions('quadprog','Algorithm','active-set','Display','none');
r=quadprog(V'*Dw*V,V'*Dw*theta,[A;-A]*V,[yi.' ;(yi*0).']-[A;-A]*theta,[],[],[],[],zeros(size(V,2),1),options);
theta=theta+V*r;
end


inter_par{1}=3;
inter_par{2}=ymin;
inter_par{3}=xmin;
inter_par{4}=theta(1:n);
inter_par{5}=(reshape(theta(n+1:end),n,n)+reshape(theta(n+1:end),n,n)')/2;
end

% quadratic with diagonal hessian

if inter_method==6
    
% find the center of the interpolation
[tt,ind]=min(yi1);
xi=xi1; yi=yi1;
xmin=xi(:,ind); xi(:,ind)=[];
xi=xi-repmat(xmin,1,size(xi,2));
ymin=tt; yi(ind)=[];
yi=yi-ymin;
w=0*yi;
% weights of the interpolation
%keyboard
w=ones(size(xi,2),1);

%keyboard
A=diagonal_quadratic_coefficient_finder(w); 
options=optimoptions('linprog','Algorithm','simplex','Display','none');
%b1=[yi.' ;(yi*0).';zeros(n,1)];  A1=[A;-A;[zeros(n,n),-eye(n)]]; 
%keyboard
%A1=[A ;[zeros(n) -eye(n)]]; b1=[yi.'; zeros(n,1)];
A1=[A; -A]; b1=[yi.'; yi.'*0]; 
[theta,sss,eee,fff,lambda]=linprog(-A'*ones(size(xi,2),1),A1,b1,[],[],[],[],zeros(2*n,1),options);
%[theta,sss,eee,fff,lambda]=linprog(-A'*w,A,yi.',[],[],[],[],zeros(n^2+n+1),options);
lambda=lambda.ineqlin(1:size(A,1)); ind=1:size(A,1); lambda=ind(lambda>1e-7);
Aa=A(ind,:); V=null(Aa);
 if size(V,2)>0
%keyboard
Dw=[zeros(n,2*n) ;zeros(n,n) eye(n)];
options=optimoptions('quadprog','Algorithm','active-set','Display','none');
r=quadprog(V'*Dw*V,V'*Dw*theta,A1*V,b1-A1*theta,[],[],[],[],zeros(size(V,2),1),options);
theta=theta+V*r;
 end


inter_par{1}=3;
inter_par{2}=ymin;
inter_par{3}=xmin;
inter_par{4}=theta(1:n);
inter_par{5}=diag(theta(n+1:2*n));
end
end


% Calculate the quadratic interpolation cost function
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

% p(x)=x^T H x+f^T x+d coefficients

function [A,H_w,f_w]=quadratic_coefficient_finder(w) 
global n xi yi
%keyboard
  for l=1:length(yi)
    a1=(xi(:,l)).';
    a2=reshape(xi(:,l)*xi(:,l)',1,n^2); 
    A(l,:)=[a1 a2]; 
  end
  d_w=[zeros(1,n) reshape(eye(n),1,n^2)]; 
  rho=0; 
  %H_w=-d_w'*d_w; 
  %keyboard
  H_w=A'*diag(w.^2)*A+rho*d_w'*d_w; 
 % keyboard

  f_w=-2*yi*diag(w.^2)*A;
  %f_w=zeros(n^2+n,1);
end

function A=diagonal_quadratic_coefficient_finder(w) 
global n xi yi
%keyboard
  A=[xi;xi.^2]; A=A';
 % b=[yi.'; zeros(2*n,1)];
end
% the gradient of the quadratic interpolation
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