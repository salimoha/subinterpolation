clear neighber ygps
[t,ind]=min(yiT); x=xiT(:,ind);
[neighber] = GPSpollig(xmin,0.05);
for ii=1:size(neighber)
ygps(ii)=fun(ss0+rk.*neighber(:,ii));
end
xiT=[xiT neighber]; yiT=[yiT ygps];
figure(1)
    subplot(2,1,1)
    plot(1:length(yiT(n+2:end)),yiT(n+2:end),'-')
    ylim([-45 0])
    subplot(2,1,2)
    plot(xiT(:,n+2:end)')
    drawnow