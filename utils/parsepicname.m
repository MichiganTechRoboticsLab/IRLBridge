function [ picnum, time ] = parsepicname( filename )

%extract just the name
[~,name,~] = fileparts(filename);

%find commas
a = find(name == ',');

%grab the picnum
strnum = name(1:(a(1)-1));
picnum = str2double(strnum);

%grab seconds
strsec = name((a(1)+1):a(2)-1);
strusec= name(a(2)+1:end);

time   = str2double(strsec) + str2double(strusec)/1000000;



end

