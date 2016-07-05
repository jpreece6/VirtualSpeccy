%% Function
function varargout = GlassesSimGUI(varargin)
% GlassesSimGUI MATLAB code for GlassesSimGUI.fig
%      GlassesSimGUI, by itself, creates a new GlassesSimGUI or raises the existing
%      singleton*.
%
%      H = GlassesSimGUI returns the handle to a new GlassesSimGUI or the handle to
%      the existing singleton*.
%
%      GlassesSimGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GlassesSimGUI.M with the given input arguments.
%
%      GlassesSimGUI('Property','Value',...) creates a new GlassesSimGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GlassesSimGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GlassesSimGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GlassesSimGUI

% Last Modified by GUIDE v2.5 04-Dec-2015 00:42:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GlassesSimGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GlassesSimGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GlassesSimGUI is made visible.
function GlassesSimGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GlassesSimGUI (see VARARGIN)

% Choose default command line output for GlassesSimGUI
handles.output = hObject;

% Setup webcam device and clear the video screen
cam = videoinput('winvideo', 1, 'YUY2_640x480');
hImage = image(zeros(480,640),'Parent',handles.vidView);

% Create new handles
handles.cam = cam;
handles.frame = hImage;

%app properties
handles.debug = false;
handles.displayFrameRate = false;

% Update handles structure
guidata(hObject, handles);

% Initialse the webcam properties
if (handles.displayFrameRate == true)
    handles.cam.FramesPerTrigger = 50; % Get 50 so we can process the frame rate
else
    handles.cam.FramesPerTrigger = 1; % Speed up performance if we don't maybe a fraction of a second.....
end
handles.cam.ReturnedColorSpace = 'rgb'; % Only return an RGB image 
handles.cam.TriggerRepeat = inf; % Capture frames indefinately
handles.cam.FramesAcquiredFcnCount = 1; % Trigger on each frame
handles.cam.FramesAcquiredFcn = {@ProcessFrame, hObject}; % Subscribe to new frame event

% Start capturing and displaying the output
start(handles.cam);
preview(handles.cam,handles.frame);

% UIWAIT makes GlassesSimGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GlassesSimGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in itemList.
function itemList_Callback(hObject, eventdata, handles)
% hObject    handle to itemList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns itemList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from itemList

% Get the file name and load the image into memory
contents = cellstr(get(hObject,'String'));
fileName = contents{get(hObject,'Value')};
newOverlay = imread(strcat(handles.pathGlasses, fileName));
handles.overlay = newOverlay;
guidata(hObject, handles); % Update the app data cache

% --- Executes during object creation, after setting all properties.
function itemList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to itemList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Define output paths
handles.ext = '*.jpg'; % Extension to look for
handles.pathGlasses = 'glasses/'; % Location of overlays to load
handles.pathSnaps = 'snaps/'; % Output location for taking snaps
handles.imageDump = 'testing/'; % Output location when saving every frame

% Get all jpg files from our current directory
 for file = dir(strcat(handles.pathGlasses, handles.ext));
    
    % Load the first image into the overlay var
    if ~isfield(handles,'overlay')
        name = file.name;
        handles.overlay = imread(strcat(handles.pathGlasses, name));
    end
    
    set(hObject,'string',{file.name});
 end
 
 % Update app data 
 guidata(hObject, handles);

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnStopCapture.
function btnStopCapture_Callback(hObject, eventdata, handles)
% hObject    handle to btnStopCapture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stop capturing and clear the screen
stop(handles.cam);
handles.frame = image(zeros(480,640),'Parent',handles.vidView);
set(handles.vidView,'ytick',[],'xtick',[]);

% --- Executes on button press in btnStartCapture.
function btnStartCapture_Callback(hObject, eventdata, handles)
% hObject    handle to btnStartCapture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Zero the screen so we start fresh
handles.frame = image(zeros(480,640),'Parent',handles.vidView);
guidata(hObject,handles); % Save the frame state - prevents the ProcessFrame from miss firing

% Start capturing images and display to screen
start(handles.cam);
preview(handles.cam,handles.frame);

% --- Executes on button press in btnTakeSnapshot.
function btnTakeSnapshot_Callback(hObject, eventdata, handles)
% hObject    handle to btnTakeSnapshot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Generate a new file name with a time stamp and write to disk
saveFrame(handles.frame, handles.pathSnaps);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Should we display the frame rate?
% From http://uk.mathworks.com/help/imaq/examples/determining-the-rate-of-acquisition.html
if (handles.displayFrameRate == true)
    % Get frame info
   [frames, timeStamp] = getdata(handles.cam);
                       
    % Graph frames vs time.
    figure;
    plot(timeStamp,'x')
    xlabel('Frame Index')
    ylabel('Time(s)') 

    % The average time difference can also be determined to compare to the 
    % expected acquisition rate. 

    % Find the time difference between frames.
    diffFrameTime = diff(timeStamp);

    % Graph the time differences.
    plot(diffFrameTime, 'x');
    xlabel('Frame Index')
    ylabel('Time Difference(s)')
    ylim([0 .12])
    
    % Output average difference and expiermental FPS
    avgTime = mean(diffFrameTime)
    expRate = 1/avgTime 
end

% Stop capturing images
stop(handles.cam);

% Close the window
delete(hObject);

% --- Executes when a new frame is captured by the webcam device
function ProcessFrame(obj, eventData, hObject, handles)
% obj        handle of the source function
% eventData  data passed to the event
% hObject    handle of the main figure window
% handles    structure with handles and user data (see GUIDATA)

    if ishandle(hObject)
        % Reload the app data so we're up to date
        handles = guidata(hObject);
        if isgraphics(handles.frame) % Check we have valid objects
            if isobject(handles.cam)
                % Draw our processed frame to the screen
                frame = GlassesSim(handles.cam,handles.overlay);      
                
                % Set the window to draw the processed frame
                set(handles.frame,'Cdata',frame);
				
				% If debugging write the current frame to disk
				if (handles.debug == true)             
                    saveFrame(handles.frame, handles.imageDump);
                end
            end
        end
        
        % Don't wait to update
        drawnow;
    end

% --- Saves a frame to the disk
function saveFrame(frame, path) 
% frame      frame to save to disk
% path  	 destination path to save files

% generate a new file name with a time stamp
fileName = strrep(sprintf('snap_%s_%s.jpg',datestr(now,'yyyy-mm-dd'),datestr(now,'HH:MM:SS.FFF')),':','_');
I = get(frame,'cData');
imwrite(I,strcat(path, fileName)); % write frame to disk