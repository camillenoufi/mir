function snip = songExtract(title,T)
    [song, fs] = audioread(title);
    if size(song) < T * fs 
        snip = song;
        return;
    end
    
    snip = song(round(size(song)/2 - (T/2)*fs) : round(size(song)/2 + (T/2) * fs - 1));
    
end
    
    