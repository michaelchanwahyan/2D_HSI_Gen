close all
clear
clc

load HSI
RGBIMG = HSI.RGB ;
HSI    = HSI.HSICUBE ;
HSI = HSI / max( HSI(:) ) ;
HSI( HSI < 0 ) = 0 ;

GEN_opt.type           = 'fullspectral'  ; GEN_opt.outputFileName = 'HSI' ;
%GEN_opt.type           = 'hyperspectral' ; GEN_opt.outputFileName = 'HS'  ;
%GEN_opt.type           = 'multispectral' ; GEN_opt.outputFileName = 'MS'  ;
GEN_opt.outputExt      = 'png' ;
GEN_opt.dsRatio        = 6     ;
GEN_opt.G              = construct_G_Gaussian( size(HSI,1) , size(HSI,2) , 11 , 4.7 , GEN_opt.dsRatio ) ;
GEN_opt.F              = construct_F_Uniform( HSI , 15 ) ;
GEN_opt.RGBIMG         = RGBIMG ;
GEN_opt.background     = 'white' ; % 'black' ;

GEN_2DHSI( HSI , GEN_opt ) ;
