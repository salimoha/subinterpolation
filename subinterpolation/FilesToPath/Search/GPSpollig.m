function [x,y,Imp] = GPSpollig(inter_par,xi,x,delta)
%perform GPS polling
global n m Ain bin y00

inda=1:m;
inda=inda(Ain*x-bin>-delta);
if length(inda)>n
    Imp=0;
    y=inf;
else
Aa=Ain(inda,:);
ba=bin(inda);
if length(ba)==0
    neighber=[-eye(n) eye(n)];
else
V=null(Aa);
neighber=[-V V];
    for i=1:length(ba)    
        A1=[Aa ;V'];
        b1=zeros(n,1);
        b1(i)=-1;
        neighber=[neighber A1\b1];
    end
end
neighber=repmat(x,1,size(neighber,2))+delta*neighber;
for ii=1:size(neighber,2)
        yp(ii)=(interpolate_val(neighber(:,ii),inter_par)-y00)/mindis(neighber(:,ii),xi);
        if mindis(neighber(:,ii),xi)<0.9*delta
            yp(ii)=inf;
        end
end
[y,ind]=min(yp);
x=neighber(:,ind);
if y==inf
    Imp=0;
else
    Imp=1;
end
end
end

