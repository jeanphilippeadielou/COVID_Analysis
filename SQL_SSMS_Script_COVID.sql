SELECT *
FROM PortfolioProjetJPA..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select the data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjetJPA..CovidDeaths
ORDER BY 1,2

--Looking at Total cases VS Total deaths
--Shows the likelihood of dying if you contract covid-19 in Canada
SELECT Location, date, CONVERT(FLOAT, total_cases), CONVERT(FLOAT, total_deaths), (CONVERT(FLOAT, total_deaths)/CONVERT(FLOAT, total_cases))*100 AS Death_Percentage
FROM PortfolioProjetJPA..CovidDeaths
WHERE Location LIKE '%Canada%'
ORDER BY 1,2

--Looking at total cases VS Population
SELECT Location, date, total_cases, Population, (CONVERT(FLOAT, total_cases)/CONVERT(FLOAT, population))*100 AS Case_Percentage
FROM PortfolioProjetJPA..CovidDeaths
WHERE Location LIKE '%Canada%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(CONVERT(FLOAT, total_cases)/CONVERT(FLOAT, population))*100 AS InfectionRate
FROM PortfolioProjetJPA..CovidDeaths
--WHERE Location LIKE '%Canada%'
GROUP BY Location, Population
ORDER BY InfectionRate DESC


--Showing countries with the highest death count per population
SELECT Location, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathsCount
FROM PortfolioProjetJPA..CovidDeaths
--WHERE Location LIKE '%Canada%'
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY TotalDeathsCount DESC

--Let's break things down by continent

--Showing the continent with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathsCount
FROM PortfolioProjetJPA..CovidDeaths
--WHERE Location LIKE '%Canada%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC

--GLOBAL NUMBERS

SELECT  SUM(CAST(new_cases AS FLOAT)) AS TotalCases, SUM(CAST(new_deaths AS FLOAT)) AS TotalDeaths, SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS Death_Percentage
FROM PortfolioProjetJPA..CovidDeaths
--WHERE Location LIKE '%Canada%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at total population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST (vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjetJPA..CovidDeaths dea
JOIN PortfolioProjetJPA..CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE

WITH PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST (vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjetJPA..CovidDeaths dea
JOIN PortfolioProjetJPA..CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac



--TEMP TABLE

DROP TABLE if EXISTS #PercentePopulationVaccinated
CREATE TABLE #PercentePopulationVaccinated
(
Continent nvarchar (255),
location nvarchar (255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST (vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjetJPA..CovidDeaths dea
JOIN PortfolioProjetJPA..CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentePopulationVaccinated

--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST (vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjetJPA..CovidDeaths dea
JOIN PortfolioProjetJPA..CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

