%Tool to visualize burst detection
%spikeTimes : cell array containing spike data per electrode

%---HINTS
%spikeSamples: spikeTimes converted to sample points by *12500 

function multiVisinOne_2(spikeTimes,burstStart,burstStop, shortStart,shortStop)

spikeArray = conversion(spikeTimes,1);
nbEl =size(spikeArray,2);

spikeVec = sort(conversion(spikeTimes,2));

% firstPos = min(spikeVec)*12500;
% lastPos =max(spikeVec)*12500;



fig = figure ('NumberTitle', 'off', 'Name', 'timestamp plot');
place = 0.3;
for pl = 1:nbEl
    hold on
    spikeSamples = ceil(spikeArray(:,pl)*12500);
    spikeSamples(spikeSamples == 0) = [];
%     spikeStemps = zeros(nbSamples,1);
%     spikeStemps(spikeSamples) = 1;
%     
    %% create line coordinates
    spikeSamples_ = spikeSamples';
    x = repmat(spikeSamples_,2,1);
    y = repmat(pl-1,2,length(spikeSamples));
    y(2,:) = y(2,:) + 1 - place;
    
    line(x,y, 'color','k');

end

%% burstCluster
burstStempStart = floor(spikeVec(burstStart).*12500);
burstStempStop = ceil(spikeVec(burstStop).*12500);

width = (burstStempStop-burstStempStart);
widthVal = width(width > 0); 
x = burstStempStart(width>0);
nbBurst = length(x);

y = repmat(-0.2,1,nbBurst);
height = repmat(nbEl + 0.4,1,nbBurst);
for b = 1:nbBurst    
    rectangle('Position', [x(b),y(b),widthVal(b), height(b)], 'EdgeColor', 'red');
end

%% shortBurst
shortStempStart = floor(spikeVec(shortStart).*12500);
shortStempStop = ceil(spikeVec(shortStop).*12500);
width = (shortStempStop-shortStempStart);
x = shortStempStart;
nbBurst = length(x);

y = repmat(-0.2,1,nbBurst);
height = repmat(nbEl + 0.4,1,nbBurst);
for b = 1:nbBurst    
    rectangle('Position', [x(b),y(b),width(b), height(b)], 'EdgeColor', 'green');
end


end


