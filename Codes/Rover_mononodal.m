clear ;
close all;
clc;

%% power
P_science = 188*0.6; 
P_eclipse = 186*0.6;

%% emittance and absorptance
% Materials for coating and radiators has been chosen from the MEX mission,
% after a better evaluation of the power generated inside the ground segment it
% could be revaluated 

eps_rad = 0.9;
eps_coat = 0.02;
alpha_coat = 0.07; %(Kapton Pag 194 TCS materials from ESA)

%% sphere parallelism
% in order to perform our single mode analysis we need to translate the
% info into a equivalent sphere. 
% compute the total area of the s/c, without considering solar panel. If
% needed, a computation of just the solar panels can be done.

D=0.782; %Diameter of lander surface [m]

r=D/2;

A=4*pi*(r^2);

%% heat sources
%we need to select the hot and cold case and compute the thermal 
% heat sources that hit our spacecraft in our environament. The main heat 
% sources are 3: Sun, Albedo and IR.
%For the solar flux you need to know q0 and the distance btwn s/c and Sun.

%% Sun

%q_Sun_min = 710;q_sun_min =490 
q_Sun = 589;  %[W/m2]


%% HOT
%% Albedo heat hot case
%it is at the closest the s/c is to the planet (pericentre)
% the albedo will be the greatest


albedo_factor = 0.4;   

q_Albedo_hot = q_Sun * albedo_factor; %[W/m2]


%% IR heat hot case 

T_planet = 350; %[K]   %Max surface temperature of the planet (250K is the average and 150 is the lowest value)
sigma =5.67e-8; %[W/(m2K4)] Boltzmann constant
eps = 0.71; 

q_IR_hot = sigma * eps * T_planet^4; %[W/m2]


%% hot scenario

A_cross = pi*r^2; %[m2]

Q_Sun = A_cross * alpha_coat * q_Sun;


% view factor, depend on distances, on shape of s/c... considering planet as sphere and s/c as sphere

F_pl_sc_hot = 0.09;

K_a = 1;  %diffusion factor of the planet, to be conservative we use 1

Q_albedo_hot = A * alpha_coat * F_pl_sc_hot * K_a * q_Albedo_hot ;  %[W]  

Q_IR_hot = A * F_pl_sc_hot * q_IR_hot;  %[W]

%now we compute the temperature of the s/c assuming static equilibtrium

Q_env = Q_Sun + Q_albedo_hot + Q_IR_hot;
Q_emitted_hot = Q_Sun + Q_albedo_hot + Q_IR_hot + P_science;

%such that

T_sc_max = 40-5+273;

T_sc_hot = (Q_emitted_hot/(sigma * eps_coat *A))^(1/4);     

% Computation of the radiators area to gurantee the temperature (if
% T_sc_hot > T_sc_max)

if T_sc_hot > T_sc_max
    fprintf('Radiators are needed')
    A_rad_min = (Q_emitted_hot - (sigma * eps_coat * A * T_sc_max^4))/(sigma * (eps_rad - eps_coat) * T_sc_max^4) * 1.1;% 20% margin is used
else
    A_rad_min = 0;
end






%% COLD
%% IR heat cold case

T_planet = 143; %[K]  
sigma =5.67e-8; %[W/(m2K4)] Boltzmann constant

eps = 0.71;

q_IR_cold = sigma * eps * T_planet^4; %[W/m2]

%% cold scenario

F_pl_sc_cold = 0.09;

Q_IR_cold = A * F_pl_sc_cold * q_IR_cold ;   %[W]

Q_emitted_cold = Q_IR_cold + P_eclipse;

%such that 
T_sc_min = -30 + 5 +273; 

T_sc_cold = (Q_emitted_cold/(sigma * eps_coat *A))^(1/4);

T_sc_cold_wradiator = (Q_emitted_cold/(sigma * (eps_coat *(A - A_rad_min) +eps_rad * A_rad_min)))^(1/4);

if T_sc_cold_wradiator<T_sc_min
    fprintf('\n Heaters are needed')
end
%the sizing of the heater becomes

Q_heaters_wradiator = sigma * (eps_coat *(A - A_rad_min) +eps_rad * A_rad_min) * T_sc_min^4 - Q_emitted_cold;

area_ratio_percentage = A_rad_min/A*100;
