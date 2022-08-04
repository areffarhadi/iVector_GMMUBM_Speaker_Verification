# iVector_GMMUBM_Speaker_Verification on NIST2004 and NIST2008 speaker verification dataset
MATLAB implementation of DBN-based Speaker Verification using iVector and GMMUBM on the NIST04 and NIST08 dataset
in this code, we use Deep Belief Network as post-processing in the speech feature extraction stage to generate more efficient features using MFCC as DBN input.

we used MATLAB toolboxes:
  * DeeBNet
  * MSRIdentityToolkit

dbn.m is our proposed deep belief network that performs the post-processing in the DBNFea.m that is called in postProcessingFeatures.m
we train this net using the DeeBNet toolbox.
The proposed system is shown in figure (1). 


<p align="center">
  <img src="https://user-images.githubusercontent.com/93467718/182956237-77600943-1755-48b5-b1ef-87e2af077b2c.jpg">
 </p>
 <p align="center">
 Figure (1). DBN structure as the new feature extraction method
</p>


gmmUbmSpeakerVerification.m is prepared to use GMMUBM for speaker verification.
iVectorSpeakerVerification_jfa.m is prepared to use iVector and JFA for speaker verification.

It is necessary to mention that we used HTK for MFCC feature extraction and SSVAD [1] to remove silence in Linux.


[1] M.-W. Mak, and H.-B. Yu, “A study of voice activity detection techniques for NIST speaker recognition evaluations,” Computer Speech & Language, vol. 28, no. 1, pp. 295-313, 2014.
