clc;
clear all;
close all;

%Include source files in path
addpath(genpath('../src'))

%Initialization Parameters
server_ip   = '127.0.0.1';     %IP address of the Unity Server
server_port = 55001;           %Server Port of the Unity Sever

client = tcpclient(server_ip,server_port);
fprintf(1,"Connected to server\n");

% x,y,z,yaw[z],pitch[y],roll[x]
depthRange_m = [-0.5:-0.1:-4.75];
computedRange_mm = [];
for i = 1:length(depthRange_m)
    pose = [depthRange_m(i),-0.03,0,0,0,0];
    [x1, y1] = getCenterPixels(depthRange_m(i), pose, client);
    pose = [depthRange_m(i),0.03,0,0,0,0];
    [x2, y2] = getCenterPixels(depthRange_m(i), pose, client);
    [Z_mm, X_mm, Y_mm] = getCenterPosition(x1, y1, x2, y2);
    Z_mm
    computedRange_mm = [computedRange_mm, Z_mm];
end

computedRange_m = computedRange_mm / 1000;
depthRange_m = -1 * depthRange_m;

percentError = [];
for i = 1 : length(depthRange_m)
    percentError = [percentError, (computedRange_m(i) - depthRange_m(i))];
end

figure
plot(depthRange_m, percentError);
grid on
xlabel('Nominal Depth of Ball (m)');
ylabel('Error = Computed - Actual (m)');
title('Computed-Nominal Range Error vs Actual Tennis Ball');

%Close Gracefully
fprintf(1,"Disconnected from server\n");
