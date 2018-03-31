Sets    t    time    / t1 * t24 /,
        i    generators    / g1 * g10 /,
        k    cost    / sg1 * sg20 /,
        char    /ch1 * ch2 /;
Alias (t, h);
Alias (i, g);

Table gendata(i, *) generator cost characteristics and limits
      a       b       c     CostsD  costst  RU    RD    UT  DT  SD   SU   Pmin  Pmax  U0   Uini  S0    e    f    g
g1    0.014   12.1    82    42.6    42.6    80    80    3   2   90   110  0     400   1    0     0     0    0    0
g2    0.028   12.6    49    50.6    50.6    64    64    4   2   130  140  0     420   2    1     0     0    0    0
g3    0.013   13.2    100   57.1    57.1    80    80    3   2   70   80   0     450   3    0     2     0    0    0
g4    0.012   13.9    105   47.1    47.9    104   104   5   3   240  250  0     520   1    0     0     0    0    0
g5    0.026   13.5    72    56.6    56.9    96    96    4   2   110  130  0     380   1    0     0     0    0    0
g6    0.021   15.4    29    141.5   141.5   30    30    3   2   90   90   0     450   0    1     0     0    0    0
g7    0.038   14.0    32    113.5   113.5   24    24    3   2   80   80   0     320   0    0     0     0    0    0
g8    0.039   13.5    40    42.6    42.6    22    22    3   2   95   95   0     50    0    0     0     1    0    0
g9    0.039   15.0    25    50.6    50.6    16    16    0   0   85   85   0     50    0    0     0     0    1    0
g10   0.051   14.3    15    57.1    57.1    12    12    0   0   80   90   0     360   0    0     0     0    0    1 ;


Parameter data(k, i, *);

data(k, i, 'DP') = (gendata(i, "Pmax") + 50 - gendata(i, "Pmin")) / card(k);
data(k, i, 'Pini') = (ord(k) - 1) * data(k, i, 'DP') + gendata(i, "Pmin");
data(k, i, 'Pfin') = data(k, i, 'Pini') + data(k, i, 'DP');
data(k, i, 'Cini') = gendata(i, "a") * power(data(k, i, 'Pini'), 2) + gendata(i, "b") * data(k, i, 'Pini') + gendata(i, "c");
data(k, i, 'Cfin') = gendata(i, "a") * power(data(k, i, 'Pfin'), 2) + gendata(i, "b") * data(k, i, 'Pfin') + gendata(i, "c");
data(k, i, 's') = (data(k, i, 'Cfin') - data(k, i, 'Cini')) / data(k, i, 'DP');
gendata(i, 'Mincost') = gendata(i, 'a') * power(gendata(i, "Pmin"), 2) + gendata(i, 'b')*gendata(i, "Pmin") + gendata(i, 'c');

Table dataLP(t, *)
        lambda  load    PV      WT
t1      14.72   883     0       96.12
t2      15.62   915     0       96.12
t3      14.22   1012    0       84.24
t4      14.76   1102    0       112.32
t5      15.03   1244    0       118.44
t6      15.84   1340    0.36    171.36
t7      20.31   1392    1.44    171.72
t8      23.12   1415    6.3     152.64
t9      24.03   1476    18      137.16
t10     21.03   1453    41.4    165.24
t11     20.01   1422    41.94   140.4
t12     17.22   1411    57.24   177.84
t13     18.04   1387    77.94   127.8
t14     17.83   1324    66.6    155.88
t15     18.57   1387    72.54   115.56
t16     17.21   1344    59.4    118.44
t17     23.01   1244    42.84   109.08
t18     18.78   1100    23.94   131.04
t19     18.82   1040    7.74    134.28
t20     18.91   972     0.54    93.6
t21     20.87   921     0       121.68
t22     20.74   900     0       112.32
t23     20.88   913     0       124.56
t24     15.63   821     0       131.04 ;

dataLP(t, 'load') = dataLP(t, 'load') * 1;

Parameter unit(i, char);
unit(i, 'ch1') = 24;
unit(i, 'ch2') = (gendata(i, 'UT') - gendata(i, 'U0')) * gendata(i, 'Uini');

Parameter unit2(i, char);
unit2(i, 'ch1') = 24;
unit2(i, 'ch2') = (gendata(i, 'DT') - gendata(i, 'S0')) * (1 - gendata(i, 'Uini'));
gendata(i, 'Lj') = smin(char, unit(i, char));
gendata(i, 'Fj') = smin(char, unit2(i, char));

Variable costThermal;
Binary variable u(i, t), y(i, t), z(i, t);
Positive variables pu(i, t), p(i, t), StC(i, t), SDC(i, t), Pk(i, t, k);

