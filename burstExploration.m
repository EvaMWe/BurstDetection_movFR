function [burstInfo, burstID, start, stop] = burstExploration(start,stop,spikeVec,spikeTime,varargin)
%default
theta = 10;

if nargin == 5
    theta = varargin{1};
end

if iscell(spikeTime)
    spikeTime = conversion(spikeTime,1);
end

nb_burst = length(start);
burstInfo = repmat(struct('burstNumber',1),nb_burst,1);
burstID = zeros(nb_burst,1);

%% for each
count = 1;
for burst = 1:nb_burst
    
    start_temp = spikeVec(start(burst));
    stop_temp = spikeVec(stop(burst));
    Alin = find(spikeTime >= start_temp & spikeTime <= stop_temp);
    [Arow, Acol] = ind2sub(size(spikeTime),Alin);
    contributors = unique(Acol);
    nbContr = length(contributors);
    nbSpikes = stop(burst)-start(burst) +1;
    if nbContr >= 6 && nbSpikes >= theta        
        burstInfo(count).burstNumber=burst;
        burstInfo(count).burstSubscripts = [Arow,Acol];
        burstInfo(count).contribChannels = contributors;
        burstInfo(count).nbcontribChannels = nbContr;
        burstInfo(count).burstID = burst;
        burstID(count) = burst;
        burstInfo(count).nbSpikes = nbSpikes;
        count = count +1;
    end
end

burstID(burstID == 0) = [];
start = start(burstID);
stop = stop(burstID);

end