%% TEST unstructured streamlines function
clc; clear; close all
addpath ..\
%% DATA -------------------------------------------------------------------

load TestData.mat

%% CELL CENTER ------------------------------------------------------------
[triOut,validTriangles] = removeZeroAreaTriangles(TestData.Geometry);

vx = 1/3*(TestData.V_x(TestData.Geometry.ConnectivityList(:,1)) + ...
          TestData.V_x(TestData.Geometry.ConnectivityList(:,2)) + ...
          TestData.V_x(TestData.Geometry.ConnectivityList(:,3)));
vx(~validTriangles,:) = [];

vy = 1/3*(TestData.V_y(TestData.Geometry.ConnectivityList(:,1)) + ...
          TestData.V_y(TestData.Geometry.ConnectivityList(:,2)) + ...
          TestData.V_y(TestData.Geometry.ConnectivityList(:,3)));
vy(~validTriangles,:) = [];

vz = 1/3*(TestData.V_z(TestData.Geometry.ConnectivityList(:,1)) + ...
          TestData.V_z(TestData.Geometry.ConnectivityList(:,2)) + ...
          TestData.V_z(TestData.Geometry.ConnectivityList(:,3)));
vz(~validTriangles,:) = [];

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
radius = 1.38e-03; %   
lines = evenly_spaced_streamlines(triOut.Points,...
            triOut.ConnectivityList,...
            [vx,vy,vz],radius,"num_threads",4);

% hold on
% for i=1:length(lines)
%     plot3(lines{i}(:,1),lines{i}(:,2),lines{i}(:,3),LineWidth=1,Color=[0 0 0])
% end

hold on
Nstreamlines = 25000;
temp_lines = lines(round(linspace(1,length(lines),Nstreamlines)));
temp_lines = cellfun(@(c) [c; NaN(1,3)], temp_lines, 'UniformOutput', false);
temp_lines = vertcat(temp_lines{:});
p_str_lines = plot3(temp_lines(:,1),temp_lines(:,2),temp_lines(:,3),LineWidth=1,Color=[0 0 0]);

%% FUNCTION


function [triOut,validTriangles] = removeZeroAreaTriangles(triIn)
    % removeZeroAreaTriangles - Removes triangles with zero area from a triangulation object.
    %
    % Syntax:
    %   triOut = removeZeroAreaTriangles(triIn)
    %
    % Inputs:
    %   triIn - A triangulation object
    %
    % Outputs:
    %   triOut - A triangulation object with zero-area triangles removed

    % Extract the connectivity list and points from the triangulation
    connectivityList = triIn.ConnectivityList;
    points = triIn.Points;

    % Calculate the area of each triangle
    areas = zeros(size(connectivityList, 1), 1);
    for i = 1:size(connectivityList, 1)
        % Get the vertices of the triangle
        v1 = points(connectivityList(i, 1), :);
        v2 = points(connectivityList(i, 2), :);
        v3 = points(connectivityList(i, 3), :);

        % Compute the area of the triangle using the cross product
        areas(i) = 0.5 * norm(cross(v2 - v1, v3 - v1));
    end

    % Identify triangles with non-zero area
    validTriangles = areas > 0;

    % Create a new triangulation object without zero-area triangles
    triOut = struct('ConnectivityList',connectivityList(validTriangles, :),'Points', points);
end