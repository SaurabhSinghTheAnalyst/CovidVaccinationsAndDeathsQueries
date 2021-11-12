SELECT * 
FROM Portfolioproject..CovidDeaths
where continent is not null
order by 3,4

--SELECT * 
--FROM Portfolioproject..CovidVaccinations
-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolioproject..CovidDeaths
order by 1,2

--10-11-2021
--Looking at total cases vs total deaths 
--Shows likelyhood of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (Total_deaths/total_cases)* 100 as DeathPercentage
FROM Portfolioproject..CovidDeaths
Where location like 'India'
order by 1,2

-- Looking at Total Cases vs the population 
--Shows what % of population got covid
SELECT location, date, total_cases, population, (total_cases/population)* 100 as TotalCasePercentage
FROM Portfolioproject..CovidDeaths
Where location like 'India'
order by 1,2

--What countries have the highest infection rate compared to the population? 
--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))* 100 as TotalCasePercentage
FROM Portfolioproject..CovidDeaths
--Where location like 'India'
Group by Location, population
order by TotalCasePercentage desc

--Showing countries with highest death count per population 
SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM Portfolioproject..CovidDeaths
--Where location like 'India'
Where continent is null
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM Portfolioproject..CovidDeaths
Where continent is not null
Group by continent 
order by TotalDeathCount desc

-- GLOBAL DEATH NUMBERS 
SELECT SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as bigint)) as TotalNewDeaths, 
SUM(cast(new_deaths as bigint))/SUM(new_cases) * 100 as TotalDeathPercentage
FROM Portfolioproject..CovidDeaths
--Where location like 'India'
where continent is not null
--Group By date
order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATION
-- USE CTE 
With PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
--,Cast(RollingPeopleVaccinated as bigint)/population) * 100
FROM Portfolioproject..CovidVaccinations vac
join Portfolioproject..CovidDeaths dea
on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
,SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
--,Cast(RollingPeopleVaccinated as bigint)/population) * 100
FROM Portfolioproject..CovidVaccinations vac
join Portfolioproject..CovidDeaths dea
on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

Create View PercentagePopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
,SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
--,Cast(RollingPeopleVaccinated as bigint)/population) * 100
FROM Portfolioproject..CovidVaccinations vac
join Portfolioproject..CovidDeaths dea
on dea.location = vac.location
	and dea.date = vac.date
	
Select *
From PercentagePopulationVaccinated
