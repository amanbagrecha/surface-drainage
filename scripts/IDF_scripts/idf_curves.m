clc;clear;
n=[1976:2019];
dat=[];
for i=1:length(n)
    str=sprintf('Rainfall_ind%d_rfp25.grd',n(i));
fid = fopen(str); %file address
NDAY = 365; %dnt
ISIZ = 135; JSIZ = 129; %dnt
T = zeros(ISIZ, JSIZ, NDAY, 'single'); %dnt
for IDAY = 1 : NDAY  %dnt
    T( :, :, IDAY ) = fread(fid, [ISIZ JSIZ ], '*single');  %dnt
end   %dnt
fclose(fid);   %dnt

T(T==-999) = NaN;
Tr=zeros(1,365);
for fgd = 1 : NDAY
    Tr(fgd) = T(27,46,fgd);   
end
p=max(Tr);
for n=5:5:60
     Tr(n)=p*(((n/60)/24)^(1/3));
     dur(i,1:12)=n/60;
end
for m=2:2:10;
    Tr(m)=p*((m/24)^(1/3));
end
Tr48=zeros(1,364);
for j=1:364
   Tr48(j)=Tr(j)+Tr(j+1);
end
Tr72=zeros(1,363);
for j=1:363
   Tr72(j)=Tr(j)+Tr(j+1)+Tr(j+2);
end
for j=1:362
   Tr96(j)=Tr(j)+Tr(j+1)+Tr(j+2)+Tr(j+3);
end
% data48(i)=max(f);
% data24(i)=max(Tr);
data(i,1:21)=[Tr(5);Tr(10);Tr(15);Tr(20);Tr(25);Tr(30);Tr(35);Tr(40);Tr(45);Tr(50);Tr(55);Tr(60);Tr(2);Tr(4);Tr(6);Tr(8);Tr(10);max(Tr);max(Tr48);max(Tr72);max(Tr96)]; % 24 and 48  hrs max values for 18 years
end
data(1,1)=data(1,1)*0.1329;
% data48;
% data24;

du=[dur,2,4,6,8,10,24,48,72,96];
% hold on
% 2,5,10,50,100
kt=[-0.164272];
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
plot(du,y24,'b','LineWidth',1.5)
end
y24
hold off
% x=linspace(1,100,10)
% f1=figure
% hold on
% for i= 1:length(a)
%    
%     y=a(i,1)*x+a(i,2)*x.^2 +a(i,3)*x.^3;
%     plot(x,y)
% end 
% du2=[1/2 1];
% for w=1:2
%     datax=data48/du2(w);
%     me1=mean(datax);
%     s1=std(datax);
%     kt=-0.164272;
%     y48(w)=me1+(kt*s1);
% end
% plot(du2,y48)
% y48(6)
% y24(6)