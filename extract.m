%%%%BLACK RoCK TIME DATA / double(NEV.MetaTags.SampleRes)=>=>=>=>(Second)
%%%%Eye LINK TIME DATA / 1000=>=>=>=>(Second)

addpath(genpath('./toolbox'))
addpath('./Utils');
data_folder = [CONFIG.DATA_FOLDER CONFIG.DATE '/'];
daq_folder = [CONFIG.DAQ_FOLDER CONFIG.DATE '/'];
stimuliFolder =  CONFIG.STIMULI_FOLDER;


%% Inputs _ set input to * if not important
% =========================================
SubjectName = 'Milo';
TaskName = 'Attention';
ResearcherFirstname = 'Jafar';
ResearcherLastname = '';

TimeStart = CONFIG.TIME_START;
TimeEnd   = CONFIG.TIME_END;
bar_sampling_frequency = CONFIG.BAR_SAMPLING_FREQ;
photoDiodName = CONFIG.PHOTO_DIOD_NAME;
stimuliName   = CONFIG.STIMULI_NAME;

data_list   = dir([data_folder '*.edf']);

time_start = datetime(TimeStart,'InputFormat','yyyy-MM-dd HH:mm:SS');
time_end   = datetime(TimeEnd  ,'InputFormat','yyyy-MM-dd HH:mm:SS');

exp_index = 1;

NEV = openNEV([daq_folder CONFIG.POSTFIX '.nev'], 'overwrite');
NS5 = openNSx([daq_folder CONFIG.POSTFIX '.ns6']);
Behavioural = Edf2Mat([data_folder '15-Aug-2018-16-45-03-a11aor3.edf']);
% Behavioural = Edf2Mat(fullfile(data_folder, ['*' CONFIG.POSTFIX '.edf']));
stimulusData = load([stimuliFolder stimuliName '.mat']);


spikes = NEV.Data.Spikes;

events = Behavioural.Events.Messages;

trialStartIndex = find(cellfun(@(x) ~isempty(x), strfind(events.info, 'trialNumber')));
trialEndIndex   = find(cellfun(@(x) ~isempty(x), strfind(events.info, 'reward:')));

properties = events.info(1:trialStartIndex(1)-1);

brTimeStamps = NEV.Data.SerialDigitalIO.TimeStamp;
Values       = NEV.Data.SerialDigitalIO.UnparsedData;
binary_condition(1)=true;
n=0;
for stampIndex = 1:numel(brTimeStamps)
    binaryVector = de2bi(Values(stampIndex));
    binaryVector1{stampIndex} = binaryVector(1:6);
    if binaryVector(6)==1
        binary_condition(stampIndex+1)=false;
        binary_condition(stampIndex)=false;

    else
        binary_condition(stampIndex+1)=true;
    end
    if binary_condition(stampIndex+1) && binary_condition(stampIndex) ...
            && double(bi2de(  binaryVector1{stampIndex}))<10
        n=n+1;

        brStates(n) = double(bi2de(  binaryVector1{stampIndex}));
        ro(n)=stampIndex;
    end

end

brTimeStamps=brTimeStamps(ro);
brTimeTags=brTimeStamps;

brTimeTags=brTimeTags(brStates~=0);
brTimeStamps = double(brTimeStamps(brStates~=0)) / double(NEV.MetaTags.SampleRes);%second
brStates     = brStates(brStates~=0)';

brInitTime = brTimeStamps(brStates==3);%second
elInitTime = events.time(find(strcmp(events.info, 'init=>barWait'),1)) / 1000.0;%second

alignTime_br2el  = (elInitTime   - brInitTime(1));
brTimeStamps     = brTimeStamps + alignTime_br2el;%second

    continous_data = double(NS5.Data);
    NS5.time_ = (1:1:size(continous_data,2))/double(NS5.MetaTags.SamplingFreq);
    NS5.time_ = NS5.time_ + alignTime_br2el;
    NS5.time_ = NS5.time_ * 1000;
    channelNames = vertcat(NS5.ElectrodesInfo.Label);
    for string_index = 1:size(channelNames, 1)
        if contains(channelNames(string_index, :), photoDiodName)
            photoDiodIndex = string_index;
            break
        end
    end

data=NS5.Data(1,:) ;

[waveForm10,timeStamp10]=spike_sorting_rawdata6(data);

timeStamp11=1000.*((timeStamp10/ double(NEV.MetaTags.SampleRes) + alignTime_br2el));

Trials = [];

