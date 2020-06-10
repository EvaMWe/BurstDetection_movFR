%this is a function implementing an innovative idea for burst detection;
% this is for single electrode bursts
% based on a vector containing the spike time the spike density / rate
% is calculated within a sliding window, lets say according to the moving
% firing rate
% (1) define mask
% (2) convolute spikeTime vector --> moving length over n spikes (n =
% length(mask))
% (3) rate = n spikes / length --> moving firing rate (MovFR)
% (4) calculating delta
% (5) searching strong deltas (strong differences in MovFR)
% (6) getting the maxima as burstStarts


function getBurst_movFR(spikeTime, varargin)


%defaults
mask = [1 0 0 0 0 -1];
SE = [1 1 1];
grad = [-2 -1 0 1 2];

%% find rough burst positions
filtered = conv(spikeTime,mask,'same');
rate = length(mask)./filtered;
rateDiff = imfilter(rate,grad);


dil = imdilate(rateDiff,SE);
startBurst = (dil - rateDiff) == 0;
%könnte noch durch einen noise filter ersetzt werden // statistik -->
%butterworth high pass, mean + 3*std = threshold;
filterSettings  = constructFilt;
[~,cleaner] =  filterSignal(rateDiff,filterSettings );
starters = rateDiff >= 0.4*cleaner & startBurst;

% rateDiffinv = -rateDiff;
% dil = imdilate(rateDiffinv,SE);
% stopBurst = (dil - rateDiffinv) == 0;
% stops = rateDiffinv >= 0.2*cleaner & stopBurst;


%
idxStart = find(starters == 1);
%idxStop = find(stops == 1)+1;

%% refinement
[burstStart, burstStop] = refineEdges(idxStart,spikeTime);


%[burstStart, burstStop]=reSeq(idxStart,idxStop);


% merge if needed
%S = Maximum_median(abs(filtered)(1:end-length(mask)+2),40,'Type','percent','Dimension',2);
%IntraBurst = burstStart(1,2:end)-burstStop(1,1:end-1);

%% visualize
lineX = zeros(1,length(rateDiff));
markerStart = lineX;
% if burstStop(end) > length(lineX)
%     burstStart(end) = [];
%     burstStop(end) = [];
% end
markerStart(burstStart) = 200;
markerStartna = markerStart;
markerStartna(markerStart == 0) = NaN;
markerStop = lineX;
markerStop(burstStop) = 180;
markerStopna = markerStop;
markerStopna(markerStopna == 0) = NaN;

figure, hold on
X = 1:length(rateDiff);
plot(X, rateDiff);
plot(X,markerStartna,'marker', '*')
plot(X,markerStopna,'marker','*')

%% spiketrain
firstPos = min(spikeTime)*12500;
lastPos =max(spikeTime)*12500;
nbSamples = lastPos-firstPos;
spikeSamples = ceil(spikeTime*12500);
spikeStemps = zeros(nbSamples,1);
spikeStemps(spikeSamples) = 1;

