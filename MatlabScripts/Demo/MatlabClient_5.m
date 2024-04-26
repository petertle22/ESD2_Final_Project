% MatlabClient_4 Connest to a Zynq server and continuously awaits a request
% from server for a frame at time t

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLIENT INITIALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image Transfer Dimensions
width = 752.0;
height = 480.0;

% Function to preprocess images (convert to grayscale)
preprocessImage = @(img) rgb2gray(img);

% Get and save Empty Court images (Left/Right). 
emptyLeftImage = imread("../../testImages/LeftEmptyCourt.jpg");
emptyRightImage = imread("../../testImages/rightEmptyCourt.jpg");
emptyLeftGray = preprocessImage(emptyLeftImage);
emptyRightGray = preprocessImage(emptyRightImage);


%Connect to sever;
server_ip   = '129.21.41.4';     % IP address of the server -NEEDS CHANGE

% NO CHNAGE
server_port = 9999;                % Server Port of the sever
client = tcpclient(server_ip,server_port);
fprintf(1,"Connected to server\n");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEND SERVER INIT PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SEND
write(client,'0'); %Transfer Protocol
flush(client);

% For now, just leave values as is
MODE = '7';       % 1 -> coefficient of restitution, 2 -> ball is inside or out
write(client, MODE);
flush(client);

MATCH_TYPE = '3'; % 1 -> singles mode, -> 2 doubles mode
write(client, MATCH_TYPE);
flush(client);

SHOT_TYPE = '5';  % 1 -> serve mode, 2 -> volley mode
write(client, SHOT_TYPE);
flush(client);


% Serve/Volley Number  
SHOT_NUM = 0;   % 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REQUEST-RETRIEVE-RESPOND LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tell Server to begin processing a shot
write(client,'1'); %Transfer Protocol
flush(client);

% Loop until Server sends special value
while 1

    % 1. Wait for request from server (t value), exit if special value
    request = read(client, 1, 'uint32');
    request
    if request == 99999
        break
    end

    % 2. Retrieve Left/Right Unity images at time t
    path = '../datFiles/volley2.dat';
    errorCode = MoveTennisBall(request, path);

    if errorCode == 0 
        [leftImage, rightImage] = MoveCamera(request, 0); 

        % 3. Grayscale Left/Right
        BallLeftGray  = preprocessImage(leftImage);
        BallRightGray = preprocessImage(rightImage);

        % 4. Send Left/Right
        %Package all four images
        imageStack = uint8(ones(height,width,8));

        imageStack(:,:,1) = BallLeftGray;
        imageStack(:,:,2) = emptyLeftGray;
        imageStack(:,:,3) = BallLeftGray;
        imageStack(:,:,4) = emptyLeftGray;
        imageStack(:,:,5) = emptyRightGray;
        imageStack(:,:,6) = ballRightGray;
        imageStack(:,:,7) = emptyLeftGray;
        imageStack(:,:,8) = ballLeftGray;

        imageStack = permute(imageStack,[3 2 1]);
        write(client,imageStack(:)); %SEND
        flush(client);
    else
        % 4. Send Left/Right
        %Package all four images
        disp('Printing zeros')
        imageStack = uint8(ones(height,width,8));
        imageStack(:,:,1) = ones(480, 752) * 0;
        imageStack(:,:,2) = ones(480, 752) * 0;
        imageStack(:,:,3) = ones(480, 752) * 0;
        imageStack(:,:,4) = ones(480, 752) * 0;
        imageStack(:,:,5) = ones(480, 752) * 0;
        imageStack(:,:,6) = ones(480, 752) * 0;
        imageStack(:,:,7) = ones(480, 752) * 0;
        imageStack(:,:,8) = ones(480, 752) * 0;

        imageStack = permute(imageStack,[3 2 1]);
        write(client,imageStack(:)); %SEND
        flush(client);
        break
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESULTS HANDELING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write(client,'2'); %Transfer Protocol
flush(client);

% Receive calculated X,Y,Z position
numFrames = read(client, 1, 'uint32');
calc_X = read(client, numFrames, 'double');
calc_Y = read(client, numFrames, 'double');
calc_Z = read(client, numFrames, 'double');
t = read(client, numFrames, 'uint32');
disp('here')

for i = 1:numFrames
    real_X = zeros(size(calc_X));
    real_Y = zeros(size(calc_X));
    real_Z = zeros(size(calc_X));
    ballData = load(path);

    % Populate actualDepths using indices from calculatedDepths_t
    for i = 1:length(t)
        t_index = t(i);
        if t_index <= size(ballData, 1)
            real_X(i) = ballData(t_index, 3);
            real_Y(i) = ballData(t_index, 1);
            real_Z(i) = ballData(t_index, 2);
        else
            error('Index exceeds the number of rows in ballData file.');
        end
    end
end

% Plot 3D coordinates
figure;
plot3(calc_X, calc_Y, calc_Z, 'ro'); % Plot calculated positions in red
hold on;
plot3(real_X, real_Y, real_Z, 'bo'); % Plot real positions in blue
legend('Calculated Position', 'Real Position');
title('3D Plot of Real and Calculated Positions');
xlabel('X Position');
ylabel('Y Position');
zlabel('Z Position');
grid on;


% Plot X coordinate
figure;
plot(t, calc_X, 'r'); % Plot calculated X positions in red
hold on;
plot(t, real_X, 'b'); % Plot real X positions in blue
legend('Calculated X', 'Real X');
title('Comparison of Calculated and Real X Positions Over Time');
xlabel('Time');
ylabel('X Position');
grid on;


% Plot Y coordinate
figure;
plot(t, calc_Y, 'r'); % Plot calculated Y positions in red
hold on;
plot(t, real_Y, 'b'); % Plot real Y positions in blue
legend('Calculated Y', 'Real Y');
title('Comparison of Calculated and Real Y Positions Over Time');
xlabel('Time');
ylabel('Y Position');
grid on;


% Plot Z coordinate
figure;
plot(t, calc_Z, 'r'); % Plot calculated Z positions in red
hold on;
plot(t, real_Z, 'b'); % Plot real Z positions in blue
legend('Calculated Z', 'Real Z');
title('Comparison of Calculated and Real Z Positions Over Time');
xlabel('Time');
ylabel('Z Position');
grid on;


write(client,'9999');