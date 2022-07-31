  //////////////////////////////////// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 //// 				TWFE BINARY AND CONTINUOUS TREATMENT  		 \\\\\\\\\\\
///////////////////////////////////// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

/////////////////////// First Regression Attempt: 6 lags/leads, UU \\\\\\\\\\\\\\\\\\\\\\\

preserve

import excel "/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Final Datasets/All Counties/ghg_cmp_upanel_ufac.xlsx", sheet("Sheet 1") firstrow
destring year county_fips, replace

// - Chaisemartin and D'Haultfoeuille 2020, 2021 - Binary Treatment

did_multiplegt ch4hh county_fips year binarytreat_cs, breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUb1")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUb2")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUb3")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUb4")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUb5")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUb6")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUb7")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare do_treatshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUb8")
ereturn list

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since Curbside Collection is Implemented") ytitle("Average causal effect") title("UU Dataset - Binary Treatment") ylabel(-1(0.5)1) xlabel(-6(1)6)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "UUbinaryEvent.pdf"

// - Chaisemartin and D'Haultfoeuille 2020, 2021 - Continuous Treatment

did_multiplegt ch4hh county_fips year cs_treatshare, breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUc1")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUc2")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUc3")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUc4")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUc5")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUc6")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUc7")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare do_treatshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/UUc8")
ereturn list

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since Curbside Collection is Implemented") ytitle("Average causal effect") title("UU Dataset - Continuous Treatment") ylabel(-1(0.5)1) xlabel(-6(1)6)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "UUcontinuousEvent.pdf"

restore

/////////////////////// Second Regression Attempt: 6 lags/leads, UB \\\\\\\\\\\\\\\\\\\\\\\

preserve

import excel "/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Final Datasets/All Counties/ghg_cmp_bpanel_ufac.xlsx", sheet("Sheet 1") firstrow
destring year county_fips, replace

// - Chaisemartin and D'Haultfoeuille 2020, 2021 - Binary Treatment

did_multiplegt ch4hh county_fips year binarytreat_cs, breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUb1")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUb2")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUb3")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUb4")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUb5")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUb6")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUb7")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare do_treatshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUb8")
ereturn list

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since Curbside Collection is Implemented") ytitle("Average causal effect") title("BU Dataset - Binary Treatment") ylabel(-1(0.5)1) xlabel(-6(1)6)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "BUbinaryEvent.pdf"

// - Chaisemartin and D'Haultfoeuille 2020, 2021 - Continuous Treatment


did_multiplegt ch4hh county_fips year cs_treatshare, breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUc1")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUc2")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUc3")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUc4")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUc5")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUc6")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUc7")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare do_treatshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BUc8")
ereturn list

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since Curbside Collection is Implemented") ytitle("Average causal effect") title("BU Dataset - Continuous Treatment") ylabel(-1(0.5)1) xlabel(-6(1)6)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "BUcontinuousEvent.pdf"
restore

/////////////////////// Third Regression Attempt: 6 lags/leads, BB \\\\\\\\\\\\\\\\\\\\\\\

preserve

import excel "/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Final Datasets/All Counties/ghg_cmp_bpanel_bfac.xlsx", sheet("Sheet 1") firstrow
destring year county_fips, replace

// - Chaisemartin and D'Haultfoeuille 2020, 2021 - Binary Treatment

did_multiplegt ch4hh county_fips year binarytreat_cs, breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBb1")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBb2")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBb3")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBb4")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBb5")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBb6")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBb7")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare do_treatshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBb8")
ereturn list

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since Curbside Collection is Implemented") ytitle("Average causal effect") title("BB Dataset - Binary Treatment") ylabel(-1(0.5)1) xlabel(-6(1)6)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "BBbinaryEvent.pdf"

// - Chaisemartin and D'Haultfoeuille 2020, 2021  - Continuous Treatment
did_multiplegt ch4hh county_fips year cs_treatshare, breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBc1")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBc2")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBc3")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBc4")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBc5")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBc6")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBc7")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare do_treatshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/BBc8")
ereturn list

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since Curbside Collection is Implemented") ytitle("Average causal effect") title("BB Dataset - Continuous Treatment") ylabel(-1(0.5)1) xlabel(-6(1)6)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "BBcontinuousEvent.pdf"

restore

/////////////////////// Fourth Regression Attempt: 6 lags/leads, SUU \\\\\\\\\\\\\\\\\\\\\\\

preserve

