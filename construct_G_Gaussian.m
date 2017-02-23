function G = construct_G_Gaussian( M , N , ks , sigVal , dsRatio )

H   = fspecial('Gaussian',ks,sigVal) ; [mH,nH] = size(H) ;

% -----------------------------------------------------------
% replicate image with periodic boundary ; usage: IMG(:)' * R
% -----------------------------------------------------------
R   = zeros( M , N ) ;
for i = 1 : numel(R)
    R(i) = i ;
end
R   = [ R(M-floor(ks/2)+1:M,:) ; R ; R(1:floor(ks/2),:) ] ;
R   = [ R(:,N-floor(ks/2)+1:N) , R , R(:,1:floor(ks/2)) ] ;
R   = sparse( R(:)' , 1:numel(R) , ones(1,numel(R)) , M*N , numel(R) ) ;

% -------------------------------------------------------------
% convolution matrix for Gaussian blurring ; usage: IMG(:)' * G
% -------------------------------------------------------------
    G    = convmtx2(H,M+ks-1,N+ks-1) ;
    % cut edge matrix (trancate the extended boundary due to convmtx2() ; usage: IMG(:)' * CUT 
    P    = zeros(M+2*(ks-1),N+2*(ks-1)) ;
    for i = 1 : numel(P)
        P(i) = i ;
    end
    P(:,1:(ks-1)) = 0 ; P(:,end-(ks-1)+1:end) = 0 ;
    P(1:(ks-1),:) = 0 ; P(end-(ks-1)+1:end,:) = 0 ;
    P_nonZero = P(:) > 0 ;
    iArr = 1:(M+2*(ks-1))*(N+2*(ks-1)) ;
    CUT  = sparse( iArr(P_nonZero) , 1:M*N , ones(1,M*N) , (M+2*(ks-1))*(N+2*(ks-1)) , M*N ) ;
G   = G' * CUT ;

% ----------------------------------------
% downsampling matrix ; usgae: IMG(:)' * D
% ----------------------------------------
Q   = zeros(M,N) ;
Q0  = Q ;
for i = 1 : numel(Q)
    Q(i) = i ;
end
Q0( 1 : dsRatio : end , 1 : dsRatio : end ) = Q( 1 : dsRatio : end , 1 : dsRatio : end ) ;
Q   = Q0 ;
Q_nonZero = Q(:) > 0 ;
iArr = 1 : M*N ;
D   = sparse( iArr(Q_nonZero) , 1:M*N/dsRatio^2 , ones(1,M*N/dsRatio^2) , M*N , M*N/dsRatio^2 ) ;

G   = R * G * D ;

return
end