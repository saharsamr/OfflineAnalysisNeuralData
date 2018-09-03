function [Y33,timeStamp10]=spike_sorting_rawdata6(data1)
                

               close all
%                 f = waitbar(0,'Please wait...');
%    
            data1=double(data1);
            
            d = designfilt('bandpassiir','FilterOrder',4, ...
                'HalfPowerFrequency1',300,'HalfPowerFrequency2',6000, ...
                'SampleRate',30000);
            
            % fvt = fvtool(d,'Fs',30000);
            data = filtfilt(d,data1);
            
           base=5*median(abs(data(1:end))/.6745);

           r1=double((downsample(data,round(30000/24000))));
            r=r1(:,:);
            x=find(r>base | r<-1*base);
            x=x(x>100);
            g=diff(x);
%             n=0;
            rr=cell(0);
            x2=[];
            Y33=zeros(size(g,2)-1,41);
            timeStamp10=[];
             for i=1:size(g,2)-1
%             disp(i)
%                 n=n+1;
                signal1=r((x(i)-70):(x(i)+20));
                cc=find (r((x(i)-70):(x(i)+20))==max(signal1),1);
                x2(i)=cc+x(i)-70;
                timeStamp10(i)=x2(i);
                rr{i}=(r(x2(i)-100:x2(i)+120));
                TT=rr{i};
                maxTT=find(TT==max(TT(80:140)),1);
%                 disp(size(TT,2))
                if maxTT>15 && maxTT<175
                TT =TT(maxTT-15:maxTT+25);
                timeStamp10(i)=x2(i);
                Y33(i,:)=TT;
                end
                
                
                
            end
            
            %%%%%%%romove duplicate spikes
%             Y44=Y33(:,1)';
            [Y44,ia,~]=unique(Y33,'stable','rows');
            Y33=Y44;
%             AllTIME=app.Time_Stamp{1,1};
            timeStamp10=timeStamp10(:,ia);
            
                Y33= Y33(:,1:30);
                
%                 Spikes=Spikes(:,1:35);
                              
               

end