function [A,B,s,r]=actual_scaling_lincon(A,B,ub,lb,a,b,n,neq)
% find the real scaling factor
A=[A; eye(n);-eye(n)];
B=[B; ub; -lb];

% Find all vertice of Ax \leq B, 
% and the nonredundent constraints
[X,NRC]=vertexfind(A,B,a,b,n,neq);
s=min(X.').'; s1=max(X.').'; 
r=s1-s;
s=s(1:n-neq); r=r(1:n-neq);
A=A(NRC,:); B=B(NRC,:);
A1=A(:,1:n-neq); A2=A(:,n-neq+1:end);
a1=a(:,1:n-neq); a2=a(:,n-neq+1:end);
A=A1-A2*(a2\a1); B=B-A2*(a2\b);
% Scale the matrixes
B=B-A*s;
for jj=1:size(A,1)
    A(jj,:)=A(jj,:).*(r.');
    a=norm(A(jj,:)); 
    A(jj,:)=A(jj,:)/a; B(jj)=B(jj)/a; 
end

end

function [X,NRC]=vertexfind(A,B,a,b,n,neq)
m=size(A,1); 
P=nchoosek(1:m,n-neq);
r=size(P,1);
X=[]; NRC=[];
for ii=1:r
    A1=A(P(ii,:),:); B1=B(P(ii,:));
    if abs(det([a;A1]))>1e-5
    xn=[a;A1]\[b;B1]; 
    if (A*xn-B)<1e-4
        X=[X xn];
        NRC=union(NRC,P(ii,:));
    end
    end
end
end
