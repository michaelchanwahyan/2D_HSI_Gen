close all
clear
clc

% load image data
load HSI_AVIRIS_CUPRITE    % loaded variable : "HSI"
% load wavelength data
load HSI_AVIRIS_wavelength % loaded variable : "wavelength"

HSI          = HSI(:,:,[3:103,114:147,168:220]) ; % trancate noisy and water absorption band
L            = 120 ;
HSI          = HSI(:,:,1:L) ;
wavelength   = wavelength(1:L) ;
HSI          = ( HSI - min(HSI(:)) ) / mean( [ min(HSI(:)) , mean(HSI(:)) ] ) ;
band_separat = 2 ;
HSI_3D_PERSP = GEN_2DHSI( HSI , wavelength , band_separat ) ;
figure , imshow( HSI_3D_PERSP ) ;