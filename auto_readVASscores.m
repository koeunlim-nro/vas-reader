function T_vas_i = auto_readVASscores(I_reg_binarized,I_reg,T_vas_i,img_options)

%% count black pixels
im_size = size(I_reg_binarized);

row_count = [];
for i_row = 1:im_size(1)
    row_count(i_row) = sum(I_reg_binarized(i_row,:) == 0);
end
figure(100)
findpeaks(row_count,'MinPeakDistance',20,'MinPeakProminence',100)
[pks,locs_row] = findpeaks(row_count,'MinPeakDistance',20,'MinPeakProminence',100);
if length(pks) > 6
    [B,idx_p] = sort(pks,'descend');
    locs_row = locs_row(sort(idx_p(1:6)));
end
vas_scale_loc = locs_row(2:2:6);

col_count = [];
locs_scale_edges = [];
locs_marker = [];
marker_width = [];

figure(101)
for i_scale = 1:3
    rows_scale = (-10:10) + vas_scale_loc(i_scale);
    for i_col = 1:im_size(2)
        col_count(i_col,i_scale) = sum(I_reg_binarized(rows_scale,i_col) == 0);
    end
    subplot(3,1,i_scale)
    findpeaks(col_count(:,i_scale),'MinPeakProminence',15,'MinPeakHeight',20), hold on
    [pks,locs_col] = findpeaks(col_count(:,i_scale),'MinPeakProminence',15,'MinPeakHeight',20);
    idx_pks = find(locs_col < 700);
    if length(idx_pks) > 2
        idx_pks = idx_pks([1 end]);
    end
    pks = pks(idx_pks);
    locs_col = locs_col(idx_pks);

    if length(locs_col) < 2
        if locs_col > 600
            [pk_end,idx_end] = max(col_count(locs_col - 480 + [-10:10],i_scale));
            locs_col = [locs_col - 480 + idx_end - 10,locs_col];
            pks = [pk_end,pks];
        else
            [pk_end,idx_end] = max(col_count(locs_col + 480 + [-10:10],i_scale));
            locs_col = [locs_col,locs_col + 480 + idx_end - 10];
            pks = [pks,pk_end];
        end
    end

    while length(pks) > 3
        filt_gauss = filt_gauss*2;
        I_blurred = imgaussfilt(I,filt_gauss);
        I_binarized = uint8(imbinarize(I_blurred))*255;
        I_binarized = imcrop(I_binarized,rect_crop);

        I_reg_binarized = imwarp(I_binarized,tform);
        figure(11)
        I_fuse = imfuse(I_ref_binarized,I_reg_binarized);
        imshow(I_fuse)
        for i_col = 1:im_size(2)
            col_count(i_col,i_scale) = sum(I_reg_binarized(rows_scale,i_col) == 0);
        end
        [pks,locs_col] = findpeaks(col_count(:,i_scale),'MinPeakProminence',15,'MinPeakHeight',20);

        figure(101)
        subplot(3,1,i_scale)
        findpeaks(col_count(:,i_scale),'MinPeakProminence',15,'MinPeakHeight',20)
    end

    cols_start = (-10:10)+locs_col(1);
    cols_end = (-10:10)+locs_col(end);
    scale_start_width = length(cols_start(col_count((-10:10)+locs_col(1),i_scale)>10));
    scale_end_width = length(cols_end(col_count((-10:10)+locs_col(end),i_scale)>10));
    [scale_edge_widths,idx_w] = sort([scale_start_width scale_end_width]);

    scale_start = median(cols_start(col_count((-10:10)+locs_col(1),i_scale)>10));
    scale_end = median(cols_end(col_count((-10:10)+locs_col(end),i_scale)>10));
    locs_marker_edge = [];
    if scale_edge_widths(2)/scale_edge_widths(1) >= 1.25
        if idx_w(2) == 1
            scale_start = median(cols_start(find(col_count((-10:10)+locs_col(1),i_scale)>10,scale_end_width)));
            locs_marker_edge = scale_start + min(scale_edge_widths)/2 + diff(scale_edge_widths)/2;
            marker_width_edge = diff(scale_edge_widths)*2;
            if max(scale_edge_widths) < 7
                locs_marker_edge = scale_start;
                if marker_width_edge < 3
                    marker_width_edge = 20/img_options.ref_confidence;
                else
                    marker_width_edge = scale_edge_widths(2)*2;
                end
            end
        else
            scale_end = median(cols_end(find(col_count((-10:10)+locs_col(end),i_scale)>10,scale_start_width,'last')));
            locs_marker_edge = scale_end - min(scale_edge_widths)/2 - diff(scale_edge_widths)/2;
            marker_width_edge = diff(scale_edge_widths)*2;
            if max(scale_edge_widths) < 7
                locs_marker_edge = scale_end;
                if marker_width_edge < 3
                    marker_width_edge = 20/img_options.ref_confidence;
                else
                    marker_width_edge = scale_edge_widths(2)*2;
                end
            end
        end
    end
    locs_scale_edges(i_scale,:) = [scale_start,scale_end];

    % obtain moving average between the scale edges to estimate the
    % center of the marker
    rows_scale = (-5:5) + vas_scale_loc(i_scale);
    for i_col = 1:im_size(2)
        col_count(i_col,i_scale) = sum(I_reg_binarized(rows_scale,i_col) == 0);
    end
    cols = locs_col(1):locs_col(end);
    smoothed_col_count = movmean(col_count(cols,i_scale),10);
    th_col_count = mean(smoothed_col_count(smoothed_col_count<=quantile(smoothed_col_count,0.95))) + ...
        3.6*std(smoothed_col_count(smoothed_col_count<=quantile(smoothed_col_count,0.975)));
    th_col_count = max(4.8,th_col_count);
    [pks,locs_col,w,p] = findpeaks(smoothed_col_count,'MinPeakHeight',th_col_count,'MinPeakDistance',10);

    if ~isempty(pks)
        n_marker = length(pks);
        d_marker = max(locs_col) - min(locs_col);
        locs_marker_i = locs_col(pks == max(pks));
        idx_cols = (-20:20)+locs_marker_i;
        if idx_cols(1) < 1
            [~,locs_marker_min] = min(smoothed_col_count(1:locs_marker_i));
            idx_cols = 1:locs_marker_i+20;
        elseif idx_cols(end) > length(cols)
            [~,locs_marker_min] = min(smoothed_col_count(locs_marker_i:end));
            idx_cols = locs_marker_i-20:length(cols);
        end
        cols_marker = cols(idx_cols);
        locs_marker(i_scale) = median(cols_marker(smoothed_col_count(idx_cols)>th_col_count));
        marker_width(i_scale) = length(cols_marker(smoothed_col_count(idx_cols)>th_col_count));
        if d_marker > 20
            marker_width(i_scale) = d_marker;
        end
        marker_strength(i_scale) = max(pks)/marker_width(i_scale);
        %marker_width(i_scale) = w;
    else
        if isempty(locs_marker_edge)
            locs_marker_edge = scale_start;
            marker_width_edge = 20/img_options.ref_confidence;
        end
        locs_marker(i_scale) = locs_marker_edge;
        marker_width(i_scale) = marker_width_edge;
        marker_strength(i_scale) = th_col_count/marker_width_edge;
    end

    plot(locs_marker(i_scale),col_count(round(locs_marker(i_scale)),i_scale),'rv'), hold off

    % Calculate relative location of the marker
    scale_len(i_scale) = diff(locs_scale_edges(i_scale,:));
    marker_len(i_scale) = locs_marker(i_scale) - scale_start;
    vas(i_scale) = round(marker_len(i_scale)/scale_len(i_scale)*100,1);
    confidence_f(i_scale) = 1/marker_width(i_scale);
    %confidence_f(i_scale) = marker_strength(i_scale);
    confidence(i_scale) = round(min(confidence_f(i_scale)/img_options.ref_confidence*100,100));
