%This script takes bridge data and turns it into something 3D that is
%viewable by us humans.

%clear
clc
close all

%speed up or slow down the simulation
SPEEDUP = 1;

%location of major directory
testdir = ['/home/jmmanela/IRLStuff/bigsets/eerc3/'];

%location of data
vnfname  = [testdir 'vn.csv'];
ldrfname = [testdir 'lidar_data.csv'];

%reading vector nav csv
%vectornavdata = csvread(vnfname);
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

alt = alt * 0;

%reading lidar csv
%lidardata = csvread(ldrfname);
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
        scan_range=scan(:,1)>1 & scan(:,1)<15;
        
        scan=scan(scan_range,:);
        
        cos_ldr = cos(scan(:,2));
        sin_ldr = sin(scan(:,2));
        
        %setup base starting point for each sweep
        %base=[lat_m(vnI) long_m(vnI) alt(vnI)];
        base=[lat_m(vnI) long_m(vnI) 150];
        
        sweep=zeros(size(scan,1),3);
        
        %x y z from perspective of hokuyo, the sweep is technically in the
        %xy plane of the vector nav
        sweep(:,1) = cos_ldr.*scan(:,1);
        sweep(:,2) = sin_ldr.*scan(:,1);
        sweep(:,3) = zeros(1,size(scan(:,1),1));
        
        %{
        %calculate the cm_x and the cm_y
        cm_x = sum(sweep(:,1))/size(sweep(:,1),1);
        cm_y = sum(sweep(:,2))/size(sweep(:,2),1);
        
        sweep(:,1)=sweep(:,1)-cm_x;
        sweep(:,2)=sweep(:,2)-cm_y;
        
        %try calculating the minimum point in the y direction
        min_x = min(sweep(:,1));
        sweep(:,1)=sweep(:,1)-min_x;
        %}
        
        %setup rotation matrix, this needs to be worked on, right now the
        %hokuyo sweep is not in the correct orientation
        R = rotation(deg2rad(vn.roll-90),deg2rad(vn.pitch-90),deg2rad(vn.yaw+90));
        
        %Rotation and translation for each point in the sweep
        for jj=1:size(sweep,1)
            sweep(jj,:) = sweep(jj,:) * R + base;
        end
        
        %build a cross for the xyz of the hexcopter with a length of
        %crosslen (m)
        crosslen=2.5;
        cross=[lat_m(vnI) long_m(vnI) alt(vnI);crosslen,0,0;0,crosslen,0;0,0,crosslen];
        cross(2,:) = cross(2,:) * R + cross(1,:);
        cross(3,:) = cross(3,:) * R + cross(1,:);
        cross(4,:) = cross(4,:) * R + cross(1,:);

        view(3);
        
        ldrI
        if( ldrI < 950 )
            cla
        else
            plot3(cross(1,1),cross(1,2),cross(1,3), 'r-');
            
            if( ldrI == 2600 )
                hold on
                plot3(cross([1 2],1),cross([1 2],2),cross([1 2],3), 'r-');
                plot3(cross([1 3],1),cross([1 3],2),cross([1 3],3), 'g-');
                plot3(cross([1 4],1),cross([1 4],2),cross([1 4],3), 'b-');
                hold off
            end
        end
        
        hold on
        
        %plot everything
        if( mod(ldrI,10)==0 )
            plot3(sweep(:,1),sweep(:,2),sweep(:,3), 'm.');
        end
        
        if( ldrI < 900)
            hold off
        end
        
        %Increment lidar Iterator variable
        %axis([minlat_m maxlat_m minlong_m maxlong_m minalt/1.25 maxalt])
        ldrI = ldrI + 1;

    end
    
    pause(.001);
end

