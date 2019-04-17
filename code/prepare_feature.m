global g_bird_data;
init_data_params()
for i = 1:length(g_bird_data.features.classes)
    prepare(g_bird_data.features.functions{i},i);
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


