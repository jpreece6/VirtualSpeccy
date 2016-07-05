function img = GlassesSim(cam,overlay)
    % input: cam object
    % input: overlay image to draw over cam frame
    %
    % output: frame after image has been processed
    %
    % Description: Takes the next frame captured by the webcam device
    % and overlays the glasses image on over the detected area of the users
    % eyes.
    
    % Inialise
    maxSize = [480 640];
    overlay = imresize(overlay,[100 242]);
    imGlassesCpy = overlay;
    
    % Processing loop
    try

        % Get our data from the webcam device
        I = getdata(cam,1);
        flushdata(cam);

        % Detect eyes
        % From http://uk.mathworks.com/help/vision/ref/vision.cascadeobjectdetector-class.html#zmw57dd0e63131
        EyeDetect = vision.CascadeObjectDetector('EyePairBig');
        BB = step(EyeDetect,I);

        % Valid detection!? draw it!
        if size(BB) > 0
            
            % Paste the glasses at the boudning box location
            x = BB(2);
            y = round(BB(1) - (BB(3) * 0.2)); % shift left, ensures glasses are centered
            
			% scale the glasses with the bounding box to give a 'realistic' size
            width = round(BB(3) * 1.4); % increase width by 40%
            height = round(BB(4) * 1.3); % increase height by 30%
            
             % Resize glasses
            overlay = imGlassesCpy; % Get a refresh copy before resizing to prevent deterioration of the original image
            overlay = imresize(overlay,[height width]);

            if x > 0 && y > 0
                I = Paste(y,x,width,height,maxSize,overlay,I);
            end
        end
        
        % Output our processed image
        img = I;

    catch err
        rethrow(err);
    end

end