%% TEST unstructured streamlines function
clc; clear; close all
addpath ..\
%% DATA -------------------------------------------------------------------

load TestData.mat

%% CELL CENTER ------------------------------------------------------------

vx = 1/3*(TestData.V_x(TestData.Geometry.ConnectivityList(:,1)) + ...
          TestData.V_x(TestData.Geometry.ConnectivityList(:,2)) + ...
          TestData.V_x(TestData.Geometry.ConnectivityList(:,3)));


vy = 1/3*(TestData.V_y(TestData.Geometry.ConnectivityList(:,1)) + ...
          TestData.V_y(TestData.Geometry.ConnectivityList(:,2)) + ...
          TestData.V_y(TestData.Geometry.ConnectivityList(:,3)));


vz = 1/3*(TestData.V_z(TestData.Geometry.ConnectivityList(:,1)) + ...
          TestData.V_z(TestData.Geometry.ConnectivityList(:,2)) + ...
          TestData.V_z(TestData.Geometry.ConnectivityList(:,3)));


%% PLOT MESH --------------------------------------------------------------

figure
p = patch('Faces',TestData.Geometry.ConnectivityList,'Vertices',TestData.Geometry.Points,...
    'EdgeColor','none','FaceColor','interp','FaceVertexCData',TestData.V_x);

xlabel('x')
ylabel('y')
zlabel('z')
daspect([1 1 1])
view([-75,6])
cbar = colorbar();
cbar.Label.String = 'F_x';
drawnow

%% PROCESS ----------------------------------------------------------------
radius = 1.38e-03; %0.03; % 3 cm  
lines = evenly_spaced_streamlines(TestData.Geometry.Points,...
            TestData.Geometry.ConnectivityList,...
            [vx,vy,vz],radius,"num_threads",2);
