% JBFILTER2 Two dimensional Joint bilateral filtering.
%    This function implements 2-D bilateral filtering using
%    the method outlined in, however with weights calculated according
%    to another image. 
%
%       C. Tomasi and R. Manduchi. Bilateral Filtering for 
%       Gray and Color Images. In Proceedings of the IEEE 
%       International Conference on Computer Vision, 1998. 
%
%    B = jbfilter2(D,C,W,SIGMA) performs 2-D bilateral filtering
%    for the grayscale or color image A. D should be a double
%    precision matrix of size NxMx1 (i.e., grayscale) 
%    with normalized values in the closed interval [0,1]. 
%    C should be similar to D, from which the weights are 
%    calculated, with normalized values in the closed 
%    interval [0,1].  The half-size of the Gaussian
%    bilateral filter window is defined by W. The standard
%    deviations of the bilateral filter are given by SIGMA,
%    where the spatial-domain standard deviation is given by
%    SIGMA(1) and the intensity-domain standard deviation is
%    given by SIGMA(2).
%
% Based on the code from Douglas R. Lanman, Brown University, September 2006.
%
% Varuna De Silva, University of Surrey, May 2010
% varunax@gmail.com


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pre-process input and select appropriate filter.
function B = jbfilter2(D,C,w,sigma)


%% modified by Wenzhi 
% normalize input depth map 
d_minD = min(D(:));
d_maxD = max(D(:));
D = (D-d_minD)/(d_maxD-d_minD);
D(D < 0) = 0;
D(D > 1) = 1;

d_minC = min(C(:));
d_maxC = max(C(:));
    
C = (C-d_minC)/(d_maxC-d_minC);
C(C < 0) = 0;
C(C > 1) = 1;
%%%%%%%%%%%%%%%%%%%%%

% Verify that the input image exists and is valid.
if ~exist('D','var') || isempty(D)
   error('Input image D is undefined or invalid.');
end
if ~isfloat(D) || ~sum([1,3] == size(D,3)) || ...
      min(D(:)) < 0 || max(D(:)) > 1
   error(['Input image D must be a double precision ',...
          'matrix of size NxMx1 or NxMx3 on the closed ',...
          'interval [0,1].']);      
end

% Verify bilateral filter window size.
if ~exist('w','var') || isempty(w) || ...
      numel(w) ~= 1 || w < 1
   w = 5;
end
w = ceil(w);

% Verify bilateral filter standard deviations.
if ~exist('sigma','var') || isempty(sigma) || ...
      numel(sigma) ~= 2 || sigma(1) <= 0 || sigma(2) <= 0
   sigma = [3 0.1];
end

% Apply either grayscale or color bilateral filtering.
if size(D,3) == 1
   B = jbfltGray(D,C,w,sigma(1),sigma(2));
else
   B = jbfltND(D,C,w,sigma(1),sigma(2));
end

%%   Modified by Wenzhi%%%%%%%%%%%%
B= B*(d_maxD-d_minD)+d_minD;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implements bilateral filtering for grayscale images.
function B = jbfltGray(D,C,w,sigma_d,sigma_r)

% Pre-compute Gaussian distance weights.
[X,Y] = meshgrid(-w:w,-w:w);
G = exp(-(X.^2+Y.^2)/(2*sigma_d^2));

% Create waitbar.
%h = waitbar(0,'Applying bilateral filter on gray image...');
%set(h,'Name','Bilateral Filter Progress');

% Apply bilateral filter.
dim = size(D);
B = zeros(dim);
for i = 1:dim(1)
   for j = 1:dim(2)
      
         % Extract local region.
         iMin = max(i-w,1);
         iMax = min(i+w,dim(1));
         jMin = max(j-w,1);
         jMax = min(j+w,dim(2));
         I = D(iMin:iMax,jMin:jMax);
         
         % To compute weights from the color image
         J = C(iMin:iMax,jMin:jMax);
      
         % Compute Gaussian intensity weights according to the color image
         H = exp(-(J-C(i,j)).^2/(2*sigma_r^2));
      
         % Calculate bilateral filter response.
         F = H.*G((iMin:iMax)-i+w+1,(jMin:jMax)-j+w+1);
         B(i,j) = sum(F(:).*I(:))/sum(F(:));
               
   end
   %waitbar(i/dim(1));
end

%%
function B = jbfltND(D,C,w,sigma_d,sigma_r)

% Pre-compute Gaussian distance weights.
[X,Y] = meshgrid(-w:w,-w:w);
G = exp(-(X.^2+Y.^2)/(2*sigma_d^2));

% Create waitbar.
%h = waitbar(0,'Applying bilateral filter on gray image...');
%set(h,'Name','Bilateral Filter Progress');

% Apply bilateral filter.
dim = size(D);
B = zeros(dim);
for i = 1:dim(1)
   for j = 1:dim(2)
      
         % Extract local region.
         iMin = max(i-w,1);
         iMax = min(i+w,dim(1));
         jMin = max(j-w,1);
         jMax = min(j+w,dim(2));
         I = D(iMin:iMax,jMin:jMax);
         
         % To compute weights from the color image
         J = C(iMin:iMax,jMin:jMax,:);
         H=zeros(size(J,1),size(J,2));
         % Compute Gaussian range weights.
         for jj=1:size(C,3)
             dC = J(:,:,jj)-C(i,j,jj);
             H=dC.^2+H;
         end
         H=H/max(H(:));
         H=exp(-H/(2*sigma_r^2));
             
         
      
         % Compute Gaussian intensity weights according to the color image
         %H = exp(-(J-C(i,j)).^2/(2*sigma_r^2));
      
         % Calculate bilateral filter response.
         F = H.*G((iMin:iMax)-i+w+1,(jMin:jMax)-j+w+1);
         B(i,j) = sum(F(:).*I(:))/sum(F(:));
               
   end
   %waitbar(i/dim(1));
end
% Close waitbar.
%close(h);