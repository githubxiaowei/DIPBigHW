function [data] = yolo_request(abs_path)

t = tcpip('localhost', 54321, 'Timeout', 30,'InputBufferSize',1024);%�������ip������˿ڵķ�����

fopen(t);
fwrite(t,abs_path);%����һ�����ݸ�tcp����������������֪��matlab��ip�Ͷ˿�
while(1) %��ѯ��ֱ������������fread
    nBytes = get(t,'BytesAvailable');
    if nBytes>0
        break;
    end
end
receive = fread(t,nBytes);%��ȡtcp����������������
fclose(t);
data = str2num(char(receive(1:end)')); %��ASCII��ת��Ϊstr���ٽ�strת��Ϊ����

delete(t);
end
