Select*
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--Select*
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population_density
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Canada%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of Population got Covid

Select Location, date, population_density, total_cases, (total_cases/ population_density)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%Canada%'
order by 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population

Select Location, population_density, max (total_cases) as HighestInfectionCount, max((total_cases/ population_density))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- where location like '%Canada%'
Group by Location, population_density 
order by PercentPopulationInfected desc

-- Showing the Highest Death Count per Population

Select Location, max(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%Canada%'
Where continent is not null
Group by Location 
order by TotalDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENT

Select Location, max(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%Canada%'
Where continent is not null
Group by Location 
order by TotalDeathCount desc


-- Showing Continents with the Highest Death Count Per Population

Select continent, max(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%Canada%'
Where continent is not null
Group by continent 
order by TotalDeathCount desc



-- GLOBAL NUMBERS 


Select Date, SUM(new_cases) as Total_Cases, SUM(Cast (new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- where location like '%Canada%'
Where continent is not null
Group by date
order by 1,2


Select SUM(new_cases) as Total_Cases, SUM(Cast (new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- where location like '%Canada%'
Where continent is not null
--Group by date
order by 1,2


-- looking at Total Population vs Vacciantion

Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
	order by 2,3


Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population_density)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
	order by 2,3


-- USE CTE

with PopvsVac (continent, location, date, population_density, new_vaccinations, RollingPeopleVaccinated)
as
(
	Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population_density)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
Select*, (RollingPeopleVaccinated/population_density)*100
From PopvsVac

-- TEMP TABLE

Drop table if exists #PerecentPopulationVaccinated

create table #PerecentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population_density numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PerecentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population_density)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

Select*, (RollingPeopleVaccinated/population_density)*100
From #PerecentPopulationVaccinated




-- Creating view to store data for later visualizations

Create view PerecentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population_density)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select*
From PerecentPopulationVaccinated

