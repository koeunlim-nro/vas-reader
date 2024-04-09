# vas-reader

## System requirements:
- python 3.8 or above <br/>
  : type `pyenv` in MATLAB command to check if your MATLAB is configured for python & see python version information.<br/>
  [Configure Your System to Use Python](https://www.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html)
- python package pdf2image <br/>
  : type `!pip install pdf2image` in MATLAB command window
- MATLAB image processing toolbox

## Followings are provided in the repository:
- 1 main script : readVAS
- 3 function mfiles for processing VAS scans
    - normalize_img.m : image pre-processing
    - auto_readVASscores.m : automatically detects VAS scales and markings
    - semi_auto_readVASscores.m : adds user-interface to manually mark VAS scales and patient markings when automatic detection fails
- 1 function python script
    - convert_pdf_to_img.py : converts pdf scan to jpg
- VAS_template.pdf & VAS_template.jpg : use VAS_template.pdf for data collection. JPEG format is used for the algorithm.
  ![alt text](https://github.com/koeunlim-nro/vas-reader/blob/main/resources/VAS_template.jpg "VAS Questionnaire Template")
- 3 samples (VAS_sample_01~03.pdf) to test the algorithm.

## How to use:
(1) Scan marked VAS questionnaire ([Template pdf](https://github.com/koeunlim-nro/vas-reader/blob/main/VAS_template.pdf)) in grayscale or color and save in pdf format.<br/>
(2) Change directory to the cloned local repository, then run `readVAS` in the command window.<br/>
(3) Select a VAS pdf scan to read when prompted.<br/><br/>

If the script can automatically read the scales,<br/>
(4) A prompt window will appear if the detected marking is correct or not. Click OK if the markings are correct.<br/>
If detected markings are incorrect,<br/>
(5) Another prompt window will appear to select the incorrect marking(s) or incorrect edge(s). Multiple selection is possible.<br/><br/>

If the script cannot automatically read the scales,<br/>
(4) Whole scan will appear for the user to mark the edges of the scales first (left-right, top-down),<br/>
(5) then mark the patient markings (top-down) with mouse clicks. <br/><br/>

(6) Annotated output image file will be saved in the same directory.

## Example input and output:
Input: VAS_sample_01.pdf<br/>
![alt text](https://github.com/koeunlim-nro/vas-reader/blob/main/resources/VAS_sample_01.jpg "VAS Questionnaire Sample 1")<br/>
Output: VAS_sample_01_output.png<br/>
![alt text](https://github.com/koeunlim-nro/vas-reader/blob/main/resources/VAS_sample_01_output.png "Annotated VAS output 1")
