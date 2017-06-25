function [ mfccDistanceMatrix, chromaDistanceMatrix, mfccGenreMatrix, chromaGenreMatrix ] = createDistanceMatrix( audioFolderName )

    %read in all the songs in the input
    songStruct = dir(audioFolderName);
    songStruct = songStruct(4:end);         %for Macs only, to remove hidden files
    numSongs = size(songStruct,1);
    numGenres = 6;
    songsPerGenre = numSongs/numGenres;

    %declare parameters
    fs = 22050;
    fftSize = 512;
    window = hamming(fftSize);

    %initialize mean/cov struct
    mfccMeanStruct = struct('index',{},'mean',{},'cov',{},'genre',{});
    chromaMeanStruct = struct('index',{},'mean',{},'cov',{},'genre',{});

    %get mean and cov from all songs for MFCC and CHROMA
    g = 0;
    for n=1:numSongs
        songName = strcat(audioFolderName,'/',songStruct(n).name);
        length = 120;
        songWav = songExtract(songName, length);
        songWavTrans = transpose(songWav);
        if(mod(n,songsPerGenre)==1) 
            g = g+1;
        end

        %MFCC
        mfccMatrix = mfccNew(songWav,fs,fftSize,window);
        mu = mean(mfccMatrix,2);
        covMatrix = cov(transpose(mfccMatrix));    
        mfccMeanStruct(n).mean = mu;
        mfccMeanStruct(n).cov = covMatrix;
        mfccMeanStruct(n).genre = g;
        mfccMeanStruct(n).index = n;

        %CHROMA
        chromaMatrix = mychroma(songWavTrans,fs,fftSize);
        mu = mean(chromaMatrix,2);
        covMatrix = cov(transpose(chromaMatrix));    
        chromaMeanStruct(n).mean = mu;
        chromaMeanStruct(n).cov = covMatrix;
        chromaMeanStruct(n).genre = g;
        chromaMeanStruct(n).index = n;

    end

    %initialize distance matrix
    mfccDistanceMatrix = zeros(numSongs,numSongs);
    chromaDistanceMatrix = zeros(numSongs,numSongs);

    %iterate through all songs pairwise and calculate their distance
    for i = 1:numSongs
        for j = i:numSongs 
            %MFCC distance calculations
            mfccDistance = songDistance(mfccMeanStruct(i).mean,mfccMeanStruct(j).mean,mfccMeanStruct(i).cov,mfccMeanStruct(j).cov);
            mfccDistanceMatrix(i,j) = mfccDistance;
            mfccDistanceMatrix(j,i) = mfccDistance;
            %CHROMA distance calculations
            chromaDistance = songDistance(chromaMeanStruct(i).mean,chromaMeanStruct(j).mean,chromaMeanStruct(i).cov,chromaMeanStruct(j).cov);
            chromaDistanceMatrix(i,j) = chromaDistance;
            chromaDistanceMatrix(j,i) = chromaDistance;   
        end
    end

    figure
    imagesc(mfccDistanceMatrix);
    colormap(jet)
    title('MFCC Distance Matrix')
    colorbar

    figure
    imagesc(chromaDistanceMatrix);
    title('Chroma Distance Matrix')
    colormap(jet)
    colorbar


    %initialize genre matrices
    mfccGenreMatrix = zeros(numGenres,numGenres);
    chromaGenreMatrix = mfccGenreMatrix;
    mfccMatrixTemp = zeros(numSongs,numGenres);
    chromaMatrixTemp = mfccMatrixTemp;


    %condense song matrix into genre matrix
    for j=1:numSongs
        for i=1:numGenres
            mfccMatrixTemp(j,i) = mean(mfccDistanceMatrix(j,songsPerGenre*(i-1)+1:songsPerGenre*i));
            chromaMatrixTemp(j,i) = mean(chromaDistanceMatrix(j,songsPerGenre*(i-1)+1:songsPerGenre*i));
        end
    end


    for j=1:numGenres
        for i=1:numGenres
            mfccGenreMatrix(j,i) = mean(mfccMatrixTemp(songsPerGenre*(i-1)+1:songsPerGenre*i,j));
            chromaGenreMatrix(j,i) = mean(chromaMatrixTemp(songsPerGenre*(i-1)+1:songsPerGenre*i,j));
        end
    end



    %display genre matrices
    figure
    imagesc(mfccGenreMatrix);
    colormap(jet)
    title('GENRE: MFCC Distance Matrix')
    colorbar


    figure
    imagesc(chromaGenreMatrix);
    title('GENRE: Chroma Distance Matrix')
    colormap(jet)
    colorbar


    %[mcmAvg,mcmStd] = classifySongs(mfccMeanStruct,mfccDistanceMatrix);
    %[ccmAvg,ccmStd] = classifySongs(chromaMeanStruct,chromaMeanMatrix);

end

