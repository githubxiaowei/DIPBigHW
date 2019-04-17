function [data] = yolo_request(abs_path)

t = tcpip('localhost', 54321, 'Timeout', 30,'InputBufferSize',1024);%连接这个ip和这个端口的服务器

fopen(t);
fwrite(t,abs_path);%发送一段数据给tcp服务器。服务器好知道matlab的ip和端口
while(1) %轮询，直到有数据了再fread
    nBytes = get(t,'BytesAvailable');
    if nBytes>0
        break;
    end
end
receive = fread(t,nBytes);%读取tcp服务器传来的数据
fclose(t);
data = str2num(char(receive(1:end)')); %将ASCII码转换为str，再将str转换为数组

delete(t);
end
