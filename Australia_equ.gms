* OSEMOSYS_EQU.GMS - model equations
*
* OSEMOSYS 2011.07.07 medley with 2012.01.01
* - 2017/05 Restyling by The Prophets
* - 2012/08 Conversion to GAMS by Tommy il bello, TommyTomac, Nobel e Winters
*
* OSEMOSYS 2011.07.07
* Open Source energy Modeling SYStem
*
* =======================================================================


*------------------------------------------------------------------------
* Objective function
*------------------------------------------------------------------------

free variable z;
equation cost;
cost..
    z =e= sum((y,t,r), TotalDiscountedCost(y,t,r));

*** START & FINISH ***
Yearmin = smin(y, YearVal(y));
Yearmax = smax(y, YearVal(y));

*------------------------------------------------------------------------
* Total Discounted Costs
*------------------------------------------------------------------------
***AGGIUNTA DISTINZIONE TRA TOTAL_DISCOUNTED_COST_BY_TECHNOLOGY E TOTAL_DISCOUNTED_COST (takes into account also the cost of storage)***
equation TDC1_TotalDiscountedCostByTechnology(YEAR,TECHNOLOGY,REGION);
TDC1_TotalDiscountedCostByTechnology(y,t,r)..
    TotalDiscountedCostByTechnology(y,t,r) =e= DiscountedOperatingCost(y,t,r) + DiscountedCapitalInvestment(y,t,r) + DiscountedTechnologyEmissionsPenalty(y,t,r) - DiscountedSalvageValue(y,t,r);

equation TDC2_TotalDiscountedCost(YEAR,REGION);
TDC2_TotalDiscountedCost(y,r)..
        TotalDiscountedCost(y,r) =e= sum(t,TotalDiscountedCostByTechnology(y,t,r))+sum(s,TotalDiscountedStorageCost(s,y,r));


*------------------------------------------------------------------------
* Operating Costs
*------------------------------------------------------------------------

equation OC4_DiscountedOperatingCostsTotalAnnual(YEAR,TECHNOLOGY,REGION);
OC4_DiscountedOperatingCostsTotalAnnual(y,t,r)..
    DiscountedOperatingCost(y,t,r) =e= OperatingCost(y,t,r)/((1 + DiscountRate(r,t))**(YearVal(y) - smin(yy, YearVal(yy)) + 0.5));

equation OC3_OperatingCostsTotalAnnual(YEAR,TECHNOLOGY,REGION);
OC3_OperatingCostsTotalAnnual(y,t,r)..
    OperatingCost(y,t,r) =e= AnnualFixedOperatingCost(y,t,r) + AnnualVariableOperatingCost(y,t,r);

equation OC2_OperatingCostsFixedAnnual(YEAR,TECHNOLOGY,REGION);
OC2_OperatingCostsFixedAnnual(y,t,r)..
    AnnualFixedOperatingCost(y,t,r) =e= TotalCapacityAnnual(y,t,r)*FixedCost(r,t,y);

equation OC1_OperatingCostsVariable(YEAR,TECHNOLOGY,REGION);
OC1_OperatingCostsVariable(y,t,r)..
    AnnualVariableOperatingCost(y,t,r) =e= sum(m, (TotalAnnualTechnologyActivityByMode(y,t,m,r)*VariableCost(r,t,m,y)));

equation Acc3_AverageAnnualRateOfActivity(YEAR,TECHNOLOGY,MODE_OF_OPERATION,REGION);
Acc3_AverageAnnualRateOfActivity(y,t,m,r)..
    TotalAnnualTechnologyActivityByMode(y,t,m,r) =e= sum(l, RateOfActivity(y,l,t,m,r)*YearSplit(l,y));


*------------------------------------------------------------------------
* Capital Investments
*------------------------------------------------------------------------

equation CC2_DiscountingCapitalInvestmenta(YEAR,TECHNOLOGY,REGION);
CC2_DiscountingCapitalInvestmenta(y,t,r)..
    DiscountedCapitalInvestment(y,t,r) =e= CapitalInvestment(y,t,r)/((1 + DiscountRate(r,t))**(YearVal(y) - StartYear));

equation CC1_UndiscountedCapitalInvestment(YEAR,TECHNOLOGY,REGION);
CC1_UndiscountedCapitalInvestment(y,t,r)..
    CapitalInvestment(y,t,r) =e= CapitalCost(r,t,y) * NewCapacity(y,t,r);



*------------------------------------------------------------------------
* Emissions Penalties
*------------------------------------------------------------------------

equation E5_DiscountedEmissionsPenaltyByTechnology(YEAR,TECHNOLOGY,REGION);
E5_DiscountedEmissionsPenaltyByTechnology(y,t,r)..
    DiscountedTechnologyEmissionsPenalty(y,t,r) =e= AnnualTechnologyEmissionsPenalty(y,t,r)/
    ((1 + DiscountRate(r,t))**(YearVal(y) - smin(yy, YearVal(yy)) + 0.5));

