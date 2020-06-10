function [start,stop] = spliceOver(start_temp,stop_temp,len)

TS = zeros(len,1);
for i = 1:length(start_temp)
    TS(start_temp(i):stop_temp(i)) = 1;
end

TSdiff = diff(TS);
start = find(TSdiff == 1)+1;
stop = find(TSdiff == -1);
end
