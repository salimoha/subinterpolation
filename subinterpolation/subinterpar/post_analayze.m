
close all
clc

% plot the regert functions for different method

for n=1:3
    for iii=1:2
        clearvars -except iii n
        keyboard
     if iii==1
         filename=['parab_' num2str(n) '.mat'];
     else
         filename=['schewfel_' num2str(n) '.mat'];
     end
     load(filename)
     y_star=0;
     if iii==2
         y_star=funr(0.8419*ones(n,1));
     end
      keyboard
      regret=regret-y_star;
     figure(1)
     loglog(regret(1,:).','k:','linewidth',2)
     hold on
     loglog(regret(2,:).','k.-','linewidth',2)
     loglog(regret(3,:).','k--','linewidth',2)
     T=length(regret);
     plot(1:T, 0.3./sqrt(1:T),'k-','linewidth',3)
     
     figure(2)
     semilogx(datalength(1,:).','k:','linewidth',2)
     hold on
     semilogx(datalength(2,:).','k.-','linewidth',2)
     semilogx(datalength(3,:).','k--','linewidth',2)
     
     
    end
end