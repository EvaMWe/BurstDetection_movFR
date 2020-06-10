% spikeTime: vectorized spike times
% start_temp: vector containing spikeID that starts a burst
% stop_temp: vector containing spikeID that stops a burst
% varargin: optional: 1 = check for minimum psike number
%                     0 and else = don't check


function [start, stop] = mergeBursts(start_temp, stop_temp, spikeTime, varargin)

%default 
check = 0;
theta = 10;  %Grenzwert für spike number check

if nargin >= 4
    check = varargin{1};
end

if nargin == 5
    theta = varargin{2};
end

start = start_temp;
stop = stop_temp;
nbSpInter = start_temp(2:end)-stop_temp(1:end-1);
potMerge = find(nbSpInter<10);
for merge = 1: length(potMerge)-1
    a = diff(spikeTime(start_temp (potMerge(merge)):stop_temp (potMerge(merge)))); %first burst
    b = diff(spikeTime(start_temp(potMerge(merge)+1):stop_temp(potMerge(merge)+1))); %second burst
    ab = [a b];    
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

if check == 1
    nbSpikes = stop-start;
    logCh = nbSpikes > theta;
    start = start(logCh);
    stop = stop(logCh);
end



end
    