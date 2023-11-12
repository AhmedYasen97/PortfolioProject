SELECT *
From CovidProject.. CovidDeaths
WHERE continent is not NULL
order by 3,4

--SELECT *
--From CovidProject.. CovidVaccinations
--order by 3,4


-- Select Data we are gonna be using 
SELECT location, date, total_cases, new_cases,total_deaths,population
From CovidProject.. CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject.. CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at the total cases vs the population
-- Showing what percentage of population got covid
SELECT location, date,population, total_cases ,(total_cases/population)*100 as InfecPercentage
From CovidProject.. CovidDeaths
--WHERE location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate

SELECT location,population, MAX(total_cases) AS HighestInfec,MAX((total_cases/population))*100 as InfecPercentage
From CovidProject.. CovidDeaths
GROUP BY location, population
order by InfecPercentage desc


-- showing Countries with highest death / population

SELECT location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From CovidProject.. CovidDeaths
WHERE continent is not NULL
GROUP BY location
order by TotalDeathCount desc

-- Break it down by contitnent

SELECT continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From CovidProject.. CovidDeaths
WHERE continent is not NULL
GROUP BY continent
order by TotalDeathCount desc


-- Global Numbers

SELECT  SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject.. CovidDeaths
WHERE continent is not null
--GROUP BY date
order by 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER ( PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
From CovidProject.. CovidDeaths dea
JOIN CovidProject.. CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

with PopVsVac (contintent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER ( PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
From CovidProject.. CovidDeaths dea
JOIN CovidProject.. CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, ( RollingPeopleVaccinated/population)*100
FROM PopVsVac


-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER ( PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
From CovidProject.. CovidDeaths dea
JOIN CovidProject.. CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, ( RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualization

create view PercentPopulationVaccinated101 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER ( PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
From CovidProject.. CovidDeaths dea
JOIN CovidProject.. CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated101

