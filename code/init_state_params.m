function init_state_params()
%init_state_params 初始化与程序状态相关的全局变量

global g_state; %定义全局变量
g_state.img = nan; %用户上传的图片
g_state.img_class = 'nan'; %当前图片的类别
g_state.curr_page = 0; %当前页面
g_state.total_page_num = 0; %页面总数
g_state.img_per_page = 8; %每页8张图片
g_state.img_list = {}; %检索结果
g_state.task = 0; %0-浏览数据库 1-检索相似图片，用于区分图片标题格式
g_state.similarity_id = 1; %计算特征相似度的方式
end

