% This is a script for Random Cascade Modeling of Temporal Rainfall
% The assumed model is described in Random_Cascade_Model_documentation.docx
% This script disaggregates a rainfall time series into finer time steps
% Requires Matlab statistical toolbox 12:18
clear
close all
% settings
dfile='Daily30.txt'; %input file with data in 'number-of-resolution-units/time step' (24 h in the sample data), where 'number-of-resolution-units'=accumulation/vres
vres=1; %volume resolution of the measurement device used in model analysis/calibration (mm)
pfile='NASA_Para16hrs_FullData.mat'; %file with model parameters
nstep=7; %"disaggregation steps" (7 means disaggregating by successive halving from 1 day to 11 min 15 s (675 s))
tres=675; %final time resolution of the disaggregated data in seconds (note that an interpolation to 15-min (900 s) values are included in the end of the script)
boxs=[128;64;32;16;8;4;2;1]; %from 2^nstep down to 1
nrea=1; %number of desired stochastic realizations
nvc=3; %number of volume classes assumed (note that three classes is hardcoded below on lines 183-186, another number requires adjustments there)
boxt=boxs*tres;
for cs=1:nstep
    cst(cs)=mean(boxt(cs:cs+1));
end
dum1=cst';
cstlog2=log2(dum1);

% load parameters and data, the latter assumed to be in textfile with one column and nr rows, 

