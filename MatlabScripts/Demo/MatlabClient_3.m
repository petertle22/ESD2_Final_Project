% MatlabClient_3 Connest to a Zynq server and continuously awaits a request
% from server for a frame at time t

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLIENT INITIALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image Transfer Dimensions
width = 752;
height = 480;

% Get and save Empty Court images (Left/Right). 

% Grayscale

%Connect to sever
% CHANGE
server_ip   = '129.21.42.240';     % IP address of the server -NEEDS CHANGE

% NO CHNAGE
server_port = 9999;                % Server Port of the sever
client = tcpclient(server_ip,server_port);
fprintf(1,"Connected to server\n");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEND SERVER INIT PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For now, just leave values as is
MODE = 0;
MATCH_TYPE = 0;
SHOT_TYPE = 0;
SHOT_NUM = 0; 
INIT_PARAMETERS = ;  %CONCATENATE ALL THESE PARAMETERS AND SEND

%SEND
write(client,'0'); %Transfer Protocol
flush(client);
write(client,INIT_PARAMTERS);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REQUEST-RETRIEVE-RESPOND LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop until Server sends special value

    % 1. Wait for request from server (t value), exit if special value
    request = read(client, 1, 'uint32');
    % 2. Retrieve Left/Right Unity images at time t

    % 3. Grayscale Left/Right

    % 4. Send Left/Right 
    write(client,'1'); %Transfer Protocol
    flush(client);

    %Package all four images
    imageStack = uint8(ones(height,width,8));
    imageStack(:,:,1) = BallLeftGray;
    imageStack(:,:,2) = emptyLeftGray;
    imageStack(:,:,3) = BallLeftGray;
    imageStack(:,:,4) = emptyLeftGray;
    imageStack(:,:,5) = BallRightGray;
    imageStack(:,:,6) = emptyRightGray;
    imageStack(:,:,7) = BallRightGray;
    imageStack(:,:,8) = emptyRightGray;

    imageStack = permute(imageStack,[3 2 1]);
    write(client,imageStack(:)); %SEND

%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESULTS HANDELING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write(client,'2'); %Transfer Protocol
flush(client);

%TBD


%Close Server
write(client,'3');