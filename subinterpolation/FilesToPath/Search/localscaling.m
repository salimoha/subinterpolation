function U=local_scaling(A,b)
% find U such that U^T A x=b has minimum x^T x.
% A: R^{m\times n}, b: R^m, U:uitary in R^{ n\times n}
global n
m=3; n=2;

A=rand(m,n); b=rand(m,1);
cost1=(A'*A)\(A'*b);

[Q,R]=qr(A); R=R(1:n,:); Q=Q(
M=R*inv(R'*R)^2*R'; % cost=  
[V,D] = eig(A'*A); % A^T A= VDV^T.
v=V(:,end); % eigenvector of the maximum eigenvalue.
b=b/norm(b); % normalize b.
 % find Unitary U that U*b=v1
%b=rand(n,1); v=rand(n,1); b=b/norm(b); v=v/norm(v);
e1=zeros(n,1); e1(1)=1; w=(b+sign(b(1))*e1)/norm(b+sign(b(1))*e1); H1=eye(n)-2*w*w';
w=(v+sign(v(1))*e1)/norm(v+sign(v(1))*e1); H2=eye(n)-2*w*w';
U=H2'*H1;
A1=U*A; 
cost2=norm((A1'*A1)\b);