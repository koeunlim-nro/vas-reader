function T_vas = readVAS()
% Description here
% 

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
    T_vas = readVASscores(I_reg_binarized,I_reg,T_vas,img_options);
catch
    % semi-automatic if auto-reader fails
    T_vas = semi_auto_readVAS(img_fname,T_vas,img_options);
end

