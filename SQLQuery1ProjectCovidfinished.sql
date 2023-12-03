-- Selecting data
SELECT *
FROM 
  PortfolioProject..CovidDeaths
WHERE 
  continent is not null
ORDER BY 
  3,4

--SELECT *
--FROM 
--  PortfolioProject..CovidDeaths
--ORDER BY 
--  3,4

-- See the typo of variables
EXEC 
  sp_help 'PortfolioProject..CovidDeaths'

--Correct mistakes
ALTER TABLE 
  PortfolioProject..CovidDeaths
ALTER COLUMN 
  new_cases float

-- Select Data that we are going to be using
SELECT 
  location, date, total_cases, new_cases, total_deaths, population
FROM 
  PortfolioProject..CovidDeaths
ORDER BY 
  1,2


-- Looking at Total cases vs Total Deaths
SELECT 
  location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM 
  PortfolioProject..CovidDeaths
WHERE 
  continent is not null
WHERE 
  location like '%spain%'

-- Shows what percentage of the population get Covid
SELECT 
  location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM 
  PortfolioProject..CovidDeaths
WHERE 
  continent is not null
WHERE 
  location like '%states%'

--Lookin at Countries with Highest Infection Rate compared to Population
SELECT 
  location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM 
  PortfolioProject..CovidDeaths
WHERE 
  continent is not null
GROUP BY 
  location, population
ORDER BY 
  PercentPopulationInfected desc

--Showing Countries with the Highest Death Count per Population
SELECT 
  location, MAX(total_deaths) as TotalDeathCount
FROM 
  PortfolioProject..CovidDeaths
WHERE 
  continent is not null
GROUP BY 
  location
ORDER BY 
  TotalDeathCount desc


--Showing Countries with the Highest Death Count per Population
SELECT 
  continent, MAX(total_deaths) as TotalDeathCount
FROM 
  PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE 
  continent is not null
GROUP BY 
  continent
ORDER BY 
  TotalDeathCount desc


-- Global Numbers
SELECT 
  SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM 
  PortfolioProject..CovidDeaths
WHERE 
  continent is not null
--GROUP BY date
ORDER BY 
  1,2


-- Looking at Total Population vs Vaccination
SELECT *
FROM 
  PortfolioProject..CovidDeaths as dea
  Join PortfolioProject..CovidVaccinations as vac
  On dea.location = vac.location
  and dea.date = vac.date

SELECT 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by  dea.location)  --Option 1 to convert variable. --, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by  dea.location)  -- Option 2 to convert variable
FROM PortfolioProject..CovidDeaths as dea
  Join PortfolioProject..CovidVaccinations as vac
  On dea.location = vac.location
  and dea.date = vac.date
 WHERE 
  dea.continent is not null
 ORDER BY 
 2,3

SELECT 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by  dea.location order by dea.location, dea.date) as 'RollingPeopleVaccinated'
, (RollingPeopleVaccinated/dea.population)*100
FROM 
  PortfolioProject..CovidDeaths as dea
  Join PortfolioProject..CovidVaccinations as vac
  On dea.location = vac.location
  and dea.date = vac.date
WHERE 
  dea.continent is not null
ORDER BY 
  2,3

SELECT 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
  (SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100 AS PercentageVaccinated
FROM
  PortfolioProject..CovidDeaths AS dea
  JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  2, 3;


  -- USE CTE
WITH popvsvac (continent, location, data, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
SELECT 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  --(SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100 AS PercentageVaccinated
FROM
  PortfolioProject..CovidDeaths AS dea
  JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
--ORDER BY
--  2, 3
  )
SELECT *, (RollingPeopleVaccinated/population)/100 as PercenRPVac
FROM PopvsVac


--Temp Table

DROP TABLE IF Exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
  (
  continent nvarchar(225),
  location nvarchar(255),
  Date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

INSERT INTO #PercentagePopulationVaccinated 
SELECT 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  --(SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100 AS PercentageVaccinated
FROM
  PortfolioProject..CovidDeaths AS dea
  JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
--ORDER BY

SELECT *, (RollingPeopleVaccinated/population)/100 as PercenRPVac
FROM #PercentagePopulationVaccinated

-- Creating view to store date for later visualizations

 CREATE VIEW PercentPopulationVaccinated as
 SELECT 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
  PortfolioProject..CovidDeaths AS dea
  JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL

Select *
From PercentPopulationVaccinated