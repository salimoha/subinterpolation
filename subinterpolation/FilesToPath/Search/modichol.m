function [A1] = modichol(A,alpha,beta )
%Find a positive definite approximate of symmetric matrix A for Newton method
 
n=size(A,2);
L=eye(n);
D(1)=max(abs(A(1,1)),alpha);
c(:,1)=A(:,1);
L(2:n,1)=c(2:n,1)/D(1);

for j=2:n-1
    c(j,j)=A(j,j)-(L(j,1:j-1).^2)*D(1:j-1).';
    for i=j+1:n
        c(i,j)=A(i,j)-(L(i,1:j-1).*L(j,1:j-1))*D(1:j-1)';
    end
    theta=max(c(j+1:n,j));
    D(j)=max([(theta/beta)^2,abs(c(j,j)),alpha]);
    L(j+1:n,j)=c(j+1:n,j)/D(j);
end
    j=n;
    c(j,j)=A(j,j)-(L(j,1:j-1).^2)*D(1:j-1).';
    D(j)=max(abs(c(j,j)),alpha);
    A1=L*diag(D)*L';
end