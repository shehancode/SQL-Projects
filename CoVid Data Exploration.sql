SELECT * FROM ProjectPortfolio..CovidDeaths$
WHERE continent is not NULL
ORDER BY 1,2


--SELECT * FROM ProjectPortfolio..Covidvaccincations$
--ORDER BY 3,4

--Select the data that going to use

SELECT location, date, total_cases, new_cases, total_deaths, population FROM ProjectPortfolio..CovidDeaths$
ORDER BY 1,2

-- Total Cases vs Total Deaths. Shows the liklihood of dying if youinfect by Covid
SELECT location, date, total_cases, total_deaths, (total_deaths*100/total_cases) AS DeathPercentage FROM ProjectPortfolio..CovidDeaths$
WHERE location like '%lanka%'
ORDER BY 1,2

--Total Cases vs Population. Shows what percentage of population got CoVid
SELECT location, date, total_cases, population, (total_cases*100/population) as InfectedPopulationPercentage FROM ProjectPortfolio..CovidDeaths$
--WHERE location like '%lanka%'
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases*100/population) as InfectedPopulationPercentage FROM ProjectPortfolio..CovidDeaths$
--WHERE location like '%lanka%'
GROUP BY location, population
ORDER BY InfectedPopulationPercentage DESC

--Countries with the highest deathcount per population
SELECT location, population, MAX(cast(total_deaths as INT)) as HighestDeathCount,  MAX(total_deaths*100/population) as DeathPopulationPercentage FROM ProjectPortfolio..CovidDeaths$
--WHERE location like '%lanka%'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY HighestDeathCount DESC

--by continent
SELECT location,  MAX(cast(total_deaths as INT)) as HighestDeathCount,  MAX(total_deaths*100/population) as DeathPopulationPercentage FROM ProjectPortfolio..CovidDeaths$
--WHERE location like '%lanka%'
WHERE continent is NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--continent with hight death count per population
SELECT location,  MAX(cast(total_deaths as INT)) as HighestDeathCount,  MAX(total_deaths*100/population) as DeathPopulationPercentage FROM ProjectPortfolio..CovidDeaths$
--WHERE location like '%lanka%'
WHERE continent is NULL
GROUP BY location
ORDER BY DeathPopulationPercentage DESC

--Global Numbers

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, SUM(cast(new_deaths as INT))*100/SUM(new_cases) AS DeathPercentage 
FROM ProjectPortfolio..CovidDeaths$
WHERE continent is not NULL

ORDER BY 1,2

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ,dea.location) as RollingPeopleVccinated
FROM ProjectPortfolio..CovidDeaths$ as dea
JOIN ProjectPortfolio..CovidVaccinations$ as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--Use CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ,dea.location) as RollingPeopleVccinated
FROM ProjectPortfolio..CovidDeaths$ as dea
JOIN ProjectPortfolio..CovidVaccinations$ as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

--Use Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ,dea.location) as RollingPeopleVccinated
FROM ProjectPortfolio..CovidDeaths$ as dea
JOIN ProjectPortfolio..CovidVaccinations$ as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Create view to store data for visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ,dea.location) as RollingPeopleVccinated
FROM ProjectPortfolio..CovidDeaths$ as dea
JOIN ProjectPortfolio..CovidVaccinations$ as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated


