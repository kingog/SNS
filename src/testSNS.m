% This script runs a test to make sure that the SNS software works 
% correctly.
%
% Copyright Oliver King, June 2010
% ogk@astro.caltech.edu
%

clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modify this to point to the directory in which this file is stored:
pth = '~/matlab/SNS/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath([pth 'pointers/']);
addpath([pth 'snsTest/']);

syms a1 b1 c1
S1 = [a1 b1 c1; b1 a1 0; c1 0 a1];
syms c11 c12 c13
cc1 = [c11;c12;c13];
syms a2 b2
S2 = [a2 b2; b2 a2];
syms c21 c22
cc2 = [c21;c22];
syms a3 b3
S3 = [a3 b3; b3 a3];
syms c31 c32
cc3 = [c31;c32];
num = 0;

NI1 = makeNode(); NO1 = makeNode(); NO2 = makeNode();
NC1 = makeNode(); NC2 = makeNode();
P1 = makeNport(); P2 = makeNport(); P3 = makeNport();
P1.S = S1; P1.c = cc1;
P2.S = S2; P2.c = cc2;
P3.S = S3; P3.c = cc3;

connectNode(NI1,[],1,P1,1);

connectNode(NO1,P2,2,[],1);
connectNode(NO2,P3,2,[],1);

connectNode(NC1,P1,2,P2,1);
connectNode(NC2,P1,3,P3,1);

inputs = {NI1};
outputs = {NO1 NO2};
cnodes = {NC1 NC2};
tnodes = {};
    
disp('Calculating equivalent network scattering matrix using two methods:')
disp('    Using Hallbjorner algorithm')
tic
Shall = getScatteringHallbjorner(inputs,outputs,cnodes,tnodes,num);
toc

disp('    Using recursive algorithm')
tic
[Srec,crec] = getScatteringRecursive(inputs,outputs,cnodes,tnodes,num);
toc

disp('Hallbjorner - recursive:')
HmR = simplify(Shall - Srec)

if sum(sum(abs(HmR)))==0
    disp('SNS installation works with algebraic quantities.')
else
    disp('No luck. SNS installation does not work with algebraic quantities.')
end

% Do a test with some real data to see if numerical simulations work:
disp('Performing numerical simulation of this network:')
disp('')
disp('       --       --       --       --       --')
disp('   o--|  |--o--|  |--o--|  |--o--|  |--o--|  |--o')
disp('       --       --       --       --       --')
disp('    TXLine  Attenuator TXLine Amplifier  TXLine')
disp('')
disp('  If your installation works, two plots will appear.')
disp('  The first will show the S-parameters. The SNS points')
disp('  should match the Designer simulations.')
disp('  The second plot shows the input-referenced noise')
disp('  temperature of the amplifier and the cascaded network.')

% Now, read in a bunch of files:
fnTX = 'SNStestTXline.s2p';
fnAmp = 'SNStestAmp.s2p';
fnAtt = 'SNStestAtt.s2p';
fnFULL = 'SNStestFull.s2p';
[ftx,Stx] = importS2P(fnTX);
[famp,Samp] = importS2P(fnAmp);
[fatt,Satt] = importS2P(fnAtt);
[ffull,Sfull] = importS2P(fnFULL);

% Create the network:
% Port 1 <-> TXline - Att - TXline - Amp - TXline <-> Port 2
%   In1        P1  c1  P2 c2  P3  c3  P4 c4 P5    On1
In1 = makeNode(); On1 = makeNode(); cn1 = makeNode();
cn2 = makeNode(); cn3 = makeNode(); cn4 = makeNode();
P1 = makeNport(); P2 = makeNport(); P3 = makeNport();
P4 = makeNport(); P5 = makeNport();

syms c11 c12 c21 c22 c31 c32 c41 c42 c51 c52
c1 = [c11; c12]; c2 = [c21; c22];
c3 = [c31; c32]; c4 = [c41; c42];
c5 = [c51; c52];
P1.S = Stx; P1.c = c1;
P2.S = Satt; P2.c = c2;
P3.S = Stx; P3.c = c3;
P4.S = Samp; P4.c = c4;
P5.S = Stx; P5.c = c5;
connectNode(In1,[],1,P1,1);
connectNode(cn1,P1,2,P2,1);
connectNode(cn2,P2,2,P3,1);
connectNode(cn3,P3,2,P4,1);
connectNode(cn4,P4,2,P5,1);
connectNode(On1,P5,2,[],1);

[S,c] = getScatteringRecursive({In1},{On1},{cn1 cn2 cn3 cn4},{},1);

cvectors = {c1 c2 c3 c4 c5};
Tp = 15; % Assume that everything is at 15 K.
C1 = getNoiseCorrelationMatrix(Stx,Tp);
C2 = getNoiseCorrelationMatrix(Satt,Tp);
C3 = C1;
% simple amp noise model
C4 = getAmplifierNoiseCorrelationMatrix(Samp,Tp,1100);
C5 = C1;
Cmatrices = {C1 C2 C3 C4 C5};
P = getOutputNoise(c(2,1,:),cvectors,Cmatrices);

figure
subplot(2,2,1)
plot(ffull,20*log10(abs( squeeze(Sfull(1,1,:)) )),'k-',...
    ffull,20*log10(abs( squeeze(S(1,1,:)) )),'k*')
xlabel('Freq [GHz]')
ylabel('S11 amp [dB]')
legend('Designer','SNS')
subplot(2,2,3)
plot(ffull,angle(squeeze(Sfull(1,1,:))),'k-',...
    ffull,angle(squeeze(S(1,1,:))),'k*')
xlabel('Freq [GHz]')
ylabel('S11 phase [rad]')
legend('Designer','SNS')
subplot(2,2,2)
plot(ffull,20*log10(abs( squeeze(Sfull(2,1,:)) )),'k-',...
    ffull,20*log10(abs( squeeze(S(2,1,:)) )),'k*')
xlabel('Freq [GHz]')
ylabel('S21 amp [dB]')
legend('Designer','SNS')
subplot(2,2,4)
plot(ffull,angle(squeeze(Sfull(2,1,:))),'k-',...
    ffull,angle(squeeze(S(2,1,:))),'k*')
xlabel('Freq [GHz]')
ylabel('S21 phase [rad]')
legend('Designer','SNS')

% Input-referenced noise temperature is:
T = sum(P./repmat(S(2,1,:).*conj(S(2,1,:)),[size(P,1),1,1]),1);

figure
plot(ffull,squeeze(T),'k-',ffull,squeeze(C4(2,2,:)./(Samp(2,1,:).*conj(Samp(2,1,:)))),'r-')
xlabel('Freq [GHz]')
ylabel('Noise temperature [K]')
legend('Full model noise temp','Amplifier noise temp','Location','NorthEast')
