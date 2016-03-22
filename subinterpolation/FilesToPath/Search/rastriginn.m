function y = rastriginn(x)

global n
% keyboard
A=1;
x=-2.2+x*(pi+2);
%x=x+0.3;
y = A * n;
for ii = 1 : 1 : n
    y = y + (x(ii,:) .^ 2 - A * cos(2 * pi * x(ii,:)));
end

end
