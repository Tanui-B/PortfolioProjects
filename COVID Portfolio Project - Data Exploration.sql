SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProjects..CovidVaccinations
--ORDER BY 3, 4

--Select Data to start with

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProjects..CovidDeaths
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
Where location like '%states%'
ORDER BY 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases,
(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
Where location like '%kenya%'
ORDER BY 1, 2

--Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--Where location like '%States%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
--Where location like '%States%'
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
--Where location like '%States%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
ORDER BY 1, 2


SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
ORDER BY 1, 2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations))OVER (Partition by dea.location 
Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
ORDER BY 2, 3

--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations))OVER (Partition by dea.location 
Order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if Exists #PercentofPopulationVaccinated
CREATE TABLE #PercentofPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentofPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations))OVER (Partition by dea.location 
Order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentofPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentofPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations))OVER (Partition by dea.location 
Order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2, 3


SELECT *
FROM PercentofPopulationVaccinated