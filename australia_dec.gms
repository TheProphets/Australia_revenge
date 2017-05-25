* OSEMOSYS_DEC.GMS - declarations for sets, parameters, variables (but not equations)
*
* OSEMOSYS 2011.07.07
* - 2017/04 Restyling by Giacomo Marangoni
* - 2012/08 Conversion to GAMS by Ken Noble, Noble-Soft Systems
*
* OSEMOSYS 2011.07.07
* Open Source energy Modeling SYStem
*
* ============================================================================


*------------------------------------------------------------------------
*  Sets
*------------------------------------------------------------------------


set YEAR 'Time frame of the model';
alias (y,yy,YEAR);

set TIMESLICE 'Fractions of the year with specific load and supply characteristics (e.g. weekend evenings in summer)';
alias (l,TIMESLICE);

set TECHNOLOGY 'Any element of the energy system which generates a fuel (e.g. a coal mine), converts energy (e.g. a coal-fired power plant), or consumes a fuel (e.g. an air conditioner)';
alias (t,TECHNOLOGY);

set FUEL 'Energy carriers (fuels produced by some technology, eventually consumed or feeding final demand) and demands for energy services (e.g. a heating demand)';
alias (f,FUEL);

set EMISSION 'Emissions to be accounted for';
alias (e,EMISSION);

set MODE_OF_OPERATION 'Choices of input/output fuel mix for a technology (e.g CHP plant producing either heat or electricity)';
alias (m,MODE_OF_OPERATION);

set REGION 'Regions representing single or multiple countries';
alias (r,REGION);

set BOUNDARY_INSTANCES;
alias (b,BOUNDARY_INSTANCES);

set STORAGE 'Storage facilities';
alias (s,STORAGE);

set SEASON 'Season of the year: 1=winter, 2=intermediate, 3=summer';
alias (ls,lsls,SEASON);

set DAYTYPE 'Different type of day, like weekends etc';
alias (ld,ldld,DAYTYPE);

set DAILYTIMEBRACKET 'Different moment of the day';
alias (lh,lhlh,DAILYTIMEBRACKET);

*------------------------------------------------------------------------
* Parameters
*------------------------------------------------------------------------

*
* ####### Global #############
*
parameter StartYear;
parameter Yearmin;
parameter Yearmax;
parameter YearSplit(TIMESLICE,YEAR) 'Duration of a modelled time slice as a fraction of the year. The sum of each entry over the year should equal 1.';
parameter DiscountRate(REGION,TECHNOLOGY) 'Discount rate for each region and technology';

* Parameters introduced by The Prophets
parameter Conversionls(SEASON,TIMESLICE);
parameter Conversionld(DAYTYPE,TIMESLICE);
parameter Conversionlh(DAILYTIMEBRACKET,TIMESLICE);
parameter DaysInDayType(YEAR,SEASON,DAYTYPE);
parameter DaySplit(YEAR,DAILYTIMEBRACKET);
*
* ####### Demands #############
*
parameter SpecifiedAnnualDemand(REGION,FUEL,YEAR) 'Demands for which "time of use" is necessarily specified during the year. It contains the total specified demand for the year';
parameter SpecifiedDemandProfile(REGION,FUEL,TIMESLICE,YEAR) 'Annual fraction of energy-service or fuel demand required in each time slice. For each year these should sum up to one';
parameter AccumulatedAnnualDemand(REGION,FUEL,YEAR) 'Total exogenous demand of each energy-service or fuel that must be met for each model year. This demand can be met during any timeslice(s)';

*
* ######## Technology #############
*
* ######## Performance #############
*
parameter CapacityToActivityUnit(REGION,TECHNOLOGY) 'Energy that would be produced if one unit of capacity were fully used for one year';
parameter TechWithCapacityNeededToMeetPeakTS(REGION,TECHNOLOGY) 'Tag technologies which operate at timeslice level (equal to 0 or 1)';
parameter CapacityFactor(REGION,TECHNOLOGY,YEAR,TIMESLICE) 'Capacity available per unit of installed capacity';
parameter AvailabilityFactor(REGION,TECHNOLOGY,YEAR) 'Maximum time a technology may run for the whole year (net of planned maintenance)';
parameter OperationalLife(REGION,TECHNOLOGY) 'Operational lifespan';
parameter ResidualCapacity(REGION,TECHNOLOGY,YEAR) 'Capacity left over from a period prior to the modelling period';
parameter InputActivityRatio(REGION,TECHNOLOGY,FUEL,MODE_OF_OPERATION,YEAR) 'Rate of input (use) of fuel per unit of rate of activity of a technology';
parameter OutputActivityRatio(REGION,TECHNOLOGY,FUEL,MODE_OF_OPERATION,YEAR) 'Rate of output (production) of fuel per unit of rate of activity of a technology';

