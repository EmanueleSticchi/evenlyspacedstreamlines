%% TEST unstructured streamlines function
clc; clear; close all
addpath ..\
%% DATA -------------------------------------------------------------------
vertices = [0, 0, 0; 1, 0, 0; 0, 1, 0];
triangles = [1, 2, 3];
orientation = [1, 1, 0];
radius = 0.1;

%% TEST -------------------------------------------------------------------

lines = evenly_spaced_streamlines(vertices,triangles,orientation,radius);