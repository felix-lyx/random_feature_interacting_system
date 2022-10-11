function Example = SheepFood_def()
% function Example = SheepFood_def()
% Define associated terms for Sheep-food interaction DYNAMICs

% System
sys_info.name           = 'SheepFoodDynamics';
sys_info.d              = 2;                                                                        % the dimension for the opinion (state) vecor
sys_info.shape = 3; % 1 - heart, 2 - circle, 3 - better heart
sys_info.R              = 5.;
N_sheep = 20;
N_food = 40;
sys_info.N              = N_sheep+N_food;                                                                        % the number of agents
sys_info.phiE{1,1}      = @(r) SF_sheep_on_sheep(r);
sys_info.phiE{1,2}      = @(r) SF_food_on_sheep(r);
sys_info.phiE{2,1}      = @(r) SF_sheep_on_food(r);
sys_info.phiE{2,2}      = @(r) SF_food_on_food(r);                                    % energy based influence
sys_info.K              = 2;                                                                        % number of classes
sys_info.ode_order      = 1;                                                                        % order of the ODE system
sys_info.type_info      = [ones(1, N_sheep),2*ones(1,N_food)];                                                      % class function mapping agent index to it class index
sys_info.kappa          = ones(1, sys_info.K);                                                                        % coupling strength term
sys_info.RE             = [];                                                                       % regulation on collective influence on x
sys_info.has_noise      = false;                                                                    % no stochastic noise

sys_info.mu0            = @() SF_init_config(sys_info.d, sys_info.N, N_sheep, N_food, sys_info.R, sys_info.shape);                        % distribution of initial conditions
sys_info.T_f            = 400; 

% ODE solver
solver_info.time_span   = [0, sys_info.T_f];                                                        % put it into the time_span vector, always starting from 0

% Observations
obs_info.L              = 600;                                                                      % observe (equi-spaced) times
obs_info.M              = 50;                                                                     % # trajectories with random initial conditions for learning interaction kernel
obs_info.M_rhoT         = 400;                                                                     % # trajectories with random initial conditions to compute approximate \rho_T
obs_info.T_L            = sys_info.T_f/4;                                                                     % Observations will be up to this time
obs_info.time_vec       = linspace(0, obs_info.T_L, obs_info.L);                                 % time instances at which discrete observation is made
obs_info.use_derivative = false;                                                                     % indicator of the availability of derivative data
obs_info.hist_num_bins  = 400;                                                                    % number of bins for estimating \rho^L_T for all three different interactions
obs_info.obs_noise      = 0.0; % 0.01;
obs_info.mu_trajnoise   = @(traj,sigma) trajUnifNoiseMultiplicative( traj, sigma );
obs_info.mu_dtrajnoise  = @(traj,sigma) trajUnifNoiseMultiplicative( traj, sigma );

% Learning
basis_info.n = [500,500;5,5];
basis_info.type         = 'standard';
basis_info.degree       = [1, 1; 0, 0];                                                                        % basis information
basis_info.normalize = true;

basis_info.is_random_feature = 1;
basis_info.feature_type = 'gaussian';
basis_info.sigma = 10;

learn_info.sparsity = 600;
learn_info.MaxNbIter = 500;

learn_info.Ebasis_info  = basis_info;

% package data
Example.sys_info        = sys_info;
Example.solver_info     = solver_info;
Example.obs_info        = obs_info;
Example.learn_info      = learn_info;
end
