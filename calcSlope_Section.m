% this function calulates the slope within a section of a discrete curve;
% Normalization within that section
% therefore the section is fitted by a spline or by a polynome:
% - for spline use 'spline' as second argument
% - for polynomal fit use 'poly' as second argument
% then the result is outputted as degree (mean(atand(diff(intp)./diff(x)))or as a numeric value mean(diff(intp)./diff(x))
% 

function slope = calcSlope_Section(section, fitType, type)

n_frames = length(section);
x = 1:1:n_frames;
x_norm = x;

y = section;
y_max = max(section);
y_min = min(section);
if y_max -y_min == 0
    slope = 0;
    return
end
y_norm = (y-y_min)./(y_max-y_min);

x = x_norm;
xx = linspace(x(1),x(end),10);
Y = y_norm;

switch fitType
    case 'spline'
        intp = spline(x,Y,xx);
        if strcmp(type,'degree')
            slope = mean(atand(diff(intp)./diff(xx)));
        elseif strcmp(type,'numeric')
            slope = mean(diff(intp)./diff(xx));
        else
            error ('invalid argument')
        end
        
                
    case 'poly'
        x = x';
        Y = Y';
        intp = fit(x,Y,'poly2');
        slope = mean(differentiate(intp, x));
        if strcmp(type,'degree')
            slope = atand(slope);
        elseif strcmp(type,'numeric')
        else
            error ('invalid argument')
        end
end

end


