%% generate mock data for axial PSF
clear all; close all;
a1=18.8; %FWHM
a2=8.4; %FWHM
th=0.4; %threshold
fontsize=6
plotwidth=120; % specify x-axis width [μm]
sdtofwhm=2.355; % sd to FWHM conversion factor 
b1=(a1/sdtofwhm).*randn(1,1000000); %generate random numbers with FWHM a1
b2=(a2/sdtofwhm).*randn(1,1000000); %generate random numbers with FWHM a2

% create histograms
c1=histogram(b1); 
hold on
c2=histogram(b2);
c1.FaceColor='none';
c2.FaceColor='none';
c2.EdgeColor='b';
c1.EdgeColor='r';

c1.BinEdges=[-plotwidth/2:0.1:plotwidth/2];
c2.BinEdges=[-plotwidth/2:0.1:plotwidth/2];

% normalize
d1=c1.Values./max([c1.Values c2.Values]);
d2=c2.Values./max([c1.Values c2.Values]);

%moving average filter
d1=movmean(d1,5);
d2=movmean(d2,5);


%plot simulated axial psf data
figure
subplot(4,3,1)
plot(c1.BinEdges(1:end-1),d1)
hold on
plot(c2.BinEdges(1:end-1),d2, 'r')
axis([-60 60 0 1.05])
title(['axial psf']) %, threshold line at ' num2str(th)])
xlabel(['\mu' 'm'])
ylabel('a.u.')
e1=d1;
e2=d2;
%add FWHM to plot
HMe1=max(e1)/2;
HMe2=max(e2)/2;
FWHMe1=nan(size(c1.BinEdges(1:end-1)));
FWHMe2=nan(size(c1.BinEdges(1:end-1)));
FWHMe1(find(e1>HMe1))=HMe1;
FWHMe2(find(e2>HMe2))=HMe2;
plot(c1.BinEdges(1:end-1),FWHMe1,'b--')
plot(c2.BinEdges(1:end-1),FWHMe2, 'r--')

thmin=th/8;
for thcount=1:8
th1=thmin*thcount;
yline(th1)
end

% add text (FWHM and area)
FWHMwidthe1=c1.BinEdges(find(e1>HMe1,1,'last')) - c1.BinEdges(find(e1>HMe1,1,'first'));
FWHMwidthe2=c2.BinEdges(find(e2>HMe2,1,'last')) - c2.BinEdges(find(e2>HMe2,1,'first'));
text(c1.BinEdges(find(e1>HMe1,1,'first')),HMe1,['FWHM=' num2str(FWHMwidthe1,'%.1f') '\mu' 'm, area=' num2str(sum(e2),'%.1f') ' a.u. \rightarrow '], 'Color','blue','HorizontalAlignment','right','FontSize',fontsize)
text(c2.BinEdges(find(e2>HMe2,1,'last')),HMe2,[' \leftarrow FWHM=' num2str(FWHMwidthe2,'%.1f') '\mu' 'm, area=' num2str(sum(e2),'%.1f') ' a.u.'], 'Color','red','FontSize',fontsize)

%convolve with 10 different "cell sizes" (modeled with square pulses)

FWHMdata=zeros(3,12);
FWHMdata(:,1)=[0;FWHMwidthe1;FWHMwidthe2];
for i=1:11
% generate square pulse filter
cellsize=i*5;


spf=zeros(size(c1.BinEdges(1:end-1)));

% use the following line to specify square pulse
spf(find((c1.BinEdges(1:end-1)<(cellsize/2) & c1.BinEdges(1:end-1)>-cellsize/2)))=1;

% use the following line for sepcifying two unit impulses
%spf(find((c1.BinEdges(1:end-1)==(cellsize/2) | c1.BinEdges(1:end-1)==-cellsize/2)))=1;
spf=spf/sum(spf);

% convolve
e1=conv(d1,spf,'same');
e2=conv(d2,spf,'same');

%plot convolved data
subplot(4,3,i+1)
plot(c1.BinEdges(1:end-1),e1)
hold on
plot(c2.BinEdges(1:end-1),e2, 'r')
% plot(c2.BinEdges(1:end-1),50.*spf, 'k')  %add pulse shape to plot
axis([-60 60 0 1.05])
title(['psf convolved with ' num2str(cellsize) '\mu' 'm square pulse']) %, threshold line at ' num2str(th)])
xlabel(['\mu' 'm'])
ylabel('a.u.')
thmin=th/8;
for thcount=1:8
th1=thmin*thcount;
yline(th1)
end