p.up(i, t) = gendata(i, "Pmax") + gendata(i, 'e')*dataLP(t, 'PV') + gendata(i, 'f')*dataLP(t, 'WT');
p.lo(i, t) = 0;

Pk.up(i, t, k) = data(k, i, 'DP') + gendata(i, 'e')*dataLP(t, 'PV') + gendata(i, 'f')*dataLP(t, 'WT');
Pk.lo(i, t, k) = 0;

pu.up(i, t) = gendata(i, "Pmax") + gendata(i, 'e')*dataLP(t, 'PV') + gendata(i, 'f')*dataLP(t, 'WT');

Equations Uptime1, Uptime2, Uptime3, Dntime1, Dntime2, Dntime3, Ramp1, Ramp2, Ramp3, Ramp4, startc, shtdnc, genconst1, Genconst2, Genconst3, Genconst4, balance, reserve;
Uptime1(i)      $(gendata(i, "Lj") > 0) .. sum(t$(ord(t) < (gendata(i, "Lj") + 1)), 1-U(i, t) ) =e= 0;
Uptime2(i)      $(gendata(i, "UT") > 1) .. sum(t$(ord(t) > 24 - gendata(i, "UT") + 1), U(i, t) - y(i, t) ) =g= 0;
Uptime3(i, t)   $(ord(t) > gendata(i, "Lj") and ord(t) < 24 - gendata(i, "UT") + 2 and not(gendata(i, "Lj") > 24 - gendata(i, "UT"))) .. sum(h$((ord(h) > ord(t) - 1) and (ord(h) < ord(t) + gendata(i, "UT"))), U(i,h)) =g= gendata(i, "UT") * y(i, t);

Dntime1(i)      $(gendata(i, "Fj") > 0) .. sum(t$(ord(t) < (gendata(i, "Fj") + 1)), U(i, t)) =e= 0;
Dntime2(i)      $(gendata(i, "DT") > 1) .. sum(t$(ord(t) > 24 - gendata(i, "DT") + 1), 1-U(i, t) - z(i, t)) =g= 0;
Dntime3(i, t)   $(ord(t) > gendata(i, "Fj") and ord(t) < 24 - gendata(i, "DT") + 2 and not(gendata(i, "Fj") > 24 - gendata(i, "DT"))) .. sum(h$((ord(h) > ord(t) - 1) and (ord(h) < ord(t) + gendata(i, "DT"))), 1-U(i,h)) =g= gendata(i, "DT") * z(i, t);

startc(i, t) .. StC(i, t) =g= gendata(i, "costst") * y(i, t);
shtdnc(i, t) .. SDC(i, t) =g= gendata(i, "CostsD") * z(i, t);

genconst1(i, h) .. p(i, h) =e= u(i, h) * gendata(i, "Pmin") + sum(k, Pk(i, h, k));
Genconst2(i, h) $(ord(h) > 0) .. U(i, h) =e= U(i, h-1)$(ord(h) > 1) + gendata(i, "Uini")$(ord(h) = 1) + y(i, h) - z(i, h);
Genconst3(i, t, k) .. Pk(i, t, k) =l= U(i, t) * data(k, i, 'DP');
Genconst4 .. costThermal =e= sum((i, t), StC(i, t) + SDC(i ,t)) + sum((t, i), u(i, t)*gendata(i, 'Mincost') + sum(k, data(k, i, 's')*pk(i, t, k)));

Ramp1(i, t) .. p(i, t-1) - p(i, t) =l= U(i, t) * gendata(i, 'RD') + z(i, t) * gendata(i, "SD");
Ramp2(i, t) .. p(i, t) =l= pu(i, t);
Ramp3(i, t)$(ord(t) < 24) .. pu(i, t) =l= (u(i, t) - z(i, t+1)) * (gendata(i, "Pmax") + gendata(i, 'e')*dataLP(t, 'PV') + gendata(i, 'f')*dataLP(t, 'WT') ) + z(i, t+1) * gendata(i, "SD");
Ramp4(i, t)$(ord(t) > 1) .. pu(i, t) =l= p(i, t-1) + U(i, t-1) * gendata(i, 'RU') + y(i, t) * gendata(i, "SU");

balance(t) .. sum(i, p(i, t)) =e= dataLP(t, 'load');
reserve(t) .. sum(i, pu(i, t) - p(i, t)) =g= 0.05 * dataLP(t, 'load');

Model UCLP /all/;
Option optcr = 0.0;
Solve UCLP minimizing costThermal using mip;

File results / sssr.txt /;
results.ap = 1
put results;
loop((t),
     loop((i),
         put p.l(i, t)
     )
put /
);
putclose;
