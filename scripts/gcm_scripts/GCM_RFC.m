n=[1976:2005];
%Future Time for rcp45 and rcp85
%change to 1976 to 2005 for historical
for i=1:length(n)
    fo=sprintf('MIROC5/pr_day_MIROC5_historical_r1i1p1_%d.nc',n(i)); %Change File Name
    
    f=ncread(fo,'pr');
    Tr(i) = max(f(70,51,:))*86400;  
end
Tr=sort(Tr,'descend');
for i=1:length(n)
    T(i)=i/(length(n)+1);
end 
p_1=interp1(T,Tr,0.5)%Return Period 2
p_2=interp1(T,Tr,0.1)%Return Period 10
p_3=interp1(T,Tr,0.04)%Return Period 25
p_4=interp1(T,Tr,0.01,'linear','extrap')%Return Period 100
plot(T,Tr)

