% add visual stimulus library to matlab path
addpath(genpath('/home/dlee/Documents/MATLAB/visual-stimuli/d213'));
addpath(genpath('/home/dlee/Documents/MATLAB/visual-stimuli/matrix'));
addpath(genpath('/home/dlee/Documents/MATLAB/visual-stimuli/utils'));
cd('/home/dlee/Documents/MATLAB/visual-stimuli/d213');

% configure display resolution at start up (for LightCrafter4500 pattern mode)
Screen('ConfigureDisplay', 'Scanout', 1, 0, 912, 1140);
SetResolution(1, 912, 1140, 60);

% clear
clear all;
close all;