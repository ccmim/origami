<img align="left" width="300" height="300" src=Img/SelectCells.png>

# Origami  [![DOI:10.1371/journal.pcbi.1009063](http://img.shields.io/badge/DOI-10.1371/journal.pcbi.1009063-B31B1B.svg)](https://doi.org/10.1371/journal.pcbi.1009063)
An image analysis pipeline for extracting direction- variant shape features from fluorescence images of folding epithelial sheets.

### Overview
Origami accepts segmented 3D data, finds the orientation of individual cells – aligned with the apico-basal axis of the epithelium and computes oriented shape features: skewness, horizontal and transversal extent along with un-oriented shape features: volume, surface area and sphericity.


### Installation
Origami runs on MATLAB – compatible with *MATLAB R2018b* onwards. 
MATLAB can be installed through the MathWorks website: https://uk.mathworks.com/products/matlab.html

Origami requires the ‘Computer Vision System Toolbox’ and ‘Deep Learning Toolbox’ installed in MATLAB.


### Usage
Origami is an easy- to- use MATLAB program with interactive features. *It does not require knowledge of MATLAB scripting to run*. Simply add the folder directory for the Origami scripts to the MATLAB search path. Open the main script ‘OrigamiPipeline_Main.m’ in MATLAB and click on the RUN button.

#### Inputs:
* Segmented files – Origami accepts 3D segmented image data in the following file formats: ‘.mha’ , ’.tif’ , ’.obj’  and  ‘.mat’. Origami has been validated on data that represent cropped ROIs.
If importing ‘.obj’ files (output from Arivis segmentation software), Origami will also request the corresponding datasheet exported from Arivis for the un- oriented shape features. In the absence of this datasheet, Origami will compute these features but as Arivis exports the segmentation with a shrink factor applied to the boundaries of the individual cells, these un-oriented features, particularly – volume, may not accurately reflect the original data.
* Pixel dimensions – Origami extracts the pixel dimensions from the metadata of the segmented files but will ask the user to confirm this. If using ACME for segmentation, input the pixel dimensions after resampling (original pixel dimensions * resample factor in all dimensions). For best results, ensure that the input segmented file is resampled to an isotropic voxel dimension.
* Polarity direction – Set apico-basal axis to face apical or basal side - direction in relation to the curvature of the epithelium. For example, in the otic epithelium in the developing zebrafish inner ear, the apical face of the epithelium faces the lumen of the otic vesicle and so to assign apico-basal polarity facing the apical face, the polarity direction is defined as ‘in’. Default value: ‘in’.

#### Outputs:
Data table of cell-specific shape features: 
* Volume (μm<sup>3</sup>), 
* Surface area (μm<sup>2</sup>), 
* Sphericity (value between 0 and 1, with 1 indicating a perfect sphere), 
* Skewness (negative values indicating a skew in mass biased towards the direction of the polarity vector while positive values indicate a skew in the opposite direction), 
* Longitudinal spread (indicating spread along the polarity vector) and 
* Transversal spread (indicating mass spread along a plane perpendicular to the polarity vector). 

The data table can be exported as a ‘.csv’ or ‘.xlsx’ file.

#### Interactivity:
* Clean segmentation – users can assess segmentation input and reject under/over-segmented cells.
* Pixel dimensions – users are prompted to input the pixel dimensions for the data
* Polarity – users can assess the polarity output, change polarity direction or select individual vector errors to correct by applying a 180<sup>o</sup> flip.
* Grouping cells (optional) – cells are grouped by mean curvature along the apical surface by default. This separates cells in the folding region of the epithelium from cells in the flanking non- folding regions. Users can manually override the default grouping.

#### Miscellaneous:
 Cells along the boundary are removed to exclude broken cells from the analysis.

#### Additional functionality: 
‘SelectACell.m’ and ‘PlotCellsByProperty.m’ are additional scripts that can be used to visualise the data by features at a single-cell level. The GUIs for these scripts allow the user to interact with 3D renderings of the epithelium and export 2D images or data tables.

## Generating synthetic epithelia
Synthetic epithelia used to validate Origami can be generated using the ‘MembraneSim.m’ and ‘ConvolveNCorrupt.m’ scripts. These synthetic data resemble fluorescence images of folding epithelia with parameters to control extent of membrane curvature (‘crv’ line 25, ‘MembraneSim.m’) and folding height (‘pk’ line 26, ‘MembraneSim.m’). The ‘MembraneSim.m’ script produces a 3D array of pixel intensity values saved as a ‘.mat’ file. This synthetic image array is then convolved with a point spread function (‘PSF Defocus.tif’) and corrupted with image noise (three levels) to resemble real-world imaging conditions using the ‘CovolveNCorrupt.m’ script. Finally, a ‘.tiff’ image file is exported from the ‘ConvolveNCorrupt.m’ script. Please refer to the [Supplementary Materials and Methods](https://doi.org/10.1371/journal.pcbi.1009063) for a detailed explanation of the synthetic data generation.

The synthetic images must be segmented prior to applying the Origami pipeline. We use the ACME software to do this.
Download ACME binaries from (https://github.com/krm15/ACME/wiki).

The ‘ACMEinMATLAB’ folder contains scripts produced by us to call ACME binaries from within MATLAB for single file or batch processing.

## Citing this work
If you use our work, please cite it:

>Mendonca T, Jones AA, Pozo JM, Baxendale S, Whitfield TT, Frangi AF. *Origami: Single-cell 3D shape dynamics oriented along the apico-basal axis of folding epithelia from fluorescence microscopy data*. PLOS Computational Biology. 2021; 17 (11) [doi:10.1101/2021.05.13.443974](https://doi.org/10.1371/journal.pcbi.1009063)