*
* ######## Technology Costs #############
*
parameter CapitalCost(REGION,TECHNOLOGY,YEAR) 'Investment cost per unit of new capacity in each technology';
parameter VariableCost(REGION,TECHNOLOGY,MODE_OF_OPERATION,YEAR) 'Cost per unit of activity for a given mode of operation of that technology';
parameter FixedCost(REGION,TECHNOLOGY,YEAR) 'Cost per unit of capacity of that technology';

*
* ######## Storage Parameters #############   CORRECTED BY THE PROPHETS
*

parameter TechnologyToStorage(REGION,TECHNOLOGY,STORAGE,MODE_OF_OPERATION) 'Link a technology to a storage facility for charging the storage';
parameter TechnologyFromStorage(REGION,TECHNOLOGY,STORAGE,MODE_OF_OPERATION) 'Link a technology to a storage facility for discharging the storage';
parameter StorageLevelStart(STORAGE,REGION);
parameter StorageMaxChargeRate(STORAGE,REGION);
parameter StorageMaxDischargeRate(STORAGE,REGION);
parameter MinStorageCharge(STORAGE,YEAR,REGION);
parameter OperationalLifeStorage(STORAGE,REGION);
parameter CapitalCostStorage(STORAGE,YEAR,REGION);
parameter DiscountRateStorage(STORAGE,REGION);
parameter ResidualStorageCapacity(STORAGE,YEAR,REGION);

*
* ######## Capacity Constraints #############
*
parameter TotalAnnualMaxCapacity(REGION,TECHNOLOGY,YEAR) 'Upper limit for capacity cumulated up to given year';
parameter TotalAnnualMinCapacity(REGION,TECHNOLOGY,YEAR) 'Lower limit for capacity cumulated up to given year';
parameter CapacityOfOneTechnologyUnit(YEAR,TECHNOLOGY,REGION);
*
* ######## Investment Constraints #############
*
parameter TotalAnnualMaxCapacityInvestment(REGION,TECHNOLOGY,YEAR) 'Upper limit for new capacity added in given year';
parameter TotalAnnualMinCapacityInvestment(REGION,TECHNOLOGY,YEAR) 'Lower limit for new capacity added in given year';

*
* ######## Activity Constraints #############
*
parameter TotalTechnologyAnnualActivityUpperLimit(REGION,TECHNOLOGY,YEAR) 'Maximum total annual activity a technology can operate at';
parameter TotalTechnologyAnnualActivityLowerLimit(REGION,TECHNOLOGY,YEAR) 'Minimum total annual activity a technology must operate at';
parameter TotalTechnologyModelPeriodActivityUpperLimit(REGION,TECHNOLOGY) 'Maximum total cumulative activity a technology can operate at';
parameter TotalTechnologyModelPeriodActivityLowerLimit(REGION,TECHNOLOGY) 'Minimum total cumulative activity a technology must operate at';

*
* ######## Reserve Margin ############
*
parameter ReserveMarginTagTechnology(REGION,TECHNOLOGY,YEAR) 'Tag for technologies allowed to contribute to the reserve margin';
parameter ReserveMarginTagFuel(REGION,FUEL,YEAR) 'Tag for energy-services/fuels requiring a reserve margin';
parameter ReserveMargin(REGION,YEAR) 'Annual reserve level of installed capacity required over the peak demand for the corresponding fuel';