equation E4_EmissionsPenaltyByTechnology(YEAR,TECHNOLOGY,REGION);
E4_EmissionsPenaltyByTechnology(y,t,r)..
    AnnualTechnologyEmissionsPenalty(y,t,r) =e= sum(e, AnnualTechnologyEmissionPenaltyByEmission(y,t,e,r));

equation E3_EmissionsPenaltyByTechAndEmission(YEAR,TECHNOLOGY,EMISSION,REGION);
E3_EmissionsPenaltyByTechAndEmission(y,t,e,r)..
    AnnualTechnologyEmissionPenaltyByEmission(y,t,e,r) =e= AnnualTechnologyEmission(y,t,e,r)*EmissionsPenalty(r,e,y);

equation E2_AnnualEmissionProduction(YEAR,TECHNOLOGY,EMISSION,REGION);
E2_AnnualEmissionProduction(y,t,e,r)..
    AnnualTechnologyEmission(y,t,e,r) =e= sum(m, AnnualTechnologyEmissionByMode(y,t,e,m,r));

equation E1_AnnualEmissionProductionByMode(YEAR,TECHNOLOGY,EMISSION,MODE_OF_OPERATION,REGION);
E1_AnnualEmissionProductionByMode(y,t,e,m,r)..
    AnnualTechnologyEmissionByMode(y,t,e,m,r) =e= EmissionActivityRatio(r,t,e,m,y)*TotalAnnualTechnologyActivityByMode(y,t,m,r);



*------------------------------------------------------------------------
* Salvage Value
*------------------------------------------------------------------------

equation SV4_SalvageValueDiscToStartYr(YEAR,TECHNOLOGY,REGION);
SV4_SalvageValueDiscToStartYr(y,t,r)..
    DiscountedSalvageValue(y,t,r) =e= SalvageValue(y,t,r)/((1 + DiscountRate(r,t))**(1 + smax(yy, YearVal(yy))  -  smin(yy, YearVal(yy))));

equation SV1_SalvageValueAtEndOfPeriod1(YEAR,TECHNOLOGY,REGION);
SV1_SalvageValueAtEndOfPeriod1(y,t,r)$((YearVal(y)  +  OperationalLife(r,t) - 1 > smax(yy, YearVal(yy))) and (DiscountRate(r,t) > 0))..
SalvageValue(y,t,r) =e= CapitalCost(r,t,y)*NewCapacity(y,t,r)*(1 - (((1 + DiscountRate(r,t))**(smax(yy, YearVal(yy))  -  YearVal(y) + 1)  - 1)
/((1 + DiscountRate(r,t))**OperationalLife(r,t) - 1)));

equation SV2_SalvageValueAtEndOfPeriod2(YEAR,TECHNOLOGY,REGION);
SV2_SalvageValueAtEndOfPeriod2(y,t,r)$((YearVal(y)  +  OperationalLife(r,t) - 1 > smax(yy, YearVal(yy))) and (DiscountRate(r,t) = 0))..
SalvageValue(y,t,r) =e= CapitalCost(r,t,y)*NewCapacity(y,t,r)*(1 - smax(yy, YearVal(yy)) -  YearVal(y) + 1)/OperationalLife(r,t);

equation SV3_SalvageValueAtEndOfPeriod3(YEAR,TECHNOLOGY,REGION);
SV3_SalvageValueAtEndOfPeriod3(y,t,r)$(YearVal(y)  +  OperationalLife(r,t) - 1 <= smax(yy, YearVal(yy)))..
SalvageValue(y,t,r) =e= 0;



*------------------------------------------------------------------------
* Capacity Adequacy
*------------------------------------------------------------------------

equation CBa2_TotalAnnualCapacity(YEAR,TECHNOLOGY,REGION);
CBa2_TotalAnnualCapacity(y,t,r)..
    TotalCapacityAnnual(y,t,r) =e= AccumulatedNewCapacity(y,t,r) +  ResidualCapacity(r,t,y);

equation CBa1_TotalNewCapacity(YEAR,TECHNOLOGY,REGION);
CBa1_TotalNewCapacity(y,t,r)..
    AccumulatedNewCapacity(y,t,r) =e=
        sum(yy$((YearVal(y) - YearVal(yy) < OperationalLife(r,t)) and (YearVal(y) - YearVal(yy) >= 0)), NewCapacity(yy,t,r));

** Modifica: Adesso Capacity factor dipende da Timeslice l *****
equation CBa4_Constraint_Capacity(YEAR,TIMESLICE,TECHNOLOGY,REGION);
CBa4_Constraint_Capacity(y,l,t,r)$(TechWithCapacityNeededToMeetPeakTS(r,t) <> 0)..
    RateOfTotalActivity(y,l,t,r) =l=
        TotalCapacityAnnual(y,t,r) * CapacityFactor(r,l,t,y)*CapacityToActivityUnit(r,t);

