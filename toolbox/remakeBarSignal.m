function barData = remakeBarSignal(barEvents, trialEndTime, frequency, states)


barData = barEvents;
barData.signal.time = floor(min(barEvents.time):0.5:trialEndTime);
barData.signal.bar  = zeros(1, numel(barData.signal.time))-1;

for event_index = 1:numel(barData.info)
%     barState  = str2double(barData.info{event_index}(end));
    if strfind(barData.info{event_index},states{1})
        barState = 1;
    elseif strfind(barData.info{event_index},states{2})
        barState = 0;
    else
        barState = -1;
    end
    
    barData.signal.bar(barData.signal.time > barData.time(event_index)) = barState;
end


end