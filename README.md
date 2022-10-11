# Random Feature Models for Learning Interacting Dynamical Systems

Supplementary code for paper `Random Feature Models for Learning Interacting Dynamical Systems`.

Base code are from the following repositories:
- Repo1: [LearningDynamics/LearningDynamicsPNAS at master · mingjzhong/LearningDynamics (github.com)](https://github.com/mingjzhong/LearningDynamics/tree/master/LearningDynamicsPNAS)
- Repo2: [HTP/HTPCode at master · foucart/HTP (github.com)](https://github.com/foucart/HTP/tree/master/HTPCode)

Instructions for assembling the base code and our code:
- Step 1: Download folder `LearningDynamicsPNAS` from repo1 and open the folder.
- Step 2: Download folder `HTPCode` from repo2 and copy to folder `LearningDynmaicsPNAS`.
- Step 3: Download all files in this repository and copy to folder `LearningDynmaicsPNAS`, replace existing files in place. 
- Step 4: To run the code, first run `Startup_LearningDynamics.m` to add path to system, and then run `random_feature_main.m`. 

The final folder structure should be the following:

LearningDynamicsPNAS 

├─ HTP_code

├─ random_feature_util

├─ SOD_Evolve

├─ SOD_Examples

├─ SOD_External

├─ SOD_Learn

├─ SOD_Utils

├─ `Startup_LearningDynamics.m`

├─ `random_feature_main.m`

└─ `README.md`
