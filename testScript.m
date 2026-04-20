% Test script for bifurcation diagram
% This script runs bifurcationDiagram and saves the resulting figure
% to the same folder as this script (Chatbot Coding).

clear all; close all; format long;

% Parameters
v = 0.300186;
theta_0 = 1.1768;
AmpArray = 0.85:0.00005:1.175;
e = 0.94;
T = 61.2;

%v = 0.300186;
%theta_0 = 1.1768;
%AmpArray = 1.4:0.00005:1.675;
%e = 0.5;
%T = 61.2;

% Run bifurcation diagram and get figure handle
[Points, fig] = bifurcationDiagram(v, theta_0, AmpArray, e, T);

% Save outputs into the Chatbot Coding folder (script location)
script_dir = fileparts(mfilename('fullpath'));
fig_path = fullfile(script_dir, 'bifurcationDiagram_result_e=0.94.fig');
png_path = fullfile(script_dir, 'bifurcationDiagram_result_e=0.94.png');

savefig(fig, fig_path);
saveas(fig, png_path);

fprintf('Total points plotted: %d\n', size(Points, 1));
fprintf('Saved figure files:\n%s\n%s\n', fig_path, png_path);
