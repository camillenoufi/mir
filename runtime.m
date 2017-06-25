createDistanceMatrix('data');

% window = hamming(512);
% snip = songExtract('artist_9_album_1_track_1.wav', 240);
% snipTranny = transpose(snip);
% 
% %snip = snip(500:1011,:);
% 
% %PCP(snip, 44100);
% 
% x = mfccNew(snip, 22050, 512, window);
% y = mychroma(snipTranny, 22050, 512);
% z = mfcc('artist_9_album_1_track_1.wav', 22050, 512, window);
% 
% figure;
% imagesc(x);
% colormap(jet)
% 
% figure;
% imagesc(y);
% colormap(jet)
% 
% figure;
% imagesc(z);
% colormap(jet)
% 


