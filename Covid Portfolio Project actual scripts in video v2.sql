--select *
--from PortfolioProject..CovidDeaths
--order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Selecting the data that we are going to be using.

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Total cases compared to Total deaths
-- Likelihood of dying if you contract covid in your country
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Total cases compared to Population
-- Shows what percentage of the population has Covid
select location, date, population, total_cases,  (total_cases/population)* 100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population.
select location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))* 100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by population, location
order by PercentPopulationInfected desc

--Countries with highest DeathCount compared to population.
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Lets break this down by continent
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--Showing the continents with the highest death count.
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--Global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 AS DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM (convert(int, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use a CTE

WITH PopvsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population) * 100
from PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentageVaccinatedPopulation
CREATE table #PercentageVaccinatedPopulation
(
Contient nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric,
)

insert into #PercentageVaccinatedPopulation
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population) * 100
from #PercentageVaccinatedPopulation

--Create view to store data for later visualization

Create view PercentageVaccinatedPopulation as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentageVaccinatedPopulation

