function Hd = Receiver_Baseband_FIR_Coeff
%TRANSMITTER_BASBAND_FIR_COEFF Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.12 and DSP System Toolbox 9.14.
% Generated on: 22-Apr-2023 09:36:36

% Equiripple Lowpass filter designed using the FIRPM function.

% All frequency values are in Hz.
Fs = 44100*5;  % Sampling Frequency

Fpass = 10000;           % Passband Frequency
Fstop = 11000;           % Stopband Frequency
Dpass = 0.057501127785;  % Passband Ripple
Dstop = 0.0001;          % Stopband Attenuation
dens  = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);

% [EOF]
