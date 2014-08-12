%This script takes bridge data and turns it into something 3D that is
%viewable by us humans.

clear
clc
close all

%speed up or slow down the simulation
SPEEDUP = 1;

%location of major directory
testdir = ['/home/jmmanela/IRLStuff/IRL/test2/'];

%location of data
vnfname  = [testdir 'vn.csv'];
ldrfname = [testdir 'lidar_data.csv'];

%reading vector nav csv
vectornavdata = csvread(vnfname);
vnI  = 1;

%convert from gps_seconds(ticks) to meters
deg2m=60*1852;

%get vectors of latitude and longitude, and altitude
lat =vectornavdata(:,6);
lat=lat(lat~=0);

long=vectornavdata(:,7);
long=long(long~=0);

alt=vectornavdata(:,8);

%find min and max lat & long
minlat = min(lat);
maxlat = max(lat);

minlong = min(long);
maxlong = max(long);

%calculate lat and long vectors to meters from the minlat and minlong found
%above.
lat_m = distance(minlat,0,lat,0) * deg2m;
long_m= distance(0,minlong,0,long) * deg2m;

minlat_m=min(lat_m);
maxlat_m=max(lat_m);

minlong_m=min(long_m);
maxlong_m=max(long_m);

minalt = min(alt(alt~=0));
maxalt = max(alt(alt~=0));

%reading lidar csv
lidardata = csvread(ldrfname);
ldrI = 1;

[ldrScanStrt,~]=find(lidardata==-1);

%setup the starttimes vector
starttimes = zeros(1,2);

%[lat, long]
gpszero = vectornavdata(4,7:8);

%I calibrate the vector nav based on the ending points, that's where I
%it ended on the ground.  The actual calibration is done in parseVNRow.m
y=vectornavdata(:,3);
y=y(y~=0);

p=vectornavdata(:,4);
p=p(p~=0);

r=vectornavdata(:,5);
r=r(r~=0);

ypr_cal = [y(end) p(end) r(end)];

maxLdrI=3600;
minLdrI=2600;

maxVnI=8669;
minVnI=6311;

ldrI=minLdrI;
vnI=minVnI;

cloud = zeros(maxLdrI-minLdrI,3);
cloudI=1;

path=[lat_m long_m alt(1:size(lat_m,1))];
path=path(minVnI:maxVnI,:);

%adjust the base for an interpolation of the points we want
numpts=size(path,1);


%%{
lat_m(minVnI:maxVnI)=linspace(path(1,1),path(end,1),numpts);
long_m(minVnI:maxVnI)=linspace(path(1,2),path(end,2),numpts);
alt(minVnI:maxVnI)=linspace(path(1,3),path(end,3),numpts);
%}
%This will be the final point cloud
final_surf=zeros(10,3);

