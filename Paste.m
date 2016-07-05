function img = Paste(x,y,width,height,maxSize,overlayImage,backImage)
    % input: x position
    % input: y position
    % input: maxSize - the bounds of the area we can draw in
    % input: overlayImage - image to be overlayed
    % input: backImage - background image
    %
    % ouput: composite of the two input images
    %
    % Description: creates a rectangle object at a location
    % given by the input parameter.
    
    % Determine our area of the overlay to use
    width = x:((x+width)-1);
    height = y:((y+height)-1);
    
    % Prevents 'Index exceeds matrix dimensions' error
    % this is caused when we try to draw outside the screen bounds
    if max(width) < maxSize(2) && max(height) < maxSize(1)
    
        % Get a copy of the background to display behind
        panel = backImage(height,width,:);
        panel = imresize(panel,[size(overlayImage,1) size(overlayImage,2)]);

        % Spit the overlay image into the respective channels
        overlayR = overlayImage(:, :, 1);
        overlayG = overlayImage(:, :, 2);
        overlayB = overlayImage(:, :, 3);

        % Get location of green pixels
        % From https://www.quora.com/How-do-you-swap-the-color-of-pixels-in-MATLAB
        Rmask = (overlayR <= 100 & overlayG >= 80 & overlayB <= 100);

        panelR = panel(:,:,1);
        panelG = panel(:,:,2);
        panelB = panel(:,:,3);

        % Replace the pixels with our back panel colours
        overlayR(Rmask) = panelR(Rmask);
        overlayG(Rmask) = panelG(Rmask);
        overlayB(Rmask) = panelB(Rmask);

        % Combine into a new image
        overlayImage(:, :, 1) = overlayR;
        overlayImage(:, :, 2) = overlayG;
        overlayImage(:, :, 3) = overlayB;

        % Copy our overlay to the background
        backImage(height,width,1) = overlayImage(:,:,1);
        backImage(height,width,2) = overlayImage(:,:,2);
        backImage(height,width,3) = overlayImage(:,:,3);
    end

    % Return our image
    img = backImage;

end