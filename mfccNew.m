function [mel2] = mfcc(wav, fs, fftSize, window)
%
%  
%
% USAGE
%
%   [mfcc] = mfcc(wav, fs, fftSize,window)
%
% INPUT
%      wav: vector of wav samples
%      fs : sampling frequency
%      fftSize: size of fft
%      window: a window of size fftSize
% 
% OUTPUT
%   mfcc : matrix of 40 mel coefficients x nFrames


%
%
%   hard wired parameters

hopSize = fftSize/2;
nBanks = 40;

%
%
%    minimum and maximum frequencies for the analysis
fMin = 20;
fMax = fs/2;

%_________________________________________________________
%        
%     PART 1 : construction of the filters in the frequency domain
%_________________________________________________________

% generate the linear frequency scale of equally spaced frequencies from 0 to fs/2.

linearFreq = linspace(0,fs/2,hopSize+1);

fRange = fMin:fMax;

% map the linear frequency scale of equally spaced frequencies from 0 to fs/2 to an unequally spaced
%  mel scale.

melRange = log(1+fRange/700)*1127.01048;

% The goal of the next coming lines is to resample the mel scale to create uniformly spaced mel
% frequency bins, and then map this equally spaced mel scale to the linear scale.

%
% divide the mel frequency range in equal bins

melEqui = linspace (1,max(melRange),nBanks+2); 

fIndex = zeros(nBanks+2,1);

% for each mel frequency on the equally spaces grid, find the closest frequency on the unequally
% spaced mel scale

for i=1:nBanks+2,
    [dummy fIndex(i)] = min(abs(melRange - melEqui(i)));
end

%  now, we have the indices of the unequally mel scale that match the equally mel grid. These
%  indices match the linear frequency, so we can assign a linear frequency for each equally spaced
%  mel frequency

fEquiMel = fRange(fIndex);


%  design of the hat filters: we build two arrays that correspond to the center, left and right ends
%  of each triangle.

fLeft   = fEquiMel(1:nBanks);
fCentre = fEquiMel(2:nBanks+1);
fRight  = fEquiMel(3:nBanks+2);

% clip filters that leak beyond the Nyquist frequency

[dummy, tmp.idx] = max(find(fCentre <= fs/2));
nBanks = min(tmp.idx,nBanks);

% this array contains the frequency response of the nBanks hat filters.

freqResponse = zeros(nBanks,fftSize/2+1);

hatHeight = 2./(fRight-fLeft);

% for each filter, we build the left and right edge of the hat.

for i=1:nBanks,
    freqResponse(i,:) = ...
        (linearFreq > fLeft(i) & linearFreq <= fCentre(i)).* ...
        hatHeight(i).*(linearFreq-fLeft(i))/(fCentre(i)-fLeft(i)) + ...
        (linearFreq > fCentre(i) & linearFreq < fRight(i)).* ...
        hatHeight(i).*(fRight(i)-linearFreq)/(fRight(i)-fCentre(i));
end

%
% plot a pretty figure of the frequency response of the filters. 
% 
% figure; set(gca,'fontsize',14)
% semilogx(linearFreq,freqResponse'); 
% axis([0 fRight(nBanks) 0 max(freqResponse(:))])
% title('Filterbank');

%_________________________________________________________
%        
%     PART 2 : processing of the audio vector. The processing is performed in the Fourier domain.
%
%_________________________________________________________

%
% estimate the number of frames that we will process

nFrames = floor (length(wav)/hopSize);
if (mod(nFrames,2) == 0)
    nFrames = nFrames -1;
end

%
% allocate the mel coefficients

mel = zeros(nBanks, nFrames);

%
% and the power spectrum

poweSpect = zeros(fftSize/2+1, nFrames);

%
% normalize the window

window = 2*window./sum(window);

chunkIndx = 1:fftSize;

for i=1:nFrames-1,
    X = abs(fft(wav(chunkIndx).*window,fftSize));
    
    poweSpect(:,i) = X(1:end/2+1);
    mel(:,i) = freqResponse * poweSpect(:,i); 
    
    chunkIndx = chunkIndx + hopSize;
end

mfcc = mel;
%mfcc = flipud(mfcc);

%set(gca,'ydir','normal'); caxis(max(caxis)+[-60 0])


% plot the power spectrum 

% figure; subplot(2,1,1); set(gca,'fontsize',14)
% 
% poweSpect = 10*log10(poweSpect); 
% imagesc(poweSpect); 
% 
% % plot the mel coefficients
% set(gca,'ydir','normal','xtick',[]); title('Spectrum')
% colormap('jet'); hold on; colorbar
% 
% subplot(2,1,2); set(gca,'fontsize',14)
% 
% tt = [1:size(mfcc,2)]*fftSize/(2*fs);
% imagesc(tt,[1:40],mfcc); 
% 
% set(gca,'ydir','normal'); caxis(max(caxis)+[-60 0])
% colormap('jet');hold on;colorbar
% 
% title('MFCC Representation')


%normalize the mfcc into 12 bands
t = zeros(1,36); %(2.21)

t(1) =1;
t(7:8)=5;
t(15:18)= 9;
t(2) = 2; 
t(9:10) = 6; 
t(19:23) = 10;
t(3:4) = 3; 
t(11:12) = 7; 
t(24:29) = 11;
t(5:6) = 4; 
t(13:14) = 8; 
t(30:36) = 12;

%declare empty matrix for normalized mfcc
mel2 = zeros(12,size(mfcc,2));

%sum values in sections defined above, put them 
for i=1:12,
    mel2(i,:) = sum(mfcc(t==i,:),1);
end

return;


