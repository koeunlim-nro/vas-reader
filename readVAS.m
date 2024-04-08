function T_vas = readVAS()

% Git repository - https://github.com/koeunlim-nro/vas-reader
% Readme (markdown) - https://github.com/koeunlim-nro/vas-reader/edit/main/README.md
% 
% System requirements:
% + python 3.8 or above
%   type "pyenv" in MATLAB command to check if your MATLAB is configured for 
%   python & see python version information
%   https://www.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html
% + python package pdf2image
%   type "!pip install pdf2image" in MATLAB command window
% + MATLAB image processing toolbox
%
% Followings are provided in the repository:
% + 1 main script - readVAS
% + 3 function mfiles for processing VAS scans 
%   (1) normalize_img.m - image pre-processing
%   (2) auto_readVASscores.m - automatically detects VAS scales and markings
%   (3) semi_auto_readVASscores.m - adds user-interface to manually mark VAS
%       scales and patient markings when automatic detection fails
% + 1 function python script
%   (1) convert_pdf_to_img.py - converts pdf scan to jpg
% + VAS_template.pdf & VAS_template.jpg - use VAS_template.pdf for data
%   collection. JPEG format is used for the algorithm. 
% + 3 samples (VAS_sample_01~03.pdf) to test the algorithm.
%
% How to use:
% (1) Once cloned into a local directory, run readVAS in the command window.
% (A) If the script can automatically read the scales,
% (2A) A prompt window will appear if the detected marking is correct or not.
%      Click OK if the markings are correct. If detected markings are incorrect, 
% (3A) Another prompt window will appear to select the incorrect marking(s)
%      or incorrect edge(s). Multiple selection is possible.
% (B) If the script cannot automatically read the scales,
% (2B) Whole scan will appear for the user to mark the edges of the scales 
%      first (left-right, top-down), then mark the patient markings (top-down) 
%      with mouse clicks.
% Annotated output image file will be saved in the same directory.

%% load python function
warning('off','MATLAB:ClassInstanceExists')

mod = py.importlib.import_module('convert_pdf_to_img');
py.importlib.reload(mod);

%% define image processing options 
img_options = struct;
img_options.reg_type = 'rigid';
img_options.filt_gauss0 = 1;
img_options.ref_confidence = 0.12;

%% import template
img_options.rect_crop = [42  248  396  290]*2;
dir_template = dir('*template.jpg');

I_ref = imread([dir_template.folder '\' dir_template.name]);
I_ref = rgb2gray(I_ref);
I_ref = imresize(I_ref,0.6,'nearest');
img_options.size_ref = size(I_ref);
imshow(I_ref)

% blur the image for the binarization
I_ref_blurred = imgaussfilt(I_ref,img_options.filt_gauss0);
I_ref_binarized = uint8(imbinarize(I_ref_blurred,0.93))*255;
I_ref_binarized = imcrop(I_ref_binarized,img_options.rect_crop);
imshow(I_ref_binarized)

%% Load VAS scan & convert to jpg format
[file_name, path_name] = uigetfile('.pdf','Select a VAS pdf scan to read');
mod.convert_to_img([path_name file_name])

%%
img_fname = [path_name file_name(1:end-4) '.jpg'];
out_fname = [file_name(1:end-4) '_output'];

variable_cells = {'vas_back','vas_leg','vas_overall',...
    'certainty_back','certainty_leg','certainty_overall',...
    'output_date','output_path','method'};

T_vas = table;
T_vas = cell2table(cell(1,length(variable_cells)), 'VariableNames', variable_cells);
T_vas.scan_name = {out_fname};
T_vas.output_path = {[out_fname  '.png']};

close all
[I_reg,I_reg_binarized] = normalize_img(img_fname,img_options,I_ref_binarized);

try
    % auto-reader
    T_vas = auto_readVASscores(I_reg_binarized,I_reg,T_vas,img_options);
catch
    % semi-automatic if auto-reader fails
    T_vas = semi_auto_readVAS(img_fname,T_vas,img_options);
end

