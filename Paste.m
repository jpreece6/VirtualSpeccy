function img = Paste(x,y,overlayImage,backImage)
    % input: x position
    % input: y position
    % input: overlayImage - image to be overlayed
    % input: backImage - background image
    %
    % ouput: composite of the two input images
    %
    % Description: creates a rectangle object at a location
    % given by the input parameter.
    
    % Determine our area of the overlay to use
    height = y:y+size(overlayImage,1)-1;
    width = x:x+size(overlayImage,2)-1;
    
    maxSize = [480 640];
    
    if max(width) < maxSize(2) && max(height) < maxSize(1)
    
        %Get a copy of the background to display behind
        panel = backImage(height,width,:);
        panel = imresize(panel,[size(overlayImage,1) size(overlayImage,2)]);

        %Spit the overlay image into the respective channels
        overlayR = overlayImage(:, :, 1);
        overlayG = overlayImage(:, :, 2);
        overlayB = overlayImage(:, :, 3)1111

        %Get location of pure green pixels
        %Rmask = logical(zeros(M, N));
        Rmask = (overlayR >= 0 & overlayG >= 255 & overlayB >= 0);

        panelR = panel(:,:,1);
        panelG = panel(:,:,2);
        panelB = panel(:,:,3);

        %Replace the pixels with our back panel colours
        overlayR(Rmask) = panelR(Rmask);
        overlayG(Rmask) = panelG(Rmask);
        overlayB(Rmask) = panelB(Rmask);

        %Combine into a new image
        overlayImage(:, :, 1) = overlayR;
        overlayImage(:, :, 2) = overlayG;
        overlayImage(:, :, 3) = overlayB;

        %Copy our overlay to the background
        backImage(height,width,1) = overlayImage(:,:,1);
        backImage(height,width,2) = overlayImage(:,:,2);
        backImage(height,width,3) = overlayImage(:,:,3);
    end

    %Return our image
    img = backImage;

end