%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Output:
%             morph_profiles: morphlogical profiles containing openings and
%             closings;
%    
%     Input:  
%             input:          input image
%             type_g:         the type of granulometry
%             type_se:        the type of the structure elements
%             num_scale:      the scales of openings and closings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function morph_profiles=getmorphprofiles(input,type_g,type_se,num_scales)

p = fileparts(mfilename('fullpath'));
addpath(fullfile(p,'fastmorphology'));
addpath(fullfile(p,'granulometry'));

train_image=input;
scales=num_scales;
operator=type_g;


g=granulometry(operator,type_se);

%create openings with scales
open_profiles = GenerateFirstNScales(g,train_image,scales);

%create closings with scales
close_profiles = GenerateFirstNScales(g,imcomplement(train_image),scales);

for i=1:scales
  %figure;imagesc(close_profiles{i});title(sprintf('Closing %d ',i));

    close_profiles{i}=imcomplement(close_profiles{i});
  
  %figure;imagesc(open_profiles{i}); title(sprintf('Open %d ',i));
  %figure;imagesc(close_profiles{i});title(sprintf('Closing incomplement %d ',i));

end
morph_profiles=[open_profiles, close_profiles];
morph_profiles=double(cat(3, morph_profiles{:}));
