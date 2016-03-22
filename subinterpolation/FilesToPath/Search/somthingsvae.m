xv=0:.05:1;
for ii=1:length(xv)
    for jj=1:length(xv)
        U(ii,jj)=fun([xv(ii) ;xv(jj)]);
    end
end
figure(1)
contourf(xv,xv,U.')
hold on
plot(xE(1,:),xE(2,:),'ks')