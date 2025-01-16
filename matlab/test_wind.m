%% TEST unstructured streamlines function
clc; clear; close all
%% DATA -------------------------------------------------------------------

load wind.mat

%% EXTRACT SLICE ----------------------------------------------------------

iz   = 6;
zval = z(1,1,iz);

%% GENERATE TRIANGULATION -------------------------------------------------

x_uns = x(:,:,iz); x_uns = x_uns(:);
y_uns = y(:,:,iz); y_uns = y_uns(:);
z_uns = zval*ones(length(y_uns),1);

TR = delaunayTriangulation(x_uns,y_uns);

%% CELL CENTER INTERPOLATION ----------------------------------------------

centers = incenter(TR);

u_uns = u(:,:,iz); u_uns = u_uns(:);
v_uns = v(:,:,iz); v_uns = v_uns(:);
w_uns = w(:,:,iz); w_uns = w_uns(:);

Fu = scatteredInterpolant(x_uns,y_uns,u_uns);
Fv = scatteredInterpolant(x_uns,y_uns,v_uns);
Fw = scatteredInterpolant(x_uns,y_uns,w_uns);

u_uns_cell = Fu(centers(:,1),centers(:,2));
v_uns_cell = Fv(centers(:,1),centers(:,2));
w_uns_cell = Fw(centers(:,1),centers(:,2));

%% PLOT -------------------------------------------------------------------

% matlab function
figure
subplot 221
surf(x(:,:,iz),y(:,:,iz),z(:,:,iz),'FaceColor','none')
axis tight
xlabel('x')
ylabel('y')
zlabel('z')
view([0 90])
title('Matlab built-in (mesh)')
subplot 222
streamslice(x,y,z,u,v,w,[],[],zval)
axis tight
xlabel('x')
ylabel('y')
title('Matlab built-in')

% streamlines unstructured function
%figure
subplot 223
triplot(TR,'k')
axis tight
xlabel('x')
ylabel('y')
title('evenly\_spaced\_streamlines (mesh)')
subplot 224
lines = evenly_spaced_streamlines([x_uns,y_uns,z_uns],TR.ConnectivityList,...
    [u_uns_cell,v_uns_cell,w_uns_cell],1);

for i=1:length(lines)
    plot3(lines{i,1}(:,1),lines{i,1}(:,2),lines{i,1}(:,3),'b')
    hold on
    % quiver3(lines{i,1}(:,1),lines{i,1}(:,2),lines{i,1}(:,3),...
    %     Fu(lines{i,1}(:,1),lines{i,1}(:,2)), Fv(lines{i,1}(:,1),lines{i,1}(:,2)),...
    %     Fw(lines{i,1}(:,1),lines{i,1}(:,2)),...
    %     'Color','b','AutoScaleFactor',0.5);
end
axis tight
xlabel('x')
ylabel('y')
zlabel('z')
view([0 90])
title('evenly\_spaced\_streamlines')

