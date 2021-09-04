function dirver(name)

    prompt = strcat('Run script:', name, '.m')
    disp(prompt);

    switch name
        % Cases for Docker setup test.
        case 'hello_world'
            hello_world;
        case 'save_csv'
            save_csv;
        case 'process_csv'
            process_csv;

        % Cases single reporter.
        case 'single_batchreader'  % step 5
            single_batchreader;
        case 'ktrTablePlotter_long'  % step 6
            ktrTablePlotter_long;
        case 'single_div_detectionv2'  % step 8
            single_div_detectionv2;
        case 'single_div_detectionv3'  % step 8
            single_div_detectionv3;
        case 'single_randomcell'  % step 9
            single_randomcell;
        case 'boxplots_figs_Akt'  % step 10
            boxplots_figs_Akt;
        case 'boxplots_figs_ERK'  % step 10
            boxplots_figs_ERK;
        case 'dual_boxplotsForSingleCells_figs'  % step 10
            dual_boxplotsForSingleCells_figs;
        case 'roc_regression_erk'  % step 11
            roc_regression_erk;
        case 'roc_regression_akt'  % step 11
            roc_regression_akt;

        % Cases dual reporter.
        case 'Dual_batchreader'  % step 5
            Dual_batchreader;
        case 'DUALktrTablePlotter'  % step 6
            DUALktrTablePlotter;
        case 'DUALktrTablePlotterLONG'  % step 7
            DUALktrTablePlotterLONG;
        case 'dual_Div_detection2'  % step 8
            dual_Div_detection2;
        case 'dual_div_detectionv3'  % step 9
            dual_div_detectionv3;
        case 'dual_randomcell'  % step 10
            dual_randomcell;
        case 'dual_boxplots'  % step 11
            dual_boxplots;
        case 'biaxial'  % step 12
            biaxial;
        case 'scatter_and_resample'  % step 13
            scatter_and_resample;

        otherwise
            disp('No Matlab script name is specified.');

    end
