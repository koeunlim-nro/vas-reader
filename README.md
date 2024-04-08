# vas-reader

## System requirements:
- python 3.8 or above <s\>
  : type `pyenv` in MATLAB command to check if your MATLAB is configured for python & see python version information.<br/>
  [Configure Your System to Use Python] (https://www.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html)
- python package pdf2image <s\>
  : type `!pip install pdf2image` in MATLAB command window
- MATLAB image processing toolbox
<s\>
## Followings are provided in the repository:
- 1 main script - readVAS
- 3 function mfiles for processing VAS scans
1. normalize_img.m - image pre-processing
2. auto_readVASscores.m - automatically detects VAS scales and markings
3. semi_auto_readVASscores.m - adds user-interface to manually mark VAS scales and patient markings when automatic detection fails
- 1 function python script
1. convert_pdf_to_img.py - converts pdf scan to jpg
- VAS_template.pdf & VAS_template.jpg - use VAS_template.pdf for data collection. JPEG format is used for the algorithm.
- 3 samples (VAS_sample_01~03.pdf) to test the algorithm.
<s\>
## How to use:
1. Once cloned into a local directory, run readVAS in the command window.
<s\>
If the script can automatically read the scales,
2. A prompt window will appear if the detected marking is correct or not. Click OK if the markings are correct.
<s\>If detected markings are incorrect,
3. Another prompt window will appear to select the incorrect marking(s) or incorrect edge(s). Multiple selection is possible.
<s\>
If the script cannot automatically read the scales,
2. Whole scan will appear for the user to mark the edges of the scales first (left-right, top-down),
3. then mark the patient markings (top-down) with mouse clicks. 
<s\>
4. Annotated output image file will be saved in the same directory.
