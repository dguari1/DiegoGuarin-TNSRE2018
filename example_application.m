%loading data 
%File contains the raw perturbation position, torque and soleus EMG signals
%data is divided in trials. Each column represent 1 trial
%for an example with large reflex torque use 
load('large_reflex_data.mat')

%for an example with small reflex torque use 
%load('small_reflex_data.mat')

%there are 100 cycles, you need to define how many will be used for ID
trials=100;

%sampling rate was 1000Hz
T=1/1000;




%Extracting data
%we assume that data is periodic so it will be arrange as a single vector
%for preprosesing
POS_signal=vec(POSITION_SIGNAL(:,1:trials));
TOR_signal=vec(TORQUE_SIGNAL(:,1:trials));
EMG_SOL_signal=vec(EMG_SIGNAL(:,1:trials));

%data will be decimated to 100Hz
d_r=10;
Ts=T*d_r;
%decimation
pos_signal=decimate(POS_signal,d_r);
tor_signal=decimate(TOR_signal,d_r);
emg_sol_signal=decimate(EMG_SOL_signal,d_r);


%now we can re-arrange the decimated data into trials 
Ns=150;
pos=reshape(pos_signal,Ns,trials);
tor=reshape(tor_signal,Ns,trials);
EMG_SOL=reshape(emg_sol_signal,Ns,trials);

%Generating basis functions for representation of TV-IRF
%B-splines 
%these are time-based basis functions. You need to define the numner 
%of basis to use, a time vector, a center vector and the stardar deviation
%of each spline. 
number=10;
q=linspace(0,1,Ns)';
centers=linspace(min(q),max(q),number);
sd=0.1;
B=generate_B_splines(q,centers,sd);


%Generating basis functions for representation additional torque 
%Chebyshev polynomials
N_basis=6;
BASIS_TVMEAN=multi_tcheb(linspace(-1,1,Ns)',N_basis);


%initialization for iterative algorithm 
tqI=zeros(Ns,trials);
tqR=zeros(Ns,trials);
tqT=zeros(Ns,trials);
TVmean=zeros(Ns,trials);
VAFbest=-1000;
id_tolerance=0.01; 
max_iter=5;


disp('starts here')

for iter=1:max_iter
          
   %estimation of intrinsic component
   tqI=tor-(tqR+TVmean);
   [H_I, x_pred] = np_TV_ident(pos, tqI, B, 'nLags',4,'nSides',2,'periodic','yes','method','Bayes');
   tqI=x_pred;
   clear x_pred
    
   %estimation of reflex EMG-Torque component
   tqR=tor-(tqI+TVmean);
   [H_R, x_pred] = np_TV_ident(EMG_SOL, tqR, B, 'nLags',30,'nSides',1,'periodic','yes','method','Bayes');
   tqR=x_pred;
   clear x_pred
    
   %estimation of additional component
   TVmean=tor-(tqI+tqR);
   for i=1:trials
       [TVmean(:,i),param(:,i)]=TV_Bayes(TVmean(:,i),[],BASIS_TVMEAN);
   end

   
    

   tqT=tqI+tqR;
   
   VAFT=VAFnl(vec(tor(:,2:end-1)),vec(tqT(:,2:end-1)));
   ss=sprintf('Iteration: %4i \tTotal VAF: %6.3f\n',iter, VAFT);
   disp(ss);
    
    if abs((VAFT-VAFbest)) < id_tolerance
        break
    elseif VAFT<VAFbest
        break
    else
        VAFbest=VAFT;
    end
    
end

