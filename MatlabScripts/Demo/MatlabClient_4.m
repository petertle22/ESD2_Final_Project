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


%Connect to sever
server_ip   = '129.21.91.215';     % IP address of the server -NEEDS CHANGE

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
    path = '../datFiles/serve1.dat';
    errorCode = MoveTennisBall(request, path);

    if errorCode == 0 
        [leftImage, rightImage] = MoveCamera(request, 0); 

        % 3. Grayscale Left/Right
        BallLeftGray  = preprocessImage(leftImage);
        BallRightGray = preprocessImage(rightImage);

        % 4. Perform Background Subtraction and binarization
        % Background Subtraction
        diffLeft = imsubtract(BallLeftGray, emptyLeftGray);
        diffRight = imsubtract(BallRightGray, emptyRightGray);
        % Binarize the image
        threshold = graythresh(diffLeft); % Determine the best threshold
        binaryLeft = imbinarize(diffLeft, threshold);
        binaryRight = imbinarize(diffRight, threshold);
        % Convert binary image to uint8
        processedLeft = uint8(binaryLeft * 255); % Convert logical to uint8 by multiply
        processedRight = uint8(binaryRight * 255); % Convert logical to uint8 by multiply

        
        % 4. Send Left/Right
        %Package the two processed images
        imageStack = uint8(ones(height,width,8));
        imageStack(:,:,1) = processedLeft;
        imageStack(:,:,2) = processedRight;

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
% Get real X,Y,Z positions at t
real_X = zeros(size(calc_X));
real_Y = zeros(size(calc_Y));
real_Z = zeros(size(calc_Z));
ballData = load(path);
for i = 1:numFrames
    % Populate real XYZ using t as indices
    if t(i) <= size(ballData, 1)
        real_X(i) = ballData(t(i), 1);
        real_Y(i) = ballData(t(i), 2);
        real_Z(i) = ballData(t(i), 3);
    else
        error('Index exceeds the number of rows in ballData file.');
    end
end

% Plotti the real and calculated 3D coordinates
figure;
hold on;  % Hold on to add multiple plots

% Plot real coordinates
plot3(real_X, real_Y, real_Z, 'bo', 'MarkerFaceColor', 'blue', 'DisplayName', 'Real Coordinates');
% Plot calculated coordinates
plot3(calc_X, calc_Z, calc_Y, 'ro', 'MarkerFaceColor', 'red', 'DisplayName', 'Calculated Coordinates');

% Label Plot
grid on;  % Enable grid
xlabel('X Axis');  % Label X-axis
ylabel('Y Axis');  % Label Y-axis
zlabel('Z Axis');  % Label Z-axis
title('Comparison of Real and Calculated 3D Coordinates');  % Add title
legend show;  % Display legend

% Setting axis properties for better visualization
axis equal;  % Equal scaling
view(3);  % Default 3D view
rotate3d on;  % Enable rotation of plot using mouse

hold off;  % Release the plot hold


%Close Server
write(client,'9999');