equation CBa3_TotalActivityOfEachTechnology(YEAR,TECHNOLOGY,TIMESLICE,REGION);
CBa3_TotalActivityOfEachTechnology(y,t,l,r)..
    RateOfTotalActivity(y,l,t,r) =e= sum(m, RateOfActivity(y,l,t,m,r));

* All other technologies have a capacity great enough to at least meet the annual average.
** MODIFICA: Adesso CapacityFactor dipede da l, dunque � stata aggiunta sommatoria a destra della disequazione e la moltiplicazione per Year split, **
** Reference: Modeling elements of smart grids - Enhancing the OSeMOSYS - M. Welsch et al. **
equation CBb1_PlannedMaintenance(YEAR,TECHNOLOGY,REGION);
CBb1_PlannedMaintenance(y,t,r)..
    sum(l, RateOfTotalActivity(y,l,t,r)*YearSplit(l,y)) =l=
        sum (l, YearSplit(l,y)*TotalCapacityAnnual(y,t,r)*CapacityFactor(r,l,t,y)* AvailabilityFactor(r,t,y)*CapacityToActivityUnit(r,t));



*------------------------------------------------------------------------
* Energy Balance
*------------------------------------------------------------------------

* For each time slice

** Balance

equation EBa10_EnergyBalanceEachTS4(YEAR,TIMESLICE,FUEL,REGION);
EBa10_EnergyBalanceEachTS4(y,l,f,r)..
    Production(y,l,f,r) =g= Demand(y,l,f,r) + Use(y,l,f,r);

** Demand

equation EBa9_EnergyBalanceEachTS3(YEAR,TIMESLICE,FUEL,REGION);
EBa9_EnergyBalanceEachTS3(y,l,f,r)..
    Demand(y,l,f,r) =e= RateOfDemand(y,l,f,r)*YearSplit(l,y);

equation EQ_SpecifiedDemand1(YEAR,TIMESLICE,FUEL,REGION);
EQ_SpecifiedDemand1(y,l,f,r)..
    RateOfDemand(y,l,f,r) =e= SpecifiedAnnualDemand(r,f,y)*SpecifiedDemandProfile(r,f,l,y) / YearSplit(l,y);

** Use

equation EBa8_EnergyBalanceEachTS2(YEAR,TIMESLICE,FUEL,REGION);
EBa8_EnergyBalanceEachTS2(y,l,f,r)..
    Use(y,l,f,r) =e= RateOfUse(y,l,f,r)*YearSplit(l,y);

equation EBa6_RateOfFuelUse3(YEAR,TIMESLICE,FUEL,REGION);
EBa6_RateOfFuelUse3(y,l,f,r)..
    RateOfUse(y,l,f,r) =e= sum(t, RateOfUseByTechnology(y,l,t,f,r));

** MODIFICA: Aggiunta condizione su OutputActivityRatio **
equation EBa5_RateOfFuelUse2(YEAR,TIMESLICE,FUEL,TECHNOLOGY,REGION);
EBa5_RateOfFuelUse2(y,l,f,t,r)..
    RateOfUseByTechnology(y,l,t,f,r) =e= sum(m$(InputActivityRatio[y,t,f,m,r] <>0), RateOfUseByTechnologyByMode(y,l,t,m,f,r));

** MODIFICA: Aggiunta condizione su InputActivityRatio **
equation EBa4_RateOfFuelUse1(YEAR,TIMESLICE,FUEL,TECHNOLOGY,MODE_OF_OPERATION,REGION);
EBa4_RateOfFuelUse1(y,l,f,t,m,r)$(InputActivityRatio[y,t,f,m,r] <>0)..
    RateOfUseByTechnologyByMode(y,l,t,m,f,r) =e= RateOfActivity(y,l,t,m,r)*InputActivityRatio(r,t,f,m,y);

** Production

equation EBa7_EnergyBalanceEachTS1(YEAR,TIMESLICE,FUEL,REGION);
EBa7_EnergyBalanceEachTS1(y,l,f,r)..
    Production(y,l,f,r) =e= RateOfProduction(y,l,f,r)*YearSplit(l,y);

equation EBa3_RateOfFuelProduction3(YEAR,TIMESLICE,FUEL,REGION);
EBa3_RateOfFuelProduction3(y,l,f,r)..
    RateOfProduction(y,l,f,r) =e= sum(t, RateOfProductionByTechnology(y,l,t,f,r));

** MODIFICA: Aggiunta condizione su OutputActivityRatio **
equation EBa2_RateOfFuelProduction2(YEAR,TIMESLICE,FUEL,TECHNOLOGY,REGION);
EBa2_RateOfFuelProduction2(y,l,f,t,r)..
    RateOfProductionByTechnology(y,l,t,f,r) =e= sum(m$(OutputActivityRatio[y,t,f,m,r] <>0), RateOfProductionByTechnologyByMode(y,l,t,m,f,r));

