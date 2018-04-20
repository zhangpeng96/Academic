########################################################################
#
#     This is an example call of MIDACO 6.0
#     -------------------------------------
#
#     MIDACO solves Multi-Objective Mixed-Integer Non-Linear Problems:
#
#
#      Minimize     F_1(X),... F_O(X)  where X(1,...N-NI)   is CONTINUOUS
#                                      and   X(N-NI+1,...N) is DISCRETE
#
#      subject to   G_j(X)  =  0   (j=1,...ME)      equality constraints
#                   G_j(X) >=  0   (j=ME+1,...M)  inequality constraints
#
#      and bounds   XL <= X <= XU
#
#
#     The problem statement of this example is given below. You can use 
#     this example as template to run your own problem. To do so: Replace 
#     the objective functions 'F' (and in case the constraints 'G') given 
#     here with your own problem and follow the below instruction steps.
#
########################################################################
######################   OPTIMIZATION PROBLEM   ########################
########################################################################
def problem_function(x):

    f = [0.0]*1 # Initialize array for objectives F(X)
    g = [0.0]*3 # Initialize array for constraints G(X)

    DT_A = [0.104, 0.001, 0.001, 0.001, 0.001]
    DT_B = [10.2, 16.7, 14.6, 14.6, 42.3]
    DT_C = [24.5, 8.6, 20.4, 32.1, 15.2]
    DT_PMIN = [2.1, 0.01, 0.01, 0.01, 0.01]
    DT_PMAX = [10, 5.6, 0.5, 0.5, 100]
    DT_PV = [0, 0, 1, 0, 0]
    DT_WT = [0, 0, 0, 1, 0]
    DT_GRID = [0, 0, 0, 0, 1]


    LP_spot = [18.6, 19.9, 19.3]
    LP_sale = [16.2, 16.3, 16.3]
    LP_PV = [0, 0, 8.71]
    LP_WT = [43.66, 46.64, 47.3]
    LP_LD = [110.75, 106.52, 104.35]

    for i in range(3):
      for j in range(5):
        idx = i * 5 + j
        f[0] = f[0] + \
               DT_A[j] * x[idx] ** 2 + \
               DT_B[j] * x[idx] + \
               DT_C[j] + \
               DT_GRID[j] * x[idx] * LP_spot[i] - \
               DT_PV[j] * (LP_PV[i] - x[idx]) * LP_sale[i] - \
               DT_WT[j] * (LP_WT[i] - x[idx]) * LP_sale[i] 

    
    idc = 0
    for i in range(3):
      powersum = 0.0

      for j in range(5):
        idx = i * 5 + j
        powersum = powersum + x[idx]

      g[idc] = powersum - LP_LD[i]
      idc = idc + 1

    
    return f,g

########################################################################
#########################   MAIN PROGRAM   #############################
########################################################################

key = b'MIDACO_LIMITED_VERSION___[CREATIVE_COMMONS_BY-NC-ND_LICENSE]'

problem = {} # Initialize dictionary containing problem specifications
option  = {} # Initialize dictionary containing MIDACO options

problem['@'] = problem_function # Handle for problem function name

########################################################################
### Step 1: Problem definition     #####################################
########################################################################

# STEP 1.A: Problem dimensions
##############################
problem['o']  = 1  # Number of objectives 
problem['n']  = 15  # Number of variables (in total) 
problem['ni'] = 0  # Number of integer variables (0 <= ni <= n) 
problem['m']  = 3  # Number of constraints (in total) 
problem['me'] = 3  # Number of equality constraints (0 <= me <= m) 

# STEP 1.B: Lower and upper bounds 'xl' & 'xu'  
##############################################  
problem['xl'] = [0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01]
problem['xu'] = [10, 5.6, 0.5, 43.66, 100, 10, 5.6, 0.5, 46.64, 100, 10, 5.6, 8.71, 47.3, 100]


# STEP 1.C: Starting point 'x'  
##############################  
problem['x'] = problem['xl'] # Here for example: starting point = lower bounds
    
########################################################################
### Step 2: Choose stopping criteria and printing options    ###########
########################################################################
   
# STEP 2.A: Stopping criteria 
#############################
option['maxeval'] = 10000     # Maximum number of function evaluation (e.g. 1000000) 
option['maxtime'] = 60*60*24  # Maximum time limit in Seconds (e.g. 1 Day = 60*60*24) 

# STEP 2.B: Printing options  
############################ 
option['printeval'] = 1000  # Print-Frequency for current best solution (e.g. 1000) 
option['save2file'] = 1     # Save SCREEN and SOLUTION to TXT-files [0=NO/1=YES]

########################################################################
### Step 3: Choose MIDACO parameters (FOR ADVANCED USERS)    ###########
########################################################################

option['param1']  = 0.0  # ACCURACY  
option['param2']  = 0.0  # SEED  
option['param3']  = 0.0  # FSTOP  
option['param4']  = 0.0  # ALGOSTOP  
option['param5']  = 0.0  # EVALSTOP  
option['param6']  = 0.0  # FOCUS  
option['param7']  = 0.0  # ANTS  
option['param8']  = 0.0  # KERNEL  
option['param9']  = 0.0  # ORACLE  
option['param10'] = 0.0  # PARETOMAX
option['param11'] = 0.0  # EPSILON  
option['param12'] = 0.0  # BALANCE
option['param13'] = 0.0  # CHARACTER

########################################################################
### Step 4: Choose Parallelization Factor   ############################
########################################################################

option['parallel'] = 0 # Serial: 0 or 1, Parallel: 2,3,4,5,6,7,8...

########################################################################
############################ Run MIDACO ################################
########################################################################

import midaco

if __name__ == '__main__': 

  solution = midaco.run( problem, option, key )

# print(solution['f'])
# print(solution['g'])
# print(solution['x'])

########################################################################
############################ END OF FILE ###############################
########################################################################
