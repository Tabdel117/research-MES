clc
clear

% 2017.11.22 一个简单的问题 单个时间尺度，并且严格凸
%{
lamda_old=0;
lamda_new=2.0;
e=0.0001;
step=0.1;
number=0;

while sum(abs(lamda_new - lamda_old)) > e
    H1 = 1 * 2; % 成本函数 x^2
    f1 = 0 - lamda_new;
    lb1 = 0;
    ub1 = 10;
    [x1, value1, flag1]  = quadprog(H1, f1, [], [], [], [], lb1, ub1);
    
%     x1_demandCurve = lamda_new / 2; % 投标曲线，边际成本/收益
%     diff1(number+1) = x1_demandCurve - x1;
    
    H2 = 1 * 2; % 负的收益函数 x^2 - 10*x
    f2 = -10 + lamda_new;
    lb2 = 0;
    ub2 = 10;
    [x2, value2, flag2]  = quadprog(H2, f2, [], [], [], [], lb2, ub2);
    
%     x2_demandCurve = (10 - lamda_new) / 2;
%     diff2(number+1) = x2_demandCurve - x2;
    
    
    lamda_old = lamda_new
    lamda_new = max(0, lamda_old + (x2 - x1)*step); % x1-x2的差是中间的矩阵 

    number=number+1
end
%}


%{
% 2018.1.8 多个时间尺度，严格凸

maxIteration = 1000;
time = 24;

lamda_old = zeros(time,1);
lamda_new = ones(time,1) .* 5.0;
lamda_record = zeros(time, maxIteration);
e=0.0001;
step=0.5;
number=0;

% rand(time,1).*5
L = [4.07361843196590;4.52895968537810;0.634934081467530;4.56687928069510;3.16179623112705;0.487702024997048;1.39249109433524;2.73440759602492;4.78753417717149;4.82444267599638;0.788065408387741;4.85296390880308;4.78583474121473;2.42687824361421;4.00140234444400;0.709431693136077;2.10880641313138;4.57867762594534;3.96103664779777;4.79746213196452;3.27870349578293;0.178558392870948;4.24564652934389;4.66996623878775];

while sum(abs(lamda_new - lamda_old)) > e && number <= maxIteration
    H1 = diag(ones(1,time) .* 1 .* 2); % 成本函数 x^2
    f1 = ones(time,1) .* 0 - lamda_new;
    lb1 = ones(time,1) .* 0;
    ub1 = ones(time,1) .* 10;
    [x1, value1, flag1]  = quadprog(H1, f1, [], [], [], [], lb1, ub1);
    
%     x1_demandCurve = lamda_new / 2; % 投标曲线，边际成本/收益
%     diff1(number+1) = x1_demandCurve - x1;
    
    H2 = diag(ones(1,time) .* 1 .* 2); % 负的收益函数 x^2 - 10*x
    f2 = ones(time,1) .* (-10) + lamda_new;
    % 负荷总需量约束 = 50
    Aeq2 = ones(1, time);
    beq2 = 50;
    lb2 = ones(time,1) .* 0;
    ub2 = ones(time,1) .* 5;
    [x2, value2, flag2]  = quadprog(H2, f2, [], [], Aeq2, beq2, lb2, ub2);
    
%     x2_demandCurve = (10 - lamda_new) / 2;
%     diff2(number+1) = x2_demandCurve - x2;
    
    
    lamda_old = lamda_new
    lamda_new = lamda_old + (x2 + L - x1) .* step; % x1-x2的差是中间的矩阵 
    for i = 1:length(lamda_new)
        if lamda_new(i) < 0
            lamda_new(i) = 0;
        end
    end

    number=number+1  % 优化过一次才计数一次，初始lamda不记录
    lamda_record(:,number) = lamda_new;
end
%}

