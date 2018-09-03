%% Raster Plot and PSTH
% This Function will plot the raster plot and the compute the psth corresponding
% to that for all values possible for the stimulus varible that is the subject of
% the experimtn.
%
% The inputs should be as follows:
%
% * feature: This should contain the whole possible values of the stimulus variable
% that is mined in the experiment.
% * trials: Clear, the trials exist in the experiment.
% * feature_name : This argument, is stand for the name of that stimulus variable
% in trials data.
% * x_low_lim: The low limit of the x axis.
% * x_high_lim: The high limit of the x axis.
% * x_axis_partitions: The numbers we want to display on the x axis.
% * bin_size_ms: The bin size for psth computing in mili seconds.
% * x_delta_ms: The step that is using for computing the proper bin for psth in
% mili secconds.
%

function raster_plot_and_psth ( ...
            features, ...
            trials, ...
            feature_name, ...
            x_low_lim, ...
            x_high_lim, ...
            x_axis_partitions, ...
            bin_size_ms, ...
            x_delta_ms ...
)
    % freq = 30; %per ms - use this when the trials data are time stamps
    freq = 1; % use this when the trials data are in mili seconds.
    f = figure(1);
    delta_y = 0.2;
    for i = 1:numel(features)
        selected_trials = trials([trials.(feature_name)] == i);
        subplot(2*numel(features),1,2*i-1);
        % --------------------------------------------------
        % raster plot
        for j = 1:numel(selected_trials)
            h = errorbar( ...
                selected_trials(j).spikeTimes_PHDI/freq - ...
                selected_trials(j).Time_Onset_PHDI/freq ...
                , ...
                j*delta_y* ...
                ones(1, numel(selected_trials(j).spikeTimes_PHDI)) ...
                , ...
                0.1*ones(1, numel(selected_trials(j).spikeTimes_PHDI)), ...
                'k' ...
            );
            h.CapSize = 0;
            h.LineStyle = 'none';
            hold on
        end
        xlim([x_low_lim x_high_lim]);
        ylim([0 (numel(selected_trials)+1)*delta_y]);
        ylabel(features(i));
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        h1=gca;
        h1.XAxis.Visible='off';
        box off;
        hold off
        % --------------------------------------------------
        % psth
        subplot(2*numel(features),1,2*i);
        num_of_samples = x_high_lim - x_low_lim + 1;
        psth_ = zeros(1, num_of_samples);
        for j = 1:numel(selected_trials)
            for k = selected_trials(j).spikeTimes_PHDI/freq - selected_trials(j).Time_Onset_PHDI/freq
                if (k > x_low_lim & k < x_high_lim)
                    psth_(floor(k-x_low_lim+1)) = psth_(floor(k-x_low_lim+1))+1;
                end
            end
        end
        final_psth = zeros(1, num_of_samples);
        for k = 1:x_delta_ms:num_of_samples
            low_band = max(1, k-bin_size_ms/2);
            high_band = min (num_of_samples, k+bin_size_ms/2-1);
            x = sum(psth_(low_band:high_band));
            for i = k:k+x_delta_ms-1
                final_psth(i) = x;
            end
        end
        bar_ = bar(x_low_lim:x_high_lim, final_psth);
        bar_.FaceColor = [0, 0, 0];
        bar_.BarWidth = 1;

        xlim([x_low_lim x_high_lim]);
%         ylim([0 max(final_psth)]);
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        h2=gca;
        h2.XAxis.Visible='off';
        box off;
    end
    hold on, ...
    subplot(2*numel(features), 1, 2*numel(features)), ...
    h2=gca;
    h2.XAxis.Visible='on';
    set(gca,'xtick', x_axis_partitions), ...
    xlabel('Time(ms)','FontSize',13)
    subplot(2*numel(features), 1, 1)
    title(CONFIG.TASK_NAME)

end
