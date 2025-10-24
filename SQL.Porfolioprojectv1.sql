select *
From PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4

--select * 
--From PortfolioProject1..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
order by 1,2

-- Shows Likelihood of dying if you contract covid in your Country 
select Location, date, total_cases,  total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%Canada%'
order by 1,2

-- Looking at total Cases vs Population 
-- Shows what percentage of population got covid 
select Location, date,Population, total_cases,  (total_cases/Population)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%Canada%'
order by 1,2


-- Looking at Countries with highest infection rate compared to population 

select Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
Group by Location,Population
order by PercentPopulationInfected desc


-- Let's break things down by continent 



select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is null
Group by Location
order by TotalDeathCount desc

--Showing the Countries with the highesr death count per population 


select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- showing the continents with the highest deathcount per population 

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers 

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100  as DeathPercentage
From PortfolioProject1..CovidDeaths
-- Where location like '%Canada%'
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100  as DeathPercentage
From PortfolioProject1..CovidDeaths
-- Where location like '%Canada%'
where continent is not null
order by 1,2

-- Looking at Total population vs Vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM( CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.Date) as RollingPeopleVaccinate,
---(RollingPeopleVaccinate/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Use CTE

With PopvsVac(Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM( CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.Date) as RollingPeopleVaccinate
--, (RollingPeopleVaccinate/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table
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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM( CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.Date) as RollingPeopleVaccinate
--, (RollingPeopleVaccinate/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later data visualtions

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM( CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.Date) as RollingPeopleVaccinate
--, (RollingPeopleVaccinate/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

