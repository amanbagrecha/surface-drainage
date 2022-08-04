# Climate Responsive Design for Road Surface Drainage Systems

**This repository contains code accompanying the manuscript Climate Responsive Design for Road Surface Drainage Systems**

Implementation of the algorithm in our 2021 Paper.

![](https://lucid.app/publicSegments/view/b117258b-7175-47fb-9b38-477c2c8ed660/image.png)
## 🛠️ Using the code

The repository contains three folders
```sh
├───data
│   ├───assesment_points
│   ├───bbmpwards
│   ├───blr_SRTM_DEM
│   ├───KMeansClusterRaster
│   ├───k_means_validation
│   └───Sentinel2_10mResolution
├───input
│   └───input.gdb
├───output
│   └───output.gdb 
└───scripts
    ├───.vscode
    ├───cascade_modelling_scripts # code for cascade modelling
    ├───cohen_kappa # code for validation
    ├───gcm_scripts # code for gcm analysis
    └───IDF_scripts # code for non-stationary IDF derivation
    └───main.py # implementation of algorithm
    └───data_download.js # data download from GEE
```
All three folders are required to run the algorithm and reproduce the result. `Input` contains all the design road while `output` contains the result of the algorithm. Folder `scripts` contains a code to run the analysis. 

### 🏁 Requirements
Tested under python 2.7, ArcGIS 10.7 and Windows 10 OS.

**Additional python packages**

numpy>=0.3.1

NOTICE: If you do not have ArcGIS 10.7 installed, you would not be able to reproduce the result.

**Note**: *To run the code you need to have ArcGIS 2.7 installed on your machine.*

## 🔀 Local Installation
Step 1: Fork the Repository
![](https://docs.github.com/assets/images/help/repository/fork_button.jpg)

Step 2: Clone the Repository by going to your local Git Client and pushing in the command:
```
git clone https://github.com/amanbagrecha/surface-drainage.git
```
Step 3: Open `main.py` and run the python file.

Output is a `csv` file containing design values for specified `roads` in the file and feature classes of the road.


To view the catchment area of specified road, open arcGIS and load the `X_watershed_with_mean` feature class for visual inspection.
![](https://i.imgur.com/Pssu53B.png)


Author: Shubham Kalore, Yashas V, Aman Bagrecha, Nypunya J, Sivakumar Babu G L
