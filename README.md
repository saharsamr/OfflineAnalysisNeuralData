# OfflineAnalysisNeuralData

These codes are generated to extract data from Eyelink and Blackrock systems, and merges their information together.
After extracting the needed data, these can be used to plot different diagrams, such as LFP signal, raster plot and PSTH of spikes during the trials, and the plor histogram of number of spikes. 

We used edfReader, NPMK, and Chronux_2_12 toolboxes in these codes.

In addition, the files extract.m, Utils/cleanNames.m, Utils/findStimuliData.m, Utils/spike_sorting_rawdata6.m were all been written before, and we add some small piece of codes to extract.m file to achieve all data that will be needed in further analysis with theire proper format.

## Results

Here is the results of the code for an experiment on "orientation" feature of stimulus.

* The Raster Plot and PSTH of Spikes:

![LFP Signal - Orientations](https://github.com/saharsamr/OfflineAnalysisNeuralData/blob/master/Some%20Results/Raster.png)

* The Ploar Histogram of Number Of Spikes In Each Orientation:

![LFP Signal - Orientations](https://github.com/saharsamr/OfflineAnalysisNeuralData/blob/master/Some%20Results/Polar.png)

* The LFP Signal for Different Orientations:

![LFP Signal - Orientations](https://github.com/saharsamr/OfflineAnalysisNeuralData/blob/master/Some%20Results/LFP.png)
