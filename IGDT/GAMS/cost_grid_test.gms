Sets    t   hours       /t1*t24/
        i   thermal units /g1*g4/;
scalar  lim /inf/;
table   gendata(i, *)
    a       b       c    d       e     f     Pmin   Pmax  RU0   RD0
g1  0.12    14.80   89   1.2    -5     3     28     100   40    40 
g2  0.17    16.57   83   2.3    -4.24  6.09  20     190   30    30
g3  0.15    15.55   100  1.1    -2.15  5.69  30     190   30    30
g4  0.19    16.21   70   1.1    -3.99  6.2   20     160   50    50;

table   data(t, *)
        lambda      load
t1      32.71       510
t2      34.72       530
t3      32.71       516
t4      32.74       510
t5      32.96       515
t6      34.93       544
t7      44.9        646
t8      52          686
t9      53.03       741
t10     47.26       734
t11     44.07       748
t12     38.63       760
t13     39.91       754
t14     39.45       700
t15     41.14       686
t16     39.23       720
t17     52.12       714
t18     40.85       761
t19     41.2        727
t20     41.15       714
t21     45.76       618
t22     45.59       584
t23     45.56       578
t24     34.72       544 ;

Variables      OF           Objective (revenue)
              costThermal   Cost of thermal units
               p(i, t)      Power generated by thermal power plant
               EM           Emission calculation  
               grid(t)      Power from Grid ;

p.up(i, t) = gendata(i, "Pmax") ;
p.lo(i, t) = gendata(i, "Pmin") ;

Equations
Genconst3, Genconst4, costThermalcalc, balance, EMcalc, Emlim, benefitcalc;

costThermalcalc..   costThermal =e= sum((t, i), gendata(i, 'a')*power(p(i, t),2) + gendata(i, 'b')*p(i, t) + gendata(i, 'c')) + sum(t, grid(t)*data(t, 'lambda')/100);

Genconst3(i, t) .. p(i, t+1)-p(i, t) =l= gendata(i, 'RU0');
Genconst4(i, t) .. p(i, t-1)-p(i, t) =l= gendata(i, 'RD0');

balance(t) .. sum(i, p(i, t)+grid(t)) =l= data(t, 'load');

EMcalc ..                         EM =e= sum((t, i), gendata(i, 'd')*power(p(i, t),2) + gendata(i, 'e')*p(i,t) + gendata(i, 'f'));

EMlim ..                          EM =l= lim;
benefitcalc ..                    OF =e= costThermal;

Model DEDPB /all/;
Solve DEDPB us qcp min costThermal;
