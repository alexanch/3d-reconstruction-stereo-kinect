%% First, read a RGB-D image
close all; clear; clc;
rgb = imread('RightRgbobjects_sceneUGR_Final.png');
dep = imread('RightDedpthobjects_sceneUGR_Final.png');

rgb_l = imread('LeftRgbobjects_sceneUGR_Final.png');
dep_l = imread('LeftDepthobjects_sceneUGR_Final.png');

dep(:,1:100) = nan;
dep_l(:,1:100) = nan;
dep(:,540:640) = nan;
dep_l(:,540:640) = nan;
% 
% 
dep(1:80,:) = nan;
dep_l(1:80,:) = nan;
dep(380:480,:) = nan;
dep_l(380:480,:) = nan;


% dep(:,1:150) = nan;
% dep_l(:,1:150) = nan;
%preprossesing

 SE = strel('sphere',2);
 depth = imerode(dep,SE);
 depth_l = imerode(dep_l,SE);

% depth = double(depth)/1000;
% depth = imgaussfilt(depth);

% here I divide by 1000 to convert mm to m.
% Also, I divide values by 5 to normalize it from 0 to 1 to use bfilter
depth = double(depth)/1000/5;
depth = 5*bfilter2(depth);

depth(depth == 0) = nan;
depth(depth > 2.9) = nan;
depth(depth < 1.2) = nan;

% depth_l= double(depth_l)/1000;
% depth_l = imgaussfilt(depth_l);

depth_l = double(depth_l)/1000/5;
depth_l = 5*bfilter2(depth_l);

% unknown depth points = not a number
depth_l(depth_l == 0) = nan;
depth_l(depth_l > 2.9) = nan;
 
depth_l(depth_l < 1.2) = nan;
figure;imshowpair(rgb,rgb_l,'montage');
figure;imshowpair(depth,depth_l,'montage');


%%%%%%%%%%%%%%%%%%%%%
%% Intrinsic parameters of left camera:
fc_left = [ 525.91555   528.76660 ];
cc_left = [ 319.45571   273.24978 ];
% Skew:             alpha_c_left = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees
% Distortion:            kc_left = [ 0.18264   -0.26293   0.01044   0.00464  0.00000 ] ± [ 0.02498   0.08262   0.00407   0.00403  0.00000 ]

%% Intrinsic parameters of right camera:
 fc_right = [ 523.04244   525.87810 ];
 cc_right = [ 312.21580   263.92612 ];
% Skew:             alpha_c_right = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees
% Distortion:            kc_right = [ 0.19469   -0.36418   0.00106   0.00209  0.00000 ] ± [ 0.02016   0.06069   0.00352   0.00418  0.00000 ]

%% Extrinsic parameters (position of right camera wrt left camera):

% parameters from lab 2 
%om = [ 0.01575   0.53349  -0.03561 ]; %Rotation vector:    
% T = [ -1039.09504   -16.65551  425.33596 ]/1000; %Translation vector
% %  R = rodrigues(om) - in lab 2
% R =[    0.8604    0.0380    0.5081
%    -0.0298    0.9993   -0.0243
%    -0.5087    0.0057    0.8609]; 
% % 
% R = ([0.863676805198133,-0.0312944812880674,-0.503073584680866;
%     0.0484250766580186,0.998605690531141,0.0210163457691677
T = -[-1.094126617090287e+03,24.250894977685686,2.428117903390593e+02]/1000;

R = [0.863387108340955,-0.032452790457088,-0.503497286529125;
    0.047082609117476,0.998756988973249,0.016361689881535;
    0.502340451356781,-0.037832438047750,0.863841870692796];
%% Kinect Depth camera parameters
fx_d =  5.7616540758591043e+02;
%     0.501714448778796,-0.0425127072736492,0.863988010105959]);
% T = [-298.606792644909 6.60327065137064 65.7348800677946]/1000;
fy_d = 5.7375619782082447e+02;
cx_d = 3.2442516903961865e+02;
cy_d = 2.3584766381177013e+02;



%% Extrinsic parameters between RGB and Depth camera for Kinect V1

% Rotation matrix IN METERS
R_extr_cam =  inv([  9.9998579449446667e-01, 3.4203777687649762e-03, -4.0880099301915437e-03;
    -3.4291385577729263e-03, 9.9999183503355726e-01, -2.1379604698021303e-03;
    4.0806639192662465e-03, 2.1519484514690057e-03,  9.9998935859330040e-01]);

% Translation vector. in METERS
T_extr_cam = -[  2.2142187053089738e-02, -1.4391632009665779e-04, -7.9356552371601212e-03 ]';

%% Depth alignment 

% RGB-D camera constants
[rows, cols] = size(depth);


% convert depth image to 3d point clouds
pcloud_left = zeros(rows,cols,3);
pcloud_right = zeros(rows,cols,3);

xgrid = ones(rows,1)*(1:cols) - cx_d;
ygrid = (1:rows)'*ones(1,cols) - cy_d;

pcloud_left(:,:,1) = xgrid.*depth_l/fx_d;
pcloud_left(:,:,2) = ygrid.*depth_l/fy_d;
pcloud_left(:,:,3) = depth_l;


pcloud_right(:,:,1) = xgrid.*depth/fx_d;
pcloud_right(:,:,2) = ygrid.*depth/fy_d;
pcloud_right(:,:,3) = depth;


% left Kinect alignment of Depth camera

for i = 1:rows
    for j = 1:cols
        pcloud_align_Left(i,j,1:3)=R_extr_cam*[pcloud_left(i,j,1); pcloud_left(i,j,2); pcloud_left(i,j,3)]+T_extr_cam;
    end
end

% right Kinect alignment of Depth camera
for i = 1:rows
    for j = 1:cols
        pcloud_align_Right(i,j,1:3)=R_extr_cam*[pcloud_right(i,j,1); pcloud_right(i,j,2); pcloud_right(i,j,3)]+T_extr_cam;
    end
end


%%   right Kinect alignment with left Kinect
for i = 1:rows
    for j = 1:cols
        Right_align(i,j,1:3)=(R)*[pcloud_align_Right(i,j,1); pcloud_align_Right(i,j,2); pcloud_align_Right(i,j,3)]+T';
    end
end

%%

ptCloudLeft = pointCloud(pcloud_align_Left,'Color',rgb_l);
ptCloudRight = pointCloud(pcloud_align_Right,'Color',rgb);


% ptCloudLeft = pcdenoise(ptCloudLeft);
% ptCloudRight = pcdenoise(ptCloudRight); 

%percentage = 0.95;
% ptCloudLeft_samp = pcdownsample(ptCloudLeft,'random',percentage);
% ptCloudRight_samp = pcdownsample(ptCloudRight,'random',percentage);

 [tform,movingReg,rmse] = pcregrigid(ptCloudRight,ptCloudLeft,'Extrapolate',true,'Metric','PointToPoint','Tolerance',[ 0.001, 0.0009]);
rmse


% ptCloudAligned = pctransform(ptCloudRight,tform);
%mergeSize = 0.000001;
% ptCloudScene = pcmerge(ptCloudLeft, ptCloudAligned, mergeSize);




figure;
% resize it to see the scene properly
pcshow(pcdenoise(movingReg), 'VerticalAxis','Y', 'VerticalAxisDir', 'Down')
title('Initial world scene')
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
drawnow

%% left and right Point Clouds

figure;
% resize it to see the scene properly
pcshow(ptCloudRight, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down')
title('Initial world scene')
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
drawnow

figure;
% resize it to see the scene properly
pcshow(ptCloudLeft, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down')
title('Initial world scene')
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
drawnow
