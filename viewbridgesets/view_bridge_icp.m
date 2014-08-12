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

pltcnt = 1;
pltskip = 1;

cloud = zeros(1,3);

%[lat, long]
gpszero = vectornavdata(4,7:8);

avgcnt = 0;
avg = 0;

%calibrate ypr
ypr_cal = [0 0 0];
set_cal = 1;

m_scans=cell(1);

Tx=0;
Ty=0;
theta_sum=0;

figure(2)
hold on
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
        
        %fprintf('%.2f %.2f %.2f %.10f %.10f %.10f\n', vn.yaw, vn.pitch, vn.roll, ... 
            %vn.lat, vn.long, vn.alt)
        vnI = vnI + 1;
    end
    
    %LIDAR
    if curtime == starttimes(2)
        point = zeros(1,3);
        scan = zeros(1,3);
        firstcld = 1;
        
        ldrI = ldrI + 1;
        ldr               = parseLdrRow(lidardata(ldrI,:), -pi/2);
        

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
                point(3) = vn.alt*1000 - abs(ldr.y);
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

            %calculate the center of mass for the slice, have the slice
            %based around that
            

            
            cm_x=sum(scan(:,2))/size(scan,1);
            cm_z=sum(scan(:,3))/size(scan,1);
            
            scan(:,2)=scan(:,2)-cm_x;
            scan(:,3)=scan(:,3)-cm_z;
            
            cloud = [cloud ; scan];
            scsize = size(m_scans,2);
            
            
            dff_x=abs(diff(scan(:,2)));
            dff_z=abs(diff(scan(:,3)));
            test = dff_x<50 & dff_z<5;
            
            %[a,b]=findones(test');
            %test=test(a:b);
            
            samp=scan(test,2);
            samp=[samp scan(test,3)];
            
            %m_scans{scsize  }=scan(:,2:3);
            m_scans{scsize}=samp;
            m_scans{scsize+1}=0;
            
            axis([-10000 10000 -300 1000])
            if( scsize > 4 )
                
                first = m_scans{3};
                %old = m_scans{scsize-2};
                new = m_scans{scsize-1};

                [X,~,~] = find_diff(first,new,1);
                cla
                
                plot(first(:,1),first(:,2), 'g+');
                %plot(old(:,1),old(:,2), 'b+');
                plot(new(:,1),new(:,2), 'r+');
                
                %cc=rad2deg(acos(X(1)))
                %ss=rad2deg(asin(X(2)))
                
                c=new;
                %theta=-(acos(X(1)));
                theta=0
                rad2deg(theta)/2
                R = [cos(theta) sin(theta); -sin(theta) cos(theta)];
                c=c*R;
                
                %c(:,1)=c(:,1)-X(3);
                %c(:,2)=c(:,2)-X(4);
                
                
                plot(c(:,1),c(:,2), 'k.');
                1;
                
                %{
                c = new;
                
                Tx = Tx + X(3);
                Ty = Ty + X(4);
                
                c(:,1)=new(:,1)-X(3);
                c(:,2)=new(:,2)-X(4);
                
                ac=rad2deg(acos(X(1)));
                as=rad2deg(asin(X(2)));
                
                theta=-real(acos(X(2)));
                %theta_sum=theta_sum+theta;
                
                R = [cos(theta_sum) sin(theta_sum); -sin(theta_sum) cos(theta_sum)];
                c = c * R;
                
                %plot(c(:,1),c(:,2), 'g.')
                %}
            end
            
            
        end
        pltcnt = pltcnt + 1;
        
        
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

