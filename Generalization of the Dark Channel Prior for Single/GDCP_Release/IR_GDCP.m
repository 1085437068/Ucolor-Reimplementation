%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    File: IR_GDCP.m                                         %
%    Author: Jerry Peng                                      %
%    Date: Aug/2017                                          %
%                                                            %
%    Generalization of the Dark Channel Prior for Single     %
%    Image Restoration                                       %
%------------------------------------------------------------%
%    MODIFICATIONS                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;close all;
Stretch = @(x) (x-min(x(:))).*(1/(max(x(:))-min(x(:))));
win = 15;
t0 = 0.2;
r0 = t0 * 1.5;
sc = 1;
folder2='/home/hzc/CodeRepository/UnderwaterEnhancement/DeepLearning/CNN/Ucolor/Ucolor_final_model_corrected/Generalization of the Dark Channel Prior for Single/GDCP_Release/Images';
filepaths = dir(fullfile(folder2,'*.jpg'));


for ii= 1 : length(filepaths)
    tic
   
im = im2double(imread(fullfile(folder2,filepaths(ii).name)));
% [~, width, ~] = size(im);
% if width ~= 480 
%     sc = 480/width;
% end
% I = im2double(imresize(im, sc));

 I =  im2double(im);

% I=imresize(I,[548,728]);
s = CC(I);
[DepthMap, GradMap] = GetDepth(I, win);
A = atmLight(I, DepthMap);

T = calcTrans(I, A, win);
maxT = max(T(:));
minT = min(T(:));
T_pro  = ((T-minT)/(maxT-minT))*(maxT-t0) + t0;
Jc = zeros(size(I));
for ind = 1:3 
    Am = A(ind)/s(ind);
    Jc(:,:,ind) = Am+(I(:,:,ind)-Am)./max(T_pro, r0);
end
Jc(Jc < 0) = 0;
Jc(Jc > 1) = 1;
%figure, imshow([I Jc])
toc
%imwrite(Jc,filepaths(ii).name);
imwrite(T_pro,fullfile('',[filepaths(ii).name,'_depth_estimate.png']));
end