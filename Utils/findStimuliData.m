function stimuli = findStimuliData(stimulusNames, stimulusData)


stimuli = nan(size(stimulusNames,1),  size(stimulusData.stimuli{1, 1}{1, 1},1), size(stimulusData.stimuli{1, 1}{1, 1},2));

for data_index = 1:numel(stimulusNames)
    for stimulus_index = 1:numel(stimulusData.stimuli)
        
        
        
        if strcmp(stimulusNames{data_index}, stimulusData.stimuli{1,stimulus_index}{1,2})
            stimuli(data_index, :, :) = stimulusData.stimuli{1,stimulus_index}{1,1};
        end
    end
end

end