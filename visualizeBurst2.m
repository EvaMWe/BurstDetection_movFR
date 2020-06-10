function visualizeBurst2( burstStart, burstStop, spikeTime)


%% spiketrain
firstPos = min(spikeTime)*12500;
lastPos =max(spikeTime)*12500;
nbSamples = ceil(lastPos-firstPos);
spikeSamples = ceil(spikeTime*12500);
spikeStemps = zeros(nbSamples,1);
spikeStemps(spikeSamples) = 1;

figure, hold on
plot(1:nbSamples,spikeStemps(1:nbSamples),'marker', 'none')
burstMarkerS = zeros(nbSamples,1);
%burstMarkerS(burstMarkerS==0) = NaN;
burstMarkerS(ceil(spikeTime(burstStart)*12500)') = 1;
plot(1:nbSamples,burstMarkerS(1:nbSamples),'marker', 'none', 'color', 'red')
burstMarkerE = zeros(nbSamples,1);
%burstMarkerE(burstMarkerE==0) = NaN;
burstMarkerE(ceil(spikeTime(burstStop)*12500)') = 1;
plot(1:nbSamples,burstMarkerE(1:nbSamples),'marker', 'none', 'color', 'green')
end
