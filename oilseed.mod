set GrowingArea;  # Growing areas G1....G8
set TechPlant;   # oilseed oil ecxtraction plants locations
set Tech;		  # Technology available of TechPlants 	
set ExtractPlant; # seedcake oil extraction plant locations
set ExTech;		  # Technology available of ExTechPlants 		
set K;
 
#=================Parameters=========================

param TechCap{Tech};  	    # Capacity of TechPlants type "T"
param TechFixedCost{Tech} ;	# Fixed cost of TechPlants type "T"
param TechProcessCost{Tech};  # Processing cost of TechPlants type "T" (Rs/T) 
param TechOil{Tech};			# Oil extraction in TechPlants type "T" (kg/T)
param TechSeedCake{Tech};		# Seedcake output from TechPlant type "T" (kg/T)
param TechSCoilPer{Tech};		# pecetage of oil remaining in seedcake at TechPlant type "T"  
param CostTechmat{GrowingArea,TechPlant};		# Cost between oil Tech Plant and growing area 

param ExTechCap{ExTech};		 # Capacity of ExtractPlant of level "l"
param ExTechFixedCost{ExTech};	 # Fixed cost of ExtractPlant of level "l"
param ExTechProcessCost{ExTech}; # Processing cost of ExtractPlant of level "l"
param CostExTechmat{TechPlant,ExtractPlant};	 # Cost between the ExtractPlant  and TechPlant 
param OilTransport{TechPlant,K};

param OilTransport2{K};

#================Variables=====================================

# x{Tech,TechPlants} takes value 1 if Tech "T" establish at TechPlant and 0 otherwise
var x{Tech,TechPlant} binary;                    

#U{Tech,TechPlants, GrowingArea} takes value  1 if flow from Growing area (G1..G8) to oil Tech plants type Tech(T1,T2,T3)
var U{Tech,TechPlant, GrowingArea} binary;

# y{ExtractPlant,ExTech} takes value 1 if extraction plant of type ExTech established    
var y{ExTech,ExtractPlant} binary;

# incomming seedcake at Ectraction plant (e1,e2) of type ExTech from TechPlant
var z{ExTech,ExtractPlant,TechPlant} >=0;

#  multipication of z{ExTech,E1,TechPlant}*x{Tech,TechPlant}
var r{ExTech, TechPlant, Tech } >=0;


var M{TechPlant,K} binary;

var P{Tech,TechPlant,GrowingArea,K} binary;
#============================M=O=D=E=L=============================#


#==============Objective================================================================

minimize TotalCost: sum{j in TechPlant, t in Tech}(TechFixedCost[t]*x[t,j])+ sum{j in TechPlant, t in Tech, g in GrowingArea}(1500*U[t,j,g]*TechProcessCost[t])+sum{j in TechPlant, t in Tech, g in GrowingArea}(1500*U[t,j,g]*CostTechmat[g,j])+
sum{l in ExTech,e in ExtractPlant }(ExTechFixedCost[l]*y[l,e]) + sum{ l in ExTech,e in ExtractPlant,j in TechPlant}(z[l,e,j]*ExTechProcessCost[l])+ sum{ l in ExTech,e in ExtractPlant,j in TechPlant}(z[l,e,j]*CostExTechmat[j,e])+
sum{t in Tech,j in TechPlant,g in GrowingArea, k in K }(P[t,j,g,k]*TechOil[t]*1.5*(OilTransport2[k]+OilTransport[j,k]))+sum{t in Tech,l in ExTech,j in TechPlant}(TechSCoilPer[t]*600*r[l,j,t]);


#=============Contraints=========================================================
 
# supply from g from any j (enforcing contraint) 
s.t. con1{g in GrowingArea}: sum{t in Tech, j in TechPlant}(U[t,j,g])=1;
#  j can have only one technology {T1,T2,T3}
s.t. con2{j in TechPlant}: sum{t in Tech}(x[t,j]) <= 1;
# oilseed incomming at plant j of tech t is not more than the it's capacity 
s.t. con3{t in Tech, j in TechPlant}: sum{g in GrowingArea}(U[t,j,g])<= (TechCap[t]/1500)*x[t,j];
# any extraction plant can have only {L,M,H} level 
s.t. con4{e in ExtractPlant}: sum{l in ExTech}(y[l,e]) <=1;
# seedcake comming at extraction plant e  from j is equal to seedcake going from j to e 
s.t. con5{j in TechPlant}:sum{e in ExtractPlant,l in ExTech}(z[l,e,j]) = sum{t in Tech, g in GrowingArea}(U[t,j,g]*TechSeedCake[t]*1.5);
# 
s.t. con6{e in ExtractPlant,l in ExTech} : sum{j in TechPlant}(z[l,e,j]) <=  ExTechCap[l]*y[l,e];
#
s.t. con7{l in ExTech,t in Tech, j in TechPlant}: r[l,j,t]<= ExTechCap[l]*x[t,j];
#
s.t. con8{l in ExTech,t in Tech, j in TechPlant}: r[l,j,t]-z[l,'E1',j]>= -1*(1-x[t,j])*ExTechCap[l];
#
s.t. con9{l in ExTech,t in Tech, j in TechPlant}: r[l,j,t]-z[l,'E1',j]<= (1-x[t,j])*ExTechCap[l];
# for E2 alway be there in system
#s.t. con10:sum{l in  ExTech} y[l,'E2']=1;
 
s.t. con10{t in Tech,j in TechPlant,g in GrowingArea, k in K }: P[t,j,g,k]<=M[j,k];  
 
s.t. con11{t in Tech,j in TechPlant,g in GrowingArea, k in K }: P[t,j,g,k]<=U[t,j,g];

 
s.t. con12{t in Tech,j in TechPlant,g in GrowingArea, k in K }: P[t,j,g,k]>=M[j,k]+U[t,j,g]-1;
 
 #16302040
 #16026008


