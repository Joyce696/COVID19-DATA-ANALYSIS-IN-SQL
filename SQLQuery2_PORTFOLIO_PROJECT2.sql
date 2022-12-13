select * 
from PORTFOLIO_PROJECT..CovidDeaths$
where continent is not null
ORDER BY 3,4 

--select * 
--from PORTFOLIO_PROJECT..covidvaccinations$
where continent is not null
--ORDER BY 3,4 

select Location, date, total_cases, new_cases, total_deaths, population
from PORTFOLIO_PROJECT..CovidDeaths$ 
where continent is not null
order by 1,2

-- TOTAL CASES Vs TOTAL DEATHS (Shows the likelihood of dying if contract covid) --

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from PORTFOLIO_PROJECT..CovidDeaths$ 
where location LIKE '%NIGERIA%' 
and continent is not null
order by 1,2

-- PERCENTAGE of Nigeria Population with covid --

select Location, date, population, total_cases, (total_cases/population)*100 as Infected_population_percentage
from PORTFOLIO_PROJECT..CovidDeaths$ 
where location LIKE '%Nigeria%' and continent is not null
order by 1,2

---Countries with the highest infection Rate compared to the population--

select Location, population, MAX(total_cases) AS Highest_Infected_Countries,  
MAX((total_cases/population))*100 as Infected_population_percentage
from PORTFOLIO_PROJECT..CovidDeaths$ 
--where location LIKE '%States%'--
GROUP BY location, population
order by Infected_population_percentage DESC

-- Countries with the highest death count per population--

select Location, MAX(cast(total_deaths as int)) AS Total_Death_Count
from PORTFOLIO_PROJECT..CovidDeaths$ 
where continent is not null
GROUP BY location
order by Total_Death_Count DESC

--FINDING INFO BY CONTINENT--

select location, MAX(cast(total_deaths as int)) AS Total_Death_Count
from PORTFOLIO_PROJECT..CovidDeaths$ 
where continent is null
GROUP BY location
order by Total_Death_Count DESC

--showing the continents with the highest death count--

select continent, max(cast(total_deaths as int)) as total_death_count
from PORTFOLIO_PROJECT..CovidDeaths$ 
where continent is not null
GROUP BY continent
order by Total_Death_Count DESC

--GLOBAL NUMBERS--

select location, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PORTFOLIO_PROJECT..CovidDeaths$ 
--where location LIKE '%states%' 
WHERE continent is not null
GROUP BY location
order by 1,2

---sum total of all days in one value for global numbers--

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PORTFOLIO_PROJECT..CovidDeaths$ 
--where location LIKE '%states%' 
WHERE continent is not null
--GROUP BY date
order by 1,2



select date, sum(new_cases), sum(cast(new_deaths as int))--, total_deaths, (total_deaths/total_cases)*100 as 
Death_percentage
from PORTFOLIO_PROJECT..CovidDeaths$ 
--where location LIKE '%states%' 
WHERE continent is not null
GROUP BY date
order by 1,2

--- ANALYSIS OF THE COVID DEATHS/VACINATION Tables JOINED---

select * 
from PORTFOLIO_PROJECT..CovidDeaths$ as dea
join PORTFOLIO_PROJECT..CovidVaccinations$ as vac
   on dea.location = vac.location
   and dea.date = vac.date

--Total population vs Total vacination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) 
as rolling_people_vacinated
from PORTFOLIO_PROJECT..CovidDeaths$ as dea
join PORTFOLIO_PROJECT..CovidVaccinations$ as vac
   on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   order by 2,3

--USE CTE--

WITH PopvsVac (continent, Location, date, population, new_vacinations, rolling_people_vacinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) 
as rolling_people_vacinated
--,(rolling_people_vacinated/population)*100 
from PORTFOLIO_PROJECT..CovidDeaths$ as dea
join PORTFOLIO_PROJECT..CovidVaccinations$ as vac
   on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3
)
select *, (rolling_people_vacinated/population)*100 as percentage_roll_pvac
 from PopvsVac 

 --- Temporary Table
 DROP TABLE #percent_population_vacinated
 
 Create Table #PERCENT_POPULATION_VACINATED(
 Continent nvarchar(255),
 Location Nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rolling_people_vacinated numeric
 )

 insert into #PERCENT_POPULATION_VACINATED 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) 
as rolling_people_vacinated
--,(rolling_people_vacinated/population)*100 
from PORTFOLIO_PROJECT..CovidDeaths$ as dea
join PORTFOLIO_PROJECT..CovidVaccinations$ as vac
   on dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null
   --order by 2,3

select *, (rolling_people_vacinated/population)*100 as percentage_roll_pvac
 from #PERCENT_POPULATION_VACINATED

--CREATING VIEW FOR DATA VISUALIZATION

CREATE VIEW Total_deaths_continents AS
select continent, max(cast(total_deaths as int)) as total_death_count
from PORTFOLIO_PROJECT..CovidDeaths$ 
where continent is not null
GROUP BY continent
--order by Total_Death_Count DESC
select * from Total_deaths_continents

CREATE VIEW Totalpopulation_TotalVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) 
as rolling_people_vacinated
from PORTFOLIO_PROJECT..CovidDeaths$ as dea
join PORTFOLIO_PROJECT..CovidVaccinations$ as vac
   on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
--order by 2,3
select * from Totalpopulation_TotalVaccinated

create view Global_Numbers as

select location, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PORTFOLIO_PROJECT..CovidDeaths$ 
--where location LIKE '%states%' 
WHERE continent is not null
GROUP BY location
---order by 1,2
select * 
from Global_Numbers

create view CountriesDeath_VSpopulation as
select Location, MAX(cast(total_deaths as int)) AS Total_Death_Count
from PORTFOLIO_PROJECT..CovidDeaths$ 
where continent is not null
GROUP BY location
---order by Total_Death_Count DESC

select * from CountriesDeath_VSpopulation