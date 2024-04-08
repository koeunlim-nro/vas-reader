function T_vas_i = semi_auto_readVASscores(img_fname,T_vas_i,img_options)

% activated only when the auto-reader fails
% no crop, just scaling.
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

locs_scale_edges = nan(6,2);
locs_marker = nan(3,2);
vas = nan(3,1);
confidence = nan(3,1);
confidence_f = nan(3,1);

close all
f_vas = figure(10);
imshow(I), hold on
axis on

title('Mark the edges of the scales:')
for i = 1:6
    locs_scale_edges(i,:) = ginput(1);
    plot(locs_scale_edges(i,1),locs_scale_edges(i,2),'gx','LineWidth',2,'MarkerSize',10)
end

title('Mark the patient markings on the scales:')
for i = 1:3
    locs_marker(i,:) = ginput(1);
    
    vas(i) = round(pdist([locs_scale_edges(i*2-1,:);locs_marker(i,:)],'euclidean')/pdist(locs_scale_edges(i*2-1:i*2,:),'euclidean')*100,1);
    confidence(i) = 75; % manual process

    text(locs_marker(i,1),locs_marker(i,2),'k','Color','r','FontName','Target Shooting','FontSize',16,'HorizontalAlignment','center','VerticalAlignment','middle')
    text(locs_marker(i,1),locs_marker(i,2)+20,[num2str(vas(i)) 'mm'],'Color','r','FontSize',14,'HorizontalAlignment','center')
    text(locs_marker(i,1),locs_marker(i,2)+40,'Manually marked','Color','m','FontSize',10,'HorizontalAlignment','center')
end
hold off
title('')
saveas(f_vas,T_vas_i.output_path{1}(1:end-4),'png')

T_vas_i.vas_back = vas(1);
T_vas_i.vas_leg = vas(2);
T_vas_i.vas_overall = vas(3);
T_vas_i.certainty_back = confidence(1);
T_vas_i.certainty_leg = confidence(2);
T_vas_i.certainty_overall = confidence(3);
T_vas_i.output_date = datetime(date);
T_vas_i.method = {'semi-automatic'};

end