function data = DataLoader(dataPath, organDataset)
%% This function is used to load a dataset from path, takes as input: 
% dataPath: the path of the dataset
% organDataset: the dataset

    % Load from local or MATLAB Online Driver
    fprintf('Loading dataset from: %s\n', dataPath);
    fprintf('Selected organ: %s\n', organDataset);
    
    % Construct dataset path
    datasetPath = fullfile(dataPath, "DATA", organDataset);
    jsonFile = fullfile(datasetPath, 'dataset.json'); 
    
    % Load JSON file (possiamo anche eliminare questa parte IMO)
    if isfile(jsonFile)
        jsonData = jsondecode(fileread(jsonFile)); % Read and decode JSON
    else
        error('JSON file not found: %s', jsonFile);
    end
    
    % Initialize output structure (da commentare meglio IMO)
    data = struct();
    data.name = jsonData.name; 
    data.description = jsonData.description; 
    data.reference = jsonData.reference;
    data.license = jsonData.licence;
    data.tensorImageSize = jsonData.tensorImageSize;
    data.labels = jsonData.labels;

    % vectors that will contain training and test data
    data.training = []; 
    data.test = [];
    
    % Load training data
    fprintf('Loading training data...\n');

    for i = 1:length(jsonData.training)
        imagePath = fullfile(datasetPath, jsonData.training(i).image);
        labelPath = fullfile(datasetPath, jsonData.training(i).label);
        
        % Check if the files exist
        if ~isfile(imagePath)
            error('Image file not found: %s', imagePath);
        end
        if ~isfile(labelPath)
            error('Label file not found: %s', labelPath);
        end
        
        % Load image and label
        image = niftiread(imagePath);
        label = niftiread(labelPath);
        
        % Store in the training data array
        data.training(end+1).image = image;
        data.training(end).label = label;
        data.training(end).imagePath = imagePath;
        data.training(end).labelPath = labelPath;
    end
    
    % Load test data
    fprintf('Loading test data...\n');
    for i = 1:length(jsonData.test)
        testImagePath = fullfile(datasetPath, jsonData.test{i});
        
        % Check if the file exists
        if ~isfile(testImagePath)
            error('Test image file not found: %s', testImagePath);
        end
        
        % Load test image
        testImage = niftiread(testImagePath);
        
        % Store in the test data array
        data.test(end+1).image = testImage;
        data.test(end).imagePath = testImagePath;
    end
    
    fprintf('Dataset successfully loaded.\n');
end