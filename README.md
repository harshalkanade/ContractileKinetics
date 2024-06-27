# ContractileKinetics

This code analyzes strain data from DIC results. The first file allows for the conversion of DIC results into strain data. The file cmcf_functions contains all the functions needed for the strain analyses. The files labeled Day 6, Day 12, Day 18 calculate the cell area at threshold, relaxtion rate, relaxation time, upstroke rate and time at peak for each specific day over the different sample types. These strain anaytics are defined below. 

Cell Area at Threshold was found through looping through each contraction video and determining the total cells above a .008 strain value.
Relaxation Rate was calculated by first finding where the contraction was at 90% strength after max contraction. Then the instantaneous slope was calculated iteratively and tested against the experimentally determined absolute slope value of .1. If it was below that value, that meant the contraction had been interrupted or had ended. The index of the location where the contraction was terminated was recorded and a slope was calculated between the 90% strength point and contraction termination point.
Relaxation Time was calculated through the difference between those indices. Likewise the Upstroke Rate used the 90% strength point before max contraction and calculated instantaneous slope backwards compared to the Relaxation Rate. The slope was similarly calculated. The Time at Peak contraction was calculated using 95% strength points before and after the max contraction.

The file labeled Grouped contains comparisons between days for the different sample types.

Instructions for using this code are as follows:
<l> Convert the DIC results into strain data using the MATLAB file. Save these results in a folder called Strain_Data. These data files are in folder for each day (D6, D12, D18) in larger folder for each sample types(CF, CMCF, CM, and DCM). If this folder names are different, then data loading portion in each Day file must be changed.
<l> Next download all the files here into a directory and transport all the data files through a singular file (Full CMCF Data) into that directory.
<l> If any changes to samples, days and/or filenames are made, ensure that the last section of the code where data is stored in shelf files and Excel is properly executed.