% 验证非严格凸情况下lamda会振荡，但是其平均值是收敛的
% a=[2.575329957	2.913560083	3.234878704	3.540131395	3.830121449	4.105612008	4.367328032	4.615958254	4.85215698	6.076545756	6.239715094	6.394725966	6.541986293	6.681883604	6.814786051	6.941043376	7.060987833	7.174935067	7.28318494	7.38602232	7.483717841	7.576528575	7.664698772	7.748460512	8.828034113	8.853629038	8.877944216	8.901043629	8.922988079	8.943835307	8.963640173	8.982454795	9.000328687	9.017308887	9.033440077	9.048764705	9.063323104	9.077153581	9.090292534	10.10277454	10.06463246	10.02839747	9.993974241	9.961272169	9.930205201	9.90069158	9.872653641	9.846017598	9.820713342	9.796674299	9.773837208	9.752141973	9.731531498	10.71195155	10.64335059	10.57817969	10.51626733	10.45745058	10.40157468	10.34849257	10.29806457	10.25015796	10.20464669	10.16141098	10.12033705	10.08131682	10.04424761	11.00903185	10.92557688	10.84629466	10.77097655	10.69942435	10.63144975	10.56687389	10.50552682	10.4472471	10.39188137	10.33928393	10.28931635	10.24184716	10.19675143	10.15391048	11.11321158	11.02454762	10.94031687	10.86029765	10.78427939	10.71206204	10.64345556	10.57827941	10.51636206	10.45754058	10.40166018	10.34857379	10.29814173	10.25023127	10.20471633	11.16147713	11.0703999	10.98387653	10.90167933	10.82359198	10.74940901	10.67893518	10.61198505	10.54838242	10.48795992	10.43055855	10.37602725	10.32422251	10.27500801	10.22825423	10.18383814	11.14164286	11.05155734	10.9659761	10.88467392	10.80743684	10.73406163	10.66435517	10.59813403	10.53522396	10.47545938	10.41868304	10.36474551	10.31350486	10.26482624	10.21858155	10.1746491	11.13291327	11.04326423	10.95809764	10.87718938	10.80032654	10.72730683	10.65793812	10.59203783	10.52943257	10.46995756	10.41345631	10.35978012	10.30878773	11.26034497	11.16432435	11.07310475	10.98644614	10.90412046	10.82591106	10.75161213	10.68102815	10.61397336	10.55027132	10.48975438	10.43226328	10.37764674	10.32576103	10.2764696	10.22964274	10.18515723	11.14289599	11.05274782	10.96710705	10.88574832	10.80845753	10.73503128	10.66527634	10.59900914	10.53605531	10.47624917	10.41943333	10.36545829	11.314182	11.21546952	11.12169267	11.03260466	10.94797105	10.86756912	10.79118729	10.71862455	10.64968995	10.58420207	10.52198859	10.46288579	10.40673812	10.35339784	11.30272457	11.20458497	11.11135234	11.02278135	10.93863891	10.85870359	10.78276503	10.7106234	10.64208886	10.57698104	10.51512861	10.4563688	10.40054699	10.34751626	10.29713707	10.24927684	10.20380963	11.16061577	11.0695816	10.98309915	10.90094081	10.8228904	10.7487425	10.678302	10.61138352	10.54781097	10.48741705	10.43004282	10.3755373	10.32375706	10.27456583	11.22783416	11.13343908	11.04376375	10.95857219	10.8776402	10.80075481	10.7277137	10.65832464	10.59240503	10.5297814	10.47028896	10.41377113	10.3600792	10.30907186	10.26061489	10.21458077	11.17084836	11.07930256	10.99233406	10.90971398	10.83122491	10.75666028	10.68582389	10.61852932	10.55459948	10.49386613	10.43616945	10.3813576	10.32928634	11.27981865	11.18282434	11.09067975	11.00314238	10.91998189	10.84097942	10.76592707	10.69462734	10.6268926	10.56254459	10.50141399	10.44333991	10.38816954	10.33575769	10.28596643	10.23866473	11.19372812	11.10103834	11.01298304	10.92933051	10.84986061	10.77436421	10.70264262	10.63450711	10.56977838	10.50828609	10.44986841	10.39437161	10.34164965	10.29156379	10.24398223	11.19877974	11.10583738	11.01754213	10.93366165	10.85397519	10.77827306	10.70635603	10.63803485	10.57312973	10.51146987	10.452893	10.39724497	10.34437935	10.294157	11.24644578	11.15112011	11.06056073	10.97452932	10.89279948	10.81515613	10.74139494	10.67132182	10.60475235	10.54151136	10.48143242	10.42435742	10.37013617	10.31862599	10.26969131	10.22320337	11.17903983	11.08708446	10.99972686	10.91673714	10.83789691	10.76299869	10.69184537	10.62424973	10.56003387	10.4990288	10.44107398	10.38601691	10.33371269	10.28402367	10.23681912	11.19197478	11.09937267	11.01140066	10.92782725	10.84843251	10.77300751	10.70135376	10.63328269	10.56861518	10.50718105	10.44881862	10.39337431	10.34070222	10.29066373	10.24312717	11.19796743	11.10506568	11.01680902	10.9329652	10.85331356	10.77764451	10.70575891	10.63746758	10.57259083	10.51095791	10.45240664	10.39678293	10.34394041	10.29374001	10.24604964	11.20074378	11.10770322	11.01931468	10.93534557	10.85557492	10.77979279	10.70779978	10.63940641	10.57443272	10.5127077	10.45406894	10.39836212	10.34544064	10.29516523	11.2474036	11.15203004	11.06142516	10.97535053	10.89357962	10.81589727	10.74209903	10.6719907	10.60538779	10.54211502	10.4820059	10.42490223	10.37065374	10.31911768	10.27015842	11.22364712	11.12946139	11.03998494	10.95498232	10.87422983	10.79751496	10.72463583	10.65540067	10.58962726	10.52714252	10.46778202	10.41138954	10.35781669	10.30692248	10.25857298	10.21264096	11.16900553	11.07755188	10.99067091	10.90813399	10.82972391	10.75523434	10.68446925	10.61724241	10.55337691	10.49270469	10.43506608	10.3803094	10.32829055	10.27887265	10.23192564	11.18732598	11.09495631	11.00720512	10.92384148	10.84464603	10.76941036	10.69793646	10.63003626	10.56553107	10.50425114	10.44603521	10.39073007	10.3381902	10.28827731	10.24086007	10.19581369	11.15301963	11.06236527	10.97624363	10.89442807	10.81670329	10.74286475	10.67271814	10.60607886	10.54277154	10.48262958	10.42549473	10.37121662	10.31965241	11.27066641	11.17412971	11.08241985	10.99529548	10.91252733	10.83389759	10.75919933	10.68823599	10.62082082	10.5567764	10.4959342	10.43813412	10.38322403	10.33105946	10.28150311	11.23442458	11.13969997	11.0497116	10.96422264	10.88300813	10.80585435	10.73255826	10.66292697	10.59677724	10.53393501	10.47423488	10.41751976	10.3636404	10.312455	11.26382887	11.16763405	11.07624897	10.98943315	10.90695812	10.82860683	10.75417312	10.68346108	10.61628465	10.55246705	10.49184032	10.43424493	10.3795293	10.32754946	10.27816861	11.2312568	11.13669058	11.04685268	10.96150667	10.88042796	10.80340318	10.73022965	10.66071479	10.59467567	10.53193851	10.47233821	10.41571793	10.36192865	10.31082885	10.26228403	10.21616645	10.17235475];
% for i=1:length(a)
%     b(i) = sum(a(1,1:i)) / i;
% end