import excel "/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Final Datasets/Counties without NA Communities/sghg_cmp_upanel_ufac.xlsx", sheet("Sheet 1") firstrow
destring year county_fips, replace

// - Chaisemartin and D'Haultfoeuille 2020, 2021 - Binary Treatment

did_multiplegt ch4hh county_fips year binarytreat_cs, breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUb1")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUb2")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUb3")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUb4")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUb5")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUb6")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUb7")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare do_treatshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUb8")

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since Curbside Collection is Implemented") ytitle("Average causal effect") title("SUU Dataset - Binary Treatment") ylabel(-1(0.5)1) xlabel(-6(1)6)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "SUUbinaryEvent.pdf"

// - Chaisemartin and D'Haultfoeuille 2020, 2021 - Continuous Treatment
did_multiplegt ch4hh county_fips year cs_treatshare, breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUc1")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUc2")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUc3")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUc4")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUc5")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUc6")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUc7")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare do_treatshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SUUc8")
ereturn list

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since Curbside Collection is Implemented") ytitle("Average causal effect") title("SUU Dataset - Continuous Treatment") ylabel(-1(0.5)1) xlabel(-6(1)6)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "SUUcontinuousEvent.pdf"

restore

/////////////////////// Fifth Regression Attempt: 6 lags/leads, SBU \\\\\\\\\\\\\\\\\\\\\\\

preserve

import excel "/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Final Datasets/Counties without NA Communities/sghg_cmp_bpanel_ufac.xlsx", sheet("Sheet 1") firstrow
destring year county_fips, replace

// - Chaisemartin and D'Haultfoeuille 2020, 2021 - Binary Treatment

did_multiplegt ch4hh county_fips year binarytreat_cs, breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUb1")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUb2")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUb3")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUb4")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUb5")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUb6")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUb7")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare do_treatshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUb8")
ereturn list

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since Curbside Collection is Implemented") ytitle("Average causal effect") title("SBU Dataset - Binary Treatment") ylabel(-1(0.5)1) xlabel(-6(1)6)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "SBUbinaryEvent.pdf"

// - Chaisemartin and D'Haultfoeuille 2020, 2021 - Continuous Treatment
did_multiplegt ch4hh county_fips year cs_treatshare, breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUc1")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUc2")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUc3")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUc4")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUc5")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUc6")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUc7")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare do_treatshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBUc8")
ereturn list

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since Curbside Collection is Implemented") ytitle("Average causal effect") title("SBU Dataset - Continuous Treatment") ylabel(-1(0.5)1) xlabel(-6(1)6)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "SBUcontinuousEvent.pdf"

restore

/////////////////////// Sixth Regression Attempt: 6 lags/leads, SBB \\\\\\\\\\\\\\\\\\\\\\\

preserve

import excel "/Users/DNW/Desktop/ECON 594_595/MA Thesis/Datasets/Final Datasets/Counties without NA Communities/sghg_cmp_bpanel_bfac.xlsx", sheet("Sheet 1") firstrow
destring year county_fips, replace

// - Chaisemartin and D'Haultfoeuille 2020, 2021 - Binary Treatment

did_multiplegt ch4hh county_fips year binarytreat_cs, breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBb1")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBb2")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBb3")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBb4")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBb5")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBb6")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBb7")
ereturn list

did_multiplegt ch4hh county_fips year binarytreat_cs, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare do_treatshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBb8")

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since Curbside Collection is Implemented") ytitle("Average causal effect") title("SBB Dataset - Binary Treatment") ylabel(-1(0.5)1) xlabel(-6(1)6)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "SBBbinaryEvent.pdf"


// - Chaisemartin and D'Haultfoeuille 2020, 2021 - Continuous Treatment
did_multiplegt ch4hh county_fips year cs_treatshare, breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBc1")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBc2")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBc3")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBc4")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBc5")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBc6")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBc7")
ereturn list

did_multiplegt ch4hh county_fips year cs_treatshare, controls(Population AvgHHSize RenterFraction MedianIncome facnum demshare do_treatshare) breps(10) average_effect covariances cluster(county_fips) robust_dynamic placebo(6) dynamic(6) threshold_stable_treatment(0.05) save_results("/Users/DNW/Desktop/ECON 594_595/MA Thesis/Results/RegOutput/SBBc8")
ereturn list

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since Curbside Collection is Implemented") ytitle("Average causal effect") title("SBB Dataset - Continuous Treatment") ylabel(-1(0.5)1) xlabel(-6(1)6)) stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "SBBcontinuousEvent.pdf"

restore








