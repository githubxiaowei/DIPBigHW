global g_bird_data;
init_data_params()
for i = 1:length(g_bird_data.features.classes)
    if strcmp('localRGBhist',g_bird_data.features.classes{i}) %单独处理区域特征
        prepare_localRGB(i)
    else
        prepare(g_bird_data.features.functions{i},i);
    end
end

function prepare(feat_func,feat_i)
    global g_bird_data;
    fprintf(['\n-- preparing ',g_bird_data.features.classes{feat_i},' feature for database ...'])

    if ~exist(g_bird_data.features.paths{feat_i},'file')
        features = cell(g_bird_data.img_num,1);
        h = waitbar(0,['preparing ',g_bird_data.features.classes{feat_i},' feature for database']);
        for i = 1:g_bird_data.img_num
            features{i} = feat_func(g_bird_data.img_paths{i}); 
            waitbar(i/g_bird_data.img_num);
        end
        close(h);
        save(g_bird_data.features.paths{feat_i},'features');
    end
    fprintf(['done\n']);
end

function prepare_localRGB(feat_i)
    global g_bird_data;
    fprintf(['\n-- preparing ',g_bird_data.features.classes{feat_i},' feature for database ...'])

    if ~exist(g_bird_data.features.paths{feat_i},'file')
        load_bbox = load(g_bird_data.features.yolo_bbox);
        bbox = load_bbox.all_bbox;
        features = cell(g_bird_data.img_num,1);
        h = waitbar(0,['preparing ',g_bird_data.features.classes{feat_i},' feature for database']);
        for i = 1:g_bird_data.img_num
            pos = bbox{i};
            img = imread(g_bird_data.img_paths{i});
            img = double(img(pos(2):(pos(2)+pos(4)),pos(1):(pos(1)+pos(3)),:));
            [M,N,C] = size(img);
            bin_num = 16;
            if C > 1
                R = img(:,:,1);
                G = img(:,:,2);
                B = img(:,:,3);
                [rh,~] = hist(R(:),bin_num); %R_hist
                [gh,~] = hist(G(:),bin_num); %G_hist
                [bh,~] = hist(B(:),bin_num); %B_hsit
                feature = [rh,gh,bh]/(M*N); %concatenation and normalization
            else
                gray = img(:,:,1);
                [gyh,~] = hist(gray(:),bin_num); %gray_hist in case of gray img
                feature = [gyh,gyh,gyh]/(M*N);
            end
            features{i} = feature;
            waitbar(i/g_bird_data.img_num);
        end
        close(h);
        save(g_bird_data.features.paths{feat_i},'features');
    end
    fprintf(['done\n']);
end

