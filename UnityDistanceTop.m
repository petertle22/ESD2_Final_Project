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
x = 0;
y = 13.5;
z = 0;
pitch = 90;
roll = 0;
yaw = 90;
pose = [x,y,z,yaw,pitch,roll];
unityImageLeft = unityLink(client,pose);
%subplot(1, 2, 1);
imshow(unityImageLeft);
%imsave;

%x2 = 8;
%y2 = 4.5;
%z2 = -14;
%pitch2 = 25;
%roll2 = 0;
%yaw2 = -43;
%pose2 = [x2,y2,z2,yaw2,pitch2,roll2];
%unityImageRight = unityLink(client,pose2);
%subplot(1, 2, 2);
%imshow(unityImageRight);


%Close Gracefully
fprintf(1,"Disconnected from server\n");
