warning: in the working copy of 'MatlabScripts/Demo/MatlabClientAPI.m', CRLF will be replaced by LF the next time Git touches it
[1mdiff --git a/MatlabScripts/Demo/MatlabClientAPI.m b/MatlabScripts/Demo/MatlabClientAPI.m[m
[1mindex c3e58ae..1abfc28 100644[m
[1m--- a/MatlabScripts/Demo/MatlabClientAPI.m[m
[1m+++ b/MatlabScripts/Demo/MatlabClientAPI.m[m
[36m@@ -1,4 +1,4 @@[m
[31m-function [isShotIn, restitutionCoeff,  GCF] = MatlabClientAPI(MODE, MATCH_TYPE, SHOT_TYPE, path)[m
[32m+[m[32mfunction [isShotIn, restitutionCoeff, xCoeff, yCoeff, bounceT, gcf] = MatlabClientAPI(MODE, MATCH_TYPE, SHOT_TYPE, path)[m
 	% MatlabClient_Final performs the following:[m
 	% - Waits for the GUI to initialize its parameters[m
 	% - Once GUI initiates process, connects to server over wifi[m
[36m@@ -220,7 +220,7 @@[m [mfunction [isShotIn, restitutionCoeff,  GCF] = MatlabClientAPI(MODE, MATCH_TYPE,[m
 		ylabel('Z Position, m');[m
 		grid on;[m
 		hold off;[m
[31m-		saveas(gcf, 'volley4DoubleData.jpg', 'jpg');[m
[32m+[m		[32msaveas(gcf, 'volley6DoubleData.jpg', 'jpg');[m
 	[m
 	% 2. 3D plot of real and calc trajectory?[m
 		% Plotting[m
[36m@@ -236,8 +236,7 @@[m [mfunction [isShotIn, restitutionCoeff,  GCF] = MatlabClientAPI(MODE, MATCH_TYPE,[m
 		grid on;[m
 		zlim([0 inf]); % Set the minimum Z value to 0[m
 		hold off;[m
[31m-		saveas(gcf, 'volley4DoubleData3D.jpg', 'jpg');[m
[32m+[m		[32msaveas(gcf, 'volley6DoubleData3D.jpg', 'jpg');[m
 	[m
     end[m
[31m-    GCF = gcf;[m
 end[m
\ No newline at end of file[m