% 2018.1.10 多个时间尺度，非严格凸，采用平均值方法
maxIteration = 1000;
time = 24;

lamda_old = ones(time,1) .* (-1);
lamda_new = ones(time,1) .* 2.0; %初始值
lamda_record = zeros(time, maxIteration+1);
e=0.001;
step=0.1;
number = 1;
lamda_record(:,number) = lamda_new;

% rand(time,1).*5
L = [4.07361843196590;4.52895968537810;0.634934081467530;4.56687928069510;3.16179623112705;0.487702024997048;1.39249109433524;2.73440759602492;4.78753417717149;4.82444267599638;0.788065408387741;4.85296390880308;4.78583474121473;2.42687824361421;4.00140234444400;0.709431693136077;2.10880641313138;4.57867762594534;3.96103664779777;4.79746213196452;3.27870349578293;0.178558392870948;4.24564652934389;4.66996623878775];

lamda_avg_old = lamda_old;
lamda_avg_new = lamda_new;
lamda_avg_record = zeros(time, maxIteration+1);
lamda_avg_record(:,number) = lamda_avg_new;

% while sum(abs(lamda_new - lamda_old)) > e && number <= maxIteration
while sum(abs(lamda_avg_new - lamda_avg_old)) > e && number <= maxIteration
    
    H1 = diag(ones(1,time) .* 0 .* 2); % 成本函数 x^2 ( + 5*x)
    f1 = ones(time,1) .* 5 - lamda_new;
    lb1 = ones(time,1) .* 0;
    ub1 = ones(time,1) .* 10;
    [x1, value1, flag1]  = quadprog(H1, f1, [], [], [], [], lb1, ub1);
    
%     x1_demandCurve = lamda_new / 2; % 投标曲线，边际成本/收益
%     diff1(number+1) = x1_demandCurve - x1;
    
    H2 = diag(ones(1,time) .* 0 .* 2); % 负的收益函数不再是严格凸： - 10*x
    f2 = ones(time,1) .* (-10) + lamda_new;
    % 负荷总需量约束 = 50
    Aeq2 = ones(1, time);
    beq2 = 50;
    lb2 = ones(time,1) .* 0;
    ub2 = ones(time,1) .* 10;
    [x2, value2, flag2]  = quadprog(H2, f2, [], [], Aeq2, beq2, lb2, ub2);
    
%     x2_demandCurve = (10 - lamda_new) / 2;
%     diff2(number+1) = x2_demandCurve - x2;
    
    
    lamda_old = lamda_new
    lamda_avg_old = lamda_avg_new
    
    lamda_new = lamda_old + (x2 + L - x1) .* step; % x1-x2的差是中间的矩阵 
    for i = 1:length(lamda_new)
        if lamda_new(i) < 0
            lamda_new(i) = 0;
        end
    end

    number = number + 1  % 改为初始lamda记录
    lamda_record(:,number) = lamda_new;
    
    lamda_avg_new = (lamda_avg_old .* (number-1) + lamda_new) ./ number;
    lamda_avg_record(:,number) = lamda_avg_new;
    
end





