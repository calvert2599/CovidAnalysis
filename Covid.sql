SELECT * 
FROM covid..CovidDeaths 
ORDER BY 3,4

SELECT * 
FROM covid..CovidVaccinations 
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM covid..CovidDeaths
ORDER BY 1,2

--Total cases v total deaths 
-- Liklihood of dying if contract Covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases*100) AS DeathPercentage
FROM covid..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

-- Total cases v population 
SELECT Location, date, total_cases, population, (total_cases/Population * 100) AS PopulationCovid
FROM covid..CovidDeaths
WHERE location like 'China'
ORDER BY 1,2

-- Total cases v population 
SELECT Location, date, total_cases, population, (total_cases/Population * 100) AS PopulationCovid
FROM covid..CovidDeaths
WHERE location like 'China'
ORDER BY 1,2

--Countries with highest infection rates 
SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/Population * 100)) AS PopulationCovid
FROM covid..CovidDeaths
GROUP BY Location, Population
ORDER BY PopulationCovid desc

--Countries with highest infection rates 
SELECT Location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population * 100)) AS PopulationCovid
FROM covid..CovidDeaths
GROUP BY Location, Population, date
ORDER BY PopulationCovid desc

--Countries with highes death count
SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM covid..CovidDeaths
GROUP BY Location, continent
ORDER BY TotalDeathCount desc

--Break down by continent with highest death count
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM covid..CovidDeaths
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global numbers by day
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases)*100) AS Percentage --, total_deaths, (total_deaths/total_cases*100) AS DeathPercentage
FROM covid..CovidDeaths
GROUP BY date
ORDER BY 1,2

--Global
SELECT SUM(new_cases) AS  TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases)*100) AS Percentage --, total_deaths, (total_deaths/total_cases*100) AS DeathPercentage
FROM covid..CovidDeaths
ORDER BY 1,2


--Total population v vccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS CountryVaccinations
FROM covid..CovidDeaths dea
JOIN covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
ORDER BY 2,3

-- Use CTE for vaccinated by country
WITH PopvVac (continent, location, date, population, new_vaccinations, country_vac)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS country_vac
FROM covid..CovidDeaths dea
JOIN covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--Order By 2,3
)
SELECT *, (country_vac/population) *100 AS per_vac
FROM PopvVac


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    country_vac numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS country_vac
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac 
	ON dea.location = vac.location 
    AND dea.date = vac.date;

-- Select the final result, calculating the percentage
SELECT *,
  CASE WHEN population = 0 THEN 0 
       ELSE (country_vac / population) * 100 
    END AS Test
FROM #PercentPopulationVaccinated;


-- Creating view to store data for later visualisation 
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS country_vac
FROM covid..CovidDeaths dea
JOIN covid..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date

SELECT , SUM(new_deaths) AS TotalDeathCount
FROM covid..CovidDeaths
WHERE location NOT IN ('World', 'Eurpean Union', 'International') 
GROUP BY continent
ORDER BY TotalDeathCount desc