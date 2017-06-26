function varargout = mibStereologyGUI(varargin)
% MIBSTEREOLOGYGUI MATLAB code for mibstereologygui.fig
%      MIBSTEREOLOGYGUI, by itself, creates a new MIBSTEREOLOGYGUI or raises the existing
%      singleton*.
%
%      H = MIBSTEREOLOGYGUI returns the handle to a new MIBSTEREOLOGYGUI or the handle to
%      the existing singleton*.
%
%      MIBSTEREOLOGYGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIBSTEREOLOGYGUI.M with the given input arguments.
%
%      MIBSTEREOLOGYGUI('Property','Value',...) creates a new MIBSTEREOLOGYGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mibStereologyGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mibStereologyGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (C) 10.02.2017 Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% part of Microscopy Image Browser, http:\\mib.helsinki.fi 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
%

% Last Modified by GUIDE v2.5 10-Feb-2017 21:18:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mibStereologyGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mibStereologyGUI_OutputFcn, ...
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
end

% --- Executes just before mibstereologygui is made visible.
function mibStereologyGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mibstereologygui (see VARARGIN)

% obtain controller
handles.winController = varargin{1};

% Choose default command line output for mibChildGUI
handles.output = hObject;

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mibstereologygui wait for user response (see UIRESUME)
% uiwait(handles.mibStereologyGUI);
end

% --- Outputs from this function are returned to the command line.
function varargout = mibStereologyGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in closeBtn.
function closeBtn_Callback(hObject, eventdata, handles)
handles.winController.closeWindow();
end

% --- Executes when user attempts to close mibStereologyGUI.
function mibStereologyGUI_CloseRequestFcn(hObject, eventdata, handles)
handles.winController.closeWindow();
end

% --- Executes on button press in generateGrid.
function generateGrid_Callback(hObject, eventdata, handles)
handles.winController.generateGrid_Callback();
end

% --- Executes on button press in doStereologyBtn.
function doStereologyBtn_Callback(hObject, eventdata, handles)
handles.winController.doStereologyBtn_Callback();
end
