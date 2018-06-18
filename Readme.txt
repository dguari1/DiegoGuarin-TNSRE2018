This folder contains all the files necesary to execute the TV-IRF identification method proposed in 
D.L Guarin and R.E. Kearney 'Unbiased Estimation of Human Joint Mechanical Properties during Movement'

The folder includes two experimental data sets and the implementation of the proposed algorithms. 

The included funcions are:

- example_application.m -> Code used to estimate the intrinsic and reflex EMG-Torque, TV systems from experimental data
			   adquired during movement

- np_TV_ident.m -> Implementation of proposed TV-IRF identification algorithm

- TV_Bayes.m  -> Linear identification algorithm used for parameter estimation



Other tools included for completness:
- arg_parse_c.m  -> needed to read to optional input arguments
- vec.m -> vectorize a matrix
- VAFnl.m -> compute VAF
- generate_B_splines.m -> Generate B-Splines
- multi-tcheb.m -> Generate Tchebichev polynomials


This code is property of Diego L. Guarin, please email diego.guarinlopez at mail.mcgill.ca if you requiere further information.

