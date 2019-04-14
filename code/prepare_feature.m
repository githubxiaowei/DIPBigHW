
init_data_params()
prepare_RGBhist();

function prepare_RGBhist()
    fprintf('\n--- preparing RGB_histogram feature for database ...\n')
    global g_bird_data;
    features = cell(g_bird_data.img_num,1);
    parfor i = 1:g_bird_data.img_num
        features{i} = feat_RGBhist(imread(g_bird_data.img_paths{i}));  
    end
    fprintf('--- saving RGB_histogram features ...\n')
    save(g_bird_data.features.RGBhist,'features');
    fprintf('--- complete RGB_histogram feature preparing!\n')
end


