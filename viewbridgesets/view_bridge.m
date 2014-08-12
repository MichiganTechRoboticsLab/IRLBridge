%This script takes bridge data and turns it into something 3D that is
%viewable by us humans.

%clear
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
%vectornavdata = csvread(vnfname);
vnI  = 1;

%reading lidar csv
%lidardata = csvread(ldrfname);
ldrI = 1;
ldrScanI = 1;

firstldr = 1;

%setup the starttimes vector
starttimes = zeros(1,2);
lasttime = 0;

first = 1;

%define figure
f = figure;
set(f,'name','Bridge Viewer','numbertitle','off')

pltcnt = 1;
pltskip = 5;

h(1) = subplot(1,3,1);
h(2) = subplot(1,3,2);
h(3) = subplot(1,3,3);

cloud = zeros(1,3);

%[lat, long]
gpszero = vectornavdata(4,7:8);

avgcnt = 0;
avg = 0;

%calibrate ypr
ypr_cal = [0 0 0];
set_cal = 1;



while true
    
    %get vector nav start time
    vn                = parseVNRow(vectornavdata(vnI,:), ypr_cal);
    starttimes(1)     = vn.time;
    
    %get lidar start time
    ldr               = parseLdrRow(lidardata(ldrI,:), -pi/2);
    starttimes(2)     = ldr.time;
    
    %find smallest, and set current time
    [curtime,smlI] = min(starttimes);
    
    %VECTORNAV
    if curtime == starttimes(1)
        %print vectornav data to the screen
        %{
        if set_cal == 1 && vn.yaw ~= 0 && vn.roll ~= 0 && vn.pitch ~= 0
            ypr_cal = [vn.yaw vn.pitch vn.roll];
            set_cal = 0;
        end
        %}
        
        %fprintf('%.2f %.2f %.2f %.10f %.10f %.10f\n', vn.yaw, vn.pitch, vn.roll, ... 
            %vn.lat, vn.long, vn.alt)
        vnI = vnI + 1;
    end
    
    %LIDAR
    if curtime == starttimes(2)
        %point = zeros(1,3);
        scan = zeros(1,3);
        firstcld = 1;
        
        ldrI = ldrI + 1;
        ldr               = parseLdrRow(lidardata(ldrI,:), -pi/2);
        
        cla

        %loop through entire scan and build a list of points to plot
        kk = 1;
        while ~ldr.isend
            if(ldr.isbig || ldr.x == 0 || ldr.y == 0 || vn.long == 0)
                %temp.x(kk) = 0;
                %temp.y(kk) = 0;
            else
                temp.x(kk) = ldr.x;
                temp.y(kk) = ldr.y;
                
                %%%{
                point(1) = vn.long;
                point(2) = ldr.x + vn.lat;
                %point(3) = vn.alt*1000 - abs(ldr.y);
                point(3) = -abs(ldr.y);
                %}
                
                if firstcld
                    scan = point;
                    firstcld = 0;
                else
                    scan = [scan;point];
                end

                kk = kk + 1;
            end
            
            ldrI = ldrI + 1;
            ldr = parseLdrRow(lidardata(ldrI,:), -pi/2);

        end
        
        if mod(pltcnt, pltskip) == 0

            ([vn.yaw vn.pitch vn.roll])

            R = rotation(deg2rad(vn.pitch),deg2rad(vn.roll),deg2rad(vn.yaw));
            scan = scan * R;
            
            cm_x=sum(scan(:,2))/size(scan,1)
            cm_z=sum(scan(:,3))/size(scan,1)
            
            scan(:,2)=scan(:,2)-cm_x;
            scan(:,3)=scan(:,3)-cm_z;

            cloud = [cloud ; scan];
        end
        pltcnt = pltcnt + 1;
        

        
        %%{
        subplot(h(1))
        plot3(cloud(2:end,1),cloud(2:end,2),cloud(2:end,3), 'b.', 'MarkerSize', 1);
        
        subplot(h(2))
        plot(cloud(2:end,1),cloud(2:end,3), 'b.', 'MarkerSize', 1);
        
        subplot(h(3))
        hold on
        plot(cloud(2:end,2),cloud(2:end,3), 'b.', 'MarkerSize', 1);
        plot(0,0,'r+','MarkerSize',5);
        %}
        
    end
    
    %skip displaying the first dataset (whatever it is)
    %so that we can have an easier last time.  this is lazy...
    if ~first
        pause(.001);
    else
        first = 0;
    end
    lasttime = curtime;
    
    
end

