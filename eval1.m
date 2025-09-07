%% 7 -  Sep - 2025 
% Samik Banerjee
% Evaluation for the images for variouys techniques
% F1 score for the methods used in comparison

%% Read paths
img_folder = 'Test_tiles';
img_files = dir(fullfile("Test_tiles/", "*.tiff"));

GT_folder = 'manual_GT_centroids';
GMM_folder = 'GMM_centers_test_tiles';
m1_folder = 'Model1_centroids';
m2_folder = 'Model2_centroids';

TP_tot_gmm = 0; TP_tot_m1 = 0; TP_tot_m2 = 0;
FP_tot_gmm = 0; FP_tot_m1 = 0; FP_tot_m2 = 0;
FN_tot_gmm = 0; FN_tot_m1 = 0; FN_tot_m2 = 0;


for i = 1 : length(img_files)
    
    % Read images
    img = imread(fullfile("Test_tiles/", img_files(i).name));

    [~, img_name, ext] = fileparts(img_files(i).name);

    if exist(fullfile(GT_folder, img_name + ".csv"))
        
        % Read centers
        GT_cen = table2array(readtable(fullfile(GT_folder, ...
            img_name + ".csv")));
        GMM_cen = table2array(readtable(fullfile(GMM_folder, ...
            img_name + "_centroid.csv")));
        m1_cen = table2array(readtable(fullfile(m1_folder, ...
            img_name + "_centroid.csv")));
        m2_cen = table2array(readtable(fullfile(m2_folder, ...
            img_name + "_centroid.csv")));

        %% Evaluition using F1 metrics and accumulation of TP, FP, FN

        c_dist = 7.51; % for all centers with 15 pixels from the GT
        
        % For GMM - proposed technique
        D = min(pdist2(GT_cen, GMM_cen));
        TP = sum(D < c_dist); % if a GT center exists within the radius 
        FP = length(GMM_cen) - TP; % all centers outside the radius
        FN = length(GT_cen) - TP; % all centers in GT that is missed
        prec = TP / (TP + FP); % Precision
        rec = TP / (TP + FN); % Recall
        f1(i,1) = 2 * (prec * rec) / (prec + rec); % f1_score
        TP_tot_gmm = TP + TP_tot_gmm; % TP Accumulation
        FP_tot_gmm = FP + FP_tot_gmm; % FP Accumulation
        FN_tot_gmm = FN + FN_tot_gmm; % FN Accumulation
        
        % For Model 1 (MEDIAR)
        D = min(pdist2(GT_cen, m1_cen));
        TP = sum(D < c_dist);
        FP = length(m1_cen) - TP;
        FN = length(GT_cen) - TP;
        prec = TP / (TP + FP);
        rec = TP / (TP + FN);
        f1(i,2) = 2 * (prec * rec) / (prec + rec);
        TP_tot_m1 = TP + TP_tot_m1;
        FP_tot_m1 = FP + FP_tot_m1;
        FN_tot_m1 = FN + FN_tot_m1;
        
        % For Model 2 (Multio-stream Segmentation)
        D = min(pdist2(GT_cen, m2_cen));
        TP = sum(D < c_dist);
        FP = length(m2_cen) - TP;
        FN = length(GT_cen) - TP;
        prec = TP / (TP + FP);
        rec = TP / (TP + FN);
        f1(i,3) = 2 * (prec * rec) / (prec + rec);
        TP_tot_m2 = TP + TP_tot_m2;
        FP_tot_m2 = FP + FP_tot_m2;
        FN_tot_m2 = FN + FN_tot_m2;

    end


    %% Show detections


    % imshow(img); hold on;
    % plot(GT_cen(:,1), GT_cen(:,2), 'r*');
    % plot(GMM_cen(:,1), GMM_cen(:,2), 'y*');
    % plot(m1_cen(:,1), m1_cen(:,2), 'g*');
    % plot(m2_cen(:,1), m2_cen(:,2), 'm*');
    %
end

%% mean of alll F1-scores
f_mean = mean(f1);

%% Accumulated average of F1-scores
% For GMM - Proposed
prec = TP_tot_gmm / (TP_tot_gmm + FP_tot_gmm);
rec = TP_tot_gmm / (TP_tot_gmm + FN_tot_gmm);
f1_tot_gmm = 2 * (prec * rec) / (prec + rec);

% For Model 1 (MEDIAR)
prec = TP_tot_m1 / (TP_tot_m1 + FP_tot_m1);
rec = TP_tot_m1 / (TP_tot_m1 + FN_tot_m1);
f1_tot_m1 = 2 * (prec * rec) / (prec + rec);

% For Model 2 (Multio-stream Segmentation)
prec = TP_tot_m2 / (TP_tot_m2 + FP_tot_m2);
rec = TP_tot_m2 / (TP_tot_m2 + FN_tot_m2);
f1_tot_m2 = 2 * (prec * rec) / (prec + rec);
