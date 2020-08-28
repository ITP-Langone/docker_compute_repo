function varargout = MROptimum(varargin)
% MROPTIMUM MATLAB code for MROptimum.fig
%      MROPTIMUM, by itself, creates a new MROPTIMUM or raises the existing
%      singleton*.
%
%      H = MROPTIMUM returns the handle to a new MROPTIMUM or the handle to
%      the existing singleton*.
%
%      MROPTIMUM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MROPTIMUM.M with the given input arguments.
%
%      MROPTIMUM('Property','Value',...) creates a new MROPTIMUM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MROptimum_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MROptimum_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MROptimum

% Last Modified by GUIDE v2.5 10-Apr-2018 17:04:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MROptimum_OpeningFcn, ...
    'gui_OutputFcn',  @MROptimum_OutputFcn, ...
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


% --- Executes just before MROptimum is made visible.
function MROptimum_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MROptimum (see VARARGIN)

% Choose default command line output for MROptimum
handles.output = hObject;

if ~isdeployed
    addpath(genpath('code'));
end

axis(handles.Logo);
imshow(fullfile('icons','logo.jpg'));
%instanciated the webreader
handles.WR=WebReport('https://cai2r.000webhostapp.com/','Q');
%login and 



handles.tgroup = uitabgroup('Parent', handles.figure1,'TabLocation', 'top');
handles.tab1 = uitab('Parent', handles.tgroup, 'Title', 'MROPTGUI');
handles.tab2 = uitab('Parent', handles.tgroup, 'Title', 'converterTab');
handles.tab3 = uitab('Parent', handles.tgroup, 'Title', 'loginTab');

%Place panels into each tab
set(handles.MROPTGUI,'Parent',handles.tab1)
set(handles.converterTab,'Parent',handles.tab2)
set(handles.loginTab,'Parent',handles.tab3)

%Reposition each panel to same location as panel 1
set(handles.MROPTGUI,'position',get(handles.TabA,'position'));
set(handles.converterTab,'position',get(handles.TabA,'position'));
set(handles.loginTab,'position',get(handles.TabA,'position'));


handles.User=recognizeMROPTuser(handles.WR);
handles.User.saluta();
set(handles.UserName,'String',handles.User.Name);
set(handles.UserSurname,'String',handles.User.Surname);
set(handles.UserEmail,'String',handles.User.Email);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MROptimum wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MROptimum_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in setSignal.
function setSignal_Callback(hObject, eventdata, handles)
% hObject    handle to setSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[f,p] = uigetfile('*.*','Select the Signal raw file');

handles.INPUT.SignalFileName=fullfile(p,f);
guidata(hObject, handles);

% --- Executes on button press in setNoise.
function setNoise_Callback(hObject, eventdata, handles)
% hObject    handle to setNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f,p] = uigetfile('*.*','Select the Noise raw file');

handles.INPUT.NoiseFileName=fullfile(p,f);


a=MROPTSNRCalculatorKellman();
a.setNoiseFilename(handles.INPUT.NoiseFileName);
b=a.getNoiseCovariance;
a.plotNoiseCovarianceMatrix;
promptfeatures(abs(b.'));


guidata(hObject, handles);
% --- Executes on button press in setRSS.
function setRSS_Callback(hObject, eventdata, handles)
% hObject    handle to setRSS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of setRSS

handles.CombiningMethod=MROPTArrayCombiningMethodRSS(handles.INPUT.SignalFileName,handles.INPUT.NoiseFileName);
guidata(hObject, handles);


% --- Executes on button press in showSNR.
function showSNR_Callback(hObject, eventdata, handles)
% hObject    handle to showSNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=handles.CombiningMethod.getSNR();
figure;
imshow(a,[]);

guidata(hObject, handles);


% --- Executes on button press in setROI.
function setROI_Callback(hObject, eventdata, handles)
% hObject    handle to setROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in siemensToH5.
function siemensToH5_Callback(hObject, eventdata, handles)
% hObject    handle to siemensToH5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
H5convert('SI')


% --- Executes on button press in philipstoH5.
function philipstoH5_Callback(hObject, eventdata, handles)
% hObject    handle to philipstoH5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
H5convert('PH')


% --- Executes on button press in coilFeed.
function coilFeed_Callback(hObject, eventdata, handles)
% hObject    handle to coilFeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feedbackme(2,0,handles);

% --- Executes on button press in globalFeed.
function globalFeed_Callback(hObject, eventdata, handles)
% hObject    handle to globalFeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feedbackme(0,0,handles);

% --- Executes on button press in inputFeed.
function inputFeed_Callback(hObject, eventdata, handles)
% hObject    handle to inputFeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feedbackme(1,0,handles);

% --- Executes on button press in convertsFeed.
function convertsFeed_Callback(hObject, eventdata, handles)
% hObject    handle to convertsFeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feedbackme(1,1,handles);


% --- Executes on button press in setRSSPSI.
function setRSSPSI_Callback(hObject, eventdata, handles)
% hObject    handle to setRSSPSI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of setRSSPSI

handles.CombiningMethod=MROPTArrayCombiningMethodRSSPSI(handles.INPUT.SignalFileName,handles.INPUT.NoiseFileName);
guidata(hObject, handles);


% --- Executes on button press in setOPT.
function setOPT_Callback(hObject, eventdata, handles)
% hObject    handle to setOPT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of setOPT

handles.CombiningMethod=MROPTArrayCombiningMethodOPT(handles.INPUT.SignalFileName,handles.INPUT.NoiseFileName);
handles.CombiningMethod.setSimpleSense(1);
guidata(hObject, handles);
