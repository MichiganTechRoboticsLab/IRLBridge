function [ ldrdata ] = parseLdrRow( varargin ) %lidar_file )
%parseLdrRow this function parses a row of lidar data into a struct

row = varargin{1};

if nargin > 1
    phi = varargin{2};
else
    phi = 0;
end

%{
line = fgetl(lidar_file);
ldrdata.isend = line(1) == char('-1');
if ldrdata.isend
    data = sscanf(line,'%d,%d,%d');
    ldrdata.time = data(2) + data(3) / 1000000;
else
    data = sscanf(line,'%d,%f');
    ldrdata.isbig = data(1) > 15000;
    ldrdata.x    = data(1) * cos(data(2));
    ldrdata.y    = data(1) * sin(data(2));
    ldrdata.distance = data(1);
    ldrdata.radian   = data(2);
    ldrdata.time = 0;
end
%}

    ldrdata.isend = row(1) == -1;
    
    if ldrdata.isend
       ldrdata.time = row(2) + row(3) / 1000000;
    else
       ldrdata.isbig = row(1) > 10000 || row(1) < 1000;
       
       ldrdata.distance = row(1);
       
       ldrdata.radian   = row(2) + phi;
       
       ldrdata.x    = row(1) * cos(ldrdata.radian);
       ldrdata.y    = row(1) * sin(ldrdata.radian);
       
       ldrdata.isbig = ldrdata.isbig || ldrdata.x == 0 || ldrdata.y == 0;
       
       ldrdata.time = 0;
    end

%{
    ldrdata.time = row(1) + row(2) / 1000000;
    ldrdata.x    = row(3);
    ldrdata.y    = row(4);
    ldrdata.distance = row(5);
    ldrdata.radian   = row(6);
    
    ldrdata.isend    = ldrdata.time == 0 && ldrdata.distance == 0 && ...
        
    ldrdata.radian == 0;
%}
end

