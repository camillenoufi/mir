function [mel2] = mfcc(title, fs, fftSize, window)
%
T = 24;
wav = songExtract(title,T);

% USAGE
% [mfcc] = mfcc(wav, fs, fftSize,window)
%
% INPUT
% vector of wav samples
% fs : sampling frequency
% fftSize: size of fft
% window: a window of size fftSize
%
% OUTPUT
% mfcc (matrix) size coefficients x nFrames
% hardwired parameters
hopSize = fftSize/2;
nBanks = 40;
% minimum and maximum frequencies for the analysis
fMin = 20;
fMax = fs/2;
%_____________________________________________________________________
%
% PART 1 : construction of the filters in the frequency domain
%_____________________________________________________________________
% generate the linear frequency scale of equally spaced frequencies from 0 to fs/2.
linearFreq = linspace(0,fs/2,hopSize+1);
fRange = fMin:fMax;
% map the linear frequency scale of equally spaced frequencies from 0 to fs/2
% to an unequally spaced mel scale.
melRange = log(1+fRange/700)*1127.01048;

% The goal of the next coming lines is to resample the mel scale to create uniformly
% spaced mel frequency bins, and then map this equally spaced mel scale to the linear
%& scale.
% divide the mel frequency range in equal bins
melEqui = linspace (1,max(melRange),nBanks+2);
fIndex = zeros(nBanks+2,1);
% for each mel frequency on the equally spaces grid, find the closest frequency on the
% unequally spaced mel scale
for i=1:nBanks+2
[dummy, fIndex(i)] = min(abs(melRange - melEqui(i)));
end
% Now, we have the indices of the equally-spaced mel scale that match the unequally-spaced
% mel grid. These indices match the linear frequency, so we can assign a linear frequency
% for each equally-spaced mel frequency
fEquiMel = fRange(fIndex);
% Finally, we design of the hat filters. We build two arrays that correspond to the center,
% left and right ends of each triangle.
fLeft = fEquiMel(1:nBanks);
fCentre = fEquiMel(2:nBanks+1);
fRight = fEquiMel(3:nBanks+2);
% clip filters that leak beyond the Nyquist frequency
[dummy, tmp.idx] = max(find(fCentre <= fs/2));
nBanks = min(tmp.idx,nBanks);
% this array contains the frequency response of the nBanks hat filters.
freqResponse = zeros(nBanks,fftSize/2+1);
hatHeight = 2./(fRight-fLeft);

% for each filter, we build the left and right edge of the hat.
for i=1:nBanks
freqResponse(i,:) = ...
(linearFreq > fLeft(i) & linearFreq <= fCentre(i)).* ...
hatHeight(i).*(linearFreq-fLeft(i))/(fCentre(i)-fLeft(i)) + ...
(linearFreq > fCentre(i) & linearFreq < fRight(i)).* ...
hatHeight(i).*(fRight(i)-linearFreq)/(fRight(i)-fCentre(i));
end
%
% plot a pretty figure of the frequency response of the filters.
%figure;set(gca,'fontsize',14);semilogx(linearFreq,freqResponse');
%axis([0 fRight(nBanks) 0 max(freqResponse(:))]);title('FilterbankS');
%_________________________________________________________
%
% PART 2 : processing of the audio vector In the Fourier domain.
%_________________________________________________________
%
N = fftSize;
K = N/2 + 1;

nf = floor(size(wav)/256);
nf = nf(1);
findex = 0;

mfcc = zeros(nBanks , nf);

for n = 1 : 256 : ((nf-1) * 256)
    findex = findex + 1;
    xn = wav(n : n + 511);
    Y = fft(xn .* window);
    Xn = Y(1:K);
    for p = 1 : 40
        for k = 1 : K
            mfcc(p,findex) = mfcc(p,findex) + abs(freqResponse(p,k) * Xn(k)) .^ 2;
        end
    end
end

%flip matrix so lowest frequencies are at the bottom
mfcc = flipud(mfcc);


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



end




