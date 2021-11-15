# Predicting Individual Cell Division Events from Single-Cell ERK and Akt Dynamics

Here's the tutorial to run the code. The code used in this instruction can be found in the same GitHub repository. The data used can be found through the [Box cloud storage link](https://clemson.box.com/s/y70cy4f13a3ogmnvyj80lhstlyrl099n).

## Getting Started

### Dependencies

- CellProfiler
- ilastik
- Excel
- Matlab or Docker
### Data files
An example set of raw images can be found on our Box host.

### Single reporter expressing cells
Example images and pipelines can be found in the demo->image_analysis_pipelines->single folder of our Box host. In this folder, both **ilastik** (`10.ilp` / `10_imported.ilp`)and **CellProfiler** (`CORR.cpproj` and `analyst.cpproj`) scripts can be found.

To extract data from single reporter expressing cells, please follow the steps below:

1. Using **CellProfiler**, run the `CORR.cpproj` pipeline to flatfield correct the input images.

2. Run **ilastik** using the corrected nuclear channel as the input images, along with the nuclei detection features mentioned in the paper. These features are also found in features.PNG. The output will generate masks of cell nuclei.

3. Using **CellProfiler**, run `analyst.cpproj` using images corresponding to the KTR, cell nucleus, and the **ilastik** generated masks. Some fine tuning of parameters may be required depending on the images provided. The pipeline will export a CSV file containing fluorescence intensity values and cell tracking IDs.

4.	Open the CSV files generated from **CellProfiler**. Make sure to concatenate the first two rows as shown below using the excel command `CONCAT`. Or use the provided preprocessed CSV file.

    |     | A                 | B                      |
    | --- | ----------------- | ---------------------- |
    | 1   | Image ImageNumber | Cytoplasm ObjectNumber |

5.	The CSV files can now be passed to the **Matlab** script `single_batchreader.m`, which will generate a `mat` file for each imaged column of a 96 well plate. The provided `a.mat` file can be used downstream.

6.	To plot KTR for short titration time courses use `ktrTablePlotter.m`, otherwise for cell division assays use `ktrTablePlotter_long.m`.
For long time series, load `a.mat` along with `maxtimeBC.mat` (high EGF and insulin) or `maxtimeEF.mat`. Be sure that the vars in `ktrTablePlotter_long.m` are correct for parsing out data in `a.mat`.

7.	The output mat files (`a.mat` along with `maxtimeBC.mat`) of `ktrTablePlotter_long.m` can now be used to show long time course data.

8.	We need to identify cell division events. Use `single_div_detectionv2.m` followed by manual curation.

    - Manual curation. For each well, load the mat file `joined_1hr_parsed` and verify cell division status. Cell division status can be verified by identifying the cell tracking ID, and looking at the mask and corresponding KTR dynamics. If division status is mislabeled, correct the value, either 1 for dividing and 0 for non-dividing and re-save the mat file.

    - Save the results. Load either `maxtimeBC.mat` (high EGF and insulin) or `maxtimeEF.mat`, `joined_1hr_parsed.mat` and run `single_div_detectionv3.m` to finish parsing out the data, plot it, along with combining data from all wells of a similar condition. Or you can use the provided file, which contains preprocessed data from true dividing and non-dividing cells.

	- If you are using the preprocessed `joined_1hr_parsed.mat` data, be sure to load either `maxtimeBC.mat` (high EGF and insulin) or `maxtimeEF.mat` to continue. The output will be `all_div_cells.mat` and `all_non_div.mat`.

9.	Load the files below and run `single_randomcell.m` to create the figure shown in the paper, with the population median overlayed with dividing and non-dividing cells. You can choose to plot the number of random cells to plot. Please only plot the number of random cells corresponding with the size of the smallest population. Ex-dividing cells- 50 and non-dividing-20, therefore the number of random cells to select for plotting should equal the population of non-dividing cells.
    - `all_div_cells_ERK.mat`
    - `all_non_div_ERK.mat`
    - `med_DIV_ERK.mat`
    - `med_noDIV_ERK.mat`
    - `all_div_cells_Akt.mat`
    - `all_non_div_Akt.mat`
    - `med_DIV_Akt.mat`
    - `med_noDIV_Akt.mat`

