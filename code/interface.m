function varargout = interface(varargin)
% INTERFACE MATLAB code for interface.fig
%      INTERFACE, by itself, creates a new INTERFACE or raises the existing
%      singleton*.
%
%      H = INTERFACE returns the handle to a new INTERFACE or the handle to
%      the existing singleton*.
%
%      INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFACE.M with the given input arguments.
%
%      INTERFACE('Property','Value',...) creates a new INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interface

% Last Modified by GUIDE v2.5 13-Apr-2019 22:29:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interface_OpeningFcn, ...
                   'gui_OutputFcn',  @interface_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before interface is made visible.
function interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interface (see VARARGIN)

% Choose default command line output for interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using interface.
% % if strcmp(get(hObject,'Visible'),'off')
% %     plot(rand(5));
% % end
init_data_params(); %初始化数据库
global g_state; %定义全局变量
g_state.img = nan; %用户上传的图片
g_state.curr_page = 0; %当前页面
g_state.total_page_num = 0; %页面总数
g_state.img_per_page = 8; %每页8张图片
g_state.img_list = {}; %检索结果



% UIWAIT makes interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = interface_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in showbutton.
function showbutton_Callback(hObject, eventdata, handles)
% hObject    handle to showbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes_list = [handles.axes1,handles.axes2,handles.axes3,handles.axes4,...
             handles.axes5,handles.axes6,handles.axes7,handles.axes8];

bird_class = get(handles.popupmenu1, 'Value');
global g_bird_data;
I = g_bird_data.img_paths([g_bird_data.start_idx(bird_class):g_bird_data.start_idx(bird_class+1)-1]);
global g_state;
g_state.img_list = I;
g_state.curr_page = 1;
g_state.total_page_num = ceil(length(I)/g_state.img_per_page);
for i = 1:8
    axes(axes_list(i));
    cla;title(''); % 删除标题
    if(i>length(I))
        continue;
    end
    imshow(imread(string(I(i)).char));
    title(num2str(i));
end
set(handles.pagetext,'String',[num2str(g_state.curr_page),'/',num2str(g_state.total_page_num)]);


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end
global g_bird_data;
set(hObject, 'String', g_bird_data.classes);


% --- Executes on button press in selectbutton.
function selectbutton_Callback(hObject, eventdata, handles)
% hObject    handle to selectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_state;
[filename,pathname]=uigetfile({'*.*';'*.bmp';'*.jpg';'*.tif';'*.jpg'},'选择图像');
if isequal(filename,0)||isequal(pathname,0)
    return;
else
image=[pathname,filename];%合成路径+文件名
g_state.img=imread(image);%读取图像
set(handles.axes0,'HandleVisibility','ON');%打开坐标，方便操作
axes(handles.axes0);%%使用图像，操作在坐标1
imshow(g_state.img);%在坐标axes1显示原图像
% title('检索图像');
end

% --- Executes on button press in searchbutton.
function searchbutton_Callback(hObject, eventdata, handles)
% hObject    handle to searchbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_state;
if isnan(g_state.img)
    errordlg('您还没有选取图片！！','温馨提示');%如果没有输入，则创建错误对话框
else
    axes_list = [handles.axes1,handles.axes2,handles.axes3,handles.axes4,...
             handles.axes5,handles.axes6,handles.axes7,handles.axes8];
    
    %TODO: return images similar with g_state.img
    I = {};
    g_state.img_list = I;
    g_state.curr_page = 1;
    g_state.total_page_num = ceil(length(I)/g_state.img_per_page);
    for i = 1:8
        axes(axes_list(i));
        cla;title(''); % 删除标题
        if(i>length(I))
            continue;
        end
        imshow(imread(string(I(i)).char));
        title(num2str(i));
    end
    set(handles.pagetext,'String',[num2str(g_state.curr_page),'/',num2str(g_state.total_page_num)]);
         
end



% --- Executes on button press in lastpage_button.
function lastpage_button_Callback(hObject, eventdata, handles)
% hObject    handle to lastpage_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_state;
if g_state.curr_page <= 1
    return;
else
    axes_list = [handles.axes1,handles.axes2,handles.axes3,handles.axes4,...
             handles.axes5,handles.axes6,handles.axes7,handles.axes8];
    global g_state;
    I = g_state.img_list;
    g_state.curr_page = g_state.curr_page-1;
    for i = 1:8
        axes(axes_list(i));
        cla;title(''); % 删除标题
        idx = (g_state.curr_page-1)*g_state.img_per_page+i;
        imshow(imread(string(I(idx)).char));
        title(num2str(idx));
    end
    set(handles.pagetext,'String',[num2str(g_state.curr_page),'/',num2str(g_state.total_page_num)]);
end


% --- Executes on button press in nextpage_button.
function nextpage_button_Callback(hObject, eventdata, handles)
% hObject    handle to nextpage_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_state;
if g_state.curr_page >= g_state.total_page_num
    return;
else
    axes_list = [handles.axes1,handles.axes2,handles.axes3,handles.axes4,...
             handles.axes5,handles.axes6,handles.axes7,handles.axes8];
    global g_state;
    I = g_state.img_list;
    g_state.curr_page = g_state.curr_page+1;
    for i = 1:8
        axes(axes_list(i));
        cla;title(''); % 删除标题
        idx = (g_state.curr_page-1)*g_state.img_per_page+i;
        if(idx>length(I))
            continue;
        end
        imshow(imread(string(I(idx)).char));
        title(num2str(idx));
    end
    set(handles.pagetext,'String',[num2str(g_state.curr_page),'/',num2str(g_state.total_page_num)]);
end
