[1mdiff --git a/MatlabScripts/Demo/MatlabClient_5.m b/MatlabScripts/Demo/MatlabClient_5.m[m
[1mindex 00b84a3..c768834 100644[m
[1m--- a/MatlabScripts/Demo/MatlabClient_5.m[m
[1m+++ b/MatlabScripts/Demo/MatlabClient_5.m[m
[36m@@ -20,7 +20,7 @@[m [memptyRightGray = preprocessImage(emptyRightImage);[m
 [m
 %Connect to sever;[m
 %server_ip   = '129.21.42.178';     % IP address of the server -NEEDS CHANGE[m
[31m-server_ip   = '129.21.41.4';     % IP address of the server -NEEDS CHANGE[m
[32m+[m[32mserver_ip   = '129.21.91.215';     % IP address of the server -NEEDS CHANGE[m
 [m
 % NO CHNAGE[m
 server_port = 9999;                % Server Port of the sever[m
[36m@@ -114,7 +114,6 @@[m [mwhile 1[m
         imageStack = permute(imageStack,[3 2 1]);[m
         write(client,imageStack(:)); %SEND[m
         flush(client);[m
[31m-        break[m
     end[m
 [m
 end[m
[1mdiff --git a/MatlabScripts/Demo/MoveCamera.m b/MatlabScripts/Demo/MoveCamera.m[m
[1mindex e71f1fe..c2f8fa7 100644[m
[1m--- a/MatlabScripts/Demo/MoveCamera.m[m
[1m+++ b/MatlabScripts/Demo/MoveCamera.m[m
[36m@@ -7,7 +7,7 @@[m [mfunction [unityImageLeft, unityImageRight] = MoveCamera(time, isWind)[m
   addpath(genpath('../src'))[m
   [m
   %Initialization Parameters[m
[31m-  server_ip   = '129.21.151.125';     %IP address of the Unity Server[m
[32m+[m[32m  server_ip   = '129.21.91.215';     %IP address of the Unity Server[m
   server_port = 55001;           %Server Port of the Unity Sever[m
   [m
   client = tcpclient(server_ip,server_port);[m
[1mdiff --git a/MatlabScripts/Demo/MoveTennisBall.m b/MatlabScripts/Demo/MoveTennisBall.m[m
[1mindex 1cb616d..cedefbf 100644[m
[1m--- a/MatlabScripts/Demo/MoveTennisBall.m[m
[1m+++ b/MatlabScripts/Demo/MoveTennisBall.m[m
[36m@@ -7,7 +7,7 @@[m [mfunction errorCode = moveTennisBall(time, pathToDatFile)[m
     addpath(genpath('../src'))[m
 [m
     %Initialization Parameters[m
[31m-    server_ip   = '129.21.151.125';     %IP address of the Unity Server[m
[32m+[m[32m    server_ip   = '129.21.91.215';     %IP address of the Unity Server[m
     server_port = 55001;               %Server Port of the Unity Sever[m
     client = tcpclient(server_ip,server_port);[m
     fprintf(1,"Connected to server\n");[m
[1mdiff --git a/MatlabScripts/Demo/slprj/modeladvisor/HDLAdv_/ImageProcessingNoShift/11387/ModelAdvisorData b/MatlabScripts/Demo/slprj/modeladvisor/HDLAdv_/ImageProcessingNoShift/11387/ModelAdvisorData[m
[1mdeleted file mode 100644[m
[1mindex 0b800e5..0000000[m
Binary files a/MatlabScripts/Demo/slprj/modeladvisor/HDLAdv_/ImageProcessingNoShift/11387/ModelAdvisorData and /dev/null differ
[1mdiff --git a/MatlabScripts/Demo/slprj/sl_proj.tmw b/MatlabScripts/Demo/slprj/sl_proj.tmw[m
[1mdeleted file mode 100644[m
[1mindex 93cd650..0000000[m
[1m--- a/MatlabScripts/Demo/slprj/sl_proj.tmw[m
[1m+++ /dev/null[m
[36m@@ -1,2 +0,0 @@[m
[31m-Simulink Coder project marker file. Please don't change it. [m
[31m-slprjVersion: 10.7_091[m
\ No newline at end of file[m
[1mdiff --git a/pythonCode/Demo/ZynqServer_5.py b/pythonCode/Demo/ZynqServer_5.py[m
[1mindex 77baad1..d1331e1 100644[m
[1m--- a/pythonCode/Demo/ZynqServer_5.py[m
[1m+++ b/pythonCode/Demo/ZynqServer_5.py[m
[36m@@ -37,9 +37,9 @@[m [mFPGA_ENABLE = False[m
 CV2_PREPROCESS_ENABLE = True[m
 WINDSHIFT_ENABLE = False[m
 ACCEL_PROCESSING = True[m
[31m-FRAME_REQUEST_TIMEOUT = 1400[m
[31m-T_SKIP = 20[m
[31m-PROCESS_T = 3[m
[32m+[m[32mFRAME_REQUEST_TIMEOUT = 5000[m
[32m+[m[32mT_SKIP = 500[m
[32m+[m[32mPROCESS_T = 100[m
 FIXED_PROCESS_TIME = True[m
 #----------------------------------------------------------------------------------------------------------[m
 # INITIALIZE FPGA[m
[36m@@ -90,6 +90,10 @@[m [mwhile True:[m
             else:[m
                 data = npSocket.receive() # Read data from client[m
 [m
[32m+[m[32m            if np.all(emptyLeftGray == 0) and np.all(emptyRightGray == 0):[m
[32m+[m[32m                print("Requested For Frame Out Of Bounds For Time")[m
[32m+[m[32m                break[m
[32m+[m
             # Start Processing Current Frame[m
             start_time = time.time()  # start a timer from 0 to track processing time[m
             # 0. Adapt stereo background to possible wind shifts in new stereo image[m