inpname=['C:\Users\Yashas\Desktop\The4Years\RAINFALL\Cascade Model\NASA Data\',pfile];
load(inpname);
indname=['C:\Users\Yashas\Desktop\The4Years\RAINFALL\Cascade Model\NASA Data\',dfile];
data(:,1)=load(indname);
[nr,nc] = size(data); % nc - columns (1), nr - rows

% Fist make matrices pxxm/p01m/p10m and am of model probabilities and a-values

% Position class 1 (isolated)

for cs=1:nstep
    scale=cstlog2(cs);
    int=c1(1,3)+c2(1,3)*scale;
    if (scale>alim)
        am(cs,1)=2^ac(1);
    else
        am(cs,1)=2^(c3(1)+c4(1)*scale);
    end
    for vc=1:nvc
        pxxm(cs,1,vc)=int+slom(1,3)*vc;
        if (pxxm(cs,1,vc)>1)
            pxxm(cs,1,vc)=1;
        end
        p01m(cs,1,vc)=(1-pxxm(cs,1,vc))/2;
        p10m(cs,1,vc)=(1-pxxm(cs,1,vc))/2;
    end
end

% Position class 2 (starting)

for cs=1:nstep
    scale=cstlog2(cs);    
    int=c1(2,3)+c2(2,3)*scale;
    if (scale>alim)
        am(cs,2)=2^ac(2);
    else
        am(cs,2)=2^(c3(2)+c4(2)*scale);
    end
    for vc=1:nvc
        pxxm(cs,2,vc)=int+slom(2,3)*vc;
        if (pxxm(cs,2,vc)>1)
            pxxm(cs,2,vc)=1;
        end
        p01m(cs,2,vc)=intm21+slom(2,1)*vc;
        if (p01m(cs,2,vc)>1)
            p01m(cs,2,vc)=1;
        end
        if ((pxxm(cs,2,vc)+p01m(cs,2,vc))>1)
            p01m(cs,2,vc)=1-pxxm(cs,2,vc);
            p10m(cs,2,vc)=0;
        else
            p10m(cs,2,vc)=1-(pxxm(cs,2,vc)+p01m(cs,2,vc));
        end
    end
end

% Position class 3 (enclosed)

for cs=1:nstep
    scale=cstlog2(cs);      
    int=c1(3,3)+c2(3,3)*scale;
    if (scale>alim)
        am(cs,3)=2^ac(3);
    else
        am(cs,3)=2^(c3(3)+c4(3)*scale);
    end    
    for vc=1:nvc
        pxxm(cs,3,vc)=int+slom(3,3)*vc;
        if (pxxm(cs,3,vc)>1)
            pxxm(cs,3,vc)=1;
        end
        p01m(cs,3,vc)=(1-pxxm(cs,3,vc))/2;
        p10m(cs,3,vc)=(1-pxxm(cs,3,vc))/2;
    end
end

% Position class 4 (stopping)

for cs=1:nstep
    scale=cstlog2(cs);       
    int=c1(2,3)+c2(2,3)*scale;
    if (scale>alim)
        am(cs,4)=2^ac(2);
    else
        am(cs,4)=2^(c3(2)+c4(2)*scale);
    end    
    for vc=1:nvc
        pxxm(cs,4,vc)=int+slom(2,3)*vc;
        if (pxxm(cs,4,vc)>1)
            pxxm(cs,4,vc)=1;
        end
        p10m(cs,4,vc)=intm21+slom(2,1)*vc;
        if (p10m(cs,4,vc)>1)
            p10m(cs,4,vc)=1;
        end
        if ((pxxm(cs,4,vc)+p10m(cs,4,vc))>1)
            p10m(cs,4,vc)=1-pxxm(cs,4,vc);
            p01m(cs,4,vc)=0;
        else
            p01m(cs,4,vc)=1-(pxxm(cs,4,vc)+p10m(cs,4,vc));
        end
    end
end

pxxm+p01m+p10m; %check that the sum of probabilities are always 1

for nt=1:nrea %number of realizations
disp(nt)
% Disaggregation model

for cs=1:nstep
    disp(cs)
    
% start by creating matrices with "parent information"

    npar=nr*(2^(cs-1)); %number of "parents"
    nkid=nr*(2^cs); %number of "parents"
    parn(1:4)=0;
    clear parinfo;
    for ap=1:npar
        if (ap==1) %start of series, assume 0 before
            lef=0;
        else
            lef=data(ap-1,cs);
        end
        if (ap==npar) %end of series, assume 0 after
            rig=0;
        else
            rig=data(ap+1,cs);
        end        
        if (data(ap,cs)>0)            
            if ((lef==0) && (rig==0))
                parn(1)=parn(1)+1;
                parval(parn(1),1)=data(ap,cs); %matrix with "parent values"
                parinfo(ap,1)=1; %column 1 "parent types": 1 - isolated, 2 - starting, 3 - enclosed, 4 - stopping
            elseif ((lef==0) && (rig>0))
                parn(2)=parn(2)+1; 
                parval(parn(2),2)=data(ap,cs);    
                parinfo(ap,1)=2; %column 1 "parent types": 1 - isolated, 2 - starting, 3 - enclosed, 4 - stopping               
            elseif ((lef>0) && (rig>0))
                parn(3)=parn(3)+1;
                parval(parn(3),3)=data(ap,cs);    
                parinfo(ap,1)=3; %column 1 "parent types": 1 - isolated, 2 - starting, 3 - enclosed, 4 - stopping                   
            else
                parn(4)=parn(4)+1;
                parval(parn(4),4)=data(ap,cs);    
                parinfo(ap,1)=4; %column 1 "parent types": 1 - isolated, 2 - starting, 3 - enclosed, 4 - stopping                   
            end
        end
    end

    parn;

% based on three volume classes, make volume limits
                
    vlim(1,1:2)=prctile(parval(1:parn(1),1),[33 67]);  
    vlim(2,1:2)=prctile(parval(1:parn(2),2),[33 67]);  
    vlim(3,1:2)=prctile(parval(1:parn(3),3),[33 67]);   
    vlim(4,1:2)=prctile(parval(1:parn(4),4),[33 67]);   
    
    vlim;

% add volume class in parinfo, column 2: 1 - small volumes, 2 - intermediate, 3 - large 
    
    for pc=1:4
        parpos=find(parinfo(:,1)==pc); %positions of a certain parent type        
        nps=0;
        np1=0;
        for pp=1:parn(pc)
            if (data(parpos(pp),cs) <= vlim(pc,1))
                parinfo(parpos(pp),2)=1;
                nps=nps+1; %total number of parents in the smallest volume class             
                if (data(parpos(pp),cs)==1)
                    np1=np1+1; %number of parents with only "one tip"  in the smallest volume class (this type can not be x/x-divided and the probabilities need to be adjusted for this, below) 
                end
            elseif (data(parpos(pp),cs) <= vlim(pc,2))
                parinfo(parpos(pp),2)=2;                
            else
                parinfo(parpos(pp),2)=3;                 
            end
        end
        f_gt_1(pc)=(nps-np1)/nps; %fraction of values larger than "one tip" in the smallest volume class
        if (f_gt_1(pc) > 0) % if fgt1=0 there are only "one tip" values in the smallest volume class, then nothing needs to be done
            pxxm(cs,pc,1)=pxxm(cs,pc,1)/f_gt_1(pc); %updated pxxm, to take "one tip" values into account
            if (pxxm(cs,pc,1) >= 1) %in this case all values larger than "one tip" needs to be x/x-divided
                pxxm(cs,pc,1)=1;
                p01m(cs,pc,1)=0;
                p10m(cs,pc,1)=0;
            else
                p01m(cs,pc,1)=p01m(cs,pc,1)/(p01m(cs,pc,1)+p10m(cs,pc,1))*(1-pxxm(cs,pc,1));
                p10m(cs,pc,1)=1-(p01m(cs,pc,1)+pxxm(cs,pc,1));
            end
        end
    end  
    
% Disaggregation start    
    
    for ap=1:npar
        pos1=(2*ap)-1;
        pos2=2*ap;
        if (data(ap,cs)==0)
            data(pos1,cs+1)=0;
            data(pos2,cs+1)=0;
        else
            pc=parinfo(ap,1);
            vc=parinfo(ap,2);    
            if (data(ap,cs)==1) %if data is one tip, x/x-div is not possible, therefore rescale p01 and p10 to sum one          
                p01ms=p01m(cs,pc,vc)/(p01m(cs,pc,vc)+p10m(cs,pc,vc));
                p10ms=p10m(cs,pc,vc)/(p01m(cs,pc,vc)+p10m(cs,pc,vc));
                ran=rand;            
                if (ran<p01ms)
                    data(pos1,cs+1)=0;
                    data(pos2,cs+1)=1;
                else
                    data(pos1,cs+1)=1;
                    data(pos2,cs+1)=0;
                end       
            else
                ran=rand;
                if(pc==0)
                    pc=1;
                end
                    if(vc==0)
                        vc=1;
                    end
                if (ran<p01m(cs,pc,vc))
                    data(pos1,cs+1)=0;
                    data(pos2,cs+1)=data(ap,cs);
                elseif (ran<(p01m(cs,pc,vc)+p10m(cs,pc,vc)))
                    data(pos1,cs+1)=data(ap,cs);
                    data(pos2,cs+1)=0;
                else
                    ran2(1)=gamrnd(am(cs,pc),1);
                    ran2(2)=gamrnd(am(cs,pc),1);
                    ran3=ran2/sum(ran2);
                    data(pos1,cs+1)=round(ran3(1)*data(ap,cs));
                    data(pos2,cs+1)=round(ran3(2)*data(ap,cs));
                    if (data(pos1,cs+1)==0) % to avoid that an x/x-div results in one zero-values
                        data(pos1,cs+1)=1;
                        data(pos2,cs+1)=data(pos2,cs+1)-1;
                    elseif (data(pos2,cs+1)==0) 
                        data(pos2,cs+1)=1;
                        data(pos1,cs+1)=data(pos1,cs+1)-1;
                    end   
                end
            end
        end
    end  
end

          
% Postprocessing to desired time resolution 15 min
% in this case four 675-s values are geometrically interpolated to three 900-s values

j=round(nkid/4);
sumdiff=0;
for i=1:j
    startin=(i*4)-3;
    startut=(i*3)-2;
    in(1)=data(startin,nstep+1);
    in(2)=data(startin+1,nstep+1);
    in(3)=data(startin+2,nstep+1);
    in(4)=data(startin+3,nstep+1);
    ut(1)=round(in(1)+(1/3)*in(2));
    ut(2)=round((2/3)*in(2)+(2/3)*in(3));
    ut(3)=round((1/3)*in(3)+in(4));
    diff=sum(in)-sum(ut); %some minor volume may be added or lost in the rounding, this is to keep track of this
    sumdiff=sumdiff+diff;
    out(startut,nt)=ut(1)*vres;
    out(startut+1,nt)=ut(2)*vres;
    out(startut+2,nt)=ut(3)*vres;
end

sumdiff;

end
save 'Disaggregated_30Years_Historical.txt' out -ascii;