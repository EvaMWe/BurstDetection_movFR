%Tool to visualize burst detection
%spikeTimes : cell array containing spike data per electrode

function multiVis(spikeTimes,burstStart,burstStop)

spikeArray = conversion(spikeTimes,1);
nbEl =size(spikeArray,2);

spikeVec = conversion(spikeTimes,2);

firstPos = min(spikeVec)*12500;
lastPos =max(spikeVec)*12500;
nbSamples = ceil(lastPos-firstPos);


fig = figure ('NumberTitle', 'off', 'Name', 'timestamp plot');

for pl = 1:nbEl
    subplot(nbEl,1,pl)
    spikeSamples = ceil(spikeArray(:,pl)*12500);
    spikeSamples(spikeSamples == 0) = [];
    spikeStemps = zeros(nbSamples,1);
    spikeStemps(spikeSamples) = 1;
    plot(1:nbSamples,spikeStemps(1:nbSamples),'marker', 'none')
    hold on
    burstMarkerS = zeros(nbSamples,1);    
    %burstMarkerS(burstMarkerS==0) = NaN;
    burstMarkerS(ceil(spikeVec(burstStart)*12500)') = 1;
    plot(1:nbSamples,burstMarkerS(1:nbSamples),'marker', 'none', 'color', 'red')
    burstMarkerE = zeros(nbSamples,1);
   % burstMarkerE(burstMarkerE==0) = NaN;
    burstMarkerE(ceil(spikeVec(burstStop)*12500)') = 1;
    
    plot(1:nbSamples,burstMarkerE(1:nbSamples),'marker', 'none', 'color', 'green')
    if pl < nbEl
        set(gca, 'XTick', []);
    end
    set(gca,'Yticklabel',[],'box','off', 'YTick', []);
end
end


