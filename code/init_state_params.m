function init_state_params()
%init_state_params ��ʼ�������״̬��ص�ȫ�ֱ���

global g_state; %����ȫ�ֱ���
g_state.img = nan; %�û��ϴ���ͼƬ
g_state.img_class = 'nan'; %��ǰͼƬ�����
g_state.curr_page = 0; %��ǰҳ��
g_state.total_page_num = 0; %ҳ������
g_state.img_per_page = 8; %ÿҳ8��ͼƬ
g_state.img_list = {}; %�������
g_state.task = 0; %0-������ݿ� 1-��������ͼƬ����������ͼƬ�����ʽ
g_state.similarity_id = 1; %�����������ƶȵķ�ʽ
end

