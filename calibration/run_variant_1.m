%% MANUAL CALIBRATION %%

% File for DREAM implementation for hierarchical calibration of 
% Monod models.

function [output1] = run_variant_1(p1,Extra)
%% Fixed Information %%

delta13_I = (-29/1000);
AT_tot    =  30000*(8*12/216);                  % Input of AT, including light and heavy isotopologues [mg C/L]
frac_coef = -0.0054;                            % Initial fraction Coefficient for the AT applied in the experiment "?" initial
SN        = (delta13_I+1)*0.011180;            % Initial C13/C12. -29 is taken from Beno?s paper (-29 per mil)

%% Define fixed parameters %% 

q(2) = AT_tot;                                  % Concentration of light AT in the inlet [mg C/L]
q(3) = AT_tot*SN;                               % Concentration of heavier AT in the inlet [mg C/L]
q(4) = 1;                                       % Factor for chemostat (1) and retentostat (0).
q(5) = 8*12/216;                                % mg C/mg AT
q(6) = 8*12/197;                                % mg C/mg HY
q(7) = 1e-15;                                   % Volume of a single bacterium [L]
q(8) = 1+frac_coef;                             % Isotopic fractionation factor "alpha" that comes from the enzymatic activity [-]
q(9) = 0.011180;                                % reference isotope ratio of VPDB (Vienna Pee Dee Belemnite) [-]

%% Calling Model %%

abstol = 1e-9;
reltol = 1e-7;
o_opts = odeset('AbsTol',abstol,'RelTol',reltol,'Events',@stopevent); %,'Jacobian',@MCPA1_jac);%,'NonNegative',1:7);

T_bioC   = 3.66e11;  % Initial Biomass [cells/L]
fcell    = 10^p1(7);
C_AT     = q(5);     % ?g C/?g AT
C_HY     = q(6);     % ?g C/?g HY
ATinitC  = 87*C_AT;  % ?g C/ L OUTSIDE
HYinitC  = 18*C_HY;  % ?g C/ L OUTSIDE
isf      = q(8);     % Isotopic fractionation factor (?)
Ref      = q(9);     % reference isotope ratio of VPDB
T_bioR   = 5.4e10;   % Initial Biomass [cells/L]
ATinitR  = 100*C_AT; % microgr/ L OUTSIDE
HYinitR  = 250*C_HY; % microgr/ L OUTSIDE 

time = linspace(0,100,201); % simulation period and vector of output times [d]

        c(1)    = T_bioC*fcell;                  % Active bacteria A biomass [?g C/L]
        c(2)    = ATinitC;                       % Lighter AT inside the cell in the system in solution [?g C/L]
        c(3)    = ATinitC*SN;                    % Heavier AT inside the cell in the system in solution [?g C/L]
        c(4)    = ATinitC;                       % Lighter AT outside the cell in the system in solution [?g C/L]
        c(5)    = ATinitC*SN;                    % Heavier AT outside the cell in the system in solution [?g C/L]
        c(6)    = HYinitC;                       % Hydroxyatrazine INSIDE the cell [?g C/L]
        c(7)    = HYinitC;                       % Hydroxyatrazine outisde the cell [?g C/L]

%% First dilution rate Chemostat %%

q(1) = 0.023*24;    % Dilution rate coeficient (d^-1)
% t    = [0 20];
t    = [0 200];

try
     warning off
