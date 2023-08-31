SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 
as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
ORDER BY 1, 2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 
as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
where location like '%states%'
ORDER BY 1, 2

SELECT location, population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT date, SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--GROUP BY date
ORDER BY 1, 2

SELECT *
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location
order by dea.location, dea.date ) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2, 3

--Use CTE
With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location
order by dea.location, dea.date ) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location
order by dea.location, dea.date ) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location
order by dea.location, dea.date ) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated