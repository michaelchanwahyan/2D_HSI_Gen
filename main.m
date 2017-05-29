close all
clear
clc
% load image data
load HSI_AVIRIS_CUPRITE                             % loaded variable : HSI
HSI            = HSI(:,:,[3:103,114:147,168:220]) ; % trancate noisy and
                                                    % water absorption band
HSI            = HSI - min(HSI(:)) ;
view_alpha     = 0.7 ;
HSI            = HSI / ([view_alpha  , (1-view_alpha)]*...
                        [min(HSI(:)) ; mean(HSI(:))]   ) ;
% load wavelength data
load HSI_AVIRIS_wavelength % loaded variable : "wavelength"
useRGB = true ;

% ------------------------------
% full-spectral resolution image
% ------------------------------
band_separat   = 3 ;
HSI_3D_PERSP   = GEN_2DHSI( HSI , wavelength , band_separat , useRGB ) ;
figure , imshow( HSI_3D_PERSP ) ;
imwrite( HSI_3D_PERSP , 'HSI.png' ) ;
unix( 'convert HSI.png HSI.eps' ) ;

% -------------------------------
% multi-spectral resolution image
% -------------------------------
wavelength_idx = [ 7     , 15    , 21    , 27    , 68    , 45 ] ; % TM sensor spec
%the band in nm :  0.465 , 0.540 , 0.605 , 0.660 , 0.740 , 0.810 ] ;
wavelength_MS  = wavelength( wavelength_idx ) ;
MS             = HSI(:,:,wavelength_idx) ;
view_alpha     = 0.6 ;
MS             = MS / ([view_alpha , (1-view_alpha)]*...
                       [min(MS(:)) ; max(MS(:))]     ) ;
band_separat   = 40 ;
MS_3D_PERSP    = GEN_2DHSI( MS , wavelength_MS , band_separat , useRGB ) ;
figure , imshow( MS_3D_PERSP ) ;
imwrite( MS_3D_PERSP , 'MS.png' ) ;
unix( 'convert MS.png MS.eps' ) ;

% -------------------------------
% hyper-spectral resolution image
% -------------------------------
dsRatio        = 4 ;
m              = ceil( size(HSI,1)/dsRatio ) ;
n              = ceil( size(HSI,2)/dsRatio ) ;
HS             = zeros( m , n , size(HSI,3) ) ;
for k = 1 : size(HSI,3)
    HS(:,:,k)  = imresize(HSI(:,:,k),[m,n]) ;
end
view_alpha     = 0.8 ;
HS             = HS / ([view_alpha  , (1-view_alpha)]*...
                     [min(HSI(:)) ; mean(HSI(:))]   ) ;
band_separat   = 3 ;
HS_3D_PERSP    = GEN_2DHSI( HS , wavelength , band_separat , useRGB ) ;
figure , imshow( HS_3D_PERSP ) ;
imwrite( HS_3D_PERSP , 'HS.png' ) ;
unix( 'convert HS.png HS.eps' ) ;