function [NPCP] = PCP(title, fs, frame_size)

    T = 24;
    song_snip = songExtract(title,T);
    
    %frame_size = round(fs/1.6) + 1;            % to obtain resolution capturing smallest distance between chroma
    frame_size = 2048;
    
    K = frame_size/2 + 1;
    
    num_frames = floor(size(song_snip,1)/(frame_size/2));
    
    f0 = 27.5;
    
    wfft = zeros(K,num_frames);
    
    % for all the frames 
    window = hamming(frame_size);
    index = 1;
    
    for m = 1:frame_size/2:(num_frames-1) * (frame_size/2);
        xn = song_snip(m: m + frame_size - 1);    %extract frame n 
        xfft = fft(xn .* window);  %window and fft the frame
        wfft(:,index) = xfft(1:K);                   % spectogram of frame frequency content
        index = index + 1;
    end

    wfft = abs(wfft).^2;
    %initialize matrix holding 12 chroma values for each frame n
    PCP = zeros(num_frames,12);
   
    % Look at a single frame n
    for n = 1:num_frames    
        % find peak magnitudes and their locations (in freq) in nth frame
        [peakmag,peakfreq] = findpeaks(wfft(:,n));       %peakmag and peakfreq are horizontal arrays
        num_peaks = size(peakfreq,1);
        
            % for all the peaks 
            % initialize vector to hold all weights for particular peak k
            wk = zeros(num_peaks,12);
            
            for k = 1:num_peaks
                fk = peakfreq(k)*fs/frame_size;
                sm = round(12*log2(fk/f0));
                c = mod(sm,12);
                distance_from_semitone = 12*log2(fk/f0)- sm;
                wk(k,c+1) = cos(pi/2*distance_from_semitone)^2;
            end 
            
            % compute the dot product of the weight at semitone and the
            % magnitude of peak, then sum all values over # of peaks
            for chroma = 0:11 
                for peak_index = 1:num_peaks
                    PCP(n,chroma+1) = PCP(n,chroma+1) + wk(peak_index,chroma+1)*peakmag(peak_index);
                end
            end
              
    end
    
    %normalize based on the highest frequency in the spectogram
    PCP = transpose(PCP);
    NPCP = PCP/(max(max(PCP)));
%     imagesc(10*log10(PCP))
end