** MODIFICA: Aggiunta condizione su OutputActivityRatio **
equation EBa1_RateOfFuelProduction1(YEAR,TIMESLICE,FUEL,TECHNOLOGY,MODE_OF_OPERATION,REGION);
EBa1_RateOfFuelProduction1(y,l,f,t,m,r)$(OutputActivityRatio[y,t,f,m,r] <>0)..
    RateOfProductionByTechnologyByMode(y,l,t,m,f,r) =e= RateOfActivity(y,l,t,m,r)*OutputActivityRatio(r,t,f,m,y);

* For each year

** Balance

equation EBb3_EnergyBalanceEachYear3(YEAR,FUEL,REGION);
EBb3_EnergyBalanceEachYear3(y,f,r)..
    ProductionAnnual(y,f,r) =g= AccumulatedAnnualDemand(r,f,y) + UseAnnual(y,f,r);

** Production
equation EBb1_EnergyBalanceEachYear1(YEAR,FUEL,REGION);
EBb1_EnergyBalanceEachYear1(y,f,r)..
    ProductionAnnual(y,f,r) =e= sum(l, Production(y,l,f,r));

** Use
equation EBb2_EnergyBalanceEachYear2(YEAR,FUEL,REGION);
EBb2_EnergyBalanceEachYear2(y,f,r)..
    UseAnnual(y,f,r) =e= sum(l, Use(y,l,f,r));


*------------------------------------------------------------------------
* Capacity Constraints
*------------------------------------------------------------------------
*** Useless condition on the equation removed **
equation NCC1_TotalAnnualMaxNewCapacityConstraint(YEAR,TECHNOLOGY,REGION);
NCC1_TotalAnnualMaxNewCapacityConstraint(y,t,r)..
    NewCapacity(y,t,r) =l= TotalAnnualMaxCapacityInvestment(r,t,y);

equation NCC2_TotalAnnualMinNewCapacityConstraint(YEAR,TECHNOLOGY,REGION);
NCC2_TotalAnnualMinNewCapacityConstraint(y,t,r)$(TotalAnnualMinCapacityInvestment(r,t,y) > 0)..
    NewCapacity(y,t,r) =g= TotalAnnualMinCapacityInvestment(r,t,y);

*** Useless condition on the equation removed **
equation TCC1_TotalAnnualMaxCapacityConstraint(YEAR,TECHNOLOGY,REGION);
TCC1_TotalAnnualMaxCapacityConstraint(y,t,r)..
    TotalCapacityAnnual(y,t,r) =l= TotalAnnualMaxCapacity(r,t,y);

equation TCC2_TotalAnnualMinCapacityConstraint(YEAR,TECHNOLOGY,REGION);
TCC2_TotalAnnualMinCapacityConstraint(y,t,r)$(TotalAnnualMinCapacity(r,t,y)>0)..
    TotalCapacityAnnual(y,t,r) =g= TotalAnnualMinCapacity(r,t,y);


*------------------------------------------------------------------------
* Activity Constraints
*------------------------------------------------------------------------

* For each year

equation AAC1_TotalAnnualTechnologyActivity(YEAR,TECHNOLOGY,REGION);
AAC1_TotalAnnualTechnologyActivity(y,t,r)..
    TotalTechnologyAnnualActivity(y,t,r) =e= sum(l, (RateOfTotalActivity(y,l,t,r)*YearSplit(l,y)));

*** Useless condition on the equation removed **
equation AAC2_TotalAnnualTechnologyActivityUpperLimit(YEAR,TECHNOLOGY,REGION);
AAC2_TotalAnnualTechnologyActivityUpperLimit(y,t,r)..
    TotalTechnologyAnnualActivity(y,t,r) =l= TotalTechnologyAnnualActivityUpperLimit(r,t,y);

equation AAC3_TotalAnnualTechnologyActivityLowerLimit(YEAR,TECHNOLOGY,REGION);
AAC3_TotalAnnualTechnologyActivityLowerLimit(y,t,r)$(TotalTechnologyAnnualActivityLowerLimit(r,t,y) > 0)..
    TotalTechnologyAnnualActivity(y,t,r) =g= TotalTechnologyAnnualActivityLowerLimit(r,t,y);

* For the whole time horizon

**Corrected Horizen with Horizon and Useless condition on the equation removed**
equation TAC1_TotalModelHorizonTechnologyActivity(TECHNOLOGY,REGION);
TAC1_TotalModelHorizenTechnologyActivity(t,r)..
    TotalTechnologyModelPeriodActivity(t,r) =e= sum(y, TotalTechnologyAnnualActivity(y,t,r));

equation TAC2_TotalModelHorizonTechnologyActivityUpperLimit(YEAR,TECHNOLOGY,REGION);
TAC2_TotalModelHorizenTechnologyActivityUpperLimit(y,t,r)..
    TotalTechnologyModelPeriodActivity(t,r) =l= TotalTechnologyModelPeriodActivityUpperLimit(r,t);

