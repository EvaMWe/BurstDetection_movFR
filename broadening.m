function [burstStart, burstStop] = broadening(start_temp, stop_temp, spikeTimes)

%delta = stop_temp-start_temp;
%f = @computeS;
S = arrayfun(@(start_temp,stop_temp) computeS(start_temp,stop_temp,spikeTimes), start_temp, stop_temp);
%matrix(:,3) = arrayfun(@(a,b)max(diff(spikeTimes(a:b))),start_temp,stop_temp);

%%elongate
winLen = 100;
win = zeros(1,winLen);
spikeTimesLong = [win spikeTimes];
startLong = start_temp + winLen;
stopLong = stop_temp + winLen;

meanS = mean(S);
burstStart = startDirection(startLong, stopLong, spikeTimesLong, S,  winLen);
burstStop = stopDirection(stopLong, startLong, spikeTimesLong, S, meanS, winLen);
end

function thresh = computeS(a,b,spikeTimes)
thresh = max(diff(spikeTimes(a:b)));
end



function start = startDirection(start_temp, stop_temp, spikeTimes, S,  win)
if size(spikeTimes,2) > 1
    spikeTimes = spikeTimes';
end
count = 1;
nbSp = zeros(length(start_temp),1);
summe = 1;
adding = ones(length(start_temp),1);
while summe ~= 0
    if start_temp(1)-count <= 0
        summe = 0;
        continue
    end
    
   
    temp = spikeTimes(start_temp-(count-1))-(spikeTimes(start_temp-count)) < S;
    temp(start_temp(2:end)-count <= stop_temp(1:end-1)) = 0;
    adding = temp & adding;
    summe = sum(adding);
    nbSp = nbSp+adding;
    count = count+1;
end
start = start_temp - nbSp;
start = start - win;
end

function stop = stopDirection(stop_temp,start_temp, spikeTimes, S,meanS,win)
if size(spikeTimes,2) > 1
    spikeTimes = spikeTimes';
end
count = 1;
nbSp = zeros(length(stop_temp),1);
summe = 1;
adding = ones(length(stop_temp),1);
while summe ~= 0
    if stop_temp(end)+count+1 >= length(spikeTimes)
        summe = 0;
        continue
    end
    alpha = 1.5.*meanS./S;
    
    temp = spikeTimes(stop_temp+count)-(spikeTimes(stop_temp+count-1)) < alpha.*S;
    temp(stop_temp(1:end-1)+count >= start_temp(2:end)) = 0;
    adding = temp & adding;
    summe = sum(adding);
    nbSp = nbSp+adding;
    count = count+1;
end
stop = stop_temp + nbSp;
stop = stop - win;
end


