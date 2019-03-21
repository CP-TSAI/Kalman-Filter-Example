clc; clear all; close all;

% Example:
n = 3;      %number of state

q = 0.1;    %std of process 
r = 0.1;    %std of measurement
Q = q^2*eye(n); % covariance of process
R = r^2;        % covariance of measurement  

f = @(x)[x(2);x(3);0.05*x(1)*(x(2)+x(3))];  % nonlinear state equations
h = @(x)x(1);                               % measurement equation

s = [0;0;1];                                % initial state
x = s + q * randn(3,1); 		            % initial state with noise
P = eye(n);                                 % initial state covraiance

% start propagation
N = 20;                                     % total dynamic steps
xV = zeros(n,N);          				    % estimate       
sV = zeros(n,N);          				    % actual
zV = zeros(1,N);							% measurement

for k = 1 : N
  z = h(s) + r * randn;                     % measurments
  zV(k)  = z;                               % save measurment
  
  sV(:,k) = s;                              % save actual state
  
  [x, P] = ekf(f,x,P,h,z,Q,R);              % ekf 
  xV(:,k) = x;                              % save estimate
  
  s = f(s) + q * randn(3,1);                % update process 
end


for k=1:3                                   % plot results
  subplot(3,1,k)
  plot(1:N, sV(k,:), '-', 1:N, xV(k,:), '--')
end
