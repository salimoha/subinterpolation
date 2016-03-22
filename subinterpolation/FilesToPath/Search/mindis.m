function [y,index, x1] = mindis(x,xi)
y=inf;
for i=1:size(xi,2)
   y1=norm(x-xi(:,i));
    if y1<y
        y=y1;
        x1=xi(:,i);
        index=i;
    end
end


end

