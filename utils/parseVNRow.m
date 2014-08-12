function [ vndata ] = parseVNRow( vnrow, ypr_cal )
%Parses a line of vector nav data
    vndata.time = vnrow(1) + vnrow(2) / 1000000;
    vndata.yaw  = vnrow(3) - ypr_cal(1);
    vndata.pitch= vnrow(4) - ypr_cal(2);
    vndata.roll = vnrow(5) - ypr_cal(3);
    vndata.lat  = vnrow(6);
    vndata.long = vnrow(7);
    vndata.alt  = vnrow(8);
end

