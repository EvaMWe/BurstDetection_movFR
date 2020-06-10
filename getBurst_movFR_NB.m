%core algorithm for network burst detection.
% input: spikeTime, spiketimes as a vector
% (1) find rough burst positions:
%     moving firing rate: convolution of spike Time with mask --> time
%     within a window defined by a fixed number of spikes (length(mask)
%     rate: number of spikes / time 
%     rateDiff: 1. derivative of rate --> strong increases indicates start
%     of burst, strong decreases indicates stop of a burst
%     filter rateDiff to get noise and threshold to clean data -->
%     idxStart,idxStop
%  
% (2) rearrange idxStart and idxStop

function [burstStart, burstStop] = getBurst_movFR_NB(spikeTime)


%defaults
mask = [1 0 0 0 0 -1];
SE = [1 1 1 1 1];
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

starters = rateDiff >= 0.2*cleaner & startBurst;

rateDiffinv = -rateDiff;
dil = imdilate(rateDiffinv,SE);
stopBurst = (dil - rateDiffinv) == 0;
stops = rateDiffinv >= 0.2*cleaner & stopBurst;


%
idxStart = find(starters == 1);
idxStop = find(stops == 1)+1;

[idxStart, idxStop]=reSeq(idxStart',idxStop');

%% refinement
%[burstStart, burstStop] = refineEdges(idxStart, idxStop, spikeTime);
[burstStart, burstStop] = broadening(idxStart, idxStop, spikeTime);

%[burstStart,burstStop] = spliceOver(burstStart,burstStop,length(spikeTime));
[burstStart, burstStop] = mergeBursts(burstStart, burstStop, spikeTime);




% merge if needed
%S = Maximum_median(abs(filtered)(1:end-length(mask)+2),40,'Type','percent','Dimension',2);
%IntraBurst = burstStart(1,2:end)-burstStop(1,1:end-1);

%% visualize
visualizeBurst(rateDiff, burstStart, burstStop, spikeTime);



end
% function [start,stop] = refineEdges(start_temp,stop_temp, spikeTime)
% if size(spikeTime,2) > 1
%     spikeTime = spikeTime';
% end
% 
% if size(start_temp,2) >1
%     start_temp = start_temp';
% end
% 
% if size(start_temp,2) >1
%     stop_temp = stop_temp';
% end
% 
% start_temp = start_temp'; 
% stop = zeros(size(start_temp));
% start = zeros(size(start_temp));
% 
% remBurst = 0;
% append = 0;
% 
% for k =1:length(start_temp)
%     
%     if k == length(start_temp)
%         segment = spikeTime(start_temp(k):end,1);
%         segment2 = spikeTime(start_temp(k-1):end,1);
%     elseif k == 1
%         segment = spikeTime(start_temp(k):start_temp(k+1),1);
%         segment2 = spikeTime(start_temp(k):start_temp(k+1),1);
%     else
%         segment = spikeTime(start_temp(k):start_temp(k+1),1);
%         segment2 = spikeTime(start_temp(k-1):start_temp(k+1),1);        
%     end
%     
%     if length(segment) <= 5 %invalide start
%         start(k) = NaN;
%         stop(k) = NaN;
%         if append == 0
%             remBurst = [spikeTime(start_temp(k)) spikeTime(start_temp(k+1)-1) start_temp(k)];
%             append = 1;
%             continue
%         else
%             if k < length(start_temp)
%                 remBurst = [remBurst; [spikeTime(start_temp(k)) spikeTime(start_temp(k+1)-1) start_temp(k)]];
%                 continue
%             else
%                 append = 0;
%                 continue
%             end
%         end
%     else
%         append =0;
%     end
%  
%     %% get threshold
%     ISI_s = diff(segment);
%     ISI = ISI_s.*12500; %in sample points
%     logISI = log10(ISI);
%     [N,edges] = histcounts(logISI, floor(0.3*length(ISI)));
%     
%     
%     sizN = size(N,2);
%  
%     if sizN <= 3
%         S = edges(2);
%         
%     elseif sizN <= 5
%         S =edges(3);
%         
%     else
%         r = cumsum(N)./(1:1:length(N));
%         [~,maxIDX] = max(r);
%         [~,minIDX] = min(r);
%         if minIDX < maxIDX
%             [~,maxIDX] = max(r(1:minIDX));
%         end
%         S = edges(maxIDX+ceil(1.0*(minIDX -maxIDX)));       
%         
%         %plus 2: next 2 interval after max, outer border
%     end
%     
%      burst = logISI <  S;
%     start(k) = start_temp(k);
%     
%     %% find end of burst
%     brstNb = find(burst==0,1,'first');
%     while brstNb < 5
%         burst(brstNb) = 1;
%         brstNb = find(burst==0,1,'first');
%     end
%     stopIdx = start_temp(k) +  brstNb-1 ;
%     
%     
%     if stopIdx > length(spikeTime)
%         stop(k) = length(spikeTime);
%         start(k) = start_temp(k);
%         continue
%     elseif isempty(stopIdx)
%         stopIdx = start_temp(k) + length(burst);
%     end
%     stop(k) = stopIdx;
%    
%   
%     %% refine start   
%     
%     if k > 1
%         cnt = 1;
%         startNew = start(k);
%         go = 1;
%         while isnan(start(k-cnt)) && go == 1         
%                 test = spikeTime(startNew) -remBurst(cnt,2);
%                 if test < 1.5*(10.^(S)/12500)
%                     startNew = remBurst(cnt,3);
%                 else 
%                     go = 0;
%                 end
%                 cnt = cnt + 1;            
%         end
%     end
%     
% end
%     
% start = start(~isnan(start));
% stop = stop(~isnan(stop));
% start(start==0) = [];
% stop(stop==0) = [];

%end



