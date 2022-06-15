SELECT * FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that use
SELECT location, date,total_cases , new_cases , total_deaths ,population FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2 

-- Total cases vs Total Deaths 
SELECT location,date ,total_cases,total_deaths , (total_deaths/total_cases)*100 AS DeathPercentage FROM  PortfolioProject..CovidDeaths$
WHERE location LIKE '%lanka%'
AND continent IS NOT NULL
ORDER BY 1,2 

-- Total cases vs population
SELECT location,date,population ,total_cases, (total_cases/population)*100 AS PopulationInfected FROM  PortfolioProject..CovidDeaths$
--WHERE location LIKE '%lanka%'
ORDER BY 1,2 

--Highest Infection Rate countries compare to population
-- Total cases vs population
SELECT location,population ,MAX(total_cases)AS HighestInfectionCountry , MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM  PortfolioProject..CovidDeaths$
--WHERE location LIKE '%lanka%'
GROUP BY location,population 
ORDER BY PercentPopulationInfected DESC

--Hightes death count per population
SELECT location,population ,MAX(CAST(total_deaths AS INT))AS TotalDeathCount  
FROM  PortfolioProject..CovidDeaths$
--WHERE location LIKE '%lanka%'
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY TotalDeathCount DESC

--Break things by continent
--continents with the highest death count per population
SELECT continent,MAX(CAST(total_deaths AS INT))AS TotalDeathCount  
FROM  PortfolioProject..CovidDeaths$
--WHERE location LIKE '%lanka%'
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers
SELECT SUM(new_cases) AS new_cases ,SUM(CAST(new_deaths AS INT)) AS new_deaths,(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage 
FROM  PortfolioProject..CovidDeaths$
--WHERE location LIKE '%lanka%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 

--Total population vs Vaccination
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccination
--,(RollingPeopleVaccination/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
WITH PopvsVac (continent ,location , Date ,population,new_vaccinations ,RollingPeopleVaccination)
AS
(
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccination
--,(RollingPeopleVaccination/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * , ( RollingPeopleVaccination/population)*100
FROM PopvsVac


--Temp Table 

DROP Table if exists #PercentPopulationVaccinate
CREATE TABLE #PercentPopulationVaccinate
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population NUMERIC,
new_vactination NUMERIC,
RollingPeopleVactionation NUMERIC
)
INSERT INTO #PercentPopulationVaccinate
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccination
--,(RollingPeopleVaccination/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT * , (RollingPeopleVactionation/population)*100
FROM #PercentPopulationVaccinate


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccination
--,(RollingPeopleVaccination/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated

--Table 1
--Global numbers
SELECT SUM(new_cases) AS new_cases ,SUM(CAST(new_deaths AS INT)) AS new_deaths,(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage 
FROM  PortfolioProject..CovidDeaths$
--WHERE location LIKE '%lanka%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 

--Table 2
SELECT location,SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM  PortfolioProject..CovidDeaths$
--WHERE location LIKE '%lanka%'
WHERE continent IS NULL
AND location NOT IN ('world' , 'European Union' , 'International')
GROUP BY location
ORDER BY TotalDeathCount desc

--Table 3
--Highest Infection Rate countries compare to population
-- Total cases vs population
SELECT location,population ,MAX(total_cases)AS HighestInfectionCountry , MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM  PortfolioProject..CovidDeaths$
--WHERE location LIKE '%lanka%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--Table 4
--Highest Infection Rate countries compare to population
-- Total cases vs population
SELECT location,population,date ,MAX(total_cases)AS HighestInfectionCountry , MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM  PortfolioProject..CovidDeaths$
--WHERE location LIKE '%lanka%'
GROUP BY location,population,date
ORDER BY PercentPopulationInfected DESCs