*
* ######## RE Generation Target ############
*
parameter RETagTechnology(REGION,TECHNOLOGY,YEAR) 'Tag technologies for renewable production target';
parameter RETagFuel(REGION,FUEL,YEAR) 'Tag fuels for renewable production target';
parameter REMinProductionTarget(REGION,YEAR) 'How much of the "RETagFuel" fuels (tagged in  parameter) must come from "RETechnology" technologies';
*parameter SourceAvailability(REGION,TECHNOLOGY,YEAR,TIMESLICE) 'When is the renewable technology available for production?';
*
* ######### Emissions & Penalties #############
*
parameter EmissionActivityRatio(REGION,TECHNOLOGY,EMISSION,MODE_OF_OPERATION,YEAR) 'Emissions level per unit of activity in a particular mode for a technology (kton/PJ)';
parameter EmissionsPenalty(REGION,EMISSION,YEAR) 'Cost per unit of emissions ($/ton of emissions)'
parameter AnnualExogenousEmission(REGION,EMISSION,YEAR) 'Emissions that need to be accounted for, but are not calculated by the model on "an annual basis"';
parameter AnnualEmissionLimit(REGION,EMISSION,YEAR) 'Limit to sum of emissions from the energy system (plus any annual exogenous emissions)';
parameter ModelPeriodExogenousEmission(REGION,EMISSION) 'Emissions that need to be accounted for, but are not calculated by the model over the "entire model period"';
parameter ModelPeriodEmissionLimit(REGION,EMISSION) 'Limit to sum of emissions from the energy system over the model period (plus any model period exogenous emissions)';

*
parameter YearVal(YEAR);
parameter SeasonVal(SEASON);
parameter DayTypeVal(DAYTYPE);


*------------------------------------------------------------------------
* Model variables
*------------------------------------------------------------------------

* ############### Demand ############*
*
positive variable RateOfDemand(YEAR,TIMESLICE,FUEL,REGION);
positive variable Demand(YEAR,TIMESLICE,FUEL,REGION);

* ############### Capacity Variables ############*
*
positive variable NewCapacity(YEAR,TECHNOLOGY,REGION);
positive variable AccumulatedNewCapacity(YEAR,TECHNOLOGY,REGION);
positive variable TotalCapacityAnnual(YEAR,TECHNOLOGY,REGION);

*
*############### Activity Variables #############

positive variable RateOfActivity(YEAR,TIMESLICE,TECHNOLOGY,MODE_OF_OPERATION,REGION);
positive variable RateOfTotalActivity(YEAR,TIMESLICE,TECHNOLOGY,REGION);
positive variable TotalTechnologyAnnualActivity(YEAR,TECHNOLOGY,REGION);
positive variable TotalAnnualTechnologyActivityByMode(YEAR,TECHNOLOGY,MODE_OF_OPERATION,REGION);
positive variable RateOfProductionByTechnologyByMode(YEAR,TIMESLICE,TECHNOLOGY,MODE_OF_OPERATION,FUEL,REGION);
positive variable RateOfProductionByTechnology(YEAR,TIMESLICE,TECHNOLOGY,FUEL,REGION);
positive variable ProductionByTechnology(YEAR,TIMESLICE,TECHNOLOGY,FUEL,REGION);
positive variable ProductionByTechnologyAnnual(YEAR,TECHNOLOGY,FUEL,REGION);
positive variable RateOfProduction(YEAR,TIMESLICE,FUEL,REGION);
positive variable Production(YEAR,TIMESLICE,FUEL,REGION);
positive variable RateOfUseByTechnologyByMode(YEAR,TIMESLICE,TECHNOLOGY,MODE_OF_OPERATION,FUEL,REGION);
positive variable RateOfUseByTechnology(YEAR,TIMESLICE,TECHNOLOGY,FUEL,REGION);
positive variable UseByTechnologyAnnual(YEAR,TECHNOLOGY,FUEL,REGION);
positive variable RateOfUse(YEAR,TIMESLICE,FUEL,REGION);
positive variable UseByTechnology(YEAR,TIMESLICE,TECHNOLOGY,FUEL,REGION);
positive variable Use(YEAR,TIMESLICE,FUEL,REGION);
*
positive variable ProductionAnnual(YEAR,FUEL,REGION);
positive variable UseAnnual(YEAR,FUEL,REGION);
*

