function DEMO_GEN_2DHSI( HSI , GEN_opt )
% ---------- %
% basic info %
% ---------- %
[ MS_imgSizeM , MS_imgSizeN , HS_bandNum ] = size( HSI ) ;
if( ~isfield( GEN_opt , 'outputFileName' ) ) ; error( 'Err: output file name is not specified !!!'               ) ; else outputFileName = GEN_opt.outputFileName ; end ;
if( ~isfield( GEN_opt , 'outputExt'      ) ) ; error( 'Err: output file format is not specified !!!'             ) ; else outputExt      = GEN_opt.outputExt      ; end ;
if( ~isfield( GEN_opt , 'type'           ) ) ; error( 'Err: image type is not specified !!!'                     ) ; else type           = GEN_opt.type           ; end ;
if( strcmp( type , 'hyperspectral' ) )
    if( ~isfield( GEN_opt , 'dsRatio'    ) ) ; error( 'Err: downsampling ratio is not specified !!!'             ) ; else dsRatio        = GEN_opt.dsRatio        ; end ;
    if( ~isfield( GEN_opt , 'G'          ) ) ; error( 'Err: spatial downsampling matrix G is not specified !!!'  ) ; else G              = GEN_opt.G              ; end ;
end
if( ~isfield( GEN_opt , 'F'              ) ) ; error( 'Err: spectral downsampling matrix F is not specified !!!' ) ; else F              = GEN_opt.F              ; end ;
if(  isfield( GEN_opt , 'RGBIMG'         ) ) ; useRGB         = true ; RGBIMG = GEN_opt.RGBIMG ;                             else useRGB         = false                  ; end ;
if(  isfield( GEN_opt , 'background'     ) )
    if(     strcmp( GEN_opt.background , 'white' ) ) ; backGndColor = [ 255 255 255 ]' ;
    elseif( strcmp( GEN_opt.background , 'black' ) ) ; backGndColor = [   0   0   0 ]' ;
    else fprintf( 'unknown background color option ... use default "black"\n' ) ; backGndColor = [   0   0   0 ]' ;
    end