for trial_index = 1:numel(trialEndIndex)
    %%
    Trials(trial_index).events.info = events.info(trialStartIndex(trial_index):trialEndIndex(trial_index));
    Trials(trial_index).events.time = events.time(trialStartIndex(trial_index):trialEndIndex(trial_index));%ms

    barIndex = find(cellfun(@(x) ~isempty(x), strfind(Trials(trial_index).events.info, 'bar:')));

    kbIndices = find(cellfun(@(x) ~isempty(x), strfind(Trials(trial_index).events.info, 'keyboard:')));
    displayIndices = find(cellfun(@(x) ~isempty(x), strfind(Trials(trial_index).events.info, 'display:')));
    trialIDInduces = find(cellfun(@(x) ~isempty(x), strfind(Trials(trial_index).events.info, 'TRIALID')));

    unusedIndexes = union(kbIndices, barIndex);
    unusedIndexes = union(unusedIndexes, displayIndices);
    unusedIndexes = union(unusedIndexes, trialIDInduces);

    Trials(trial_index).states.info = Trials(trial_index).events.info(setdiff(1:numel(Trials(trial_index).events.info), unusedIndexes));
    Trials(trial_index).states.time = Trials(trial_index).events.time(setdiff(1:numel(Trials(trial_index).events.info), unusedIndexes));

    stimulusNumberInTrialIndex =  find(cellfun(@(x) ~isempty(x), strfind(Trials(trial_index).states.info, 'stimulusNumberInTrial: 0')));
    startRealTrial = stimulusNumberInTrialIndex(end);
    Trials(trial_index).states.info = Trials(trial_index).states.info(startRealTrial:end);
    Trials(trial_index).states.time = Trials(trial_index).states.time(startRealTrial:end);

    StimulusNameIndices = find(cellfun(@(x) ~isempty(x), strfind(Trials(trial_index).states.info, 'stimulusName: ')));
    Trials(trial_index).StimulusNames = cleanNames(numel(StimulusNameIndices),{Trials(trial_index).states.info{StimulusNameIndices}}');
    Trials(trial_index).StimulusTimes = Trials(trial_index).states.time(StimulusNameIndices)';
    Trials(trial_index).Stimuli       = findStimuliData(Trials(trial_index).StimulusNames, stimulusData);

    % stimulus_name_index = Utils.Util.find_last( ...
    %                                           Trials(trial_index).states.info, ...
    %                                           'stimulusName' ...
    % );
    stimulus_name_index = find(cellfun(@(x) ~isempty(x), strfind(Trials(trial_index).states.info, 'stimulusName')), 1, 'last');
    if(~isempty(stimulus_name_index))
        stimulus_str = Trials(trial_index).states.info{stimulus_name_index};
        stimulus_str = stimulus_str(strfind(stimulus_str, ':')+3:end-1);
        stimulus_str = strrep(stimulus_str, '&', ' ');
        values = str2num(stimulus_str);
        Trials(trial_index).Orientation = values(1);
        Trials(trial_index).Contrast = values(2);
        Trials(trial_index).Phase = values(3);
        Trials(trial_index).Spatial_frequency = values(4);
        Trials(trial_index).Size = values(5);
    end
end

clearvars -except timeStamp11 Trials NEV NS5 continous_data NS5.time_ photoDiodIndex alignTime_br2el brTimeTags trialEndIndex brStates properties data_folder
timeStamp11;%ms
Trials;%trials TIME is ms

for i=1:numel(trialEndIndex)
    stimulusNameIndex = find(cellfun(@(x) ~isempty(x), strfind(Trials(i).states.info, 'stimulusName:')), 1, 'last');

    stimulusNameStr = Trials(i).states.info{stimulusNameIndex};
    stimulusName = stimulusNameStr(strfind(stimulusNameStr, ':')+3:end-1);
    Trials(i).orientation = str2double(stimulusName(1:strfind(stimulusName, '&')-1));

    startFixationIndex = find(cellfun(@(x) ~isempty(x), strfind(Trials(i).states.info, 'startFixation=>startFixation_waiter')));
    Trials(i).startFixationTime = Trials(i).states.time(startFixationIndex(end));

    stimulusStartIndex = find(cellfun(@(x) ~isempty(x), strfind(Trials(i).states.info, 'stimulus=>stimulus_waiter')));
    Trials(i).stimulusStartTime = Trials(i).states.time(stimulusStartIndex(end));

    rewardStateIndex = find(cellfun(@(x) ~isempty(x), strfind(Trials(i).states.info, 'releaseWait_waiter=>reward')));
    Trials(i).rewardStateTime = Trials(i).states.time(rewardStateIndex(end));

    Trials(i).spikeTimes = timeStamp11(timeStamp11< Trials(i).rewardStateTime & timeStamp11>Trials(i).startFixationTime);

end

signal_photodiod=NS5.Data(photoDiodIndex,:);

photoDiod_Filtered_White = (signal_photodiod > 5000).*1;
indexOne    = find(photoDiod_Filtered_White==1);
for j = 1:numel(indexOne)-1
    if indexOne(j+1)-indexOne(j) < 402
        photoDiod_Filtered_White(indexOne(j):indexOne(j+1)) = 1;
    end
end

photoDiod_Filtered_Black= (signal_photodiod > 2500 & signal_photodiod <5000 ).*1;
photoDiod_Filtered_Black(photoDiod_Filtered_White==1 | circshift(photoDiod_Filtered_White,100)==1 | circshift(photoDiod_Filtered_White,-100)==1)=0;
photoDiod_Filtered_Black_edit=double(signal_photodiod).*photoDiod_Filtered_Black;
photoDiod_Filtered_Black_edit2= (photoDiod_Filtered_Black_edit > 2800 ).*1;

indexOne    = find(photoDiod_Filtered_Black_edit2==1);
for j = 1:numel(indexOne)-1
    if indexOne(j+1)-indexOne(j) < 402
        photoDiod_Filtered_Black_edit2(indexOne(j):indexOne(j+1)) = 1;

    end
end

reward_index=find((brStates==8));
tag5=find(brStates==5);
tag6=find(brStates==6);
tag7=find(brStates==7);
for i=1:numel(reward_index)-1
    Index_start_fixation(i)=tag5(find (tag5<reward_index(i),1,'last'));
    Index_start_stimulus(i)=tag6(find (tag6<reward_index(i) & tag6>Index_start_fixation(i) ,1));
    Index_end_stimulus(i)=tag7(find (tag7<reward_index(i),1,'last'));

end
Time_start_fixation=brTimeTags(Index_start_fixation);
Time_start_stimulus=brTimeTags(Index_start_stimulus);
Time_end_stimulus=brTimeTags(Index_end_stimulus);

for i=1:numel (Time_start_fixation)

    Trials(i).fixation_time_PHDI= 1000.*((double( Time_start_fixation(i))/ double(NEV.MetaTags.SampleRes) + alignTime_br2el));
    Trials(i).Start_StimulusTimePHDI=1000.*((double( Time_start_stimulus(i))/ double(NEV.MetaTags.SampleRes) + alignTime_br2el));
    Trials(i).End_StimulusTimePHDI=1000.*((double( Time_end_stimulus(i))/ double(NEV.MetaTags.SampleRes) + alignTime_br2el));

end

    photoDiod_Filtered_White_Shift=circshift(photoDiod_Filtered_White,1);
    photoDiod_Filtered_Black_Shift=circshift(photoDiod_Filtered_Black_edit2,1);
    r1=find(photoDiod_Filtered_Black_edit2==1 & photoDiod_Filtered_Black_Shift==0 );
    r3=find(photoDiod_Filtered_White==1 & photoDiod_Filtered_White_Shift==0);

for i=1:numel(trialEndIndex)-1
    K_index=Time_start_stimulus(i);

    r2=find(r1>K_index,numel(Trials(i).StimulusNames  )+1);
    ss_Black=r1(r2);

    r4=find(r3>K_index,numel(Trials(i).StimulusNames  )+1);
    ss_White=r3(r4);
    ss_total=[ss_White, ss_Black];
    ss_total=sort(ss_total);
    ss_total=1000.*((double( ss_total)/ double(NEV.MetaTags.SampleRes) + alignTime_br2el));
    Trials(i).Start_stimulus_PHDI(1)=  ss_total(1) ;
    Trials(i).End_stimulus_PHDI(1:numel(Trials(i).StimulusNames  ))=  ss_total(2:numel(Trials(i).StimulusNames  )+1) ;
    Trials(i).Start_stimulus_PHDI(1:numel(Trials(i).StimulusNames  ))=  ss_total(1:numel(Trials(i).StimulusNames  )) ;
    Trials(i).Time_Onset_PHDI=ss_total(1);
    Trials(i).ReleasewaiteTimePHDI=Trials(i).End_stimulus_PHDI(end);
    Trials(i).spikeTimes_PHDI = timeStamp11(timeStamp11> Trials(i).Start_StimulusTimePHDI & timeStamp11<Trials(i).End_StimulusTimePHDI);
end

make_directory(CONFIG.OUTPUT_PATH);

save ([CONFIG.OUTPUT_PATH 'final_mat'], 'Trials', 'NS5', 'NEV', 'properties');
