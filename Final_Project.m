clear all;
close all;
clc;

%% Radar Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 77GHz
% Max Range = 200m
% Range Resolution = 1 m
% Max Velocity = 100 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rmax = 200;
Rres = 1;
Vmax = 100;

%speed of light = 3e8
%% User Defined Range and Velocity of target
% *%TODO* :
% define the target's initial position and velocity. Note : Velocity
% remains contant

initPos = 150; %m  
Vel = -20; %m/s
c = 3e8;  %light speed


%% FMCW Waveform Generation

% *%TODO* :
%Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
% chirp using the requirements above.
% Bsweep = C/2/d_res = c/2/1m;
Bs = c/2/Rres;
Tchirp = 5.5*2*Rmax/c;
slope = Bs/Tchirp;

%Operating carrier frequency of Radar 
fc= 77e9;             %carrier freq

                                                          
%The number of chirps in one sequence. Its ideal to have 2^ value for the ease of running the FFT
%for Doppler Estimation. 
Nd=128;                   % #of doppler cells OR #of sent periods % number of chirps

%The number of samples on each chirp. 
Nr=1024;                  %for length of time OR # of range cells

% Timestamp for running the displacement scenario for every sample on each
% chirp
t=linspace(0,Nd*Tchirp,Nr*Nd); %total time for samples


%Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(t)); %transmitted signal
Rx=zeros(1,length(t)); %received signal
Mix = zeros(1,length(t)); %beat signal

%Similar vectors for range_covered and time delay.
r_t=zeros(1,length(t));
td=zeros(1,length(t));


%% Signal generation and Moving Target simulation
% Running the radar scenario over the time. 

for i=1:length(t)         
    
    
    % *%TODO* :
    %For each time stamp update the Range of the Target for constant velocity. 
    r_t(i) = initPos + Vel*t(i);
    td(i) = 2*r_t(i)/c;
    
    % *%TODO* :
    %For each time sample we need update the transmitted and
    %received signal. 
    Tx(i) = cos(2*pi*(fc*t(i)+slope*(t(i)^2)*0.5));
    delay = t(i)-td(i);
    Rx(i) = cos(2*pi*(fc*delay+slope*(delay^2)*0.5));
    
    % *%TODO* :
    %Now by mixing the Transmit and Receive generate the beat signal
    %This is done by element wise matrix multiplication of Transmit and
    %Receiver Signal
    Mix(i) = Tx(i)*Rx(i);
    
end

%% RANGE MEASUREMENT


 % *%TODO* :
%reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
%Range and Doppler FFT respectively.
newMix = reshape(Mix,[Nr,Nd]);

 % *%TODO* :
%run the FFT on the beat signal along the range bins dimension (Nr) and
%normalize.
range_fft = fft(newMix)/Nr;

 % *%TODO* :
% Take the absolute value of FFT output
range_fft = abs(range_fft);

 % *%TODO* :
% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Hence we throw out half of the samples.
range_fft = range_fft(1:Nr/2+1,1);

%plotting the range
figure ('Name','Range from First FFT')
subplot(2,1,1)
f = (0:Nr/2)/Tchirp;
plot(f, range_fft);
xlabel('frequency Hz');

 % *%TODO* :
 % plot FFT output 
subplot(2,1,2)
R = (c*Tchirp*f)/(2*Bs);
plot(R, range_fft);
axis ([0 200 0 1]);
xlabel('meter');

%% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here. This will run a 2DFFT
% on the mixed signal (beat signal) output and generate a range doppler
% map.You will implement CFAR on the generated RDM


% Range Doppler Map Generation.

% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

Mix=reshape(Mix,[Nr,Nd]);

% 2D FFT using the FFT size for both dimensions.
sig_fft2 = fft2(Mix,Nr,Nd);

% Taking just one side of signal from Range dimension.
sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift (sig_fft2);
RDM = abs(sig_fft2);
% RDM = 10*log10(RDM);
RDM = pow2db(RDM);

%use the surf function to plot the output of 2DFFT and to show axis in both
%dimensions
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure(2),surf(doppler_axis,range_axis,RDM);

%% CFAR implementation

%Slide Window through the complete Range Doppler Map

% *%TODO* :
%Select the number of Training Cells in both the dimensions.
Tr = 12;
Td = 6;
% *%TODO* :
%Select the number of Guard Cells in both dimensions around the Cell under 
%test (CUT) for accurate estimation
Gr = 6;
Gd = 3;
% *%TODO* :
% offset the threshold by SNR value in dB
offset = 7.0;

% *%TODO* :
%Create a vector to store noise_level for each iteration on training cells
noise_level = zeros(1,1);


% *%TODO* :
%design a loop such that it slides the CUT across range doppler map by
%giving margins at the edges for Training and Guard Cells.
%For every iteration sum the signal level within all the training
%cells. To sum convert the value from logarithmic to linear using db2pow
%function. Average the summed values for all of the training
%cells used. After averaging convert it back to logarithimic using pow2db.
%Further add the offset to it to determine the threshold. Next, compare the
%signal under CUT with this threshold. If the CUT level > threshold assign
%it a value of 1, else equate it to 0.


   % Use RDM[x,y] as the matrix from the output of 2D FFT for implementing
   % CFAR
num_trainCell = (2*Tr+2*Gr+1)*(2*Td+2*Gd+1) - (2*Gr+1)*(2*Gd+1);

% create signal_CFAR to store final results
signal_CFAR = zeros(Nr/2,Nd);

% create threshold to store generated threshold
threshold = zeros(Nr/2,Nd);

for i = Tr+Gr+1:Nr/2-(Tr+Gr)
    for j = Td+Gd+1:Nd-(Td+Gd)
        
        % extract RDM of total cell
        % extract RDM of guard cell
        % calculate sum of RDM of train cell
        % calculate average noise_level(threshold)+offset
        % transfer threshold from db back to pow
        RDM_total = db2pow(RDM(i-Tr-Gr:i+Tr+Gr, j-Td-Gd:j+Td+Gd));
        RDM_guard = db2pow(RDM(i-Gr:i+Gr, j-Gd:j+Gd));
        noise_level = sum(RDM_total, 'all')-sum(RDM_guard,'all');
        thresh = pow2db(noise_level/num_trainCell)+offset;
%         thresh = db2pow(thresh);
        
        % update threhsold matrix
        threshold(i,j) = thresh;
        
        % extract signal from RDM and transfer the signal point from db to
        % pow
%         signal = db2pow(RDM(i,j));
        signal = RDM(i,j);
        if (signal>thresh)
            signal_CFAR(i,j) = 1;
        else
            signal_CFAR(i,j) = 0;
        end
    end
end

% *%TODO* :
% The process above will generate a thresholded block, which is smaller 
%than the Range Doppler Map as the CUT cannot be located at the edges of
%matrix. Hence,few cells will not be thresholded. To keep the map size same
% set those values to 0. 
 


% *%TODO* :
%display the CFAR output using the Surf function like we did for Range
%Doppler Response output.
figure,surf(doppler_axis,range_axis,signal_CFAR);
% hold on, surf(doppler_axis,range_axis,db2pow(RDM)/(max(max(db2pow(RDM)))));
% hold on, surf(doppler_axis,range_axis,threshold);
colorbar;

