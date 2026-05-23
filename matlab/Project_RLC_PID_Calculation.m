%% EEE302 - Series RLC Circuit Identification and Control
% Open-Loop Theoretical Analysis & Bode Plot
clc; clear; close all;

%% 1. Physical System Parameters
R = 100;        % Resistance in Ohms
L = 0.1;        % Inductance in Henrys
C = 10e-6;      % Capacitance in Farads (10 uF)

fprintf('--- Physical System Parameters ---\n');
fprintf('R: %d Ohm, L: %.2f H, C: %.1e F\n\n', R, L, C);

%% 2. Transfer Function Derivation
numerator = [1/(L*C)];
denominator = [1, R/L, 1/(L*C)];
G = tf(numerator, denominator);

figure('Name', 'Root Locus', 'Color', 'w');
rlocus(G); grid on; title('Root Locus of Open-Loop System');


fprintf('--- Open-Loop Transfer Function ---\n');
display(G);

%% 3. System Characteristics
[Wn, zeta] = damp(G);
fprintf('--- System Characteristics ---\n');
fprintf('Natural Frequency (Wn): %.2f rad/s\n', Wn(1));
fprintf('Damping Ratio (Zeta): %.4f\n', zeta(1));

%% 4. Theoretical Bode Plot
figure('Name', 'Theoretical Bode Plot', 'Color', 'w');
bode(G);
grid on;
title('Theoretical Bode Magnitude and Phase Plot');

%% 5. Open-Loop Step Response (5V Input)
figure('Name', 'Open-Loop Step Response', 'Color', 'w');
opt = stepDataOptions('StepAmplitude', 5);
% Simulated for 0.05 seconds to capture the underdamped oscillations clearly
step(G, 0.05, opt); 
grid on;
title('Open-Loop Step Response (5V Input without PID)');
xlabel('Time (seconds)');
ylabel('Capacitor Voltage (V)');

%% 6. Theoretical Performance Metrics (Open-Loop)
perf = stepinfo(G, 'SettlingTimeThreshold', 0.02);
fprintf('\n--- Theoretical Open-Loop Performance ---\n');
fprintf('Overshoot: %.2f %%\n', perf.Overshoot);
fprintf('Peak Time: %.4f seconds\n', perf.PeakTime);
fprintf('Settling Time (2%% criterion): %.4f seconds\n', perf.SettlingTime);

%% 7. Closed-Loop System with PID Controller
% Heuristically fine-tuned PID gains to meet time-domain and control effort targets
Kp = 1.1;
Ki = 233;
Kd = 0.0009;

fprintf('\n--- PID Controller Parameters ---\n');
fprintf('Kp: %.4f, Ki: %.4f, Kd: %.4f\n', Kp, Ki, Kd);

% Define the PID Controller Transfer Function C(s)
C_pid = pid(Kp, Ki, Kd);

% Calculate the Closed-Loop Transfer Function T(s) = (C*G) / (1 + C*G)
T_closed = feedback(C_pid * G, 1);

fprintf('\n--- Closed-Loop Transfer Function (T) ---\n');
display(T_closed);

%% 8. Closed-Loop Step Response (5V Reference)
figure('Name', 'Closed-Loop Step Response', 'Color', 'w');
opt_cl = stepDataOptions('StepAmplitude', 5);
% Simulated for 1.5 seconds to observe the settling time clearly
step(T_closed, 1.5, opt_cl); 
grid on;
title('Closed-Loop Step Response (5V Reference with PID)');
xlabel('Time (seconds)');
ylabel('Capacitor Voltage (V)');

%% 9. Theoretical Performance Metrics (Closed-Loop)
perf_cl = stepinfo(T_closed, 'SettlingTimeThreshold', 0.02);
fprintf('\n--- Theoretical Closed-Loop Performance ---\n');
fprintf('Overshoot: %.2f %%\n', perf_cl.Overshoot);
fprintf('Peak Time: %.4f seconds\n', perf_cl.PeakTime);
fprintf('Settling Time (2%% criterion): %.4f seconds\n', perf_cl.SettlingTime);