function [detection_criterion,peaks, loc, fitted_template] = event_detection2( data, duration, rise_time, decay_time, threshold, make_plot )
% function from Geoff, event detection with algorithm published by Clements
% and Bekkers 1997 (Biophysical Journal, Vol73, July 1997, 220-229)
    if nargin == 3
        make_plot = false;
    end

    N = numel(data);
    step_time = duration/N;
    detection_criterion = zeros(1,N);
    times = 1:N;
    fitted_template = zeros(N,N);

    template = get_template(0, N, step_time, rise_time, decay_time);
    
    
    
    for time = times
        template = [0, template(1:end-1)];
        scale = get_scale(template, data, N);
        offset = (nansum(data) - scale .* nansum(template))/N;

        fitted_template(:,time) = template .* scale + offset;
        sse = nansum((data - fitted_template(:,time)').^2);
        standard_error = sqrt(sse / (N-1)); 

        detection_criterion(time) = scale ./ standard_error;
    end
    
    [peaks, loc] = get_events(threshold, detection_criterion);
    
    if make_plot
        figure;
        plot(times, detection_criterion)
        hold on
        plot(loc, peaks, 'ro')
        hold off
    end
end

function [peaks, loc] = get_events(threshold, criterion)
criterion = [0 criterion];
[peaks, loc] = findpeaks(criterion,'MINPEAKHEIGHT',threshold);
loc=loc-1;
end

function scale = get_scale(template, data, N)
    scale_numerator = nansum(template.*data) - nansum(template).*nansum(data)/N;
    scale_denominator = nansum(template.^2) - nansum(template).^2/N;
    scale = scale_numerator ./ scale_denominator;
end

function template = get_template(n, N, step, rise_time, decay_time)
    t = ((-n):(N-1-n)) * step;
    template = t * 0;
    norm_factor = 1; % No idea what this is for and don't think it does anything anyway since 'scale' will account for whatever value this is.
    template(t > 0) = norm_factor * (1 - exp(-t(t > 0)/rise_time)) .* exp(-t(t > 0)/decay_time);
end
