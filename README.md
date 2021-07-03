# Udacity-Radar-Final-Project
Purpose of the Project:
- Create synthetic radar signal. Then, apply 2D FFT and CFAR detection algorithm to detect speed and and range of the preceding object.


Matlab Code Summary:
- The first few sections focus on setting up parameters for preceding car, radar sensor pspecs and generating sythetic detection signal. The picture below is the 1D FFT of the first chirp signal.

![1DFFT_Radar_detection_signal](https://user-images.githubusercontent.com/15081906/124357306-6cbf4900-dc4d-11eb-86aa-6320b3f1e117.png)

- In section RANGE DOPPLER RESPONSE, 2D FFT is applied to process image. The picture below is the radar-doppler-map(RDM) created by 2D FFT process

![2DFFT_Radar_detection_signal](https://user-images.githubusercontent.com/15081906/124357403-e48d7380-dc4d-11eb-9147-3cc4dcc0d39b.png)

- In section CFAR implementation, the code starts with setting up training cell, guard cell and noise offset parameters. Then, run CFAR analysis through the whole RDM map to generate final radar detection result. The picture below is the final CFAR results.

![CFAR_Radar_detection_signal](https://user-images.githubusercontent.com/15081906/124357500-58c81700-dc4e-11eb-8bb1-fe800fafaaf2.png)

# To Run the Code
1. create a new .m file after Matlab IDE has been started
2. copy the script from file "Final_Project.m" in this repository to the newly-created .m file
3. Then, click run at top of m file editor
![image](https://user-images.githubusercontent.com/15081906/124357605-01767680-dc4f-11eb-8bb4-0834ba882aa0.png)

