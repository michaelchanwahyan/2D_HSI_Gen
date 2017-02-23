function F = construct_F_Uniform( HSI , MS_bandNum )

HS_bandNum = size( HSI , 3 ) ;
intvl      = round( linspace( 1 , HS_bandNum , MS_bandNum+1 ) ) ;
F          = zeros( MS_bandNum , HS_bandNum ) ;
for k = 1 : MS_bandNum
    F( k , intvl(k):intvl(k+1) ) = 1 ;
end
F = F ./ repmat( sum(F,2) , 1 , HS_bandNum ) ;

end