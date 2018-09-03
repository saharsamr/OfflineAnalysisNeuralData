%% LFP Signal
% This function will calculate and plot the LFP signal, which can be obtained
% from the continous data in the .NSx files recieved from blackrock system.
%
% The inputs should be as follows:
%
% * continuous_data: The contineous data reletive to the experiment's trials.
% * continuous_data: The timestamps corresponding to the previous argument.
% * feature: This should contain the whole possible values of the stimulus variable
% that is mined in the experiment.
% * feature_name : This argument, is stand for the name of that stimulus variable
% in trials data.
% * Trials: Clear, the trials exist in the experiment.
% * x_low_lim: The low limit of the x axis.
% * x_high_lim: The high limit of the x axis.
% * x_axis_partitions: The numbers we want to display on the x axis.
%

function plot_lfp ( ...
            continuous_data, ...
            continuous_data_time, ...
            features, ...
            feature_name, ...
            Trials, ...
            x_low_lim, ...
            x_high_lim, ...
            x_axis_partitions ...
)
    Trials = Trials(1:end-1);

    continuous_data=double(continuous_data);
    min_len = 1000000;
    trials_ = struct('continueous_data', {}, 'filtered_data', {});
    for i = 1:numel(Trials)
        time_on_set = Trials(i).Time_Onset_PHDI+30;
        trials_(i).continuous_data.info = continuous_data(continuous_data_time > time_on_set + x_low_lim & continuous_data_time < time_on_set + x_high_lim);
        trials_(i).continuous_data.time = continuous_data_time(continuous_data_time > time_on_set + x_low_lim & continuous_data_time < time_on_set + x_high_lim) - time_on_set;
        trials_(i).filtered_data = lowpass(trials_(i).continuous_data.info, 250, 30000);
        min_len = min(min_len, numel(trials_(i).filtered_data));
    end

    for i = 1:numel(features)
        selected_trials = trials_([Trials.(feature_name)] == i);
        data = {selected_trials([1:end]).filtered_data};
        lfp = zeros(1, 29999);
        for t = 1:numel(selected_trials)
            lfp = lfp + selected_trials(t).filtered_data(1:29999);
        end
        lfp = lfp ./ numel(selected_trials);

        subplot(numel(features), 1, i);
        plot([1:29999], lfp, 'b');
        ylabel(features(i));
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        box off;
        hold on;
    end
end
