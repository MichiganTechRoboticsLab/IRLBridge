clear
clc
close all

%set fps to view image/ camera
FPS = 22;
%next time to repaint the image
curImgT = 0;

%set scans per second of Hokuyo (Hz)
SPS = 40;
%next time to repaint the scan
curScanT = 0;

%overall current time
curT = 0;

%max_distance for filtering data
MAXDIST = 5000;

%Number of pts
NUMPTS = 1082;

%read the data from the csv
raw_scancsv = csvread('testb/lidar_data_b.csv');

%scale to nearest scan
num_samp = floor(size(raw_scancsv,1)/NUMPTS)
cloud = zeros(NUMPTS, 4, num_samp);

f = figure;

set(f,'name','LIDAR - Camera Visualisation','numbertitle','off')

h(1) = subplot(1,2,1);
h(2) = subplot(1,2,2);

%current index of trail
t_i = 1;
%number of items in the trail
t_n = 20;

for( i=1:num_samp )
    
    if( curT == curScanT )
        
        disp('draw scan')
        
        cloud(:,:,i) = raw_scancsv((i-1)*NUMPTS+1:NUMPTS*i,:);
        sample = cloud(:,:,i);
        
        zeros =  find(sample(:,4) == 0);
        ind = find((abs(sample(:,3) > MAXDIST)));
        [sample,PS] = removerows(sample, 'ind', ind);
        
        subplot(h(1))
        
        %increments trail size until the trail array reaches the maximum
        %length, and then it just gets rid of the oldest trail marker.
        if( t_i >= t_n )
            trail(1) = [];
            trail{t_n-1} = sample;
        else
            trail{t_i} = sample;
            t_i = t_i + 1;
        end
        
        curScanT = curScanT + 1/SPS

        %plots each element of the trail, and allows the newer points to be
        %darker.
        
        %intensity of the grey, 1 = white, 0 = black
        gr = 1;
        
        cla
        hold on
        for( ii=1:(t_i-1) )
            
            sub = trail{ii};
            plot(sub(:,1), sub(:,2), 'Color',[gr gr gr])
            
            gr = gr - 1/(t_i-1);
            
        end
        hold off
        
        axi([-3000 4000 -5000 5000])
    end
    
    if( curT == curImgT )
        
        disp('paint picture')
        
        subplot(h(2))
        filename = sprintf('testb/13482028-%d.bmp', i);
        if exist(filename, 'file') == 2
            
            img = imread(filename);
            imshow(img);
            
        end
        
        curImgT = curImgT + 1/FPS
    end
    
    %need to fix for the equal case
    if( curScanT < curImgT )
        pauseT = curScanT - curT
    else
        pauseT = curImgT - curT
    end
    
    curT = curT + pauseT;
    pause(pauseT);
    
end
