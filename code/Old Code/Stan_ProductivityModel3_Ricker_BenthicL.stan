
    data {
    int Ndays; // number of days
    vector [Ndays] light; // relativized to max value
    vector [Ndays] GPP; // mean estimates from posterior probability distributions
    vector [Ndays] GPP_sd; // sd estimates from posterior probability distributions
    vector [Ndays] tQ; // standardized discharge
    vector [Ndays] depth; // depth estimate
    vector [Ndays] turb; // mean daily turbidity
    }
    
    parameters {
    // Disturbance (persistence) parameters
    real<lower=0> c; // estimate of Qcrit
    real<lower=0> s; // steepness of the transition from P=1 to P=0
    
    // Light adjustment
    real<lower=0> a; // light attenuation coefficient to inform Kd
    
    // Logistic growth parameters  
    real B [Ndays]; // Biomass; g m-2
    real<lower=0> r; // growth rate; d-1
    real<upper=0> lambda; // r/K
    
    // Error parameters
    real<lower=0> sig_p; // sigma processes error
    }
    
    transformed parameters {
    real pred_GPP [Ndays];
    real P [Ndays];
    real ben_light [Ndays];
    
    for(i in 1:Ndays){
    P[i]=exp(-exp(s*(tQ[i]-c)));
    ben_light[i]=light[i]*exp(-1*a*turb[i]*depth[i]);
    pred_GPP[i] =ben_light[i]*exp(B[i]);
    }
    
    } 
    
    model {
    
    // Process Model
    for (j in 2:(Ndays)){
    B[j] ~ normal((B[(j-1)] + r + lambda*exp(B[(j-1)]))*P[j], sig_p);
    }
 
    // Observation model
    for (j in 2:(Ndays)) {
        GPP[j] ~ normal(pred_GPP[j], GPP_sd[j])T[0,];
    }
 
    // Error priors
    sig_p ~ normal(0,2)T[0,];
    
    // Param priors
    r ~ normal(0,1)T[0,];
    lambda ~ normal(0,1)T[,0];
    c ~ rayleigh(0.5)T[0,];
    s ~ normal(0,50)T[0,];
    a ~ normal(0,1)T[0,];
    
    }
    
    
    
    
