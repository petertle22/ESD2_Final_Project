function moveTennisBall(time, pathToDatFile)
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

    ballData = load(pathToDatFile);
    [x, y, z] = ballData(time);
    pitch = 90;
    roll = 0;
    yaw = 90;
    obj = 2; % 1 means camera, 2 means ball
    pose = [x,y,z,yaw,pitch,roll, obj]
    unityLink(client,pose);

    %Close Gracefully
    fprintf(1,"Disconnected from server\n");
end