function [ confusionMatrixAvg, confusionMatrixSD ] = classifySongs( songStruct,distanceMatrix )

    %initialize parameters
    numGenres = 6;
    songsPerGenre = 25;
    testSub = 5;
    kFold = 10;
    kNearest = 5;

    %initialize confusion matrix
    confusionMatrix = zeros(numGenres,numGenres,kFold);

    for n = 1:kFold   % to get total randomization, do this 10 times

        for m = 1:testSub    %do this 5 times

            %build test and training sections
            for i = 1:numGenres
                ix = randperm(songsPerGenre);
                testIX = ix(1:testSub);
                trainIX = ix(testSub+1:end);
                testSubStruct = songStruct((i-1)*songsPerGenre + testIX);
                trainSubStruct = songStruct((i-1)*songsPerGenre + trainIX);
                if i == 1        %initialize testStruct and trainStruct
                    testStruct = testSubStruct;     
                    trainStruct = trainSubStruct;
                else 
                    testStruct = [testStruct testSubStruct];      %concatenate each iteration
                    trainStruct = [trainStruct trainSubStruct];
                end
            end

            %get sizes of training and testing sets
            sizeTrainData = size(trainStruct,2);
            sizeTestData = size(testStruct, 2);

            %build an array to hold indices of training set
            trainIndices = zeros(1,sizeTrainData);
            for i = 1:sizeTrainData
                trainIndices(i) = trainStruct(i).index;
            end

            %guess genre for each song in test set
            for i=1:sizeTestData
                %get 5 shortest distances from distance matrix (Training set)
                testSongIndex = testStruct(i).index;
                trainIndices = [trainIndices testSongIndex];    %to include tester in modified train matrix
                trainMatrix = distanceMatrix(trainIndices,trainIndices);  %should be 121x121
                trainIndices = trainIndices(1:end-1);   %remove test index to avoid self-counting

                distanceArray = trainMatrix(sizeTrainData+1,1:sizeTrainData);   %extract row holding all distances to test point
                distanceData = zeros(2,size(distanceArray,2));  %create vector holding distance and corresponding indice from matrix
                distanceData(1,:) = distanceArray;
                distanceData(2,:) = trainIndices;
                [values,order] = sort(distanceData(1,:),'descend'); %descend because high values indication shorter distance
                distanceData = distanceData(:,order);               %put in descending order of distance values
                indicesShortestDist = distanceData(2,1:kNearest);   %take indices of first 5 values (5 shortest distances)

                %initialize genre classification array
                genreArray = zeros(1,6);

                %classify genre of song by summing votes:
                for k = 1:size(indicesShortestDist,2)
                    genre = indicesShortestDist(k);         %NOTE: this only works because our song order is based on genre, from classical(low) to world(high)
                    if (1 <= genre && genre <= 25)          %classical
                        genreArray(1) = genreArray(1) + 1;
                    elseif (26 <= genre && genre <= 50)     %electronic
                        genreArray(2) = genreArray(2) + 1;
                    elseif (51 <= genre && genre <= 75)     %jazz
                        genreArray(3) = genreArray(3) + 1;
                    elseif (76 <= genre && genre <= 100)    %rock
                        genreArray(4) = genreArray(4) + 1;
                    elseif (101 <= genre && genre <= 125)   %metal
                        genreArray(5) = genreArray(5) + 1;
                    else
                        genreArray(6) = genreArray(6) + 1;  %world
                    end
                end

                [M,I] = max(genreArray(:)); % I is index of most likely genre

                %increment corresponding element in confusion matrix
                confusionMatrix(songStruct(testSongIndex).genre,I,n) = confusionMatrix(songStruct(testSongIndex).genre,I,n) + 1;

            end 
        end
    end

    confusionMatrixAvg = mean(confusionMatrix,3);  %average 10 iterations of computation

    confusionMatrixSD = std(confusionMatrix,0,3);  %find the Std Dev.  (weight = normal)

end
    