while true
    
    %get vector nav start time
    vn                = parseVNRow(vectornavdata(vnI,:), ypr_cal);
    starttimes(1)     = vn.time;
    
    %get lidar start time
    ldrrow            = lidardata(ldrScanStrt(ldrI),:);
    starttimes(2)     = ldrrow(2) + ldrrow(3) / 1000000;
    
    %find smallest, and set current time
    [curtime,smlI] = min(starttimes);
    
    %VECTORNAV
    if curtime == starttimes(1)
        vnI = vnI + 1;
    end
    
    %LIDAR
    if curtime == starttimes(2)
        firstcld = 1;
        
        scan = lidardata(ldrScanStrt(ldrI)+1:(ldrScanStrt(ldrI+1)-1),:);
        
        %scan(1)-rho
        %scan(2)-theta
        
        %convert from mm to m (Hokuyo outputs in mm, to keep things
        %consistent I changed everything to meters
        scan(:,1)=scan(:,1)/1000;
        
        %only look at points from a distance of 1 to 15 meters away
        scan_range=scan(:,1)>2 & scan(:,1)<10;
        
        scan=scan(scan_range,:);
        
        cos_ldr = cos(scan(:,2));
        sin_ldr = sin(scan(:,2));
        
        %setup base starting point for each sweep
        %base=[lat_m(vnI) long_m(vnI) alt(vnI)];
        base=[lat_m(vnI) long_m(vnI) alt(vnI)];
        
        sweep=zeros(size(scan,1),3);
        
        %x y z from perspective of hokuyo, the sweep is technically in the
        %xy plane of the vector nav
        sweep(:,1) = cos_ldr.*scan(:,1);
        sweep(:,2) = sin_ldr.*scan(:,1);
        sweep(:,3) = zeros(1,size(scan(:,1),1));
        
        %setup rotation matrix, this needs to be worked on, right now the
        %hokuyo sweep is not in the correct orientation
        R = rotation(deg2rad(vn.roll-90-3),deg2rad(vn.pitch-90),deg2rad(vn.yaw+90));
        
        for jj=1:size(sweep,1)
            sweep(jj,:) = sweep(jj,:) * R;
        end

        %calculate the cm_x and the cm_y
        %%{
        cm(1) = sum(sweep(:,1))/size(sweep(:,1),1);
        cm(2) = sum(sweep(:,2))/size(sweep(:,2),1);
        cm(3) = sum(sweep(:,3))/size(sweep(:,3),1);
        
        sweep(:,1)=sweep(:,1)-cm(1) + base(1);
        sweep(:,2)=sweep(:,2)-cm(2) + base(2);
        sweep(:,3)=sweep(:,3)-cm(3);
        
        %build a cross for the xyz of the hexcopter with a length of
        %crosslen (m)
        crosslen=1;
        cross=[lat_m(vnI) long_m(vnI) alt(vnI);crosslen,0,0;0,crosslen,0;0,0,crosslen];
        cross(2,:) = cross(2,:) * R + cross(1,:);
        cross(3,:) = cross(3,:) * R + cross(1,:);
        cross(4,:) = cross(4,:) * R + cross(1,:);

        view(3);
        
        if( ldrI < minLdrI || ldrI > maxLdrI )
            cla
        else
            
            %This would plot the linearly interpolated line if you want
            %plot3(cross(1,1),cross(1,2),cross(1,3), 'r-');

            if( ldrI == minLdrI )
                hold on
                plot3(cross([1 2],1),cross([1 2],2),cross([1 2],3), 'r-', 'LineWidth', 5);
                plot3(cross([1 3],1),cross([1 3],2),cross([1 3],3), 'g-', 'LineWidth', 5);
                plot3(cross([1 4],1),cross([1 4],2),cross([1 4],3), 'b-', 'LineWidth', 5);
                hold off
            end
        end
        
        hold on
        
        %plot everything
        %{
        if( mod(ldrI,10)==0 )
            plot3(sweep(:,1),sweep(:,2),sweep(:,3), 'm.');
        end
        %}
        final_surf=[final_surf;sweep(:,1) sweep(:,2) sweep(:,3)];
        %Increment lidar Iterator variable
        axis([minlat_m maxlat_m minlong_m maxlong_m minalt/1.25 maxalt])
        ldrI = ldrI + 1;

    end
    
    if ldrI > 3600
        break
    end
    
    %pause(.001);
end

%plot the original path ignoring the interpolation
plot3(path(:,1),path(:,2),path(:,3), 'g','LineWidth',1);

figure

x=final_surf(:,1);y=final_surf(:,2);z=final_surf(:,3);
x=x(x~=0);y=y(y~=0);z=z(z~=0);
tri = delaunay(x, y);
trimesh(tri, x, y, z);

xmin = min(x(:)); xmax = max(x(:));
ymin = min(y(:)); ymax = max(y(:));
%zmin = min(z(:)); zmax = max(z(:));

[xm,ym]=meshgrid(xmin:.1:xmax,ymin:.1:ymax);
zm = griddata(x,y,z,xm,ym);

figure(3);
surface(xm,ym,zm,'EdgeColor','none');

colormap hot
caxis([-0.5 0.5])
axis equal

title('Bridge Colormap using Lidar')
xlabel('Position (m)')
ylabel('Position (m)')
zlabel('Position (m)')

hold on
%plot the original path ignoring the interpolation
cm = sum(path(:,3))/size(path(:,3),1);
path(:,3)=path(:,3) - cm+5
plot3(path(:,1),path(:,2),path(:,3), 'g','LineWidth',1);

cross(:,1)=cross(:,1)-cross(1,1) + path(1,1);
cross(:,2)=cross(:,2)-cross(1,2) + path(1,2);
cross(:,3)=cross(:,3)-cross(1,3) + path(1,3);

legend show
legend('Bridge Depth', 'Flight Path')

plot3(cross([1 2],1),cross([1 2],2),cross([1 2],3), 'r-', 'LineWidth', 5);
plot3(cross([1 3],1),cross([1 3],2),cross([1 3],3), 'g-', 'LineWidth', 5);
plot3(cross([1 4],1),cross([1 4],2),cross([1 4],3), 'b-', 'LineWidth', 5);