%add FWHM to plot
HMe1=max(e1)/2;
HMe2=max(e2)/2;
FWHMe1=nan(size(c1.BinEdges(1:end-1)));
FWHMe2=nan(size(c2.BinEdges(1:end-1)));
FWHMe1(find(e1>HMe1))=HMe1;
FWHMe2(find(e2>HMe2))=HMe2;
plot(c1.BinEdges(1:end-1),FWHMe1,'b--')
plot(c2.BinEdges(1:end-1),FWHMe2, 'r--')

% add text (FWHM and area)
FWHMwidthe1=c1.BinEdges(find(e1>HMe1,1,'last')) - c1.BinEdges(find(e1>HMe1,1,'first'));
FWHMwidthe2=c2.BinEdges(find(e2>HMe2,1,'last')) - c2.BinEdges(find(e2>HMe2,1,'first'));
text(c1.BinEdges(find(e1>HMe1,1,'first')),HMe1,['FWHM=' num2str(FWHMwidthe1,'%.1f') '\mu' 'm, area=' num2str(sum(e2),'%.1f') ' a.u. \rightarrow '], 'Color','blue','HorizontalAlignment','right','FontSize',fontsize)
text(c2.BinEdges(find(e2>HMe2,1,'last')),HMe2,[' \leftarrow FWHM=' num2str(FWHMwidthe2,'%.1f') '\mu' 'm, area=' num2str(sum(e2),'%.1f') ' a.u.'], 'Color','red','FontSize',fontsize)

FWHMdata(:,i+1)=[cellsize;FWHMwidthe1;FWHMwidthe2];

end
set(gcf,'WindowState','maximized')
figure;plot(FWHMdata(1,:),FWHMdata(2,:),'*');hold on;plot(FWHMdata(1,:),FWHMdata(3,:),'*');
xlim([0 60])
ylim([0 60])
xlabel(['cellsize in ' '\mu' 'm'])
ylabel(['FWHM in ' '\mu' 'm'])
rl=refline(1,0)
rl.Color='k';


%% add threshold
hth=figure;
thmin=th/8;
for thcount=1:8
th=thmin*thcount;
%plot simulated axial psf data
figure(6)
subplot(4,3,1)
plot(c1.BinEdges(1:end-1),d1>th)
hold on
plot(c2.BinEdges(1:end-1),d2>th, 'r')
axis([-60 60 0 1.05])
title('axial psf')
xlabel(['\mu' 'm'])
ylabel('a.u.')


e1=d1;
e2=d2;
%add FWHM to plot
% HMe1=max(e1)/2;
% HMe2=max(e2)/2;
% FWHMe1=nan(size(c1.BinEdges(1:end-1)));
% FWHMe2=nan(size(c1.BinEdges(1:end-1)));
% FWHMe1(find(e1>HMe1))=HMe1;
% FWHMe2(find(e2>HMe2))=HMe2;
% plot(c1.BinEdges(1:end-1),FWHMe1,'b--')
% plot(c2.BinEdges(1:end-1),FWHMe2, 'r--')

% add text (FWHM and area)
% FWHMwidthe1=c1.BinEdges(find(e1>HMe1,1,'last')) - c1.BinEdges(find(e1>HMe1,1,'first'));
% FWHMwidthe2=c2.BinEdges(find(e2>HMe2,1,'last')) - c2.BinEdges(find(e2>HMe2,1,'first'));
% text(c1.BinEdges(find(e1>HMe1,1,'first')),HMe1,['FWHM=' num2str(FWHMwidthe1,'%.1f') '\mu' 'm, area=' num2str(sum(e2),'%.1f') ' a.u. \rightarrow '], 'Color','blue','HorizontalAlignment','right')
% text(c2.BinEdges(find(e2>HMe2,1,'last')),HMe2,[' \leftarrow FWHM=' num2str(FWHMwidthe2,'%.1f') '\mu' 'm, area=' num2str(sum(e2),'%.1f') ' a.u.'], 'Color','red')

