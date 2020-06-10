% spikeTimes = cell array containing the spike times per electrode
% This is the main function for network burst analysiation according to the
% moving firinge rate method 
% Input (spikeTImes) is a cell array containing the data from one time bin
% derived from one network (column = electrodes, rows: spikeTimes (in
% seconds)

% (1) cell array is transformed to a 1-D double arrays containing the
% spike times (in seconds)

% (2) spikeVec is sorting and passed to getBurst_movFR_NB --> main
% algorthim for burst detection, returning the starts and stops of fast
% bursts (intra spike interval is small) burstStart, burstStop

% (3) burstStart, burstStop are passed to burstClusters, here near bursts
% are merged and form long bursts (lburstStart,lburstStop);

% (4) lburstStart, lburstStop are passed tp broadening: starts and stops of
% clusters are refined --> Startclusters, Stopclusters

function getNB_movFR(spikeTimes)
%%convert to vector
[spikeVec,~] = conversion(spikeTimes, 2);
spikeVec = sort(spikeVec);

[burstStart, burstStop] = getBurst_movFR_NB(spikeVec);

[lburstStart,lburstStop, shBurstStart, shBurstStop]= getBurstCluster(burstStart, burstStop, spikeVec);
[Startcluster, Stopcluster] = broadening_clusters(lburstStart, lburstStop, spikeVec);
[Startcluster, Stopcluster] = mergeBursts(Startcluster, Stopcluster, spikeVec, 1, 10);
[StartAggl, StopAggl, remainersStart,remainersStop] = findAgglomerats(shBurstStart,shBurstStop, Startcluster, Stopcluster, spikeVec);
[shortBurstStart,shortBurstStop] = cleanShort(Startcluster, Stopcluster, burstStart, burstStop);
multiVisinOne_3(spikeTimes,Startcluster,Stopcluster, shBurstStart,shBurstStop, StartAggl,StopAggl)

[burstInfo, burstID, shortBurstStart,shortBurstStop] = burstExploration(shortBurstStart,shortBurstStop,spikeVec,spikeTimes, 10);
multiVisinOne_2(spikeTimes,Startcluster,Stopcluster, shortBurstStart,shortBurstStop)
end
