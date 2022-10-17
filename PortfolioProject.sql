SELECT *
FROM NashvilleHousing.dbo.CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM NashvilleHousing.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select data that we are going to using
SELECT Location, date, total_Cases, new_cases, total_deaths, population
FROM NashvilleHousing.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at total cases and total death
-- Show likehood of dying if you contract covid in the countries
SELECT
	Location,
	date,
	total_Cases,
	total_deaths,
	(total_deaths/total_Cases)* 100 as death_percent
FROM NashvilleHousing.dbo.CovidDeaths
WHERE Location like '%Denmark%'
ORDER BY Location, date

-- Looking at the total cases vs the population
-- Show what Percentage of population got covid
SELECT
	Location,
	date,
	total_Cases,
	population,
	(total_Cases/population)*100 AS cases_percent
FROM NashvilleHousing.dbo.CovidDeaths
ORDER BY Location, date

-- Looking at Countries with Highest Infection Rate compared to Populations
SELECT
	Location,
	MAX(total_cases) HighestInfectionCase,
	MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM NashvilleHousing.dbo.CovidDeaths
GROUP BY Location, population
ORDER BY 1,2

--Showing Countries with highest Death Count per Population
SELECT
	location,
	MAX(cast(total_deaths as INT)) AS highest_death_count
FROM NashvilleHousing.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT
	continent,
	MAX(cast(total_deaths as INT)) AS highest_death_count
FROM NashvilleHousing.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC

-- GLOBAL NUMBER
SELECT
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths as INT)) AS total_death,
	(SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 AS death_percentage
FROM NashvilleHousing.dbo.CovidDeaths
WHERE continent IS NOT NULL

-- Look at the population and Vaccinations

-- CREATE CTE

WITH PopandVac AS
(
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER( PARTITION BY dea.location ORDER BY dea.date) AS AccumulatedVaccinations
FROM NashvilleHousing.dbo.CovidDeaths dea
	JOIN NashvilleHousing.dbo.CovidVaccinations vac
	ON dea.location = vac.location
WHERE dea.continent IS NOT NULL
)
SELECT
	dea.location,
	(AccumulatedVaccinations/dea.population)*100 AS VaccinationsPercent
FROM PopandVac