10.	To create boxplots for Figure-1e, load `all_div_cells_ERK.mat`, `all_non_div_ERK.mat`, and run `boxplots_figs_ERK.m`. This will generate reporter specific file call `B_w_ERK.mat`, this file contains the medians calculated within the time intervals of interest, along with the rank sum stat.
By the same way we can generate `B_w_Akt.mat`. Load `B_w_ERK.mat`, `all_div_cells_ERK.mat`, `all_div_cells_Akt.mat`, `B_w_Akt.mat` and run `dual_boxplotsForSingleCells_figs.m` which will output a box and whiskers plot (B_w) for either ERK or Akt. NB, you need to modify the cell division category values so that they are aligned with the data they represent. Ex-normally dividing cells are marked as 1 and non-dividing as 0. However, for a figure showing both ERK and Akt data, you'll need to set the dividing values as follows: ERK div (1), ERK non-dividing (2), Akt div (3), Akt non-dividing (4).

11.	To generate the ROC classifier, run `roc_regression_erk.m` using `all_div_cells_ERK.mat` and `all_non_div_ERK.mat`.
Or run `roc_regression_akt.m` using `all_div_cells_Akt.mat` and `all_non_div_Akt.mat` data files.

### Dual reporter expressing cells

Similar to above's steps, navigate to the dual reporter folder and run: If you are processing from raw images start from step 1, otherwise you can use the provided `mat` file from the `Dual_batchreader.m` and start from step 5.


1.	Load **CellProfiler**, and open `CORR.cpproj`, along with the relevant images.

2.	After completion, import the nuclear images into **ilastik**, and utilize the parameters outline in the paper. The pipeline will generate masks of the nucleus. The ilastik pipeline for single reporter cells can be used here.

3.	Load the corrected images and the masks from **ilastik** into the **CellProfiler** script `DUAL_analist_testCP_V4.cpproj'.

4.	Process the CSV as shown in step 4 above or use the provided CSV.

5.	Run the Matlab script `Dual_batchreader.m` which will use the CSV files from **CellProfiler** and export a `mat` for further processing.

6.	For short titrations, run `DUALktrTablePlotter.m` otherwise for cell division data, run `DUALktrTablePlotterLONG.m`

7.	For long time series and cell division analysis load the `a.mat` file, along with `maxtime_198.mat` and run the `DUALktrTablePlotterLONG.m`

8.	To find dividing cells, open `dual_Div_detection2.m,` load `maxtime_198.mat` and navigate to the output folder of `DUALktrTablePlotterLONG.m`. the script will output `joined_1hr_parsed.mat`. Before continuing, the cell division status should be verified as described in step 8 manual curation. Alternatively, you can use the preprocessed `joined_1hr_parsed.mat` files.

9.	Open `dual_div_detectionv3.m` and load `maxtime_198.mat` and navigate to the directory where the curated `joined_1hr_parsed.mat` are located and execute the script. The script output will contain files `all_div_cells.mat` and `all_non_div.mat`. These files contain the combined cell division data across all EGF, and insulin treated wells. along with mat files for median ERK and Akt dynamics for dividing and non-dividing cells.

10.	Load `all_div_cells.mat` and `all_non_div.mat` and execute `dual_randomcell.m` to plot random dividing and non-dividing cells overlayed with the population median values.

11.	Load `all_div_cells.mat` and `all_non_div.mat` and run `dual_boxplots.m` which will plot paired ERK and Akt values for dividing and non-dividing cells. The function also plots a side by side of both ERK and Akt data along with the rank sum test results. Also, the code calculates medians, which are required for the steps that follow.

12.	Load `B_w_ERK.mat`, `B_w_akt.mat`, `all_div_cells`, and `all_non_div` files and run `biaxial.m` to produce the biaxial plot with the SVM hyperplane and the roc curve. The best possible SVM was shown in the paper. You can recapture the same plot by loading the preprocessed data.

13.	To produce the scatter plots of all timepoints load `all_div_cells.mat`, `all_non_div.mat` and run `scatter_and_resample.m`


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
