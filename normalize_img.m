function [I_reg,I_reg_binarized] = normalize_img(img_fname,img_options,I_ref_binarized)

I = imread(img_fname);

info = imfinfo(img_fname);
hasField = isfield(info, 'Orientation');
if hasField
    if info.Orientation == 3
        I = imrotate(I, 180);
    elseif info.Orientation == 6
        I = imrotate(I, 270);
    elseif info.Orientation == 8
        I = imrotate(I, 90);
    end
end

I = rgb2gray(I);
size_im = size(I);
f_scale = mean(img_options.size_ref./size_im);
I = imresize(I,f_scale,'nearest');

%figure, histogram(I(I<255))
% blur the image for the binarization
filt_gauss = img_options.filt_gauss0;
I_blurred = imgaussfilt(I,filt_gauss);
I_binarized = uint8(imbinarize(I_blurred,0.93))*255;
I_binarized = imcrop(I_binarized,img_options.rect_crop);

figure(10)
I_fuse = imfuse(I_ref_binarized,I_binarized);
imshow(I_fuse)

[optimizer, metric] = imregconfig('multimodal');
optimizer.InitialRadius = 0.001;
tform = imregtform(I_binarized,I_ref_binarized,img_options.reg_type,optimizer,metric);
I_reg_binarized = imwarp(I_binarized,tform);

figure(11)
I_fuse = imfuse(I_ref_binarized,I_reg_binarized);
imshow(I_fuse)

I_crop = imcrop(I,img_options.rect_crop);
I_reg = imwarp(I_crop,tform);

end