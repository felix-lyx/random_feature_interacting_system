%
% Main function of random feature models for learning interacting dynamical systems 
%

%% Set path
if ispc, SAVE_DIR = [getenv('USERPROFILE'), '\DataAnalyses\LearningDynamics']; else, SAVE_DIR = [getenv('HOME'), '/DataAnalyses/LearningDynamics']; end % Please keep this fixed, simply create a symlink ~/DataAnalyses pointing wherever you like                           

VERBOSE                         = 1;                                                                % indicator to print certain output
if ~exist('Params','var'), Params = [];     end
if ~exist(SAVE_DIR,'dir'), mkdir(SAVE_DIR); end

%% Tunable parameters

use_derivative = false;

solver_type = 'pinv'; % pinv, htp
HTP_sparsity = 150;
HTP_MaxNbIter = 800;

num_basis = 1000;  % scalar for homogeneous systems, matrix for heterogeneous systems 
use_random_feature = 1;
normalize_basis = 1;
feature_type = 'gaussian'; % cos, gaussian
weight_sample_mean = 0;
weight_sample_stdv = 10;

%% Load example definitions and let user select one example to run
Examples                        = LoadExampleDefinitions();
ExampleIdx                      = SelectExample(Params, Examples);

%% Get example parameters
Example                         = Examples{ExampleIdx};
Example.obs_info.use_derivative = use_derivative;
Example.learn_info.solver_type  = solver_type;
Example.learn_info.sparsity = HTP_sparsity;
Example.learn_info.MaxNbIter = HTP_MaxNbIter;

if Example.sys_info.ode_order>1
    Example.learn_info.Abasis_info.n = num_basis;
    Example.learn_info.Abasis_info.normalize = normalize_basis;
    Example.learn_info.Abasis_info.is_random_feature = use_random_feature;
    Example.learn_info.Abasis_info.feature_type = feature_type;
    Example.learn_info.Abasis_info.mu = weight_sample_mean;
    Example.learn_info.Abasis_info.sigma = weight_sample_stdv;
else
    Example.learn_info.Ebasis_info.n = num_basis;
    Example.learn_info.Ebasis_info.normalize = normalize_basis;
    Example.learn_info.Ebasis_info.is_random_feature = use_random_feature;
    Example.learn_info.Ebasis_info.feature_type = feature_type;
    Example.learn_info.Ebasis_info.mu = weight_sample_mean;
    Example.learn_info.Ebasis_info.sigma = weight_sample_stdv;
end

sys_info                        = Example.sys_info;
solver_info                     = Example.solver_info;
obs_info                        = Example.obs_info;                                          
learn_info                      = Example.learn_info;
plot_info                       = Example.plot_info;

reuse_rho_T                     = false;
n_trials                        = 1;                                                                % Number of learning rounds

learn_info.to_predict_LN        = true;
learn_info.is_parallel          = false;                                                            % Some fine-tuning of learning parameters
learn_info.keep_obs_data        = true;
learn_info.VERBOSE              = VERBOSE;
learn_info.SAVE_DIR             = SAVE_DIR;
learn_info.MEMORY_LEAN          = true;
obs_info.compute_pICs           = false;
obs_info.VERBOSE                = VERBOSE;
obs_info.SAVE_DIR               = SAVE_DIR;

% obs_info.obs_noise              = 0.0;
if obs_info.obs_noise>0
  obs_info.use_derivative     = true;
end

%% Start parallel pool
gcp
time_stamp                      = datestr(now, 30);

%% Generate \rho^L_T if needed
fprintf('\n================================================================================');
fprintf('\nGenerating rhoT......');
obs_info.rhoLT                  = generateRhoLT( sys_info, solver_info, obs_info, reuse_rho_T );
fprintf('done (%.2f sec).',obs_info.rhoLT.Timings);

