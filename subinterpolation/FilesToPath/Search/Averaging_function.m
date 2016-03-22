function [y_ave ,V_T]= Averaging_function(xiT,yiT,tri)

% Estimate the averaging of a some values: Using the simplices.

% y_ave:estimate
% V_T: The Integral

ym=y_ave; V_T=Vm;
for ii=1:size(tri,1)
   if min(tri(ii,:))>n+1
      ym=mean(yi(tri(ii,:)));
      wm=[ones(n+1,1) xi(:,tri(ii,:))'];
      y_ave=ym*Vm; V_T=V_T+Vm;
   end 
end
y_ave=y_ave/V_T;


end