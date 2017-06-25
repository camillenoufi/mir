function [  ] = genreHistogram( distMatrix,genre )

    if (strcmp(genre,'classical'))          %%extract genre
        distMatrix = distMatrix(1:25,1:25);
    elseif (strcmp(genre,'electronic'))
        distMatrix = distMatrix(26:50,26:50);
    elseif (strcmp(genre,'jazz'))
        distMatrix = distMatrix(51:75,51:75);
    elseif (strcmp(genre,'metal'))
        distMatrix = distMatrix(76:100,76:100);
    elseif (strcmp(genre,'rock'))
        distMatrix = distMatrix(101:125,101:125);
    elseif (strcmp(genre,'world'))
        distMatrix = distMatrix(126:150,126:150);
    end

    Dvec = reshape(distMatrix,25*25,1);    %%turn into array
    numBins = 10;

    figure
    hist(Dvec,numBins);
    xlabel('Distance Correlation (1=high, 0=low)')
    ylabel('Number of Occurences')
    title(genre)

end

