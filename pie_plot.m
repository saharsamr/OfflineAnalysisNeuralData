%% Ploar Histogram
% This file will plot the plor hiostogram for and experiment based on a stimulus
% variable.
%
% The inputs should be as follows:
%
% * feature: This should contain the whole possible values of the stimulus variable
% that is mined the experiment.
% * feature_name : This argument, is stand for the name of that stimulus variable
% in trials data.
% * trials: Clear, the trials exist in the experiment.
% * confined_time: The time we want to look for spikes after onset, in seconds.
%

function pie_plot(feature, feature_name, trials, confined_time)
    time_coenfficient = 1000;
    num_of_spikes = [];
    for i = 1:numel(feature)
        selected_trials = trials([trials.(feature_name)] == i);
        total = 0;
        for j = 1:numel(selected_trials)
            total = total + numel(selected_trials(j).spikeTimes_PHDI( ...
                selected_trials(j).spikeTimes_PHDI > ...
                selected_trials(j).Time_Onset_PHDI & ...
                selected_trials(j).spikeTimes_PHDI < ...
                selected_trials(j).Time_Onset_PHDI + confined_time*time_coenfficient ...
            ));
        end
        num_of_spikes(i) = ceil(total/confined_time);
    end

    num_of_spikes_total=[];
    diff = 360/numel(feature);
    for i=1:numel (num_of_spikes)
     a=ones(1,num_of_spikes(i)).*(i-1)*diff*pi/180;
    num_of_spikes_total=[num_of_spikes_total a];
    end

    h = polarhistogram(num_of_spikes_total,'FaceColor','red','FaceAlpha',.3);
    h.DisplayStyle = 'stairs';
    h.BinWidth = pi/180;
    h.Parent.ThetaTick = [0:diff:360-diff];
    h.Parent.ThetaTickLabel = feature;
    title(['Spikes per second ',CONFIG.TASK_NAME])
end
