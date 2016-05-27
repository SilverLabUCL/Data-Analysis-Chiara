function [ speedD, timeD ] = PlotSpeedData( Speed,n_trials )
%plot speed data and saves concatenated data + figure

trials=Speed{end};
counter=0;
timeEnd=0;

%concatenate speed data and time data
for t=1:n_trials
    if isempty(find(trials==t, 1))==0
        SpeedIndex=find(Speed{end}==t);
        speed(counter+1: counter+size(Speed{SpeedIndex},1))=smooth(Speed{SpeedIndex}(:,2),5); %smooth speed data a bit so the graph is easier to read
        time(counter+1: counter+size(Speed{SpeedIndex},1))=Speed{SpeedIndex}(:,1)+timeEnd;
        
        counter=counter+size(Speed{SpeedIndex},1);
        timeEnd=time(end);
    else
        speed(counter+1: counter+size(Speed{1},1))=NaN;
        time(counter+1: counter+size(Speed{1},1))=Speed{1}(:,1)+timeEnd;
    
        counter=counter+size(Speed{1},1);
        timeEnd=time(end);
    end
end

%downsample speed and time data or it's too heavy 
timeD=downsample(time,10);
speedD=downsample(speed,10);

%plot
figure; plot(timeD*1e-3,speedD)
xlabel('time, s','FontSize',25, 'FontWeight', 'Bold','FontName','Calisto MT'); ylabel('Speed, rpm','FontSize',25, 'FontWeight', 'Bold','FontName','Calisto MT')
set(gca,'FontSize',25, 'FontWeight','Bold')
axis tight, box off

%save
saveas(gcf,'SpeedConcat.fig')
save('SpeedConcat.mat')

end

