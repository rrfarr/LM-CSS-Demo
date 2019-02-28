# LM-CSS-Demo
Face Super Resolution using Local Models of Coupled Sparse Support

This code contains various single image face super-resolution algorithms, including the LM-CSS method published in [1].
To run this code you can run the single_frame_SR_main() function, which is the main function through which a number of 
face super resolution algorithm can be evaluated. This function is the main function. This method generates a number 
of datasets that can be used to train various learning methods adopted in various stages of the respective algorithms. 
The purpose of this function is to be able to evaluate a number of face super-resolution methods found in literature 
and proposed methods on equal grounds.

The single_frame_SR_main_v01_01 does not take any input or output and is controled using the configuration parameters 
specified at the beginning of this file. The current list of algorithms considered up till now are 

1. BC - Bicubic Interpolation

2. NE - Neighbour-Embedding

3. ET - EigenTransformation

4. EP - EigenPatches

5. LINE - The LINE algorithm

6. LM_CSS: This method employs basis pursuit to derive the atomic decomposition of the dictionary which best represent the test sample to
he hallucinated. The final patch is then hallucinated using ridge  regression.

7. PP: Position Patch (Ma 2009)

8. SPP: Sparse Position Patch (Jung 2011)

# Dependencies

1.  Download the DATASET folder from the following link: https://drive.google.com/open?id=1SiysnOT6B1D46quA5du89618GDmIPqe3
    Unzip the file and make sure that the DATASET/ folder is placed in the root directory.

2. Download the SparseLab folder in the MATLAB/ folder of this project. https://sparselab.stanford.edu/

To run this code one must set SR_method to one of the above values e.g. LM_CSS will run the LM-CSS algorithm.

[1] R. A. Farrugia and C. Guillemot, "Face Hallucination Using Linear Models of Coupled Sparse Support," in IEEE Transactions on Image Processing, vol. 26, no. 9, pp. 4562-4577, Sept. 2017.