tic
[ty,cu] = ode15s(@variant_1_chemo,t,c,o_opts,p1',q);
 catch ME
     warning off
end
if length(cu) < length(t)
    cu = ones(length(t),length(c))*1e+99;
end

if isreal(cu)==0
    cu = ones(length(t),length(c))*1e+99;    
end

%% Second dilution rate Chemostat %%

q(1) = 0.032*24;       % Dilution rate coeficient (d^-1)        
% t1   = [20 31];
t1   = [200 400];

        c(1)    = cu(end,1);                % Active bacteria A biomass [cells cm-3]
        c(2)    = cu(end,2);                % Lighter AT inside the cell in the system in solution [mmol AT cm-3]
        c(3)    = cu(end,3);                % Heavier AT inside the cell in the system in solution [mmol AT cm-3]
        c(4)    = cu(end,4);                % Lighter AT outside the cell in the system in solution [mmol AT cm-3]
        c(5)    = cu(end,5);                % Heavier AT outside the cell in the system in solution [mmol AT cm-3]
        c(6)    = cu(end,6);                % Hydroxyatrazine INSIDE the cell [mmol AT cm-3]
        c(7)    = cu(end,7);                % Hydroxyatrazine outisde the cell [mmol AT cm-3]

try
     warning off

tic
[ty1,cu1] = ode15s(@variant_1_chemo,t1,c,o_opts,p1',q);
 catch ME
     warning off
end

if length(cu1) < length(t1)
    cu1 = ones(length(t1),length(c))*1e+99;
end

if isreal(cu1)==0
    cu1 = ones(length(t1),length(c))*1e+99;    
end


%% Third dilution rate %%

q(1) = 0.048*24;       % Dilution rate coeficient (d^-1)        
% t2   = [31 37];
t2   = [400 600];

        c(1)    = cu1(end,1);                % Active bacteria A biomass [cells cm-3]
        c(2)    = cu1(end,2);                % Lighter AT inside the cell in the system in solution [mmol AT cm-3]
        c(3)    = cu1(end,3);                % Heavier AT inside the cell in the system in solution [mmol AT cm-3]
        c(4)    = cu1(end,4);                % Lighter AT outside the cell in the system in solution [mmol AT cm-3]
        c(5)    = cu1(end,5);                % Heavier AT outside the cell in the system in solution [mmol AT cm-3]
        c(6)    = cu1(end,6);                % Hydroxyatrazine INSIDE the cell [mmol AT cm-3]
        c(7)    = cu1(end,7);                % Hydroxyatrazine outisde the cell [mmol AT cm-3]

try
     warning off
tic
[ty2,cu2] = ode15s(@variant_1_chemo,t2,c,o_opts,p1',q);
 catch ME
     warning off
end
if length(cu2) < length(t2)
    cu2 = ones(length(t2),length(c))*1e+99;
end

if isreal(cu2)==0
    cu2 = ones(length(t2),length(c))*1e+99;    
end

%% Fourth dilution rate %%

q(1) = 0.056*24;       % Dilution rate coeficient (d^-1)        
% t3   = [37 42];
t3   = [600 800];

        c(1)    = cu2(end,1);                % Active bacteria A biomass [cells cm-3]
        c(2)    = cu2(end,2);                % Lighter AT inside the cell in the system in solution [mmol AT cm-3]
        c(3)    = cu2(end,3);                % Heavier AT inside the cell in the system in solution [mmol AT cm-3]
        c(4)    = cu2(end,4);                % Lighter AT outside the cell in the system in solution [mmol AT cm-3]
        c(5)    = cu2(end,5);                % Heavier AT outside the cell in the system in solution [mmol AT cm-3]
        c(6)    = cu2(end,6);                % Hydroxyatrazine INSIDE the cell [mmol AT cm-3]
        c(7)    = cu2(end,7);                % Hydroxyatrazine outisde the cell [mmol AT cm-3]
            
try
     warning off
tic
[ty3,cu3] = ode15s(@variant_1_chemo,t3,c,o_opts,p1',q);
 catch ME
     warning off
end
if length(cu3) < length(t3)
    cu3 = ones(length(t3),length(c))*1e+99;
end

if isreal(cu3)==0
    cu3 = ones(length(t3),length(c))*1e+99;    
end    

%% Fifth dilution rate %%

q(1) = 0.068*24;       % Dilution rate coeficient (d^-1)        
% t4   = [42 45];
t4   = [800 1000];

        c(1)    = cu3(end,1);                % Active bacteria A biomass [cells cm-3]
        c(2)    = cu3(end,2);                % Heavier AT inside the cell in the system in solution [mmol AT cm-3]
        c(3)    = cu3(end,3);                % Lighter AT inside the cell in the system in solution [mmol AT cm-3]
        c(4)    = cu3(end,4);                % Heavier AT outside the cell in the system in solution [mmol AT cm-3]
        c(5)    = cu3(end,5);                % Lighter AT outside the cell in the system in solution [mmol AT cm-3]
        c(6)    = cu3(end,6);                % Hydroxyatrazine INSIDE the cell [mmol AT cm-3]
        c(7)    = cu3(end,7);                % Hydroxyatrazine outisde the cell [mmol AT cm-3]     

try
     warning off
tic
[ty4,cu4] = ode15s(@variant_1_chemo,t4,c,o_opts,p1',q);
 catch ME
     warning off
end
if length(cu4) < length(t4)
    cu4 = ones(length(t4),length(c))*1e+99;
end

if isreal(cu4)==0
    cu4 = ones(length(t4),length(c))*1e+99;    
end

%% First dilution rate Retentostat %%

q(1)  = 0.02*24;       % Dilution rate coeficient (d^-1)        
t5    = [0 1000];
q(4)  = 0;                                       % Factor for chemostat (1) and retentostat (0).
fcell = 10^p1(11);

        c(1)    = T_bioR*fcell;              % Active bacteria A biomass [cells cm-3]
        c(2)    = cu4(end,2);                % Lighter AT inside the cell in the system in solution [mmol AT cm-3]
        c(3)    = cu4(end,3);                % Heavier AT inside the cell in the system in solution [mmol AT cm-3]
        c(4)    = ATinitR;            % Lighter AT outside the cell in the system in solution [mmol AT cm-3]
        c(5)    = ATinitR*SN;                % Heavier AT outside the cell in the system in solution [mmol AT cm-3]
        c(6)    = cu4(end,6);                % Hydroxyatrazine INSIDE the cell [mmol AT cm-3]
        c(7)    = HYinitR;                % Hydroxyatrazine outisde the cell [mmol AT cm-3]

try
     warning off
tic
[ty5,cu5] = ode15s(@variant_1_reten,t5,c,o_opts,p1',q);
 catch ME
     warning off
end
if length(cu5) < length(t5)
    cu5 = ones(length(t5),length(c))*1e+99;
end

if isreal(cu5)==0
    cu5 = ones(length(t5),length(c))*1e+99;    
end

%% Desired outputs for Chemostat %%

fcell    = 10^p1(7);

        Lcellc       = vertcat(cu(end,1),cu1(end,1),cu2(end,1),cu3(end,1),cu4(end,1))/fcell;      % Biomass 
        AT_outlc     = vertcat(cu(end,4),cu1(end,4),cu2(end,4),cu3(end,4),cu4(end,4))/C_AT;       % AT lighter
        AT_outhc     = vertcat(cu(end,5),cu1(end,5),cu2(end,5),cu3(end,5),cu4(end,5))/C_AT;       % AT lighter
        AT_Tot       = AT_outlc + AT_outhc;
        HY_outc      = vertcat(cu(end,7),cu1(end,7),cu2(end,7),cu3(end,7),cu4(end,6))/C_HY;       % AT lighter
        OUT_C        = vertcat(AT_Tot,HY_outc,Lcellc);                                 % Time

%% Desired outputs for Retentostat %%

fcell = 10^p1(11);

        Lcellr       = (cu5(end,1))/fcell;    % Biomass 
        AT_outlr     = (cu5(end,4))/C_AT;     % AT lighter
        AT_outhr     = (cu5(end,5))/C_AT;     % AT lighter
        AT_Tot2      = AT_outlr + AT_outhr;
        HY_outr      = (cu5(end,7))/C_HY;     % AT lighter
        OUT_R        = vertcat(AT_Tot2,HY_outr,Lcellr);

%% Enrichment Factor Chemostat %% 

d_not_i = delta13_I;  % ?-notation for the inlet.
d_not_o = ((cu(end,5)/cu(end,4))/Ref)-1;  % ?-notation for the outlet in the chemostat.
EF_Ch   = (d_not_i - d_not_o)*1e3;

%% Enrichment Factor Retentostat %% 

d_not_oR = (cu5(end,5)/cu5(end,4)/Ref)-1;  % ?-notation for the outlet in the chemostat.
EF_Rt    = (d_not_i - d_not_oR)*1e3;

%% SSE %%

output1     = (vertcat(OUT_C,abs(EF_Ch),OUT_R,abs(EF_Rt)));  % Only Chemostat

end