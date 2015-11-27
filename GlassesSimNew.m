%% TODO:
%
% GUI
% Dynamic resize of glasses when user gets closer or further away
% Removal of outline from glasses
%   - Pre-processing? (choose colour and store)
% Glasses switch out
% Prevent exception being thrown when overlay is larger than the image feed


%% Init
DEBUG = true;
frameNum = 0;
resized = false;

im = imread('eyeglasses.jpg');
im = imresize(im,[100 200]);
%% Webcam
imaqreset;
cam = videoinput('winvideo', 1, 'YUY2_640x480');

% Set device properties
cam.FramesPerTrigger = 10;
cam.ReturnedColorSpace = 'rgb';
cam.TriggerRepeat = inf;

%% Processing loop
try
 
    start(cam);
    
    % Create the initial preview window
    h = imshow(zeros(480,640));
    hold on;
    
    figure(1);
    
    while islogging(cam)
        
        %Get our data from the webcam device
        I = getdata(cam,1);
        flushdata(cam);
        
        % Detect eyes
        EyeDetect = vision.CascadeObjectDetector('EyePairBig');
        BB = step(EyeDetect,I);
        
        % Draw a trace around the eyes
        if DEBUG == true
            h1 = DebugTrace(BB);
        end

        if size(BB) > 0
            
            if resized == false
                %im = imresize(im,[(BB(4) + 20) BB(3)]);
                resized = true;
            end
            
            x = BB(2);
            y = BB(1);
            if x > 0 && y > 0
                I = Paste(y,x,im,I);
            end
        else
            resized = false;
        end
        
        frameNum = frameNum + 1;
        
        %Draw to the screen if we have a handle to do so
        if isgraphics(h)
            set(h,'cData',I);
            drawnow;
        else
            %Otherwise stop and exit
            stop(cam);
        end
        
        if DEBUG == true
            delete(h1);
        end
    end
    
catch err
    stop(cam);
    imaqreset;
    rethrow(err);
end
%% Clean up
stop(cam);
imaqreset;