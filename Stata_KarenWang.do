//import data sets, keep and rename necessary variables, transfrom into binary
//1 being normal, and 0 being abnormal

//cleaning 'smoking' variable
import sasxport5 "M:\SMQ_D.XPT", clear
keep smq020 seqn
drop if smq020 == 7
drop if smq020 == 9
drop if smq020 ==.
rename smq020 smoking
replace smoking = 0 if smoking == 1
replace smoking = 1 if smoking == 2
rename seqn id
save "M:\smoking.dta", replace

//cleaning 'bmi' variable
import sasxport5 "M:\BMX_D.XPT", clear
keep bmxbmi seqn
drop if bmxbmi == .
generate bmi = 0
replace bmi = 1 if bmxbmi >= 18.5 & bmxbmi <= 24.9
rename seqn id
drop bmxbmi
save "M:\bmi.dta", replace

//cleaning 'activity' variable
import sasxport5 "M:\PAQIAF_D.XPT", clear
keep padlevel padtimes paddurat seqn
drop if padlevel == .
drop if padtimes == .
drop if paddurat == .
generate pa=padlevel*padtimes*paddurat
collapse (sum) pa , by(seqn)
generate activity = 0
replace activity = 1 if pa >= 600
rename seqn id
drop pa
save "M:\activity.dta", replace

//cleaning 'diet' variable
import sasxport5 "M:\DBQ_D.XPT", clear
keep dbq700 seqn
drop if dbq700 == 7
drop if dbq700 == 9
drop if dbq700 ==.
rename dbq700 diet
rename seqn id
replace diet = 1 if diet == 1 | diet == 2 | diet == 3
replace diet = 0 if diet == 4 | diet == 5
save "M:\diet.dta", replace

//cleaning 'blood cholesterol' variable
import sasxport5 "M:\TCHOL_D.XPT", clear
keep lbxtc seqn
drop if lbxtc == .
rename seqn id
generate cholesterol = 0
replace cholesterol = 1 if lbxtc < 200
drop lbxtc
save "M:\cholesterol.dta", replace

//cleaning 'blood glucose' variable
import sasxport5 "M:\GLU_D.XPT", clear
keep lbxglu seqn
drop if lbxglu == .
rename seqn id
generate glucose = 0
replace glucose = 1 if lbxglu <= 100
drop lbxglu
save "M:\glucose.dta", replace

//cleaning 'blood pressure' variable, between 120/88 is normal
import sasxport5 "M:\BPX_D.XPT", clear
keep bpxdi1 bpxdi2 bpxdi3 bpxsy1 bpxsy2 bpxsy3 seqn
rename seqn id
egen mean_bp_di = rmean(bpxdi1 bpxdi2 bpxdi3)
egen mean_bp_sy = rmean(bpxsy1 bpxsy2 bpxsy3)
drop if mean_bp_di == 0
drop if mean_bp_sy == 0
drop if mean_bp_di == .
drop if mean_bp_sy == .
generate bp = 0
replace bp = 1 if mean_bp_di < 80 & mean_bp_sy < 120
drop bpxdi1 bpxdi2 bpxdi3 bpxsy1 bpxsy2 bpxsy3 mean_bp_di mean_bp_sy
save "M:\bp.dta", replace

//cleaning 'insurance' variable
import sasxport5 "M:\HIQ_D.XPT", clear
keep hiq011 seqn
rename seqn id
rename hiq011 insurance
drop if insurance == .
drop if insurance == 7
drop if insurance == 9
replace insurance = 0 if insurance == 2
save "M:\insurance.dta", replace

//cleaning demo data set and keep 'gender', 'age', 'race'
import sasxport5 "M:\DEMO_D.XPT", clear
keep riagendr ridageyr ridreth1 seqn
rename seqn id
rename riagendr gender
rename ridageyr age
rename ridreth1 race
drop if gender == .
drop if age == .
drop if race == .
replace gender = 0 if gender == 2
save "M:\demo_d.dta", replace

//cleaning 'education' and 'age'
import sasxport5 "M:\DEMO_D.XPT", clear
keep ridageyr dmdeduc2 seqn
rename seqn id
rename ridageyr age
rename dmdeduc2 edu
drop if age == .
drop if edu == .
drop if edu == 7
drop if edu == 9
keep if age >= 20
save "M:\edu.dta", replace

//merge all the cleaned data sets one by one using 'id'
use M:\demo_d.dta
merge 1:1 id using M:\smoking.dta 
drop _merge
save "M:\demo_d.dta", replace

use M:\demo_d.dta
merge 1:1 id using M:\bmi.dta 
drop _merge
save "M:\demo_d.dta", replace

use M:\demo_d.dta
merge 1:1 id using M:\diet.dta 
drop _merge
save "M:\demo_d.dta", replace

use M:\demo_d.dta
merge 1:1 id using M:\cholesterol.dta 
drop _merge
save "M:\demo_d.dta", replace

use M:\demo_d.dta
merge 1:1 id using M:\glucose.dta 
drop _merge
save "M:\demo_d.dta", replace

use M:\demo_d.dta
merge 1:1 id using M:\bp.dta 
drop _merge
save "M:\demo_d.dta", replace
use M:\demo_d.dta

use M:\demo_d.dta
merge 1:1 id using M:\activity.dta 
drop _merge
save "M:\demo_d.dta", replace

use M:\demo_d.dta
merge 1:1 id using M:\edu.dta 
drop _merge
save "M:\demo_d.dta", replace

use M:\demo_d.dta
merge 1:1 id using M:\insurance.dta 
drop _merge
save "M:\demo_d.dta", replace

//generate a count variable to remove all the missing value
egen count = rownonmiss(_all)
drop if count <13
drop count

//generate cvh by adding up all the index variables
generate cvh = smoking + bmi + diet + cholesterol + glucose +bp + activity

//generate age_factor which is each decade in age is a level 
generate age_factor = 1
replace age_factor = 2 if age > 10 & age < 20
replace age_factor = 3 if age > 20 & age < 30
replace age_factor = 4 if age > 30 & age < 40
replace age_factor = 5 if age > 40 & age < 50
replace age_factor = 6 if age > 50 & age < 60
replace age_factor = 7 if age > 60 & age < 70
replace age_factor = 8 if age > 70 & age < 80
replace age_factor = 9 if age > 80
save "M:\group_project_data.dta", replace


//modeling
use M:\group_project_data.dta

//logistic regression
logit smoking i.gender i.edu i.age_factor i.insurance i.race
logit bp i.gender i.edu i.age_factor i.insurance i.race
logit activity i.gender i.edu i.age_factor i.insurance i.race
logit cholesterol i.gender i.edu i.age_factor i.insurance i.race
logit glucose i.gender i.edu i.age_factor i.insurance i.race
logit bmi i.gender i.edu i.age_factor i.insurance i.race
logit diet i.gender i.edu i.age_factor i.insurance i.race

//ols model
regress cvh gender age_factor race edu insurance
regress cvh gender age_factor edu insurance

//graph all four box plots
graph box cvh, over(gender) title("Box plot for Gender", span) 
graph save "Graph" "M:\box_gender.gph",replace

graph box cvh, over(edu) title("Box plot for Education", span)
graph save "Graph" "M:\box_edu.gph", replace

graph box cvh, over(insurance) title("Box plot for Insurance", span)
graph save "Graph" "M:\box_insurance.gph", replace

graph box cvh, over(age_factor) title("Box plot for Age", span)
graph save "Graph" "M:\box_age.gph", replace

//mixed linear model with 'age_factor' as the random effects
mixed cvh i.gender i.insurance c.age c.edu ||_all:R.age_factor