equation TAC3_TotalModelHorizenTechnologyActivityLowerLimit(YEAR,TECHNOLOGY,REGION);
TAC3_TotalModelHorizenTechnologyActivityLowerLimit(y,t,r)$(TotalTechnologyModelPeriodActivityLowerLimit(r,t) > 0)..
    TotalTechnologyModelPeriodActivity(t,r) =g= TotalTechnologyModelPeriodActivityLowerLimit(r,t);



*------------------------------------------------------------------------
* Reserve Margins
*------------------------------------------------------------------------

equation RM1_ReserveMargin_TechologiesIncluded_In_Activity_Units(YEAR,TIMESLICE,REGION);
RM1_ReserveMargin_TechologiesIncluded_In_Activity_Units(y,l,r)..
    TotalCapacityInReserveMargin(r,y) =e= sum (t, (TotalCapacityAnnual(y,t,r) *ReserveMarginTagTechnology(r,t,y) * CapacityToActivityUnit(r,t)));

equation RM2_ReserveMargin_FuelsIncluded(YEAR,TIMESLICE,REGION);
RM2_ReserveMargin_FuelsIncluded(y,l,r)..
    DemandNeedingReserveMargin(y,l,r) =e= sum (f, (RateOfProduction(y,l,f,r) * ReserveMarginTagFuel(r,f,y)));

equation RM3_ReserveMargin_Constraint(YEAR,TIMESLICE,REGION);
RM3_ReserveMargin_Constraint(y,l,r)..
    TotalCapacityInReserveMargin(r,y) =g= DemandNeedingReserveMargin(y,l,r) * ReserveMargin(r,y);


*------------------------------------------------------------------------
* RE production targets
*------------------------------------------------------------------------

equation RE4_EnergyConstraint(YEAR,REGION);
RE4_EnergyConstraint(y,r)..
    REMinProductionTarget(r,y)*RETotalDemandOfTargetFuelAnnual(y,r) =l= TotalREProductionAnnual(y,r);

equation RE2_TechIncluded(YEAR,REGION);
RE2_TechIncluded(y,r)..
    TotalREProductionAnnual(y,r) =e= sum((t,f), (ProductionByTechnologyAnnual(y,t,f,r)*RETagTechnology(r,t,y)));

equation RE1_FuelProductionByTechnologyAnnual(YEAR,TECHNOLOGY,FUEL,REGION);
RE1_FuelProductionByTechnologyAnnual(y,t,f,r)..
    ProductionByTechnologyAnnual(y,t,f,r) =e= sum(l, ProductionByTechnology(y,l,t,f,r));

equation Acc1_FuelProductionByTechnology(YEAR,TIMESLICE,TECHNOLOGY,FUEL,REGION);
Acc1_FuelProductionByTechnology(y,l,t,f,r)..
    ProductionByTechnology(y,l,t,f,r) =e= RateOfProductionByTechnology(y,l,t,f,r) * YearSplit(l,y);

equation RE3_FuelIncluded(YEAR,REGION);
RE3_FuelIncluded(y,r)..
    RETotalDemandOfTargetFuelAnnual(y,r) =e= sum((l,f), (RateOfDemand(y,l,f,r)*YearSplit(l,y)*RETagFuel(r,f,y)));


*------------------------------------------------------------------------
* Emissions constraints
*------------------------------------------------------------------------

* For each year

equation E8_AnnualEmissionsLimit(YEAR,EMISSION,REGION);
E8_AnnualEmissionsLimit(y,e,r)..
    AnnualEmissions(y,e,r) + AnnualExogenousEmission(r,e,y) =l= AnnualEmissionLimit(r,e,y);

equation E6_EmissionsAccounting1(YEAR,EMISSION,REGION);
E6_EmissionsAccounting1(y,e,r)..
    AnnualEmissions(y,e,r) =e= sum(t, AnnualTechnologyEmission(y,t,e,r));


* For the whole time horizon

equation E9_ModelPeriodEmissionsLimit(EMISSION,REGION);
E9_ModelPeriodEmissionsLimit(e,r)..
    ModelPeriodEmissions(e,r) =l= ModelPeriodEmissionLimit(r,e);

equation E7_EmissionsAccounting2(EMISSION,REGION);
E7_EmissionsAccounting2(e,r)..
    ModelPeriodEmissions(e,r) =e= sum(y, AnnualEmissions(y,e,r)) + ModelPeriodExogenousEmission(r,e);



*------------------------------------------------------------------------
* Storage
*------------------------------------------------------------------------