* ############### Costing Variables #############
*
positive variable CapitalInvestment(YEAR,TECHNOLOGY,REGION);
positive variable DiscountedCapitalInvestment(YEAR,TECHNOLOGY,REGION);
*
positive variable SalvageValue(YEAR,TECHNOLOGY,REGION);
positive variable DiscountedSalvageValue(YEAR,TECHNOLOGY,REGION);
positive variable OperatingCost(YEAR,TECHNOLOGY,REGION);
positive variable DiscountedOperatingCost(YEAR,TECHNOLOGY,REGION);
*
positive variable AnnualVariableOperatingCost(YEAR,TECHNOLOGY,REGION);
positive variable AnnualFixedOperatingCost(YEAR,TECHNOLOGY,REGION);
positive variable VariableOperatingCost(YEAR,TIMESLICE,TECHNOLOGY,REGION);
*
positive variable TotalDiscountedCostByTechnology(YEAR,TECHNOLOGY,REGION);
positive variable TotalDiscountedCost(YEAR,REGION);
*
positive variable ModelPeriodCostByRegion(REGION);

*
* ############### Storage Variables #############
*
free variable RateOfStorageCharge(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
free variable RateOfStorageDischarge(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
free variable NetChargeWithinYear(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
free variable NetChargeWithinDay(STORAGE,YEAR,SEASON,DAYTYPE,DAILYTIMEBRACKET,REGION);
positive variable StorageLevelYearStart(STORAGE,YEAR,REGION);
positive variable StorageLevelYearFinish(STORAGE,YEAR,REGION);
positive variable StorageLevelSeasonStart(STORAGE,YEAR,SEASON,REGION);
positive variable StorageLevelDayTypeStart(STORAGE,YEAR,SEASON,DAYTYPE,REGION);
positive variable StorageLevelDayTypeFinish(STORAGE,YEAR,SEASON,DAYTYPE,REGION);
positive variable StorageLowerLimit(STORAGE,YEAR,REGION);
positive variable StorageUpperLimit(STORAGE,YEAR,REGION);
positive variable AccumulatedNewStorageCapacity(STORAGE,YEAR,REGION);
positive variable NewStorageCapacity(STORAGE,YEAR,REGION);
positive variable CapitalInvestmentStorage(STORAGE,YEAR,REGION);
positive variable DiscountedCapitalInvestmentStorage(STORAGE,YEAR,REGION);
positive variable SalvageValueStorage(STORAGE,YEAR,REGION);
positive variable DiscountedSalvageValueStorage(STORAGE,YEAR,REGION);
positive variable TotalDiscountedStorageCost(STORAGE,YEAR,REGION);

*
* ######## Reserve Margin #############
*
positive variable TotalCapacityInReserveMargin(REGION,YEAR);
positive variable DemandNeedingReserveMargin(YEAR,TIMESLICE,REGION);

*
* ######## RE Gen Target #############
*
free variable TotalGenerationByRETechnologies(YEAR,REGION);
free variable TotalREProductionAnnual(YEAR,REGION);
free variable RETotalDemandOfTargetFuelAnnual(YEAR,REGION);
*
free variable TotalTechnologyModelPeriodActivity(TECHNOLOGY,REGION);

*
* ######## Emissions #############
*
positive variable AnnualTechnologyEmissionByMode(YEAR,TECHNOLOGY,EMISSION,MODE_OF_OPERATION,REGION);
positive variable AnnualTechnologyEmission(YEAR,TECHNOLOGY,EMISSION,REGION);
positive variable AnnualTechnologyEmissionPenaltyByEmission(YEAR,TECHNOLOGY,EMISSION,REGION);
positive variable AnnualTechnologyEmissionsPenalty(YEAR,TECHNOLOGY,REGION);
positive variable DiscountedTechnologyEmissionsPenalty(YEAR,TECHNOLOGY,REGION);
positive variable AnnualEmissions(YEAR,EMISSION,REGION);
free variable EmissionsProduction(YEAR,TECHNOLOGY,EMISSION,MODE_OF_OPERATION,REGION);
positive variable ModelPeriodEmissions(EMISSION,REGION);

* Unused
parameter SalvageFactor(REGION,TECHNOLOGY,YEAR);
