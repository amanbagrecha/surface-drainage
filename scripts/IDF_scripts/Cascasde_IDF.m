%ppt=reshape(DATA,35040,51); ppt=ppt'; To tranform continous 15mins
%obtained from cascade modelling 
%rainfall data (one column) into yearly data 
n = [1970:2020]; 
data=[];
for y=1:31
for i= 1:96 
    Tr=zeros(1,35040);
    for j=1:(35040-i)
        Tr(j)= ppt(y,j);
        for jj= 1:i
            Tr(j)=Tr(j)+ppt(y,j+jj);
        end
    end
        T(i)=max(Tr);
end
    data(y,1:96)=T;   
end
du=([15:15:1440]/60);
% hold on
% 2,5,10,50,100
kt=[2.188]; %-0.164272 0.719  2.188
a =zeros(length(kt),3);
hold on
for alpha= 1: length(kt)
for w=1:length(du)
    datax=(data(:,w))/du(w); %converting to intensity
    me(w)=mean(datax);
    s(w)=std(datax);
%     kt=-0.164272;
    y24(w)=me(w)+(kt(alpha)*s(w));
end
a(alpha,:)=polyfit(du,y24,2);
plot(du,y24,'g','LineWidth',1.5)
end
hold off