%% Perform learning and test performance on trajectories
learn_tic = tic;
learningOutput                  = cell(1,n_trials);
learn_info.sys_info             = sys_info;
fprintf('\n================================================================================');
fprintf('\nLearning Interaction Law(s)......');
for trial_idx = 1:n_trials
  if VERBOSE >= 1, fprintf('\n------------------- Learning with trial ID#%3d.', trial_idx); end
  learningOutput{trial_idx}     = learningRoutine( solver_info, obs_info, learn_info );               % Learning
end
fprintf('\n------------------- Overall time for learning: %.2f',toc(learn_tic));

%% Test the performance on phi_hats (and regularized phi_hats)
fprintf('\n================================================================================');
L2rhoTErr_tic  = tic;
fprintf('\nComputing L2(rhoT) Errors......');
rStr        = '';
fprintf('\n------------------- L2(rho_T) Error with trial ID#: ');
for k = n_trials:-1:1
  learningOutput{k}.L2rhoTErr = computeL2rhoTErr(learningOutput{k}.Estimator, sys_info, obs_info);
  msg                         = sprintf('%3d', k);
  fprintf([rStr, msg]);
  rStr                        = repmat(sprintf('\b'), 1, length(msg));
end
fprintf('\n------------------- Overall time for computing L2(rho_T) errors: %.2f',toc(L2rhoTErr_tic));

%% Test performance on trajectories
fprintf('\n================================================================================');
trajErr_tic = tic;
fprintf('\nComputing Trajectory Errors......');
rStr        = '';
if isfield(learn_info, 'to_predict_LN') && learn_info.to_predict_LN
  obs_info.N_ratio   = learn_info.N_ratio;
  sys_info_Ntransfer = restructure_sys_info_for_larger_N(learn_info.N_ratio, sys_info);
else
  sys_info_Ntransfer = [];
end
fprintf('\n------------------- Trajectory Error with trial ID#: ');
for k = n_trials:-1:1
  learningOutput{k}.Timings.estimateTrajAccuracies = tic;
  [learningOutput{k}.trajErr,learningOutput{k}.trajErr_new, learningOutput{k}.y_init_new, learningOutput{k}.trajErr_Ntransfer, ...
  learningOutput{k}.y_init_Ntransfer, learningOutput{k}.syshatsmooth_info_Ntransfer] = ...
  estimateTrajAccuracies(sys_info, learningOutput{k}.syshatsmooth_info, learningOutput{k}.obs_data, obs_info, solver_info, sys_info_Ntransfer); % Testing performance on trajectories
  learningOutput{k}.Timings.estimateTrajAccuracies = toc( learningOutput{k}.Timings.estimateTrajAccuracies );
  msg                                              = sprintf('%3d', k);
  fprintf([rStr, msg]);
  rStr                                             = repmat(sprintf('\b'), 1, length(msg));
end
fprintf('\n------------------- Overall time for computing trajecotry errors: %.2f',toc(trajErr_tic));

%% Save
plot_info.save_file = sprintf('%s/%s_learningOutput%s.mat', SAVE_DIR, sys_info.name, time_stamp);
save(plot_info.save_file, '-v7.3', 'sys_info', 'solver_info', 'obs_info', 'learn_info', 'plot_info', ...
     'learningOutput', 'sys_info_Ntransfer', 'time_stamp');
%% Display & figures
if VERBOSE >= 1
  alpha = learningOutput{1,1}.Estimator.alpha;
  [alpha_abs, idx] = sort(abs(alpha), 'descend');
  alpha = alpha(idx);
  figure;
  if strcmp(Example.learn_info.solver_type, 'htp')
    x = 1:Example.learn_info.sparsity;
    alpha_abs = alpha_abs(1:length(x));
    alpha = sort(alpha(1:length(x)), 'descend');
  else
    x = 1:length(alpha);
    alpha = sort(alpha, 'descend');
  end
  plot(x,alpha);
  hold on;
  plot(x,alpha_abs);
  hold off;
  final_visualization(learningOutput, obs_info, solver_info, sys_info, sys_info_Ntransfer, learn_info, time_stamp, plot_info);
end

%% Done
fprintf('\ndone.\n');

return