end
Y = reshape( permute( HSI , [3,1,2] ) , HS_bandNum , MS_imgSizeM*MS_imgSizeN ) ;
% ----------------------------- %
% 2D image cube face definition %
% ----------------------------- %
%    --------
%   /       /
%  /  2    / |
%  -------   |
% |       |3 |
% |   1   | /
% |       |/
%  -------
switch type
    case 'hyperspectral'
        Y           = Y * G ;
        HS_imgSizeM = MS_imgSizeM / dsRatio ;
        HS_imgSizeN = MS_imgSizeN / dsRatio ;
        HSI         = reshape( Y' , HS_imgSizeM , HS_imgSizeN , HS_bandNum ) ;
    case 'multispectral'
        Y           = F * Y ;
        MS_bandNum  = size( Y , 1 ) ;
        HSI         = reshape( Y' , MS_imgSizeM , MS_imgSizeN , MS_bandNum ) ;
    case 'fullspectral'
        fprintf( 'Good. Full spectral image , no need to downsample!\n' ) ;
    otherwise
        error( 'Err: type error !!!' ) ;
end
% ----------------- %
% synthesize Face 1 %
% ----------------- %
switch type
    case 'hyperspectral'
        if( useRGB )
            Y    = reshape( permute( RGBIMG , [3,1,2] ) , 3 , MS_imgSizeM*MS_imgSizeN ) ;
            Y    = Y * G ;
            IMG1 = reshape( Y' , HS_imgSizeM , HS_imgSizeN , 3 ) ;
        else
            Y    = F * Y ;
            IMG1 = reshape( Y(7:-1:5,:)' , HS_imgSizeM , HS_imgSizeN , 3 ) ;
        end
    case 'multispectral'
        if( useRGB )
            IMG1 = RGBIMG ;
        else
            IMG1 = HSI(:,:,7:-1:5) ;
        end
    case 'fullspectral'
        if( useRGB )
            IMG1 = RGBIMG ;
        else
            Y    = F * Y ;
            IMG1 = reshape( Y(7:-1:5,:)' , MS_imgSizeM , MS_imgSizeN , 3 ) ;
        end
    otherwise
        error( 'Err: type error !!!' ) ;
end

pcolorNormConst = max( HSI(:) ) ;
% ----------------- %
% synthesize Face 2 %
% ----------------- %
HSI2  = permute( HSI , [3,2,1] ) ;
IMG2  = HSI2(:,:,1) ;
IMG2  = imgray2pcolor( IMG2 / pcolorNormConst, 'jet' , 255 ) ;
IMG2  = IMG2( end:-1:1 , : , : ) ; % reverse because Face 2 needs to be inverted in the output img
IMG2  = imresize( IMG2 , [round(0.5*size(IMG2,1)),size(IMG2,2)] ) ;
a     = -1 ; % 45 shearing use a == 1 !
T     = maketform('affine', [1 0 0; a 1 0; 0 0 1] ) ;
R     = makeresampler({'cubic','nearest'},'fill') ;
IMG2  = im2double( imtransform(IMG2,T,R,'FillValues',backGndColor) ) ;

% ----------------- %
% synthesize Face 3 %
% ----------------- %
HSI3  = permute( HSI , [1,3,2] ) ;
IMG3  = HSI3(:,:,end) ;
IMG3  = imgray2pcolor( IMG3 / pcolorNormConst , 'jet' , 255 ) ;
IMG3  = imresize( IMG3 , [size(IMG3,1),round(0.5*size(IMG3,2))] ) ;
a     = -1 ; % 45 shearing use a == 1 !
T     = maketform('affine', [1 a 0; 0 1 0; 0 0 1] );
R     = makeresampler({'cubic','nearest'},'fill');
IMG3  = im2double( imtransform(IMG3,T,R,'FillValues',backGndColor) ) ;

% --------------- %
% combine 3 Faces %
% --------------- %
IMG_backGnd = cat( 3 , backGndColor(1)*ones(size(IMG3,1),size(IMG1,2) ) ...
                     , backGndColor(1)*ones(size(IMG3,1),size(IMG1,2) ) ...
                     , backGndColor(1)*ones(size(IMG3,1),size(IMG1,2) ) ) ;
IMG = [ IMG_backGnd , IMG3 ] ;
IMG( end-size(IMG1,1)+1 : end , 1 : size(IMG1,2) , : ) = IMG1 ;
N = size( IMG1 , 2 ) ;
for k = 1 : size(IMG2,1)
    IMG( k , end - N + 1 - k + 1 : end - k + 1, : ) = IMG2( k , end - N + 1 - k + 1 : end - k + 1, : ) ;
end
fid = figure ; imshow( IMG ) ;
fprintf( 'finished\n' ) ;
switch outputExt
    case 'png'
        imwrite( IMG , [outputFileName,'.',outputExt] ) ;
    case 'eps'
        imwrite( IMG , [outputFileName,'.','png'] ) ;
        unix( ['convert ',outputFileName,'.png ',outputFileName,'.eps'] ) ;
    case 'fig'
        savefig( [outputFileName,'.',outputExt] ) ;
end

end




%%%%%%%%%%
%%%%%%%%%%




function rgb = imgray2pcolor(gim, map, n)
% IMGRAY2PSEUDOCOLOR transform a gray image to pseudocolor image
%   GIM is the input gray image data
%   MAP is the colormap already defined in MATLAB, for example:
%      'Jet','HSV','Hot','Cool','Spring','Summer','Autumn','Winter','Gray',
%      'Bone','Copper','Pink','Lines'
%   N specifies the size of the colormap 
%   rgb is the output COLOR image data
%
% Main codes stolen from:
%       http://www.alecjacobson.com/weblog/?p=1655
%       %% rgb = ind2rgb(gray2ind(im,255),jet(255));                      %
%                                                                           


[nr,nc,nz] = size(gim);
rgb = zeros(nr,nc,3);

if ( ~IsValidColormap(map) )
    disp('Error in ImGray2Pseudocolor: unknown colormap!');
elseif (~(round(n) == n) || (n < 0))
    disp('Error in ImGray2Pseudocolor: non-integer or non-positive colormap size');
else
    fh = str2func(ExactMapName(map));
    rgb = ind2rgb(gray2ind(gim,n),fh(n));
    rgb = uint8(rgb*255);
end

if (nz == 3)
    rgb = gim;
    disp('Input image has 3 color channel, the original data returns');
end

end

function y = IsValidColormap(map)

y = strncmpi(map,'Jet',length(map)) | strncmpi(map,'HSV',length(map)) |...
    strncmpi(map,'Hot',length(map)) | strncmpi(map,'Cool',length(map)) |...
    strncmpi(map,'Spring',length(map)) | strncmpi(map,'Summer',length(map)) |...
    strncmpi(map,'Autumn',length(map)) | strncmpi(map,'Winter',length(map)) |...
    strncmpi(map,'Gray',length(map)) | strncmpi(map,'Bone',length(map)) |...
    strncmpi(map,'Copper',length(map)) | strncmpi(map,'Pink',length(map)) |...
    strncmpi(map,'Lines',length(map));
end

function emapname = ExactMapName(map)

if strncmpi(map,'Jet',length(map))
    %emapname = 'Jet';
    emapname = 'jet';
elseif strncmpi(map,'HSV',length(map))
    %emapname = 'HSV';
    emapname = 'hsv';
elseif strncmpi(map,'Hot',length(map))
    %emapname = 'Hot';
    emapname = 'hot';
elseif strncmpi(map,'Cool',length(map))
    %emapname = 'Cool';
    emapname = 'cool';
elseif strncmpi(map,'Spring',length(map))
    %emapname = 'Spring';
    emapname = 'spring';
elseif strncmpi(map,'Summer',length(map))
    %emapname = 'Summer';
    emapname = 'summer';
elseif strncmpi(map,'Autumn',length(map))
    %emapname = 'Autumn';
    emapname = 'autumn';
elseif strncmpi(map,'Winter',length(map))
    %emapname = 'Winter';
    emapname = 'winter';
elseif strncmpi(map,'Gray',length(map))
    %emapname = 'Gray';
    emapname = 'gray';
elseif strncmpi(map,'Bone',length(map))
    %emapname = 'Bone';
    emapname = 'bone';
elseif strncmpi(map,'Copper',length(map))
    %emapname = 'Copper';
    emapname = 'copper';
elseif strncmpi(map,'Pink',length(map))
    %emapname = 'Pink';
    emapname = 'pink';
elseif strncmpi(map,'Lines',length(map))
    %emapname = 'Lines';
    emapname = 'lines';
end 

end