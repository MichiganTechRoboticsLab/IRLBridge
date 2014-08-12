%This is a script which allows the user to view vectornav, lidar, and image
%data all together.

%TODO: It currently breaks at the end because there is no end condition
clear
clc
close all

%speed up or slow down the simulation
SPEEDUP = 1;

% camera parameters
fx = 512;
fy = 512;
cx = 241;
cy = 322;

%location of major directory
% testdir = 'D:\My_Stuff\PhD\MTU\Summer_2014\IRLab\Mcodes\LIDER_CAM\949364136\';
testdir = '/home/jmmanela/IRLStuff/stop1/';
%location of data
picdir   = [testdir 'pics/'];
vnfname  = [testdir 'vn.csv'];
ldrfname = [testdir 'lidar_data.csv'];


% Sensor cluster velocity
V = 3*1.609*1000/(60*60); % m/s
Displacment = 0;

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
ldr               = parseLdrRow(lidardata(ldrI,:));    
TimeCurrent = ldr.time;  % current scan time (initi.)
TimePrev = TimeCurrent;  % previous scan time (initi.)
TimeDiff = abs(TimeCurrent - TimePrev);

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
while true
    
    %get image start time
    [~,starttimes(1)] = parsepicname([picdir images(imgI).name]);
    
    %get vector nav start time
    vn                = parseVNRow(vectornavdata(vnI,:), [0 0 0]);
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
        
        
        A = imread(filename);
        B = imrotate(A,90);
        imshow(B);
        
        %PUT YOUR STUFF IN HERE             
              
        imgI = imgI + 1;
    end
    
    %VECTORNAV
    if curtime == starttimes(2)
        %print vectornav data to the screen
%         fprintf('%.2f %.2f %.2f %.10f %.10f %.10f\n', vn.yaw, vn.pitch, vn.roll, ... 
%             vn.lat, vn.long, vn.alt)
        
%use 1200
        if ~(vn.lat == 0 && vn.long == 0) && vnI > 0
            subplot(h(3))
            hold on
            plot(vn.lat, vn.long, '.g')
            hold off
        end
        vnI = vnI + 1;
    end
    
    %LIDAR
    if curtime == starttimes(3)
        ldrI = ldrI + 1;
        ldr               = parseLdrRow(lidardata(ldrI,:));
        
        subplot(h(1))        
        axis square
%         axis([-10000 10000 -10000 10000])
        
%         cla
        
        
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
        
        Displacment = Displacment + V * TimeDiff;
        
        %use 1200
        if( vnI > 0 )
            hold on    
            plot3(Displacment*ones(1,length(temp.x)),temp.x,-1*temp.y, '.', 'MarkerSize', 3,'MarkerFaceColor','auto');
            hold off
        end
        
        
        TimePrev    = TimeCurrent;
        TimeCurrent = ldr.time;
        TimeDiff = abs(TimeCurrent - TimePrev);
        
%         hold on
%         plot(temp.x, temp.y, '.', 'MarkerSize', 3);
%         hold off
        
        
    end
    pause(.01)
    vnI
%     
%     %skip displaying the first dataset (whatever it is)
%     %so that we can have an easier last time.  this is lazy...
%     if ~first
% %         pause((curtime-lasttime) / SPEEDUP);
%         pause(.0001)
%     else
%         first = 0;
%     end
    lasttime = curtime;
end

