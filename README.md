# Relating Individual Cell Division Events to Single-Cell ERK and Akt Activity Time Courses

A tutorial for analyzing time course data pertraining to figures 1,2,3 to run the code. The data used can be found through the [Google Drive link](https://drive.google.com/drive/folders/1fHU0tPJRolywJtw8n_ztU9ib9kc0lcmO?usp=sharing).

## Getting Started

### Dependencies

- CellProfiler
- ilastik
- Excel
- Matlab or Docker
### Data files
An example set of raw images can be found on our Google Drive host.

### Single reporter expressing cells
Example images (\Demo\demo images) and pipelines (\Demo\image_analysis_pipelines\single) can be found in our Google Drive host. In this folder, both ilastik (10.ilp / 10_imported.ilp)and CellProfiler (CORR.cpproj and analyst.cpproj) scripts can be found.

To extract data from single reporter expressing cells, please follow the steps below, Or if you would like, you may start directly at step 4 by using the files contained in Demo\singleReporter, where each folder corresponds to a relevant step startng at step 4 and beyond. 

1. Using **CellProfiler**, run the `CORR.cpproj` pipeline to flatfield correct the input images (\Demo\demo images).

2. Run **ilastik** using the corrected nuclear channel as the input images, along with the nuclei detection features mentioned in the paper. These features are also found in features.PNG. The output will generate masks of cell nuclei.

3. Using **CellProfiler**, run `analyst.cpproj` using images corresponding to the KTR, cell nucleus, and the **ilastik** generated masks. Some fine tuning of parameters may be required depending on the images provided. The pipeline will export a CSV file containing fluorescence intensity values and cell tracking IDs.

4.	Open the CSV files generated from **CellProfiler**. Make sure to concatenate the first two rows as shown below using the excel command `CONCAT`. Or use the provided preprocessed CSV file (Demo\singleReporter\4).

    |     | A                 | B                      |
    | --- | ----------------- | ---------------------- |
    | 1   | Image ImageNumber | Cytoplasm ObjectNumber |

5.	The CSV files (Demo\singleReporter\4) can now be passed to the **Matlab** script `batchreader.m`, which will generate a mat file for each well processed. The provided `mat` file can be used downstream and is located in each folder of Demo\singleReporter\5 .
To plot KTR dynamics for drug titration time course data use `ktrTablePlotter.m`, otherwise for cell division assays use `ktrTablePlotter_LONG.m`. Be sure to load a matfile from step 5 when running these scripts.
For example, we want to process data from the ERK reporter acquired under high EGF and insulin stimulation. First we load `B.mat` from Demo\singleReporter\5\ERK\HIGHEGFINS along with `maxtimeBC.mat` located in Demo\singleReporter\5\ERK
Be sure that the vars listed in `ktrTablePlotter_LONG.m` are correct for parsing out data in `B.mat`.

6.	The output mat files of `ktrTablePlotter_LONG.m` can now be used to show time course data. 

7.	To identify cell division events use the `Div_detection2.m` along with the output files from step 6, joined_1hr***.mat. This script will generate files called with the following naming convention joined_1hr_parsed *well position*.mat 

    - Manual curation. For each well, load the mat file joined_1hr_parsed and verify cell division status. Cell division status can be verified by identifying the cell tracking ID, and looking at the mask and corresponding KTR dynamics. If division status is mislabeled, correct the value, either 1 for dividing and 0 for non-dividing and re-save the mat file.
	
    - Save the results. Load either `maxtimeBC.mat` (high EGF and insulin) or `maxtimeEF.mat`, `joined_1hr_parsed.mat` and run `Div_detection3.m` to finish parsing out the data, plot it, along with combining data from all wells of a similar condition. Or you can use the provided file, which contains preprocessed data for true dividing and non-dividing cells.
	
	- If you are using the preprocessed `joined_1hr_parsed.mat` data, be sure to load either `maxtimeBC.mat` (high EGF and insulin) or `maxtimeEF.mat` to continue. The output will be `all_div_cells.mat` and `all_non_div.mat`.

8.	Load the files below and run `randomcell.m` to create Fig 1B shown in the paper, with the population median KTR dynamics overlayed with dividing and non-dividing cells. You can choose to plot the number of random cells to plot. Please only plot the number of random cells corresponding with the size of the smallest population. Ex- dividing cells- 50 and non-dividing-20, therefore the number of random cells to select for plotting should equal the population of non-dividing cells (20). The medians shown are of the entire population. Example: for ERK, all the files can be found in this directory (Demo\singleReporter\7\ERK\high)  
    - `all_div_cells_ERK.mat`
    - `all_non_div_ERK.mat`
    - `med_DIV_ERK.mat`
    - `med_noDIV_ERK.mat`
    - `all_div_cells_Akt.mat`
    - `all_non_div_Akt.mat`
    - `med_DIV_Akt.mat`
    - `med_noDIV_Akt.mat`

9.	Load files from similar concentrations of growth factors. Example- For high concentrations of EGF and insulin, load  `values.mat`, and run `boxplots_figs_ERK.m`. This will generate a reporter specific file called `B_w_ERK.mat`, based on the time interval specified defined by w1s, w1e (window 1 start, window 1 end) this file contains the medians calculated within the time intervals of interest, along with the rank sum stat. By the same way we can generate `B_w_Akt.mat`. 

   To create boxplots for Figure 1E (high dose) load  `values.mat` for ERK and Akt by navigating to\Demo\singleReporter\9\ERK\high. For Akt, load `values.mat` \Demo\singleReporter\9\akt\high. Run `dual_boxplotsForSingleCells_figs.m` which will output a box and whiskers plot (B_w) for either ERK or Akt. NB, you need to modify the cell division category values so that they are aligned with the data they represent. Ex-normally dividing cells are marked as 1 and non-dividing as 0. However, for a figure showing both ERK and Akt data, you'll need to set the dividing values as follows: ERK div (1), ERK non-dividing (2), Akt div (3), Akt non-dividing (4).
   

### Dual reporter expressing cells

On our Google Drive host, navigate to Demo\dualReporter
Data aquired under the 5 minute interval utilizes similar code with slight modifications to account for the time course differences. That code can be found in our main github branch here predict_division/5mincode/ along on our Google Drive host here Demo\5 min interval\scripts\matlab 

Similar to above's steps, navigate to the dual reporter folder and run: If you are processing from raw images start from step 1, otherwise you can use the provided matfile generated from `Dual_batchreader.m` and start from step 5.


1.	Load **CellProfiler**, and open `CORR.cpproj`, along with the relevant images.

2.	After completion, import the nuclear images into **ilastik**, and utilize the parameters outline in the paper. The pipeline will generate masks of the nucleus. The ilastik pipeline for single reporter cells can be used here.

3.	Load the corrected images and the masks from **ilastik** into the **CellProfiler** script `DUAL_analist_testCP_V4.cpproj'.

4.	The provided CSV files for both concentrations of EGF and insulin are found in this directory (Demo\dualReporter\4).

5.	Run the Matlab script `Dual_batchreader.m` which will use the CSV files from step 4 generated by **CellProfiler**. The files exported files from `Dual_batchreader.m` are found in Demo\dualReporter\5.

6.	Load either `B.mat` (high EGF and insulin dose) or `C.mat` (low EGF and insulin)  file Demo\dualReporter\5 along with `maxtime_198.mat` and run the `DUALktrTablePlotterLONG.m` The data that is exported is called joined_1hr `*.mat` where * is well position. The output of this script is found in Demo\dualReporter\7

7.	To find dividing cells, open `Div_detection2.m,` load `maxtime_198.mat` and navigate to the output folder of `DUALktrTablePlotterLONG.m` (Demo\dualReporter\7). The files contained here will be used to identify cell division. The output of the script `joined_1hr_parsed.mat` is located Demo\dualReporter\8 . Before continuing, the cell division status should be verified as described in step 8 of the single reporter workflow 'manual curation'. Alternatively, you can use the provided `joined_1hr_parsed.mat` files in Demo\dualReporter\8.

8.	Open `div_detectionv3.m` and load `maxtime_198.mat`(Demo\dualReporter\7) and navigate to the directory where the curated `joined_1hr_parsed.mat` are located (Demo\dualReporter\8) and execute the script. The script output will contain files `all_div_cells.mat` and `all_non_div.mat`. These files contain the combined cell division data across all EGF, and insulin treated wells. along with mat files for median ERK and Akt dynamics for dividing and non-dividing cells. The output of this step is located in Demo\dualReporter\9

9.	Load `all_div_cells.mat` and `all_non_div.mat` (Demo\dualReporter\9) and execute `randomcell.m` to plot random dividing and non-dividing cells overlayed with the population median values.

10.	Load `all_div_cells.mat` and `all_non_div.mat` from either high or low doses (Demo\dualReporter\11\)and run `dual_boxplots.m` which will plot paired ERK and Akt values for dividing and non-dividing cells. The function also plots a side by side of both ERK and Akt data along with the rank sum test results. Also, the code calculates medians (B_w_ERK.mat and B_w_Akt.mat), which are required for the steps that follow.
11. To generate the Figure shown in Figure 2B, load `B_w_ERK.mat` and `B_w_Akt.mat` located in Demo\dualReporter\11 and run `dual_biaxial.m` 
12. To generate the data shown in Figure 2C, load `B_w_ERK.mat` and `B_w_Akt.mat`(Demo\dualReporter\11) and execute the script 'logistic_regression.m' be sure to change the intervals for w2s and w2e (windows 2 start and end) to match the correct time interval [40 166].

13.	To produce the scatter plots of all timepoints shown if Figure 3A load `all_div_cells.mat`, `all_non_div.mat`(Demo\dualReporter\11\) and run `dual_scatter_and_resample.m`. The outputs from the script are saved as `all_data.mat` (Demo\dualReporter\12\high)


### **Run Matlab script by Docker**

For users without Matlab installation, we provide a Docker based platform to test programs associated with the paper.
Here we show how to run the above Matlab scripts using Docker.

1. First, we need to install Docker Engine according to your platform. The installation instructions can be found on the Docker [official website](https://docs.docker.com/engine/install/).
2. Then, download the Docker image by the following command.
    ```bash
    docker pull ghs2015/driver_matlab
    ```
3. Run the test scripts by Docker to check if the setup of Docker and the programs work.
- Run the following command and you should see the output `Hello World!`.
    ```
    docker run -it -p 6080:6080 --rm -w /app -v "$(pwd):/app" ghs_2015/driver_matlab hello_world
    ```
- Run the following command and you should see a `M.csv` file generated at your current directory. This means the program can save the output to the computer.
    ```
    docker run -it -p 6080:6080 --rm -w /app -v "$(pwd):/app" ghs_2015/driver_matlab save_csv
    ```
- Rename `M.csv` to `M2.csv` and run the following command. You should see a `N.csv` file generated at your current directory. This means the program can process a input file located at the computer and save the result to the computer.
    ```
    docker run -it -p 6080:6080 --rm -w /app -v "$(pwd):/app" ghs_2015/driver_matlab process_csv
    ```
- Now we have checked all the setup is working. We can run the Matlab script by the following command. Just replace the script name within `< >` to what you want to run.
    ```
    docker run -it -p 6080:6080 --rm -w /app -v "$(pwd):/app" ghs_2015/driver_matlab <script_name>
    ```
- For example, to run `ktrTablePlotter_long.m`, use the following commands and make sure the needed files, `maxtimeBC.mat` and `a.mat`, are under the current working directory.
    ```
    docker run -it -p 6080:6080 --rm -w /app -v "$(pwd):/app" ghs_2015/driver_matlab batchreader
    ```
### **Docker for Single reporter expressing cells**
- For step 7, get into the directory `docker_single/7` and run `ktrTablePlotter_long` as follows:
    ```
    docker run -it -p 6080:6080 --rm -w /app -v "$(pwd):/app" ghs_2015/driver_matlab ktrTablePlotter_long
    ```
- For step 8, get into the directory `docker_single/8` and run `single_div_detectionv3`.
- For step 9, get into the directory `docker_single/9` and run `single_randomcell`.
- For step 10, get into the directory `docker_single/10` and run `dual_boxplotsForSingleCells_figs`.
- For step 11, get into the directory `docker_single/11` and run `roc_regression_erk` and `roc_regression_akt`.

### **Docker for Dual reporter expressing cells**
- For step 7, get into directory `docker_dual/7` and run `DUALktrTablePlotterLONG`.

- For step 8, it involves the manual curation, thus we skip this step here and provide the results after curation for further data processing.

- For step 9, get into the directory `docker_dual/9` and run `dual_div_detectionv3`.

- For step 10, get into the directory `docker_dual/10` and run `dual_randomcell`.

- For step 11, get into the directory `docker_dual/11` and run `dual_boxplots`.

- For step 12, get into the directory `docker_dual/12` and run `biaxial`.

- For step 13, get into the directory `docker_dual/13` and run `scatter_and_resample`.

## Authors

Alan D Stern et al., alan.stern@icahn.mssm.edu
