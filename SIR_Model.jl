using DelimitedFiles;
using Plots;
gr();
using Dates;

DATA = readdlm("EbolaVirus.csv",',');
col1 = DATA[:,1];
for i = 1 : length(col1)
	col1[i] = Dates.DateTime(col1[i],"d u y")
end
col1;

Ndays(x) = Dates.datetime2rata(x)-Dates.datetime2rata(col1[54]);

epidays = Array{Int64}(undef,54);

for i = 1 : 54
	epidays[i] = Ndays(col1[i])
end

epidays;

DATA[:,1] = epidays;

DATA;

##DelimitedFiles.writedlm("Julia_SIR_MODEL.csv",DATA,',');

DATA[end-9:end,:];

row,col = size(DATA)

for i = 1 : row
	for j = 1 : col
		if !isnumeric(string(DATA[i,j])[1])
		    DATA[i,j] = 0
	   	end
	end
end

DelimitedFiles.writedlm("Julia_SIR_MODEL.csv",DATA,',');

DATA = DelimitedFiles.readdlm("Julia_SIR_MODEL.csv",',');

No_inf = DATA[:,2];

#plot(epidays,No_inf);

diff_data = DATA[:,[4,6,8]];

#plot(epidays,diff_data);

## This Plot was used to plot virus spread across different Countries
#plot!(epidays,diff_data,marker = ([:diamond :square :star7],4),line = :scatter , xlabel = " No of days since 22nd March " , ylabel = "No of Cases",title = "Ebola Cases in different Countries",label = ["Guinea" "Liberia" "Sierra Leone"])

function updateSIR(vec)
	sus = vec[1]
	inf = vec[2]
	rem = vec[3]
	newS = sus - lambda*sus*inf*dt
	newI = inf + lambda*sus*inf*dt - gamma*inf*dt
	newR = rem + gamma*inf*dt
	return [newS newI newR]
end

# Lambda is the probability of interaction between susceptible individual and infected individual
# Gamma is the proportion of infected people being not contagious.
lambda = 1.47e-6 ; gamma = 1/8 ; dt = 0.5 ; tfin = 610 ; s0 = 10^5 ; i0 = 20. ; r0 = 0 ;

nsteps = round(Int64,tfin/dt);

resultsVal = Array{Float64}(undef , nsteps + 1 , 3);

resultsVal[1,:] = [s0 i0 r0];

timevec = Array{Float64}(undef,nsteps+1);

timevec[1] = 0 ;

for i = 1 : nsteps
	resultsVal[i+1,:] = updateSIR(resultsVal[i,:])
	timevec[i+1] = timevec[i] + dt
end
#plot(timevec,resultsVal,leg = :topright,xlabel = "Time",ylabel = "Population",Title = "SIR Model",label = ["Sus" "Inf" "Rem"])

rVal = resultsVal[:,3];
iVal = resultsVal[:,2];
cVal = iVal + rVal;

#Here we plot the Data values .
plot(timevec,cVal,xlabel = "Epidemic day" , ylabel = "No of Cases to date", title = "Model VS Data",label = "Model Values")

tval_data = DATA[:,1];
tot_cases_data = DATA[:,2];

# This is our Plot where we compare our values with the original Data values.
plot!(tval_data,tot_cases_data,label = "Reported Cases",legend = :right,line=:scatter)


