*/

--SQL - Data exploratory project - Covid 2021/22

--Features and skills used: Data exploratory, Aggregations functions, Temp table, CTE, View, Partition by, Cast, Convert

*/

USE Project_Covid
GO

-------------------------------------------------------------------------------------------------------------------------------

--Tables selected for review

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4 

SELECT *
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

--I choose the data that I will need

SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 2,3

--Looking at Total cases vs Total deaths

SELECT continent, location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like 'United Kingdom'
WHERE continent IS NOT NULL
ORDER BY 2,3

--Looking at Total cases vs Population
--Shows what percentage of population got Covid

SELECT continent, location, total_cases, population, (CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like 'United Kingdom'
WHERE continent IS NOT NULL
ORDER BY 2,3


--Looking at Countries with Highest Infection Rate compared to Population


SELECT continent, location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS FLOAT)/CAST(population AS FLOAT)))*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like 'United Kingdom'
GROUP BY continent, location, population
HAVING continent IS NOT NULL
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT continent, location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
--Where location like 'United Kingdom'
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY TotalDeathCount DESC

--Breaking down by Continent

SELECT continent, SUM(new_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers

Select date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, CAST(SUM(new_deaths) AS FLOAT)/CAST(SUM(New_Cases) AS FLOAT)*100 AS DeathPercentage
From CovidDeaths
--Where location like 'United Kingdom'
where continent IS NOT NULL 
Group By date
order by 1

--Totals for Whole World

Select SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, CAST(SUM(new_deaths) AS FLOAT)/CAST(SUM(New_Cases) AS FLOAT)*100 AS DeathPercentage
From CovidDeaths
--Where location like 'United Kingdom'
where continent IS NOT NULL 

--Looking at Total Population vs Total Vaccination

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, CONVERT(FLOAT,RollingPeopleVaccinated)/CONVERT(FLOAT,population)*100
FROM PopvsVac
--WHERE location ='United Kingdom'


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(50),
location nvarchar(50),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.Date) AS RollingPeopleVaccinated
FROM CovidDeaths d
Join CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
--WHERE d.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, RollingPeopleVaccinated/population*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

--1). Vaccinated in UK

CREATE VIEW PercentPopulationVacinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.Date) AS RollingPeopleVaccinated
FROM CovidDeaths d
Join CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (CONVERT(FLOAT, RollingPeopleVaccinated)/population)*100 AS PercentOfPopulationVaccinated
FROM PercentPopulationVacinated
WHERE location = 'United Kingdom'

--2). Death due to Covid in UK

CREATE VIEW DeathPercentageView AS
SELECT continent, location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like 'United Kingdom'
WHERE continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM DeathPercentageView
WHERE location = 'United Kingdom'

--3) Percent of population infected in UK

CREATE VIEW InfectedView AS
SELECT continent, location, total_cases, population, (CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM InfectedView
WHERE location ='United Kingdom'

--4) Countries with Highest Infection Rate compared to Population in Europe

CREATE VIEW HighestInfecionRate AS
SELECT continent, location, population, MAX(total_cases) AS HighestInfectionCount, Max((CAST(total_cases AS FLOAT)/CAST(population AS FLOAT)))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY continent, location, population
HAVING continent IS NOT NULL

SELECT *
FROM HighestInfecionRate
WHERE continent = 'Europe'