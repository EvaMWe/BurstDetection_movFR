function [lburstStart,lburstStop]= burstClusters(burstStart, burstStop, spikeVec)
IBI_s = spikeVec(burstStart(2:end)) - spikeVec(burstStop(1:end-1));
% burstMerge = zeros(length(burstStart)+length(burstStop),1);
% burstMerge(1:2:end-1) = burstStart;
% burstMerge(2:2:end) = burstStop;
[N,edges] = histcounts(IBI_s, floor(0.5*length(IBI_s)));

NSmth = smooth(N)';

window = 2;
slope = -90;
[~,x]=max(NSmth);
while slope < -45
    section = NSmth(x:x + window);
    slope = calcSlopeNorm(section, NSmth, 'spline', 'degree' );
    x=x+1;
end

theta = edges(x);
selection = IBI_s <= theta;  
selection = [0 selection 0];
burstIdx = diff(selection);
lburstStart = burstStart(burstIdx == 1);
lburstStop = burstStop(burstIdx == -1);

end