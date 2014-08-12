function [ from, to ] = findones( bitstring )

bitstring = [ 0 bitstring 0];

df = diff(bitstring);

Iones = find(df==1);
Inones= find(df==-1);

[~,I] = max(find(df==-1)-find(df==1));
from=Iones(I);
to=Inones(I)-1;

end