THRwidthe1=c1.BinEdges(find(e1>th,1,'last')) - c1.BinEdges(find(e1>th,1,'first'));
THRwidthe2=c2.BinEdges(find(e2>th,1,'last')) - c2.BinEdges(find(e2>th,1,'first'));


THRwidthe1(isempty(THRwidthe1))=0;
THRwidthe2(isempty(THRwidthe2))=0;

THRdata=zeros(3,11);
THRdata(:,1)=[0;THRwidthe1;THRwidthe2];

%convolve with 10 different "cell sizes" (modeled with square pulses)
for i=1:11
% generate square pulse filter
cellsize=i*5;


spf=zeros(size(c1.BinEdges(1:end-1)));

% use the following line to specify square pulse
spf(find((c1.BinEdges(1:end-1)<(cellsize/2) & c1.BinEdges(1:end-1)>-cellsize/2)))=1;

% use the following line for sepcifying two unit impulses
%spf(find((c1.BinEdges(1:end-1)==(cellsize/2) | c1.BinEdges(1:end-1)==-cellsize/2)))=1;

spf=spf/sum(spf);

% convolve
e1=conv(d1,spf,'same');
e2=conv(d2,spf,'same');

%plot convolved data
subplot(4,3,i+1)
plot(c1.BinEdges(1:end-1),e1>th)
hold on
plot(c2.BinEdges(1:end-1),e2>th, 'r')
% plot(c2.BinEdges(1:end-1),50.*spf, 'k')  %add pulse shape to plot
axis([-60 60 0 1.05])
title(['psf convolved with ' num2str(cellsize) '\mu' 'm square pulse, thresholded at ' num2str(th)])
xlabel(['\mu' 'm'])
ylabel('a.u.')

%add FWHM to plot
% HMe1=max(e1)/2;
% HMe2=max(e2)/2;
% FWHMe1=nan(size(c1.BinEdges(1:end-1)));
% FWHMe2=nan(size(c2.BinEdges(1:end-1)));
% FWHMe1(find(e1>HMe1))=HMe1;
% FWHMe2(find(e2>HMe2))=HMe2;
% plot(c1.BinEdges(1:end-1),FWHMe1,'b--')
% plot(c2.BinEdges(1:end-1),FWHMe2, 'r--')

% add text (FWHM and area)
% FWHMwidthe1=c1.BinEdges(find(e1>HMe1,1,'last')) - c1.BinEdges(find(e1>HMe1,1,'first'));
% FWHMwidthe2=c2.BinEdges(find(e2>HMe2,1,'last')) - c2.BinEdges(find(e2>HMe2,1,'first'));
% text(c1.BinEdges(find(e1>HMe1,1,'first')),HMe1,['FWHM=' num2str(FWHMwidthe1,'%.1f') '\mu' 'm, area=' num2str(sum(e2),'%.1f') ' a.u. \rightarrow '], 'Color','blue','HorizontalAlignment','right')
% text(c2.BinEdges(find(e2>HMe2,1,'last')),HMe2,[' \leftarrow FWHM=' num2str(FWHMwidthe2,'%.1f') '\mu' 'm, area=' num2str(sum(e2),'%.1f') ' a.u.'], 'Color','red')


THRwidthe1=c1.BinEdges(find(e1>th,1,'last')) - c1.BinEdges(find(e1>th,1,'first'));
THRwidthe2=c2.BinEdges(find(e2>th,1,'last')) - c2.BinEdges(find(e2>th,1,'first'));

THRwidthe1(isempty(THRwidthe1))=0;
THRwidthe2(isempty(THRwidthe2))=0;

THRdata(:,i+1)=[cellsize;THRwidthe1;THRwidthe2];

end
set(gcf,'WindowState','maximized')

figure(hth);subplot(2,4,thcount);plot(THRdata(1,:),THRdata(2,:),'--*');hold on;plot(THRdata(1,:),THRdata(3,:),'--*');
xlim([0 50])
ylim([0 60])
xlabel(['cellsize in ' '\mu' 'm'])
ylabel(['PPSF in ' '\mu' 'm'])
title(['threshold = ' num2str(th) ' (a.u.)'])
rl=refline(1,0)
rl.Color='k';


end

