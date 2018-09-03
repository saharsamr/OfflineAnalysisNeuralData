%% Plot Single LFP Signal
% This function will calculate and plot the LFP signal, which can be obtained
% from the continous data in the .NSx files recieved from blackrock system. The
% output LFP is the average among all trials.
%
% The inputs should be as follows:
%
% * continuous_data: The contineous data reletive to the experiment's trials.
% * continuous_data: The timestamps corresponding to the previous argument.
% * trials: Clear, the trials exist in the experiment.
% * x_low_lim: The low limit of the x axis.
% * x_high_lim: The high limit of the x axis.
% * x_axis_partitions: The numbers we want to display on the x axis.
%

function plot_lfp_sparse_noise ( ...
            continueous_data, ...
            continueous_data_time, ...
            trials, ...
            x_low_lim, ...
            x_high_lim, ...
            x_axis_partitions ...
        )
    continueous_data = double(continueous_data);
    min_len = 1000000;
    trials_ = struct('continueous_data', {}, 'filtered_data', {});
    for i = 1:numel(trials)
        trials_(i) = extract_trial_contineous_data( ...
                            trials(i), ...
                            continueous_data, ...
                            continueous_data_time, ...
                            x_low_lim, ...
                            x_high_lim ...
        );
        min_len = min(min_len, numel(trials_(i).filtered_data));
    end

    lfp = zeros(1, min_len);
    for i = 1:numel(trials_)
        lfp = lfp + trials_(i).filtered_data(1:min_len);
    end
    lfp = lfp ./ numel(trials_);
    lfp = smooth(lfp, 100);
    plot(trials_(1).continueous_data.time(1:min_len), lfp, 'b');
end
