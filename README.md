# 2D_HSI_Gen (2D Hyperspectral Image Generator)

Run main.m

Basic useful feature list:

 * Visualize a 3D Hyperspectral Image
  * Favor fancy presentation on Hyperspectral Super-resolution

  Edit
   * GEN_opt.type for the type of spectral image. Support 
     * Full spectral image (high spatial res. and high spectral res.),
     * Multispectral image (high spatial res. and low spectral res.), and
     * Hyperspectral image (low spatial res. and high spectral res.)
   * GEN_opt.outputExt for output file type. Support 
     * 'png' (all Operating Systems) and 
     * 'eps' (Linux system with "convert" cmd).
   * GEN_opt.outputFileName for output file name
     * If you want the output file to be "output.png", then the following is what you should do
       ```MATLAB
        GEN_opt.outputFileName = 'output' ;
        GEN_opt.outputFileName = 'png'    ;
        ```
   * GEN_opt.dsRatio for down-sampling ratio 
     * Please give a ratio that makes sense ;-)
     * If GEN_opt.dsRatio = 4 , it downscale the image in the two spatial direction by factor 4.
   * GEN_opt.RGBIMG for color image representation.
     * If you do not have a color image of your hyperspectral image, you may remove this field by the following. The program itself gives a color image for you.
       ```MATLAB
        GEN_opt = rmfield( GEN_opt , 'RGBIMG' ) ;
        ```
    * GEN_opt.background for background color. Currently support
      * white, by assigning 'white'
      * black, by assigning 'black'
      * default background color is black.
    
The output image is something similar the Fig. 1 of "Hyperspectral Super-Resolution by Coupled Spectral Unmixing".

### Reference

 * [iccv15] C. Lanaras, E. Baltsavias and K. Schindler,  2015 IEEE International Conference on Computer Vision (ICCV), Santiago, 2015, pp. 3586-3594.(https://www1.ethz.ch/igp/photogrammetry/publications/pdf_folder/lanaras_etal_iccv15.pdf), or
 http://ieeexplore.ieee.org/document/7410766/

