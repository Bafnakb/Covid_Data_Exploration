-- Looking at Total Cases VS Total Deaths
-- Analysis of the correlation between Total Cases and Total Deaths in COVID-19 data.

select location, date, total_cases,new_cases, total_deaths, new_deaths, population
from covid_death
where continent is not null
order by location, date;


-- Determining the fatality rate (likelihood of dying) for COVID-19 cases in each country. 
-- Calculating the percentage likelihood of death if a person contracts COVID-19 in a specific country.

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_death
where location = 'India' 
and continent is not null
order by location, date;

-- Investigating the relationship between Total Cases and Population in a specific country.
-- Analyzing the percentage of the population affected by COVID-19.

select location, date, total_cases, population, (total_cases/population)*100 as case_percentage
from covid_death
where location = 'India'
and continent is not null
order by location, date;



-- Identifying countries with the highest infection rates in relation to their population.

select location, population, max(total_cases) as Highest_Infection_Count,
	Max((total_cases/population))*100 as percentage_population_infected
from covid_death
where continent is not null
group by  location, population
order by percentage_population_infected desc;


-- Analyzing countries and their total death counts.
-- Identifying countries with the highest death count per population.

select location, max(cast(total_deaths as unsigned)) as Total_death_count
from covid_death
where continent is not null
group by location
order by Total_death_count desc;

-- Analyzing death counts by continent.
-- Identifying continents with the highest death count per population.

select continent, max(cast(total_deaths as unsigned)) as Total_death_count
from covid_death
where continent is not null
group by continent
order by Total_death_count desc;

-- Computing the daily death percentage on a global scale using COVID-19 data.
-- Calculating the total death percentage based on the available COVID-19 data.

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths , 
	sum(new_deaths)/sum(new_cases) * 100 as Death_Percentage
from covid_death
where continent is not null
group by date
order by 1 desc;

-- Analyzing the rolling vaccinations per location, date.
-- Performing a table join to combine two tables.
-- Determining the total number of vaccinations administered based on location and date.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vaccination
from covid_death as dea join covid_vaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- and vac.location = 'India'
order by 2,3;


-- Analyzing the rolling vaccinations per location, date. 
-- Explored the relationship between the total population and the percentage population of COVID-19 vaccinations administered
-- using CTE

with popVSvac(Continent, Location, Date, Population, New_Vaccination, Rolling_Total_Vaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vaccination
from covid_death as dea join covid_vaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- and vac.location = 'India'
order by 2,3
)
select * ,(Rolling_Total_Vaccinations/Population)*100
from popVSvac;

-- Analyzing the rolling vaccinations per location, date. 
-- Explored the relationship between the total population and the percentage population of COVID-19 vaccinations administered
-- using Temp table

drop temporary table if exists PercentPopulationVaccinated;
Create temporary Table PercentPopulationVaccinated
(
Continent varchar(50),
Location varchar(50),
Date date,
Population int,
New_vaccination int,
Rolling_Total_Vaccinations bigint
);

Insert into PercentPopulationVaccinated
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vaccination
from covid_death as dea join covid_vaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- and vac.location = 'India'
order by 2,3);


select * ,(Rolling_Total_Vaccinations/Population)*100
from PercentPopulationVaccinated;


-- Analyzing the rolling vaccinations per location, date. 
-- Explored the relationship between the total population and the percentage population of COVID-19 vaccinations administered
-- using View


create or replace view Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vaccination
from covid_death as dea join covid_vaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- and vac.location = 'India'
order by 2,3;

select * ,(rolling_total_vaccination/Population)*100
from Percent_Population_Vaccinated;