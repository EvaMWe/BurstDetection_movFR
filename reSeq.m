% this function iteratively takes start location and the next following
% stop location and stored in new vectors: finStop, finStart;
% Two following starts or stops are discarded in that way.

%input: (start,stop) 1xn double array containing all start and stop indices
%requirement: vectors are sorted from earliest to latest burst
%output: (finStart, finStop) 1xm double array with removed "extra" stops
%and starts

% PSEUDO
% finstart(1) = min(start) (= first value)
% finstop(1) = min(stop)

% count = 1
% WHILE no endpoint reached
%   finstart(count) = min(of all starts higher than finStop(count-1))
%   finstop(count) = min(of all stops higher than finStart(count-1))
% END

function [finStart,finStop]=reSeq(start,stop)

if start(1,1) > stop(1,1)
    stop=stop(2:end,1);
end

endStart = stop(end,1);
endStop = start(end,1);

finStart = zeros(length(start),1);
finStop = zeros(length(stop),1);

%initialize
finStart(1,1) = min(start);
finStop(1,1) = min(stop);

count = 2;
cont = 1;
while cont == 1
%sprintf('%i',count)
    finStart(count) = min(start(start>finStop(count-1)));
    finStop(count) = min(stop(stop>finStart(count)));    
    if finStop(count) >= endStop || finStart(count) >= endStart || finStart(count) >= endStop || finStop(count) >= endStart
        cont = 0;
        continue
    end
    count = count+1;
end

finStart(finStart == 0) =[];
finStop(finStop == 0)=[];

end
