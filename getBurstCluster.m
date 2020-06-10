% this function performs accoding to moving Burst Frequency:
% Inter burst intervals are calculated and moving BUrst Frequency (rate) is
% calcualted) --- algorithm accoding to getBurst_movFR_NB

function [lBurstStart,lBurstStop,shStart,shStop] = getBurstCluster(burstStart,burstStop,spikeVec)
IBI_s = spikeVec(burstStart(2:end)) - spikeVec(burstStop(1:end-1));

mask = [1 1 1];
SE = [1 1 1 1 1];
grad = [-1 0 1];

%% find rough burst positions
filtered = conv(IBI_s,mask,'same');
rate = length(mask)./filtered;
rateDiff = imfilter(rate,grad);


dil = imdilate(rateDiff,SE);
startBurst = (dil - rateDiff) == 0;
%könnte noch durch einen noise filter ersetzt werden // statistik -->
%butterworth high pass, mean + 3*std = threshold;
filterSettings  = constructFilt;
[~,cleaner] =  filterSignal(rateDiff,filterSettings );

starters = rateDiff >= 0.5*cleaner & startBurst;

rateDiffinv = -rateDiff;
dil = imdilate(rateDiffinv,SE);
stopBurst = (dil - rateDiffinv) == 0;
stops = rateDiffinv >= 0.3*cleaner & stopBurst;


%
idxStart = find(starters == 1);
idxStop = find(stops == 1)+1;

[idxStart, idxStop]=reSeq(idxStart',idxStop');


lBurstStart = burstStart(idxStart);
lBurstStop = burstStop(idxStop);

%% select short bursts
% starts
Bstart = repmat(burstStart',length(idxStart),1); 
Log1 = Bstart < lBurstStart;
Log2 = Bstart > lBurstStop;
Log = Log1 + Log2;
sumLog = sum(Log,1);
shStartlog = sumLog == length(lBurstStart);
shStart = burstStart(shStartlog);
% get associated stop
shStop = burstStop (shStartlog);



end

