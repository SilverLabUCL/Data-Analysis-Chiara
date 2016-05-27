function PloTCircle(x,y,r,z,c, FlagFill)
% plot circle given coordinates x and y (and z, just for plotting) of centre and radius r and color c
% if you want the circle filled with color c, put flagfill to 1

if nargin < 6
    FlagFill = 0;
end

if nargin < 5
    c = 'b';
end

if nargin < 4
    z = 1;
end

th = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
zunit = repmat(z,1,length(xunit));

plot3(xunit, yunit,zunit,'Color','k');

if FlagFill
    hold all;
    fill3(xunit,yunit,zunit,c);
end

end