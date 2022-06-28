clear; clc;

% load required package for Octave
try
  pkg load image;
  pkg load statistics;
  isOctave = true;
catch
  isOctave = false;
end

% Select dialog for testing
testList = {'1) Randomly select an IR image for testing', ...
            '2) Randomly select a batch of IR images for testing', ...
            '3) Process all sample images and count the average execution time', ...
            '4) Image processing time at different scales', ...
            '5) Test on Color image from FLIR dataset', ...
            '6) Test on Color image from BSDS500'};

% sample folder
flir_dir = [pwd '\FLIR-samples\'];
ir_imgs = dir(flir_dir);

[idx, tf] = listdlg('PromptString',{'Select one item to test.', ...
                    ''}, 'SelectionMode','single', ...
                    'ListSize',[500,200], ...
                    'Name', 'Experiment on Stylized Edge Extraction base on OG.', ...
                    'InitialValue',1, ...
                    'OKString','Select item to test', ...
                    'CancelString','No Selection', ...
                    'ListString',testList);

try
  % local FLIR dataset folder
  flir_dir = [pwd '\FLIR-samples\'];
  ir_imgs = dir(flir_dir);
  if tf
    switch idx
      case {1,2,3}
        % batch number
        if idx==1
          N = 1;
        elseif idx==2
          N = 5;
        else
          N = length(ir_imgs)-2;
        end
        ba_imgs = randsample(ir_imgs(3:end),N);
        bse_dir = [pwd '\FLIR-batch-results\'];
        if ~exist(bse_dir, "dir")
            mkdir(bse_dir);
        end
        delete([bse_dir '*.jpeg']);

        % Stylized edge extraction time
        t1 = zeros(1,N);
        % Save the adptive threshold
        tha = cell(1,N);

        % Canny edge execution time
        t2 = zeros(1,N);
        % Save the hard-coded threshold, in Canny, lowthreshold = 0.4 * highthreshold,
        % and manually set the non-edge percentage to 70%.
        ths = cell(1,N);

        for i=1:N
            I = im2double(imread([flir_dir, ba_imgs(i).name]));
            tic;
            [seog, lth] = stylized_edge_og(I,2);
            t1(i) = toc;
            tha{i} = lth;
            tic;
            [ec,th] = edge(I, 'Canny');
            ths{i} = th;
            t2(i) = toc;
            % Save result image
            imwrite(I, [bse_dir ba_imgs(i).name]);
            imwrite(seog, [bse_dir 'se-' ba_imgs(i).name]);
            imwrite(ec, [bse_dir 'ec-' ba_imgs(i).name]);
        end

        % Average time
        tm1 = sum(t1)/N;
        disp(['SEOG: Average time of ', num2str(N), ' images:', num2str(tm1)]);

        tm2 = sum(t2)/N;
        disp(['Canny: Average time of ', num2str(N), ' images:', num2str(tm2)]);

        % open the result folder
        if isOctave
          open(bse_dir);
        else
          winopen(bse_dir);
        end
      case 4
        % Randomly choose 9 infrared images to compose a large image
        imgs = randsample(ir_imgs(3:end), 9);
        A = imread([flir_dir, imgs(1).name]);
        [~,~,c] = size(A);
        if c==1
            Im = im2double(A);
        else
            Im = im2double(rgb2gray(A));
        end

        for i=2:9
            A = imread([flir_dir, imgs(i).name]);
            if c==1
                Im(:,:,i) = im2double(A);
            else
                Im(:,:,i) = im2double(rgb2gray(A));
            end
        end

        Ix = [Im(:,:,1) Im(:,:,2) Im(:,:,3);
              Im(:,:,4) Im(:,:,5) Im(:,:,6);
              Im(:,:,7) Im(:,:,8) Im(:,:,9);];

        tic;
        stylized_edge_og(Ix);
        toc;

        [h,w] = size(Ix);

        % Center points of `Ix`
        x0 = round((w+1)/2);
        y0 = round((h+1)/2);

        n = 20;
        rxn = floor(w/n/2);
        ryn = floor(h/n/2);

        t1 = zeros(1,n);

        for i=1:20
            Im = Ix(max(1,y0-i*ryn):min(y0+i*ryn,h), max(1,x0-i*rxn):min(x0+i*rxn,w));
            tic;
            stylized_edge_og(Im,1,2);
            t1(i) = toc;
        end

        plot(1:20,t1,'-r', 'LineWidth', 2);
        hold on;

        t2 = zeros(1,n);
        for i=1:20
            Im = Ix(max(1,y0-i*ryn):min(y0+i*ryn,h), max(1,x0-i*rxn):min(x0+i*rxn,w));
            tic;
            stylized_edge_og(Im,1,3);
            t2(i) = toc;
        end
        plot(1:20,t2,'-g', 'LineWidth', 2);

        t3 = zeros(1,n);
        xts = cell(1,n);
        for i=1:20
            Im = Ix(max(1,y0-i*ryn):min(y0+i*ryn,h), max(1,x0-i*rxn):min(x0+i*rxn,w));
            sz = size(Im);
            xts{i} = [num2str(sz(1)) '\times' num2str(sz(2))];
            tic;
            stylized_edge_og(Im,1,4);
            t3(i) = toc;
        end
        plot(1:20,t3,'-b', 'LineWidth', 2);

        title('Time profile of multiscale image processing', 'FontName', 'Times New Roman');
        xlabel('Image scale (h \times w)', 'FontName', 'Times New Roman');
        xticklabels(xts);
        ylabel('Execution time (s)', 'FontName', 'Times New Roman');
        legend('Sample 1 (r_1=1, r_2=2)', 'Sample 2 (r_1=1, r_2=3)', 'Sample 3 (r_1=1, r_2=4)');

        hold off;
      case 5
        rgb_dir = [pwd '\RGB\'];
        imgs = dir(rgb_dir);
        delete([rgb_dir 'se-*.jpg']);
        % Randomly choose 1 color images to test
        img = randsample(imgs(3:end), 1);
        A = imread([rgb_dir img.name]);

        % [~,n] = max([std2(A(:,:,1)), std2(A(:,:,2)), std2(A(:,:,3))]);
        % I = im2double(A(:,:,n));

        I = im2double(rgb2gray(A));

        tic;
        seog = stylized_edge_og(I);
        toc;

        % save results
        imwrite(seog, [rgb_dir 'se-' img.name]);

        % Show compared images
        figure("Name", "Show the compared results");
        subplot(1,2,1);
        imshow(A);
        title('Input RGB image', 'FontName', 'Times New Roman');
        subplot(1,2,2);
        imshow(seog);
        title('Stylized Edge', 'FontName', 'Times New Roman');
      case 6
        rgb_dir = [pwd '\BSDS500-samples\'];
        imgs = dir(rgb_dir);

        % Randomly choose 1 color images to test
        img = randsample(imgs(3:end-1), 1);
        name = img.name;
        A = imread([rgb_dir name]);

        % RGB to gray
        I = im2double(rgb2gray(A));

        tic;
        seog = stylized_edge_og(I);
        toc;

        % load ground truth contours map to compare
        load([rgb_dir 'groundTruth\' name(1:end-4) '.mat']);

        % choose the most detailed Boundaries
        [~, m] = max([mean2(groundTruth{1}.Boundaries) ...
            mean2(groundTruth{2}.Boundaries) ...
            mean2(groundTruth{3}.Boundaries) ...
            mean2(groundTruth{4}.Boundaries) ...
            mean2(groundTruth{5}.Boundaries)]);

        imagesc([seog groundTruth{m}.Boundaries]);
        % Show compared images
        figure("Name", "Show the compared results");
        subplot(1,3,1);
        imshow(A);
        title('Input RGB image', 'FontName', 'Times New Roman');
        
        subplot(1,3,2);
        imshow(seog);
        title('Stylized Edge', 'FontName', 'Times New Roman');
        
        subplot(1,3,3);
        imshow(groundTruth{m}.Boundaries);
        title('Ground Truth Conturs', 'FontName', 'Times New Roman');
      otherwise
        disp('Invalid selection!');
    end
  end
catch
  disp('We have implemented this source code compatible with MATLAB and Octave, but before our paper is accepted, the Octave version cannot be tested, because the core functions are in the form of pcode, but Octave does not support it yet.');
end
