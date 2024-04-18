function moveTennisBall(time, pathToDatFile)
    clc;
    %clear all;
    close all;

    %Include source files in path
    addpath(genpath('../src'))

    %Initialization Parameters
    server_ip   = '129.21.91.42';     %IP address of the Unity Server
    server_port = 55001;           %Server Port of the Unity Sever

    client = tcpclient(server_ip,server_port);
    fprintf(1,"Connected to server\n");

    ballData = load(pathToDatFile);
    x = ballData(time, 1);
    y = ballData(time, 2);
    z = ballData(time, 3);
    pitch = 90;
    roll = 0;
    yaw = 90;
    obj = 2; % 1 means camera, 2 means ball
    pose = [x,y,z,yaw,pitch,roll, obj];
    unityLink(client,pose);

    %Close Gracefully
    fprintf(1,"Disconnected from server\n");
end