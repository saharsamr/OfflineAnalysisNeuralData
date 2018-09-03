addpath(genpath('./Plots'));
addpath('./Utils');
addpath('./StimulusVariableConfigs');

load([CONFIG.OUTPUT_PATH '/final_mat.mat']);
Config = eval([CONFIG.TASK_NAME 'Config']);

figure(1);
raster_plot_and_psth(Config.Parameter, Trials, CONFIG.TASK_NAME, CONFIG.TIME_RANGE(1)*1000, CONFIG.TIME_RANGE(2)*1000, 10000*[CONFIG.TIME_RANGE(1):0.5:CONFIG.TIME_RANGE(2)], 10, 1);

figure(2);
pie_plot(Config.Parameter, CONFIG.TASK_NAME, Trials, 2);

figure(3);
continuous_data = NS5.Data(1,:);
continuous_data_time = NS5.time_;
plot_lfp(continuous_data, continuous_data_time, Config.Parameter, CONFIG.TASK_NAME, Trials, -500, 500, 10000*[-0.05:0.025:0.05]);
