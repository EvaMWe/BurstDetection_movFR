%This function is used to reanaylse the spike train regarding
%Burstagglomerates: "fast consecutive bursts including the very fast
%consecutive bursts designated as burstclsuter"

function [StartAggl, StopAggl, restStart, restStop] = findAgglomerats(shBurstStart,shBurstStop, Startcluster, Stopcluster, spikeVec)

allStarters = sort([shBurstStart; Startcluster]);
allStops = sort([shBurstStop; Stopcluster]);

[StartAggl,StopAggl,restStart,restStop] = getBurstCluster(allStarters,allStops,spikeVec);
[StartAggl, StopAggl] = broadening_clusters(StartAggl, StopAggl, spikeVec);
end