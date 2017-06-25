function [ confusionMatrixMean, confusionMatrixStd ] = classifySVM( songStruct,distanceMatrix )

    %use 'cell' data type to hold info (different from K_Cluster)

    % constants
    numGenres = 6;
    numSongs = 25;    %per Genre
    totalSongs = numGenres * numSongs;
    
    kFold = 10; % 10 total loops
    subSize = 5; % 5 songs in subset

    
    % initialize confusion matrix 
    confusionMatrix = zeros(numGenres, numGenres, kFold);
    
    % create list of class types (genre possibility of each song), must be
    % cell string data type
    classTypes = cell(150,1);
    for i= 1:totalSongs
        if (i > 0 && i <= 25)        
            classTypes(i) = cellstr('classical');
        elseif (i > 25 && i <= 50)   
            classTypes(i) = cellstr('electronic');
        elseif (i > 5 && i <= 75)   
            classTypes(i) = cellstr('jazz');
        elseif ( i > 75 && i <= 100)  
            classTypes(i) = cellstr('punk');
        elseif ( i > 100 && i <= 125) 
            classTypes(i) = cellstr('rock');
        elseif (i > 125 && i <= 150)
            classTypes(i) = cellstr('world');
        end        
    end
    
    for m = 1:kFold
        for n = 1:subSize
            
            % space for indices
            indicesTrain = zeros(1,totalSongs*(subSize-1)/subSize);
            indicesTest = zeros(1, totalSongs/subSize);
            
            % get 20 training songs and 5 test songs
            for i = 0:numGenres-1
                indicesTemp = randperm(numSongs) + i*numSongs;      %get to genre access point
                indicesTestTemp = indicesTemp(1:subSize);           %truncate after that to just get 5
                indicesTrainingTemp = indicesTemp(subSize+1:numSongs);  %the rest are the training indices
                
                indicesTest(i*subSize+1:i*subSize+subSize) = indicesTestTemp;
                indicesTrain(i*(numSongs-subSize)+1:i*(numSongs-subSize)+(numSongs-subSize)) = indicesTrainingTemp;
            end                       
        
            % make SVM multiclass model using ECOC (bc SVM can only do 2
            % seperations at a time and we have to categorize 6
            modelSVM = fitcecoc(distanceMatrix(indicesTrain,:),classTypes(indicesTrain));
            
            % for every test array      
            for i = 1:totalSongs/subSize
                testIndex = indicesTest(i);           
                genre = predict(modelSVM,distanceMatrix(testIndex,:));
                if (string(genre) == 'classical')
                    g = 1;
                elseif (string(genre) == 'electronic')
                    g = 2;
                elseif (string(genre) == 'jazz')
                    g = 3;
                elseif (string(genre) == 'punk')
                    g = 4;                
                elseif (string(genre) == 'rock')
                    g = 5;
                else %world
                    g = 6;
                end
                
                %put result into confusion matrix and sum w prior value
                confusionMatrix(songStruct(testIndex).genre, g, m) = confusionMatrix(songStruct(testIndex).genre, g, m) + 1;
                                    
            end
            
        end
    end
    
    confusionMatrixMean = mean(confusionMatrix,3);
    confusionMatrixStd = std(confusionMatrix,0,3);

end
