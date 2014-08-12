%This is a script which allows the user to view vectornav, lidar, and image
%data all together.

%TODO: It currently breaks at the end because there is no end condition
clear
clc
close all

%speed up or slow down the simulation
SPEEDUP = 1;

%location of major directory
testdir = [pwd() '/test2/'];

%location of data
picdir   = [testdir 'pics/'];
vnfname  = [testdir 'vn.csv'];
ldrfname = [testdir 'lidar_data.csv'];

%grabbing images
images = dir([picdir '*.bmp']);
imgI = 1;

%reading vector nav csv
vectornavdata = csvread(vnfname);
vnI  = 1;

%reading lidar csv
lidardata = csvread(ldrfname);
ldrI = 1;
ldrScanI = 1;

%setup the starttimes vector
starttimes = zeros(1,3);
lasttime = 0;

first = 1;

%define figure
f = figure;
set(f,'name','LIDAR - Camera Visualization','numbertitle','off')

%h(1) will be for the lidar, h(2) will be for the image
h(1) = subplot(1,3,1);
h(2) = subplot(1,3,2);
h(3) = subplot(1,3,3);

%initiailze variables for the trail
%total number of sets to save
trailLength = 10;
%current size of the trail (SHOULD BE ZERO AT START)
trailSize   = 0;
%trail itself
trail = cell(1,trailLength);

while true%~feof(lidardata)
    
    %get image start time
    [~,starttimes(1)] = parsepicname([picdir images(imgI).name]);
    
    %get vector nav start time
    vn                = parseVNRow(vectornavdata(vnI,:));
    starttimes(2)     = vn.time;
    
    %get lidar start time
    ldr               = parseLdrRow(lidardata(ldrI,:));
    starttimes(3)     = ldr.time;
    
    %find smallest, and set current time
    [curtime,smlI] = min(starttimes);
    
    %IMAGE
    if curtime == starttimes(1)
        subplot(h(2));
        
        %grab the image and show it
        filename = [picdir images(imgI).name];
        imshow(filename)
        imgI = imgI + 1;
    end
    
    %VECTORNAV
    if curtime == starttimes(2)
        %print vectornav data to the screen
        fprintf('%.2f %.2f %.2f %.10f %.10f %.10f\n', vn.yaw, vn.pitch, vn.roll, ... 
            vn.lat, vn.long, vn.alt)
        
        if ~(vn.lat == 0 && vn.long == 0)
            subplot(h(3))
            hold on
            plot(vn.lat, vn.long)
            hold off
        end
        vnI = vnI + 1;
    end
    
    %LIDAR
    if curtime == starttimes(3)
        ldrI = ldrI + 1;
        ldr               = parseLdrRow(lidardata(ldrI,:));
        
        subplot(h(1))
        %axis([-1500 100 -1500 100])
        %axis([-8000 8000 -8000 8000])
        
        cla
        
        
        %loop through entire scan and build a list of points to plot
        kk = 1;
        while ~ldr.isend
            if(ldr.isbig)
                temp.x(kk) = 0;
                temp.y(kk) = 0;
            else
                temp.x(kk) = ldr.x;
                temp.y(kk) = ldr.y;
            end
            ldrI = ldrI + 1;
            ldr = parseLdrRow(lidardata(ldrI,:));
            
            kk = kk + 1;
            
        end
        
        hold on
        plot(temp.x, temp.y, '.', 'MarkerSize', 3);
        hold off
        
        
    end
    
    %skip displaying the first dataset (whatever it is)
    %so that we can have an easier last time.  this is lazy...
    if ~first
        pause((curtime-lasttime) / SPEEDUP);
    else
        first = 0;
    end
    lasttime = curtime;
end
fclose(lidardata);
lidardata = 0;

