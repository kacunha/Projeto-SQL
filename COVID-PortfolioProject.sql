
--Selecionando dados que serão utilizados

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Converter formato do campo de varchar para float

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases float;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths float;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN Population float;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN new_deaths float;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN new_cases float;

--Total de Casos x Total de mortes
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%brazil%' AND continent is not null
ORDER BY 1,2 

-- Total de casos x população
-- Mostra qual porcentagem da população contraiu COVID-19
SELECT Location, date, Population, total_cases,  (total_deaths/Population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%brazil%' AND continent is not null
ORDER BY 1,2 

--Países com maior taxa de infecções comparado a população
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_deaths/Population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected desc

--Países com maior contagem de mortes por população
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

--Maiores contagens de morte por continente 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Números globais
SELECT  SUM(cast(new_cases as float)), SUM(cast(new_deaths as float)), SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null

ORDER BY 1,2 

--Total População x Vacina
With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinant
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT * , (RollingPeopleVaccinated/Population)* 100
FROM PopvsVac

---Tabela temporária
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinant
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT * , (RollingPeopleVaccinated/Population)* 100
FROM #PercentPopulationVaccinated

-- Criando visualização
CREATE VIEW PercentPopulationVaccinated2 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinant
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
