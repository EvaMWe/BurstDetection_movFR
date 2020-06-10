function [shortStart, shortStop] = cleanShort(Startcluster, Stopcluster, burstStart, burstStop)

Bstart = repmat(burstStart',length(Startcluster),1); 
Log1 = Bstart < Startcluster;
Log2 = Bstart > Stopcluster;
Log = Log1 + Log2;
sumLog = sum(Log,1);
shStartlog = sumLog == length(Startcluster);
shortStart = burstStart(shStartlog);

shortStop = burstStop(shStartlog);
end
% get associated stop