equation S1_RateOfStorageCharge(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
S1_RateOfStorageCharge(s,y,ls,ld,lh,r)..
    RateOfStorageCharge(s,y,ls,ld,lh,r) =e= sum((t,m,l)$(TechnologyToStorage(r,t,s,m)>0),RateOfActivity(y,l,t,m,r)*TechnologyToStorage(r,t,s,m)*Conversionls(ls,l)*Conversionld(ld,l)*Conversionlh(lh,l);

equation S2_RateOfStorageDischarge(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMBRACKET,REGION);
S2_RateOfStorageDischarge(s,y,ls,ld,lh,r)..
    RateOfStorageDischarge(s,y,ls,ld,lh,r) =e= sum((t,m,l)$(TechnologyFromStorage(r,t,s,m)>0),RateOfActivity(y,l,t,m,r)*TechnologyFromStorage(r,t,s,m)*Conversionls(ls,l)*Conversionld(ld,l)*Conversionlh(lh,l);

equation S3_NetChargeWithinYear(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
S3_NetChargeWithinYear(s,y,ls,ld,lh,r)..
    NetChargeWithinYear(s,y,ls,ld,lh,r) =e= sum(l$(Conversionls(ls,l)>0 and Conversionld(ld,l)>0 and Conversionlh(ld,l)>0),(RateOfStorageCharge(s,y,ls,ld,lh,r)-RateOfStorageDischarge(s,y,ls,ld,lh,r))*YearSplit(y,l)*Conversionls(ls,l)*Conversionld(ld,l)*Conversionlh(lh,l);

equation S4_NetChargeWithinDay(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
S4_NetChargeWithinDay(s,y,ls,ld,lh,r)..
    NetChargeWithinDay(s,y,ls,ld,lh,r) =e= (RateOfStorageCharge(s,y,ls,ld,lh,r)-RateOfStorageDischarge(s,y,ls,ld,lh,r))*DaySplit(y,lh);

equation S5_6_StorageLevelYearStart(STORAGE,YEAR,REGION);
S5_StorageLevelYearStart(s,y,r)..
    if (y=Yearmin,
         StorageLevelYearStart(s,y,r) =e= StorageLevelStart(s,r);
    else
         StorageLevelYearStart(s,y,r) =e= StorageLevelYearStart(s,y-1,r)+sum((ls,ld,lh),NetChargeWithinYear(s,y-1,ls,ld,lh,r));
        );

equation S7_8_StorageLevelYearFinish(STORAGE,YEAR,REGION);
S7_8_StorageLevelYearFinish(s,y,r)..
    if (y<Yearmax,
         StorageLevelYearFinish(s,y,r) =e= StorageLevelYearStart(s,y+1,r);
    else
         StorageLevelYearFinish(s,y,r) =e= StorageLevelYearStart(s,y,r)+sum((ls,ld,lh),NetChargeWithinYear(s,y,ls,ld,lh,r));
        );

equation S9_10_StorageLevelSeasonStart(STORAGE,YEAR,SEASON,REGION);
S9_10_StorageLevelSeasonStart(s,y,ls,r)..
    if(ls=smin(lsls,SeasonVal(lsls)),
         StorageLevelSeasonStart(s,y,ls,r) =e= StorageLevelYearStart(s,y,r);
    else
         StorageLevelSeasonStart(s,y,ls,r) =e= StorageLevelSeasonStart(s,y,ls-1,r)+sum((ld,lh),NetChargeWithinDay(s,y,ls-1,ld,lh,r));
      );

equation S11_and_S12_StorageLevelDayTypeStart(STORAGE,YEAR,SEASON,DAYTYPE,REGION);
S11_and_S12_StorageLevelDayTypeStart(s,y,ls,ld,r)..
        if( ld=smin(ldld, DayTypeVal(ldld)) ,
                StorageLevelDayTypeStart(s,y,ls,ld,r) =e= StorageLevelSeasonStart (s,y,ls,r);
        else
                        StorageLevelDayTypeStart(s,y,ls,ld,r) =e= StorageLevelDayTypeStart(s,y,ls,ld-1,r) + sum( lh, NetChargeWithinDay(s,y,ls,ld-1,lh,r)*DaysInDayTyper(y,ls,ld-1));
                        );

equation S13_and_S14_and_S15_StorageLevelDayTypeFinish(STORAGE,YEAR,SEASON,DAYTYPE,REGION);
S13_and_S14_and_S15_StorageLevelDayTypeFinish(s,y,ls,ld,r)..
        if( ls=smax(lsls, SeasonVal(lsls)) and ld= smax(ldld, DayTypeVal(ldld)),
                StorageLevelDayTypeFinish(s,y,ls,ld,r) =e= StorageLevelYearFinish(s,y,r);
        elseif        ld= smax(ldld, DayTypeVal(ldld)),
                StorageLevelDayTypeFinish(s,y,ls,ld,r) =e= StorageLevelSeasonStart(s,y,ls+1,r);
        else
                StorageLevelDayTypeFinish(s,y,ls,ld,r) =e= StorageLevelDayTypeFinish(s,y,ls,ld+1,r) - sum( lh, NetChargeWithinDay(s,y,ls,ld+1.lh,r)*DaysInDayTyper(yearsplit,ls,ld+1) );
                );

**---- STORAGE CONSTRAINTS ----**
equation SC1_LowerLimit_BeginningOfDailyTimeBracketOfFirstInstanceOfDayTypeInFirstWeekConstraint(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
SC1_LowerLimit_BeginningOfDailyTimeBracketOfFirstInstanceOfDayTypeInFirstWeekConstraint(s,y,ls,ld,lh,r)..
        ( StorageLevelDayTypeStart(s,y,ls,ld,r) + sum(lhlh$(lh-lhlh>0), NetChargeWithinDay(s,y,ls,ld,lhlh,r))) - StorageLowerLimit(s,y,r) =g= 0;

equation SC1_UpperLimit_BeginningOfDailyTimeBracketOfFirstInstanceOfDayTypeInFirstWeekConstraint(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
SC1_UpperLimit_BeginningOfDailyTimeBracketOfFirstInstanceOfDayTypeInFirstWeekConstraint(s,y,ls,ld,r)..
        StorageLevelDayTypeStart(s,y,ls,ld,r) + sum(lhlh$(lh-lhlh>0), NetChargeWithinDay(s,y,ls,ld,lhlh,r))) - StorageUpperLimit(s,y,r) =l= 0;

equation SC2_LowerLimit_EndOfDailyTimeBracketOfLastInstanceOfDayTypeInFirstWeekConstraint(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
SC2_LowerLimit_EndOfDailyTimeBracketOfLastInstanceOfDayTypeInFirstWeekConstraint(s,y,ls,ld,lh,r)$(ld>smin(ldld, DayTypeVal(ldld)))..
        (StorageLevelDayTypeStart(s,y,ls,ld,r) - sum(lhlh$(lh-lhlh<0),NetChargeWithinDay(s,y,ls,ld-1,lhlh,r))) - StorageLowerLimit(s,y,r) =g= 0;

equation SC2_UpperLimit_EndOfDailyTimeBracketOfLastInstanceOfDayTypeInFirstWeekConstraint(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
SC2_UpperLimit_EndOfDailyTimeBracketOfLastInstanceOfDayTypeInFirstWeekConstraint(s,y,ls,ld,lh,r)$(ld>smin(ldld, DayTypeVal(ldld)))..
        (StorageLevelDayTypeStart(s,y,ls,ld+1,r) - sum(lhlh$(lh-lhlh<0),NetChargeWithinDay(s,y,ls,ld-1,lhlh,r))) - StorageUpperLimit(s,y,r) =l= 0;

equation SC3_LowerLimit_EndOfDailyTimeBracketOfLastInstanceOfDayTypeInLastWeekConstraint(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
SC3_LowerLimit_EndOfDailyTimeBracketOfLastInstanceOfDayTypeInLastWeekConstraint(s,y,ls,ld,lh,r)..
        (StorageLevelDayTypeFinish(s,y,ls,ld,r) - sum(lhlh$(lh-lhlh<0),NetChargeWithinDay(s,y,ls,ld,lhlh,r))) - StorageLowerLimit(s,y,r) =g= 0;

equation SC3_UpperLimit_EndOfDailyTimeBracketOfLastInstanceOfDayTypeInLastWeekConstraint(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
SC3_UpperLimit_EndOfDailyTimeBracketOfLastInstanceOfDayTypeInLastWeekConstraint(s,y,ls,ld,lh,r)..
        (StorageLevelDayTypeFinish(s,y,ls,ld,r) - sum(lhlh$(lh-lhlh<0),NetChargeWithinDay(s,y,ls,ld,lhlh,r))) -StorageUpperLimit(s,y,r) =l= 0;

equation SC4_LowerLimit_BeginningOfDailyTimeBracketOfFirstInstanceOfDayTypeInLastWeekConstraint(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
SC4_LowerLimit_BeginningOfDailyTimeBracketOfFirstInstanceOfDayTypeInLastWeekConstraint(s,y,ls,ld,lh,r)$(ld>smin(ldld, DayTypeVal(ldld)))..
        (StorageLevelDayTypeFinish(s,y,ls,ld-1,r) + sum(lhlh$(lh-lhlh>0), NetChargeWithinDay(s,y,ls,ld,lhlh,r))) -StorageLowerLimit(s,y,r) =g= 0;

equation SC4_UpperLimit_BeginningOfDailyTimeBracketOfFirstInstanceOfDayTypeInLastWeekConstraint(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
SC4_UpperLimit_BeginningOfDailyTimeBracketOfFirstInstanceOfDayTypeInLastWeekConstraint(s,y,ls,ld,lh,r)$(ld>smin(ldld, DayTypeVal(ldld)))..
        (StorageLevelDayTypeFinish(s,y,ls,ld-1,r) + sum(lhlh$(lh-lhlh>0), NetChargeWithinDay(s,y,ls,ld,lhlh,r))) -StorageUpperLimit(s,y,r) =l= 0;

equation SC5_MaxChargeConstraint(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
SC5_MaxChargeConstraint(s,y,ls,ld,lh,r)..
        RateOfStorageCharge(s,y,ls,ld,lh,r) =g= StorageMaxChargeRate(s,r);

equation SC6_MaxDischargeConstraint(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
SC6_MaxDischargeConstraint(s,y,ls,ld,lh,r)..
        RateOfStorageDischarge(s,y,ls,ld,lh,r) =l= StorageMaxDischargeRate(s,r);

**------ STORAGE INVESTMENTS -----**
equation SI1_StorageUpperLimit(STORAGE,YEAR,REGION);
SI1_StorageUpperLimit(s,y,r)..
        StorageUpperLimit(s,y,r) =e= AccumulatedNewStorageCapacity(s,y,r) + ResidualStorageCapacity(s,y,r);

equation SI2_StorageLowerLimit(STORAGE,YEAR,REGION);
SI2_StorageLowerLimit(s,y,r)..
        StorageLowerLimit(s,y,r) =e= MinStorageCharge(s,y,r)*StorageUpperLimit(s,y,r);

equation SI3_TotalNewStorage(STORAGE,YEAR,REGION);
SI3_TotalNewStorage(s,y,r)..
        AccumulatedNewStorageCapacity(s,y,r) =e= sum(yy$(y-yy<OperationalLifeStorage(s,r) and y-yy>=0), NewStorageCapacity(s,yy,r));

equation SI4_UndiscountedCapitalInvestmentStorage(STORAGE,YEAR,REGION);
SI4_UndiscountedCapitalInvestmentStorage(s,y,r)..
        CapitalInvestmentStorage(s,y,r) =e= CapitalCostStorage(s,y,r)*NewStorageCapacity(s,y,r);

equation SI5_DiscountingCapitalInvestmentStorage(STORAGE,YEAR,REGION);
SI5_DiscountingCapitalInvestmentStorage(s,y,r)..
DiscountedCapitalInvestmentStorage(s,y,r) =e= CapitalInvestmentStorage(s,y,r)/((1+DiscountRateStorage(s,r))^(y-Yearmin));

equation SI6_7_8_SalvageValueStorageAtEndOfPeriod(STORAGE, YEAR, REGION);
SI6_SalvageValueStorageAtEndOfPeriod(s,y,r)..
         if ( ( (y+OperationalLifeStorage(r,s) -1) <= smax( yy, YearVal(yy) ) ),
                 SalvageValueStorage(s,y,r) =e= 0;
         elseif ( (y+OperationalLifeStorage(r,s) -1) > smax( yy, YearVal(yy)) and DiscountRateStorage(r,s)=0 ),
                 SalvageValueStorage(s,y,r) =e= CapitalInvestmentStorage(s,y,r) * ( 1- smax(yy, YearVal(yy)) -y+1 ) / OperationalLifeStorage(r,s);
         else ( (y+OperationalLifeStorage(r,s) -1) > smax( yy, YearVal(yy)) and DiscountRateStorage(r,s)>0 ),
               SalvageValueStorage(s,y,r) =e= CapitalInvestmentStorage(s,y,r) * ( 1-  ( (1+DiscountRateStorage(r,s)) ^(smax(yy, YearVal(yy))-y+1) -1 )/( ( 1+DiscountRateStorage(r,s) )^( OperationalLifeStorage(r,s) )-1));
         );

equation SI9_SalvageValueStorageDiscountedToStartYear (STORAGE,YEAR,REGION);
SI9_SalvageValueStorageDiscountedToStartYear(s,y,r)..
                DiscountedSalvageValueStorage(s,y,r) =e= SalvageValueStorage(s,y,r)/ ((1+ DiscountRateStorage(r,s))^ (smax(yy,YearVal(yy)) -smin(yy,YearVal(yy)) +1));

equation SI10_TotalDiscountedCostByStorage(STORAGE,YEAR,REGION);
SI10_TotalDiscountedCostByStorage(s,y,r)..
                TotalDiscountedStorageCost(s,y,r) =e= DiscountedCapitalValueStorage(s,y,r) - DiscountedSalvageValueStorage(s,y,r);
*------------------------------------------------------------------------
* Other accounting equations
*------------------------------------------------------------------------

equation RE5_FuelUseByTechnologyAnnual(YEAR,TECHNOLOGY,FUEL,REGION);
RE5_FuelUseByTechnologyAnnual(y,t,f,r)..
    UseByTechnologyAnnual(y,t,f,r) =e= sum(l, (RateOfUseByTechnology(y,l,t,f,r)*YearSplit(l,y)));

equation Acc2_FuelUseByTechnology(YEAR,TIMESLICE,TECHNOLOGY,FUEL,REGION);
Acc2_FuelUseByTechnology(y,l,t,f,r).. RateOfUseByTechnology(y,l,t,f,r) * YearSplit(l,y) =e= UseByTechnology(y,l,t,f,r);

** MODIFICA: Il TotalDiscountedCost non dipende pi� dalla tec, � stato sommato da un'altra parte per tener conto dello storage***
equation Acc3_ModelPeriodCostByRegion(REGION);
Acc3_ModelPeriodCostByRegion(r).. ModelPeriodCostByRegion(r) =e= sum((y), TotalDiscountedCost(y,r));
