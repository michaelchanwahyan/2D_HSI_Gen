function HSI_3D_PERSP = GEN_2DHSI( HSI , varargin )
fprintf( 'Generate HSI image in 3-D perspective\n' ) ;
% ======================= %
% check basic information %
% ======================= %
[ HSI_imgSizeM , HSI_imgSizeN , HSI_bandNum ] = size( HSI ) ;
switch nargin
    case 1 % only HSI is provided
        if( HSI_bandNum > 1 )
            wavelength = linspace( 400 , 700 , HSI_bandNum ) ;
        else
            error( 'too few hyperspectral band in the image ...' ) ;
        end
        pixel_skip = 1           ;
    case 2 % HSI and wavelength are provided
        wavelength = varargin{1} ;
        pixel_skip = 1           ;
    case 3 % HSI and wavelength and 3-D perspective pixel skip are provided
        wavelength = varargin{1} ;
        pixel_skip = varargin{2} ;
    otherwise
        error( 'too many input argument ...' ) ;
end
if( length(wavelength) ~= HSI_bandNum )
    error( 'provided wavelength mismatch the provided HSI image cube ...' ) ;
end
% ================================== %
% declare the R,G,B wavelength value %
% ================================== %
lambda_b = 465 ; % blue  : 465 nm
lambda_g = 540 ; % green : 540 nm
lambda_r = 605 ; % red   : 605 nm
alpha    = 100 ; % control scaling of R : G : B
% ================================ %
% create the HSI in 3D Perspective %
% ================================ %
HSI_3D_PERSP = ones( HSI_imgSizeM + pixel_skip*(HSI_bandNum-1) , ...
                     HSI_imgSizeN + pixel_skip*(HSI_bandNum-1) , 3 ) ;
[ ~ , HSI_3D_PERSP_sizeN , ~ ] = size( HSI_3D_PERSP ) ;
% ============================ %
% decide the wavelength order  %
% (thus the coloring order)    %
% IR to UV : sort by 'descend' %
% UV to IR: sort by 'ascend'   %
% ============================ %
wavelength = sort( wavelength , 'descend' ) ;
%wavelength = sort( wavelength , 'ascend' ) ;
for wCnt = 1 : HSI_bandNum
    lambda   = wavelength( wCnt ) ;
    titleStr = sprintf( 'processing: lambda = %d nm' , lambda ) ;
    fprintf( [titleStr,'\n'] ) ;
    c_r      = exp( -abs(lambda-lambda_r)/alpha ) ;
    c_g      = exp( -abs(lambda-lambda_g)/alpha ) ;
    c_b      = exp( -abs(lambda-lambda_b)/alpha ) ;
    c_rgbVec = permute( [ c_r , c_g , c_b ] , [ 3 , 1 , 2 ] ) ;
    if( lambda > lambda_r * 1.2 )
    % ==================================================== %
    % convex combination from highest wavelength           %
    % to prevent too dim color when far from R and G and B %
    % ==================================================== %
    beta = exp( -abs(lambda-max(wavelength))/(10*alpha) ) ;
    c_rgbVec = (1-beta) * c_rgbVec + beta * permute( ones(1,3) , [ 3 , 1 , 2 ] ) ;
    end
    HSI_3D_PERSP( (wCnt-1)*pixel_skip+1 : (wCnt-1)*pixel_skip+HSI_imgSizeM , ...
                  HSI_3D_PERSP_sizeN-(wCnt-1)*pixel_skip-HSI_imgSizeN+1 : HSI_3D_PERSP_sizeN-(wCnt-1)*pixel_skip , ...
                  : ) = repmat( HSI(:,:,wCnt) , 1 , 1 , 3 ) .* ...
                        repmat( c_rgbVec , HSI_imgSizeM , HSI_imgSizeN ) ;
end ; % end for w = wavelength
end