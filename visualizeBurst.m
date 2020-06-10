function visualizeBurst(rateDiff, burstStart, burstStop, spikeTime)


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
nbSamples = ceil(lastPos-firstPos);
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
