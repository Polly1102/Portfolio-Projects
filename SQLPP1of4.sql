-- DATA EXPLORATION
SELECT * 
FROM PortfolioProject..CovidDeaths
order by 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths (percentage of deaths per cases)
SELECT location, date, total_cases, total_deaths, population, ((total_deaths/total_cases)*100) as deathPercentage
FROM PortfolioProject..CovidDeaths
Order by 1,2

--Looking at Total Cases vs Population (percentage of population with covid)
SELECT location, date, population, total_cases, ((total_cases/population)*100) as cases_per_population
FROM PortfolioProject..CovidDeaths
Order by 1,2

--Looking at countries with highest infection rate vs population
SELECT location, population, MAX(total_cases) as highest_case_count, MAX((total_cases)/population)*100 as percent_population_infected
FROM PortfolioProject..CovidDeaths
Group by population, location
order by 4 desc

--Looking at death count by location
SELECT location, MAX(cast(total_deaths as int)) as death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location
order by death_count desc

--Showing continents with highest deathcount per population
SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeaths
Where continent is not null
group by continent
order by total_death_count desc


--GLOBAL NUMBERS
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percentage
FROM PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2


--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as daily_new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
Order by 2, 3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, daily_new_vaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as daily_new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
) 
Select *, (daily_new_vaccinations/population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
New_Vaccinations numeric,
daily_new_vaccinations numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as daily_new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null

Select *, (daily_new_vaccinations/population)*100
From #PercentPopulationVaccinated


--Creating View to Store Data for Later Visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as daily_new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null


Select * From PercentPopulationVaccinated