end

T_vas_i.vas_back = vas(1);
T_vas_i.vas_leg = vas(2);
T_vas_i.vas_overall = vas(3);
T_vas_i.certainty_back = confidence(1);
T_vas_i.certainty_leg = confidence(2);
T_vas_i.certainty_overall = confidence(3);
T_vas_i.output_date = datetime(date);
T_vas_i.method = {'automatic'};
%T_vas = [T_vas;T_vas_i];

f_vas = figure(1000);
imshow(I_reg), hold on
axis on
for i = 1:3
    m_edges(i*2-1) = plot(locs_scale_edges(i,1),vas_scale_loc(i),'gx','LineWidth',2,'MarkerSize',10);
    m_edges(i*2) = plot(locs_scale_edges(i,2),vas_scale_loc(i),'gx','LineWidth',2,'MarkerSize',10);
    txt_mark(i) = text(locs_marker(i),vas_scale_loc(i),'k','Color','r','FontName','Target Shooting','FontSize',16,'HorizontalAlignment','center','VerticalAlignment','middle');%,'FontWeight','bold');
    txt_vas(i) = text(locs_marker(i),vas_scale_loc(i)+20,[num2str(vas(i)) 'mm'],'Color','r','FontSize',14,'HorizontalAlignment','center');
    txt_conf(i) = text(locs_marker(i),vas_scale_loc(i)+40,['(' num2str(confidence(i)) '% Certainty)'],'Color','m','FontSize',10,'HorizontalAlignment','center');
end
hold off

answer1 = questdlg('Are VAS markings correct?', ...
	'Verify...', ...
	'Yes','No','Yes');
% Handle response
switch answer1
    case 'Yes'
        disp(['Saving the verified results for ' T_vas_i.output_path{1}(96:end-4)])
    case 'No'
        disp('Launching semi-automatic algorithm...')
        sel_scale = listdlg('PromptString',{'Select the scale(s) to correct:'},'ListString',{'1','2','3','Need to adjust edge(s)'},'ListSize',[150,60]);
        
        if sel_scale ~= 4
            figure(f_vas)
            delete(txt_mark(sel_scale))
            delete(txt_vas(sel_scale))
            delete(txt_conf(sel_scale))
            T_vas_i = b03_fn_adjust_marker(f_vas,locs_scale_edges,T_vas_i,sel_scale);
        else
            sel_edge = listdlg('PromptString',{'Select the edge(s) to correct:'},'ListString',{'1 start','1 end','2 start','2 end','3 start','3 end'},'ListSize',[150,90]);
            idx_m = unique(round(sel_edge/2));
            delete(m_edges(sel_edge))
            delete(txt_vas(idx_m))
            T_vas_i = b03_fn_adjust_edge(f_vas,locs_scale_edges,locs_marker,T_vas_i,sel_edge);
        end

end
title('')

saveas(f_vas,T_vas_i.output_path{1}(1:end-4),'png')
end