Visual Analysis using color intensity to determine PWV through an aorta.

By:
John-Paul Heinzen
heinz194@umn.edu
Barocas Lab
University of Minnesota - Twin Cities

Created:
11/21/22

Version 1.1
Last Edit:
1/6/23
by:
JP Heinzen

Changelog:
12/6/22 - Created parseGraphs so that others can easily run through the data outputted by this code.
12/13/22 - Created mergeFolder in preparation for experiment. Added 'run' feature to parseGraphs in preparation for data analysis by others.
12/27/22 - Changed vidInit so that you don't need to to be in the file where the .tif files are kept, but now you can input a filepath to specify where to pull the .tif files from. Updated gatherData accordingly.
12/27/22 - Added checkRefLines so that you can play the video with the reference lines in it to see if they are too long or too short, or just right.
12/29/22 - Separated findDelay(1-3) from postProcessing.m into its own function
12/30/22 - Created findScaling and added to postProcessing.m
12/31/22 - Removed requirement for cLines structure in findDelay so it can be used in analyzing pressure sensor data & beyond. 
		Created pressureSensor.m and pressurePWV.m to analyze pressure sensor data.
1/6/23 - Returned to findDelay and created methods 4 and 5 which are the same as 1 and 2, but use a smoothing range to smooth the data before finding the delay. Seems to be good for noisy data, and seems to give semi-consistent results compared to 1 and 2.


NOTE:
To get the files necessary to run the example, see: https://drive.google.com/drive/folders/1sHEIUDBqLFUrPMYZHcszIxrgXEWvobvu?usp=sharing

TODO: Help headers on:
writeImage
preProcessing
PostProcessing
gatherData
kmeans
& all functions

--------------------------------------------------------
Prerequisites: 
 - Matlab. Guaranteed to work in R2021b or later, but probably will work in earlier versions.
 - Image Processing Toolbox. In Matlab go to HOME > Add-Ons and search "Image Processing Toolbox". There are quite a few with similar names so ensure you get the one from Mathworks.
--------------------------------------------------------
To run example:
1. 	Download files, making sure ENTIRE FOLDER (including subfolders) is on filepath. You can do this using:
		>> addpath(genpath('<folderName>'))
		(with the name of the folder replacing <folderName>)
		Make sure this added the folders "functions" and "other" to the path. It may be more straight forward to just right click the folder in the matlab Current Folder panel and select "Add to Path" > "Selected Folder and Subfolders" which will add all the necessary files to the path.
2.	Verify you did step 1. If you don't, you'll have problems.
3. 	Open example.mov to see what's going on in the video.
4.	Run preProcessing.m to turn the video into a folder of .tif files. Start with only importing the first 6000 frames, but once you are able to run the example with the limited frames, try running it with all the frames (should be 20100 frames). Just make sure you make a new folder with the .tif's in it, or delete the existing image folder.
5. 	Run gatherData.m. This shouldn't take too long (NO more than a few minutes for this example - my laptop took ~8 minutes with all of the frames and my cpu is not particularily fast)
	Then, in command window:
6.		>> save example.mat
7. 	Run postProcessing.m. This may take a bit with large numbers of frames. It took me ~4mins with all of the frames.

You're done! You should end up with a plot (using findDelay1) the looks like examplePlot.svg. This just shows that you may not need to use all of the data in a video to do the analysis. You can save a lot of time if you are smart about it. 
Now, try using findDelay2 instead of findDelay1 to see the differences in the 2 methods (you should only have to run postProcessing.m! This is why we saved the data from gatherData.m as a .mat file!!). Try findDelay 3 if you're feeling truly spicy, but this method is now highly unoptimized.

--------------------------------------------------------

If you want to understand the code, I recommend:
1.	Look through misc. files in 'other' folder. It is probably important to have at least a brief understading of what they are, and what they do. No need to go into great depth understanding the details of them though. These really are just used as quality of life functions.

2.	Read through Information Headers on postProcessing.m, gatherData.m, writeImage.m, then, vid2im. NOTE: Some headers are long, so I minimized the comment block. You can click on the "..." at the end of the visible line, or click the "+" at the start of the line to expand these blocks (and press the "-" at the start of the line to hide again)

3.	Try changing some of the available parameters to convince yourself you know what they do. For example, try changing k to 4 instead of 2. Run the first few sections (you can use 'run section' button or CTRL + ENTER if you're using the default windows shortcuts) of gatherData and see what the aorta looks vs with k = 2.

--------------------------------------------------------

Moving Forward:
The biggest TODO's that I see are as follows:
(try to keep this updated)

1. Add thorough input checking to ever script and function. This is VERY important and not something I really did much of, just due to lack of time. This would be a VERY beneficial thing to do, especially if this will be a long term project. It will help the future debugging.
2. Add unit tests. These are tests for every function and script that can be run to ensure that every function works. You can build it so you just run a single script that calls each function's unit test and ensures that every function is working. A unit test for a function will test all of the function's possible usage to make sure it does what it should do (but ONLY do what it says it should do).
3. Update all info headers. Yuck. But should be done......
4. Improve how the reference lines are found. First, you need to think about HOW this will actually be done (eg what does a 12 degree line actually mean??), and make sure it is robust. (maybe make a structure to hold all the data...?). Haven't given much thought to this.. NOTE: AT LEAST #1 should REALLY be done first before trying to change the functions you would need to change.
5. Try to parallelize mainS.m [serial] (to create mainP.m [parallel]). I tried this, but the way I implemented it made the code read in every frame for every reference line (which is SLOW), so the serial version was actually much faster. I don't think this is super important becuase the main part of mainS.m is vectorized and already runs decently fast. (much faster than it used to, lol)
6. If I missed anything, check gatherData.m's TODO header - it would be there.