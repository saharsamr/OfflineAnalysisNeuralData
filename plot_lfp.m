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
    for i = 1:numel(Trials)
        time_on_set = Trials(i).Time_Onset_PHDI+30;
        Trials(i).continuous_data.info = continuous_data(continuous_data_time > time_on_set + x_low_lim & continuous_data_time < time_on_set + x_high_lim);
        Trials(i).continuous_data.time = continuous_data_time(continuous_data_time > time_on_set + x_low_lim & continuous_data_time < time_on_set + x_high_lim) - time_on_set;
        Trials(i).filtered_data = lowpass(Trials(i).continuous_data.info, 250, 30000);
        min_len = min(min_len, numel(Trials(i).filtered_data));
    end

    for i = 1:numel(features)
        selected_trials = Trials([Trials.(feature_name)] == i);
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