figure, hold on
plot(1:nbSamples,spikeStemps(1:nbSamples),'marker', 'none')
burstMarkerS = zeros(nbSamples,1);
burstMarkerS(burstMarkerS==0) = NaN;
burstMarkerS(ceil(spikeTime(burstStart)*12500)') = 1;
plot(1:nbSamples,burstMarkerS(1:nbSamples),'marker', '*')
burstMarkerE = zeros(nbSamples,1);
burstMarkerE(burstMarkerE==0) = NaN;
burstMarkerE(ceil(spikeTime(burstStop)*12500)') = 1;
plot(1:nbSamples,burstMarkerE(1:nbSamples),'marker', '*')



end
function [start,stop] = refineEdges(start_temp,spikeTime)
if size(spikeTime,2) > 1
    spikeTime = spikeTime';
end

if size(start_temp,2) >1
    start_temp = start_temp';
end
start_temp = start_temp'; 
stop = zeros(size(start_temp));
start = zeros(size(start_temp));

remBurst = 0;
append = 0;

for k =1:length(start_temp)
    sprintf('%i',k)
    if k == length(start_temp)
        segment = spikeTime(start_temp(k):end,1);
        
    else
        segment = spikeTime(start_temp(k):start_temp(k+1),1);
        
    end
    if length(segment) <= 5 %invalide start
        start(k) = NaN;
        stop(k) = NaN;
        if append == 0
            remBurst = [spikeTime(start_temp(k)) spikeTime(start_temp(k+1)-1) start_temp(k)];
            append = 1;
            continue
        else
            remBurst = [remBurst; [spikeTime(start_temp(k)) spikeTime(start_temp(k+1)-1) start_temp(k)]];
            continue
        end
    else
        append =0;
    end
 
    %% get threshold
    ISI_s = diff(segment);
    ISI = ISI_s.*12500; %in sample points
    logISI = log10(ISI);
    [N,edges] = histcounts(logISI, floor(0.5*length(ISI)));
    
    
    sizN = size(N,2);
 
    if sizN <= 3
        S = edges(2);
        burst = logISI<S;
    elseif sizN <= 5
        S =edges(3);
        burst = logISI<S;
    else
        r = cumsum(N)./(1:1:length(N));
        [~,maxIDX] = max(r);
        [~,minIDX] = min(r);
        if minIDX < maxIDX
            [~,maxIDX] = max(r(1:minIDX));
        end
        S = edges(maxIDX+ceil(0.8*(minIDX -maxIDX)));
        
        
        burst = logISI <  S; %plus 2: next 2 interval after max, outer border
    end
    start(k) = start_temp(k);
    
    %% find end of burst
    brstNb = find(burst==0,1,'first');
    while brstNb < 5
        burst(brstNb) = 1;
        brstNb = find(burst==0,1,'first');
    end
    stopIdx = start_temp(k) +  brstNb-1 ;
    
    
    if stopIdx > length(spikeTime)
        stop(k) = length(spikeTime);
        start(k) = start_temp(k);
        continue
    elseif isempty(stopIdx)
        stopIdx = start_temp(k) + length(burst);
    end
    stop(k) = stopIdx;
   
  
    %% refine start   
    
    if k > 1
        cnt = 1;
        startNew = start(k);
        go = 1;
        while isnan(start(k-cnt)) && go == 1         
                test = spikeTime(startNew) -remBurst(cnt,2);
                if test < 10.^S/12500
                    startNew = remBurst(cnt,3);
                else 
                    go = 0;
                end
                cnt = cnt + 1;            
        end
    end
    
end
    
start = start(~isnan(start));
stop = stop(~isnan(stop));
start(start==0) = [];
stop(stop==0) = [];

start_temp = start;
stop_temp = stop;

%% merge bursts
nbSpInter = start(2:end)-stop(1:end-1);
potMerge = find(nbSpInter<5);
for merge = 1: length(potMerge)-1
    a = diff(spikeTime(start_temp (potMerge(merge)):stop_temp (potMerge(merge)))); %first burst
    b = diff(spikeTime(start_temp(potMerge(merge)+1):stop_temp(potMerge(merge)+1))); %second burst
    ab = [a;b];    
    S =  max(ab);
    
    ISI_inter = diff(spikeTime(stop_temp (potMerge(merge)):start_temp (potMerge(merge)+1)));   

    logi = sum(ISI_inter > S);
  
    if logi == 0 
        start(potMerge(merge)+1) = NaN;
        stop(potMerge(merge)) = NaN;
    end
end

start = start(~isnan(start));
stop = stop(~isnan(stop));
start(start==0) = [];
stop(stop==0) = [];
    
    
    %% check start
%     chckstart = start_temp(k);
% %     if k > 1
%         if isnan(start_temp(k-1))
%             test = start(k) -remBurst(2);
%             if test < S
%                 start(k) = remBurst(1);
%                 chckstart = start(k);
%             end
%         end
%     end
%     
%     cnt = 1;
%     go = 1;    
%     while go == 1
%         go = spikeTime(chckstart-(cnt-1))- spikeTime(chckstart-cnt) < (10.^S_start)/12500;
%         cnt = cnt+1;        
%     end    
%     cnt = cnt-2;
    
%     stop(k) = stopIdx;
%     start(k) = chckstart;% -cnt;
%     thresh(k) = (10.^S_merge)/12500;
    





%% search for short bursts
% short = stop-start;
% while sum(short <= 0) ~= 0
%     idxShort = find(short<=0);
%     start(idxShort+1) = [];
%     stop(idxShort) = [];
%     short = stop-start;
% end

%[finStart,finStop]=reSeq(start,stop);


end



