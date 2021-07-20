SELECT *
FROM Port1..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4



SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Port1..CovidDeaths$
where continent is not null
order by 1,2

-- Testing: Total cases and Total Deaths

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Port1..CovidDeaths$
Where location like '%states%'
and continent is not null 
order by 1,2



 --Shows the population what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentUSInfected
From Port1..CovidDeaths$
Where location like '%states%'
order by 1,2


-- Show the Countries with Highest Infection Rate vs Population

Select Location, Population, MAX(total_cases) as HighestInfection,  Max((total_cases/population))*100 as PercentUSInfected
From Port1..CovidDeaths$
Group by Location, Population
order by PercentUSInfected desc


-- Current Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeath
From Port1..CovidDeaths$
Where continent is not null 
Group by Location
order by TotalDeath desc



--CATORIZING BY CONTINENT

-- Showing contintents with the highest death VS population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeath
From Port1..CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeath desc



-- GLOBAL COVIDS CASES

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Port1..CovidDeaths$
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Port1..CovidDeaths$ dea
Join Port1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- perform Calculation on Partition ]

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Port1..CovidDeaths$ dea
Join Port1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Port1..CovidDeaths$ dea
Join Port1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- FOR TABLEAU


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Port1..CovidDeaths$ dea
Join Port1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 